<?php
// POST /api/auth/forgot_password.php
// Body: { email }
// Accepts any registered email — always responds success to prevent user enumeration.
// TODO: integrate an email-sending service (e.g. SendGrid, Mailgun) to send a real reset link.
require_once __DIR__ . '/../config/helpers.php';
cors();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') error('Method not allowed', 405);

$body  = body();
$email = strtolower(trim($body['email'] ?? ''));

if (empty($email) || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    error('A valid email address is required');
}

// OWASP A07: always respond success — don't reveal whether the email is registered
// When email sending is wired up, only actually send the email if $user is found.
$db   = getDB();
$stmt = $db->prepare("SELECT id, name FROM users WHERE email = ? AND is_active = 1");
$stmt->execute([$email]);
// $user = $stmt->fetch();  // Unused until email service is integrated

respond(['message' => 'If that email exists, a reset link has been sent.']);
