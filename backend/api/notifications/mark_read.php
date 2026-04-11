<?php
// POST /api/notifications/mark_read.php
// Header: Authorization: Bearer <token>
// Body: { id? }  OR  { all: true }
require_once __DIR__ . '/../config/helpers.php';
cors();

$user = requireAuth();
$body = body();
$db   = getDB();

$all = !empty($body['all']);
$id  = $body['id'] ?? null;

if ($all) {
    $db->prepare(
        "UPDATE notifications SET is_read = 1 WHERE user_id = ?"
    )->execute([$user['id']]);
} elseif (!empty($id)) {
    $db->prepare(
        "UPDATE notifications SET is_read = 1 WHERE id = ? AND user_id = ?"
    )->execute([$id, $user['id']]);
} else {
    error('Provide notification id or all=true');
}

respond(['message' => 'Marked as read']);
