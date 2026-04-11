<?php
// PUT /api/requests/update.php?id=<request_id>
// Header: Authorization: Bearer <token>   (interpreter or admin)
// Body: { status, interpreterId? }
require_once __DIR__ . '/../config/helpers.php';
cors();

$user = requireAuth();

$id = trim($_GET['id'] ?? '');
if (empty($id)) error('Request id is required');

$body          = body();
$status        = $body['status']        ?? '';
$interpreterId = $body['interpreterId'] ?? $body['interpreter_id'] ?? null;

if (empty($status)) error('status is required');
if (!in_array($status, ['approved', 'declined', 'completed', 'pending'], true)) {
    error('Invalid status value');
}

$db = getDB();
$stmt = $db->prepare("SELECT * FROM interpreter_requests WHERE id = ?");
$stmt->execute([$id]);
$request = $stmt->fetch();
if (!$request) error('Request not found', 404);

// Permission check
if ($user['role'] === 'interpreter') {
    if (!in_array($status, ['approved', 'declined'], true)) error('Forbidden', 403);
    if ($request['status'] !== 'pending') error('Request is already ' . $request['status']);
    $interpreterId = $user['id']; // interpreter accepts with their own id
} elseif ($user['role'] === 'student') {
    error('Forbidden', 403);
}
// admin can do everything

$db->prepare(
    "UPDATE interpreter_requests
     SET status = ?, interpreter_id = COALESCE(?, interpreter_id), updated_at = NOW()
     WHERE id = ?"
)->execute([$status, $interpreterId, $id]);

// Notify the student
$statusLabel = ucfirst($status);
sendNotification(
    $request['student_id'],
    "Request $statusLabel",
    "Your interpreter request for \"{$request['event_title']}\" has been $status.",
    'request_update',
    $id
);

// If admin assigned an interpreter, notify them too
if ($interpreterId && $user['role'] === 'admin' && $status === 'approved') {
    sendNotification(
        $interpreterId,
        'You have been assigned',
        "You have been assigned as interpreter for \"{$request['event_title']}\".",
        'assignment',
        $id
    );
}

respond(['message' => "Request $status successfully"]);
