<?php
/**
 * SignLink — Password Reset Page
 * Accessible at: http://169.239.251.102:280/~tomoh.ikfingeh/uploads/reset_password.php?token=<token>
 */
require_once __DIR__ . '/api/config/db.php';

// Accept token from URL query string (GET) OR from the hidden POST field,
// because some mobile browsers strip query params when submitting a form.
$token = trim($_GET['token'] ?? $_POST['token'] ?? '');
$error = '';
$done  = false;

if (empty($token)) {
    $error = 'Invalid or missing reset token.';
} else {
    $db   = getDB();
    $stmt = $db->prepare(
        "SELECT pr.user_id, u.email FROM password_resets pr
         JOIN users u ON u.id = pr.user_id
         WHERE pr.token = ? AND pr.expires_at > NOW() AND u.is_active = 1"
    );
    $stmt->execute([$token]);
    $row = $stmt->fetch();

    if (!$row) {
        $error = 'This reset link is invalid or has expired. Please request a new one.';
    } elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $password = $_POST['password'] ?? '';
        $confirm  = $_POST['confirm']  ?? '';

        if (strlen($password) < 8) {
            $error = 'Password must be at least 8 characters.';
        } elseif ($password !== $confirm) {
            $error = 'Passwords do not match.';
        } else {
            $hash = password_hash($password, PASSWORD_BCRYPT);
            $db->prepare("UPDATE users SET password_hash = ? WHERE id = ?")->execute([$hash, $row['user_id']]);
            // Invalidate all existing auth tokens for this user
            $db->prepare("DELETE FROM auth_tokens WHERE user_id = ?")->execute([$row['user_id']]);
            // Remove the used reset token
            $db->prepare("DELETE FROM password_resets WHERE token = ?")->execute([$token]);
            $done = true;
        }
    }
}
?><!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>SignLink — Reset Password</title>
  <style>
    body { font-family: sans-serif; background:#f5f5f5; display:flex; justify-content:center; align-items:center; min-height:100vh; margin:0; }
    .card { background:#fff; border-radius:12px; padding:36px; width:100%; max-width:400px; box-shadow:0 2px 16px rgba(0,0,0,.1); }
    h1 { margin-top:0; font-size:22px; color:#1a1a2e; }
    label { display:block; margin-bottom:4px; font-size:14px; color:#555; }
    input { width:100%; box-sizing:border-box; padding:10px 12px; border:1px solid #ddd; border-radius:8px; font-size:15px; margin-bottom:16px; }
    button { width:100%; padding:12px; background:#6c63ff; color:#fff; border:none; border-radius:8px; font-size:15px; font-weight:600; cursor:pointer; }
    button:hover { background:#574fd6; }
    .error { color:#e53935; font-size:13px; margin-bottom:12px; }
    .success { color:#2e7d32; font-size:15px; }
    a { color:#6c63ff; }
  </style>
</head>
<body>
<div class="card">
  <h1>Reset Your Password</h1>
  <?php if ($done): ?>
    <p class="success">&#10003; Your password has been updated successfully.</p>
    <p>You can now log in to the SignLink app with your new password.</p>
  <?php elseif ($error): ?>
    <p class="error"><?= htmlspecialchars($error) ?></p>
    <p><a href="#">Request a new reset link</a> from the app.</p>
  <?php else: ?>
    <form method="post" action="?token=<?= htmlspecialchars(urlencode($token)) ?>">
      <label for="password">New Password</label>
      <input type="password" id="password" name="password" minlength="8" required placeholder="At least 8 characters">
      <label for="confirm">Confirm Password</label>
      <input type="password" id="confirm" name="confirm" minlength="8" required placeholder="Repeat password">
      <input type="hidden" name="token" value="<?= htmlspecialchars($token) ?>">
      <button type="submit">Set New Password</button>
    </form>
  <?php endif; ?>
</div>
</body>
</html>
