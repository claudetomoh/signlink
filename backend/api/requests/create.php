<?php
// POST /api/requests/create.php
// Header: Authorization: Bearer <token>   (student only)
// Body: { requestType, eventTitle, location, eventDate?, eventTime?, notes? }
// Returns: { id, message, request }
require_once __DIR__ . '/../config/helpers.php';
cors();

$user = requireAuth();
requireRole($user, 'student');

$body        = body();
$requestType = trim($body['requestType'] ?? $body['request_type'] ?? '');
$eventTitle  = trim($body['eventTitle']  ?? $body['event_title']  ?? '');
$location    = trim($body['location']    ?? '');
$notes       = trim($body['notes']       ?? '');
$eventDate   = $body['eventDate']   ?? $body['event_date']   ?? null;
$eventTime   = $body['eventTime']   ?? $body['event_time']   ?? null;

if (empty($requestType) || empty($eventTitle) || empty($location)) {
    error('requestType, eventTitle and location are required');
}

$db = getDB();
$id = uuid();

$db->prepare(
    "INSERT INTO interpreter_requests
       (id, student_id, request_type, event_title, location, event_date, event_time, notes)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
)->execute([$id, $user['id'], $requestType, $eventTitle, $location, $eventDate, $eventTime, $notes]);

// Notify every active, unsuspended interpreter
$interpreters = $db->query(
    "SELECT id FROM users WHERE role='interpreter' AND is_active=1 AND is_suspended=0"
)->fetchAll(PDO::FETCH_COLUMN);

$notifBody =
    "{$user['name']} needs an interpreter for \"$eventTitle\" at $location"
    . ($eventDate ? " on $eventDate" : '');

foreach ($interpreters as $interpId) {
    sendNotification($interpId, 'New Interpreter Request', $notifBody, 'new_request', $id);
}

respond([
    'id'      => $id,
    'message' => 'Request submitted successfully',
    'request' => [
        'id'            => $id,
        'studentId'     => $user['id'],
        'requestType'   => $requestType,
        'eventTitle'    => $eventTitle,
        'location'      => $location,
        'eventDate'     => $eventDate,
        'eventTime'     => $eventTime,
        'notes'         => $notes,
        'status'        => 'pending',
        'createdAt'     => date('c'),
    ],
], 201);
