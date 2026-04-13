<?php
// POST /api/users/rate.php
// Header: Authorization: Bearer <token>
// Body: { interpreter_id, rating, request_id? }
// Students only. Rates an interpreter (1–5) after a completed assignment.
// A student may only rate an interpreter once per completed request.
require_once __DIR__ . '/../config/helpers.php';
cors();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') error('Method not allowed', 405);

$user = requireAuth();
requireRole($user, 'student');

$body          = body();
$interpreterId = trim($body['interpreter_id'] ?? '');
$rating        = (float)($body['rating'] ?? 0);
$requestId     = trim($body['request_id'] ?? '');

if (empty($interpreterId)) error('interpreter_id is required');
if ($rating < 1 || $rating > 5) error('rating must be between 1 and 5');

$db = getDB();

// ── Verify the interpreter exists and is actually an interpreter ──────────────
$stmt = $db->prepare("SELECT id FROM users WHERE id = ? AND role = 'interpreter' AND is_active = 1");
$stmt->execute([$interpreterId]);
if (!$stmt->fetch()) error('Interpreter not found', 404);

// ── If request_id provided, verify it belongs to this student & is completed ─
if (!empty($requestId)) {
    $stmt = $db->prepare(
        "SELECT id FROM interpreter_requests
         WHERE id = ? AND student_id = ? AND interpreter_id = ? AND status = 'completed'"
    );
    $stmt->execute([$requestId, $user['id'], $interpreterId]);
    if (!$stmt->fetch()) {
        error('You can only rate interpreters for your completed assignments', 403);
    }

    // ── Prevent duplicate ratings for the same request ────────────────────────
    // We mark rated requests with a flag. Add the column if needed.
    try {
        $db->exec("ALTER TABLE interpreter_requests ADD COLUMN is_rated TINYINT(1) DEFAULT 0");
    } catch (PDOException $e) { /* column exists */ }

    $stmt = $db->prepare("SELECT is_rated FROM interpreter_requests WHERE id = ?");
    $stmt->execute([$requestId]);
    $row = $stmt->fetch();
    if ($row && $row['is_rated']) {
        error('You have already rated this assignment');
    }
}

// ── Recalculate interpreter's average rating ──────────────────────────────────
// Fetch current rating and count, then compute new rolling average.
$stmt = $db->prepare("SELECT rating FROM users WHERE id = ?");
$stmt->execute([$interpreterId]);
$interp = $stmt->fetch();

// Count how many completed requests this interpreter has (as proxy for rating count)
$stmt = $db->prepare(
    "SELECT COUNT(*) as cnt FROM interpreter_requests
     WHERE interpreter_id = ? AND status = 'completed' AND is_rated = 1"
);
try { $stmt->execute([$interpreterId]); $row = $stmt->fetch(); $ratingCount = (int)($row['cnt'] ?? 0); }
catch (Throwable $e) { $ratingCount = 0; }

$currentRating = (float)($interp['rating'] ?? 0);
$newCount      = max(1, $ratingCount);
$newRating     = round((($currentRating * ($newCount - 1)) + $rating) / $newCount, 2);
$newRating     = min(5.0, max(0.0, $newRating));

$db->prepare("UPDATE users SET rating = ? WHERE id = ?")->execute([$newRating, $interpreterId]);

// ── Mark the request as rated ─────────────────────────────────────────────────
if (!empty($requestId)) {
    try {
        $db->prepare("UPDATE interpreter_requests SET is_rated = 1 WHERE id = ?")
           ->execute([$requestId]);
    } catch (Throwable $e) { /* column may not exist yet */ }
}

// ── Notify the interpreter ────────────────────────────────────────────────────
sendNotification(
    $interpreterId,
    'New Rating Received',
    'A student has rated your service ' . number_format($rating, 1) . '/5. Your new average is ' . number_format($newRating, 2) . '.',
    'rating'
);

respond([
    'message'    => 'Rating submitted successfully',
    'new_rating' => $newRating,
]);
