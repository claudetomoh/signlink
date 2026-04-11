<?php
// POST /api/auth/login.php
// Body: { email, password }
// Returns: { token, user }
require_once __DIR__ . '/../config/helpers.php';
cors();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') error('Method not allowed', 405);

$body     = body();
$email    = strtolower(trim($body['email']    ?? ''));
$password = $body['password'] ?? '';

if (empty($email) || empty($password)) error('Email and password are required');

$db   = getDB();
$stmt = $db->prepare("SELECT * FROM users WHERE email = ? AND is_active = 1");
$stmt->execute([$email]);
$user = $stmt->fetch();

// OWASP A07 — generic error message (don't reveal whether email exists)
if (!$user || !password_verify($password, $user['password_hash'])) {
    error('Invalid email or password', 401);
}

if ($user['is_suspended']) error('Your account has been suspended. Contact admin.', 403);

// Generate 256-bit secure random token
$token     = bin2hex(random_bytes(32));
$expiresAt = date('Y-m-d H:i:s', strtotime('+30 days'));

$db->prepare(
    "INSERT INTO auth_tokens (user_id, token, expires_at) VALUES (?, ?, ?)"
)->execute([$user['id'], $token, $expiresAt]);

respond(['token' => $token, 'user' => sanitiseUser($user)]);
