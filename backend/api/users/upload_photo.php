<?php
// POST /api/users/upload_photo.php
// Header: Authorization: Bearer <token>
// Body: multipart/form-data  — field name: "photo"  (image file)
// Any authenticated user can upload their own profile photo.
require_once __DIR__ . '/../config/helpers.php';
cors();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') error('Method not allowed', 405);

$user = requireAuth();

if (empty($_FILES['photo'])) {
    error('No file uploaded — send the image in a field named "photo"');
}

$file    = $_FILES['photo'];
$tmpPath = $file['tmp_name'];
$origName = basename($file['name']);

if ($file['error'] !== UPLOAD_ERR_OK) {
    error('File upload error: ' . $file['error']);
}

// ── Validate size (max 5 MB) ──────────────────────────────────────────────────
$maxBytes = 5 * 1024 * 1024;
if ($file['size'] > $maxBytes) {
    error('Image too large — maximum size is 5 MB');
}

// ── Validate MIME type (images only) ─────────────────────────────────────────
$allowedMimes = ['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'image/gif'];
$finfo        = new finfo(FILEINFO_MIME_TYPE);
$detectedMime = $finfo->file($tmpPath);
if (!in_array($detectedMime, $allowedMimes, true)) {
    error('Unsupported file type — upload a JPEG, PNG, or WebP image');
}

// ── Build destination path ────────────────────────────────────────────────────
$uploadDir = __DIR__ . '/../../../../uploads/avatars/';
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0755, true);
}

$ext      = strtolower(pathinfo($origName, PATHINFO_EXTENSION)) ?: 'jpg';
$newName  = 'avatar_' . $user['id'] . '_' . time() . '.' . $ext;
$destPath = $uploadDir . $newName;

if (!move_uploaded_file($tmpPath, $destPath)) {
    error('Failed to save image — please try again', 500);
}

// ── Save URL in users.avatar_url ──────────────────────────────────────────────
$urlPath = '/uploads/avatars/' . $newName;
getDB()->prepare("UPDATE users SET avatar_url = ? WHERE id = ?")
       ->execute([$urlPath, $user['id']]);

respond([
    'message'    => 'Photo uploaded successfully',
    'avatar_url' => $urlPath,
]);
