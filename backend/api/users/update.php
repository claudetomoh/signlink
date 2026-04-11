<?php
// PUT /api/users/update.php?id=<user_id>   (or omit id to update self)
// Header: Authorization: Bearer <token>
// Body: { name?, bio?, languages?, is_suspended? }
// Admin can update any user. Non-admin can only update themselves.
require_once __DIR__ . '/../config/helpers.php';
cors();

$user     = requireAuth();
$targetId = trim($_GET['id'] ?? '') ?: $user['id'];

if ($targetId !== $user['id'] && $user['role'] !== 'admin') {
    error('Forbidden', 403);
}

$body   = body();
$fields = [];
$params = [];

if (array_key_exists('name', $body)) {
    $fields[] = 'name = ?';
    $params[] = trim($body['name']);
}
if (array_key_exists('bio', $body)) {
    $fields[] = 'bio = ?';
    $params[] = trim($body['bio']);
}
if (array_key_exists('languages', $body)) {
    $fields[] = 'languages = ?';
    $params[] = implode(',', (array)$body['languages']);
}
if (array_key_exists('is_suspended', $body) && $user['role'] === 'admin') {
    $fields[] = 'is_suspended = ?';
    $params[] = $body['is_suspended'] ? 1 : 0;
}

if (empty($fields)) error('No updatable fields provided');

$params[] = $targetId;
getDB()->prepare(
    "UPDATE users SET " . implode(', ', $fields) . " WHERE id = ?"
)->execute($params);

respond(['message' => 'User updated successfully']);
