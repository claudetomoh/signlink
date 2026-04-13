<?php
// POST /api/auth/forgot_password.php
// Body: { email }
// Generates a one-hour reset token, stores it, and sends a reset email.
// Always responds with success to prevent user enumeration (OWASP A07).
require_once __DIR__ . '/../config/helpers.php';
cors();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') error('Method not allowed', 405);

$body  = body();
$email = strtolower(trim($body['email'] ?? ''));

if (empty($email) || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    error('A valid email address is required');
}

$db   = getDB();
$stmt = $db->prepare("SELECT id, name FROM users WHERE email = ? AND is_active = 1");
$stmt->execute([$email]);
$user = $stmt->fetch();

// Only proceed if the user actually exists — but always return success
if ($user) {
    // Remove any existing tokens for this user
    $db->prepare("DELETE FROM password_resets WHERE user_id = ?")->execute([$user['id']]);

    // Generate a secure 32-byte token (64 hex chars)
    $token     = bin2hex(random_bytes(32));
    $expiresAt = date('Y-m-d H:i:s', strtotime('+1 hour'));

    $db->prepare(
        "INSERT INTO password_resets (user_id, token, expires_at) VALUES (?, ?, ?)"
    )->execute([$user['id'], $token, $expiresAt]);

    // Build the reset URL — points to the web reset page in the same uploads folder
    $resetUrl = 'http://169.239.251.102:280/~tomoh.ikfingeh/uploads/reset_password.php?token=' . $token;

    $subject = 'SignLink — Password Reset Request';
    $message = "Hello {$user['name']},\n\n"
             . "We received a request to reset the password for your SignLink account.\n\n"
             . "Click the link below to set a new password (valid for 1 hour):\n"
             . "$resetUrl\n\n"
             . "If you did not request this, you can safely ignore this email.\n\n"
             . "— The SignLink Team";
    $headers = "From: noreply@signlink.app\r\nContent-Type: text/plain; charset=UTF-8";

    // Best-effort; failures are silently ignored to prevent enumeration
    @mail($email, $subject, $message, $headers);
}

respond(['message' => 'If that email exists, a reset link has been sent.']);
