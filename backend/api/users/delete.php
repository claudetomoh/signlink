<?php
// DELETE /api/users/delete.php?id=<user_id>
// Header: Authorization: Bearer <token>  (admin only)
// Soft-deletes by setting is_active = 0
require_once __DIR__ . '/../config/helpers.php';
cors();

$user     = requireAuth();
requireRole($user, 'admin');

$targetId = trim($_GET['id'] ?? '');
if (empty($targetId)) error('User id is required');
if ($targetId === $user['id']) error('You cannot delete your own account');

getDB()->prepare(
    "UPDATE users SET is_active = 0 WHERE id = ?"
)->execute([$targetId]);

respond(['message' => 'User deactivated successfully']);
