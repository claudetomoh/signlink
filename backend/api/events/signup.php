<?php
// POST /api/events/signup.php
// Header: Authorization: Bearer <token>  (student only)
// Body: { eventId }
// Returns: { message, isSignedUp }  — toggles sign-up/cancel
require_once __DIR__ . '/../config/helpers.php';
cors();

$user    = requireAuth();
requireRole($user, 'student');

$body    = body();
$eventId = $body['eventId'] ?? $body['event_id'] ?? '';
if (empty($eventId)) error('eventId is required');

$db = getDB();

// Load event with current sign-up count
$stmt = $db->prepare(
    "SELECT e.*, (SELECT COUNT(*) FROM event_signups es WHERE es.event_id = e.id) AS signed_up
     FROM events e WHERE e.id = ? AND e.is_active = 1"
);
$stmt->execute([$eventId]);
$event = $stmt->fetch();
if (!$event) error('Event not found', 404);

// Check existing sign-up
$stmt = $db->prepare(
    "SELECT id FROM event_signups WHERE event_id = ? AND student_id = ?"
);
$stmt->execute([$eventId, $user['id']]);
$existing = $stmt->fetch();

if ($existing) {
    // Toggle off — cancel sign-up
    $db->prepare(
        "DELETE FROM event_signups WHERE event_id = ? AND student_id = ?"
    )->execute([$eventId, $user['id']]);
    respond(['message' => 'You have cancelled your sign-up.', 'isSignedUp' => false]);
}

// Check capacity
if ((int)$event['signed_up'] >= (int)$event['capacity']) {
    error('This event is full', 409);
}

$db->prepare(
    "INSERT INTO event_signups (event_id, student_id) VALUES (?, ?)"
)->execute([$eventId, $user['id']]);

respond(['message' => 'Successfully signed up for event.', 'isSignedUp' => true]);
