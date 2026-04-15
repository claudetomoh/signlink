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

// Distinguish 'email not found' from 'wrong password' so the UI can prompt
// unregistered users to sign up.  Both return 401 to avoid timing attacks.
if (!$user) {
    http_response_code(401);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['error' => 'No account found with that email address.', 'code' => 'EMAIL_NOT_FOUND']);
    exit;
}
if (!password_verify($password, $user['password_hash'])) {
    http_response_code(401);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['error' => 'Incorrect password. Please try again.', 'code' => 'WRONG_PASSWORD']);
    exit;
}

if ($user['is_suspended']) error('Your account has been suspended. Contact admin.', 403);

// Generate 256-bit secure random token
$token     = bin2hex(random_bytes(32));
$expiresAt = date('Y-m-d H:i:s', strtotime('+30 days'));

$db->prepare(
    "INSERT INTO auth_tokens (user_id, token, expires_at) VALUES (?, ?, ?)"
)->execute([$user['id'], $token, $expiresAt]);

respond(['token' => $token, 'user' => sanitiseUser($user)]);
