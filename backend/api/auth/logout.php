<?php
// POST /api/auth/logout.php
// Header: Authorization: Bearer <token>
require_once __DIR__ . '/../config/helpers.php';
cors();

$user    = requireAuth();
$headers = function_exists('getallheaders') ? getallheaders() : [];
$auth    = $headers['Authorization'] ?? $headers['authorization'] ?? '';

if (preg_match('/^Bearer\s+(.+)$/i', trim($auth), $m)) {
    getDB()->prepare("DELETE FROM auth_tokens WHERE token = ?")->execute([$m[1]]);
}

respond(['message' => 'Logged out successfully']);
