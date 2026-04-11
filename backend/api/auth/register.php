<?php
// POST /api/auth/register.php
// Body: { name, email, password, role }
// Returns: { token, user }
require_once __DIR__ . '/../config/helpers.php';
cors();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') error('Method not allowed', 405);

$body     = body();
$name     = trim($body['name']     ?? '');
$email    = strtolower(trim($body['email']    ?? ''));
$password = $body['password'] ?? '';
$role     = $body['role']     ?? 'student';

if (empty($name) || empty($email) || empty($password)) {
    error('Name, email and password are required');
}
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) error('Invalid email address');
if (strlen($password) < 8)   error('Password must be at least 8 characters');
if (!in_array($role, ['student', 'interpreter'], true)) error('Invalid role');

$db = getDB();

// Check email uniqueness
$stmt = $db->prepare("SELECT id FROM users WHERE email = ?");
$stmt->execute([$email]);
if ($stmt->fetch()) error('Email is already registered', 409);

$id   = uuid();
$hash = password_hash($password, PASSWORD_BCRYPT);

$db->prepare(
    "INSERT INTO users (id, name, email, password_hash, role) VALUES (?, ?, ?, ?, ?)"
)->execute([$id, $name, $email, $hash, $role]);

// Auto-login: generate token
$token     = bin2hex(random_bytes(32));
$expiresAt = date('Y-m-d H:i:s', strtotime('+30 days'));

$db->prepare(
    "INSERT INTO auth_tokens (user_id, token, expires_at) VALUES (?, ?, ?)"
)->execute([$id, $token, $expiresAt]);

$user = [
    'id'        => $id,
    'name'      => $name,
    'email'     => $email,
    'role'      => $role,
    'languages' => [],
    'isSuspended' => false,
    'isActive'  => true,
];

respond(['token' => $token, 'user' => $user], 201);
