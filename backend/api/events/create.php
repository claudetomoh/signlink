<?php
// POST /api/events/create.php
// Header: Authorization: Bearer <token>  (admin only)
// Body: { title, description?, location, date, capacity? }
// Returns: { id, message }
require_once __DIR__ . '/../config/helpers.php';
cors();

$user = requireAuth();
requireRole($user, 'admin');

$body        = body();
$title       = trim($body['title']       ?? '');
$description = trim($body['description'] ?? '');
$location    = trim($body['location']    ?? '');
$date        = $body['date']             ?? '';
$capacity    = max(1, (int)($body['capacity'] ?? 50));

if (empty($title) || empty($location) || empty($date)) {
    error('title, location and date are required');
}

$db = getDB();
$id = uuid();

$db->prepare(
    "INSERT INTO events (id, title, description, location, event_date, capacity, created_by)
     VALUES (?, ?, ?, ?, ?, ?, ?)"
)->execute([$id, $title, $description, $location, $date, $capacity, $user['id']]);

// Notify all active students
$students = $db->query(
    "SELECT id FROM users WHERE role='student' AND is_active=1 AND is_suspended=0"
)->fetchAll(PDO::FETCH_COLUMN);

foreach ($students as $sid) {
    sendNotification(
        $sid,
        'New Event Added',
        "A new event has been posted: \"$title\" at $location.",
        'new_event',
        $id
    );
}

respond(['id' => $id, 'message' => 'Event created successfully'], 201);
