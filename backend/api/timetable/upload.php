<?php
// POST /api/timetable/upload.php
// Header: Authorization: Bearer <token>
// Body: multipart/form-data  — field name: "timetable"  (image or PDF/Excel)
// Students only. Stores the file under uploads/timetables/ and saves the path in DB.
require_once __DIR__ . '/../config/helpers.php';
cors();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') error('Method not allowed', 405);

$user = requireAuth();
requireRole($user, 'student');

if (empty($_FILES['timetable'])) {
    error('No file uploaded — send the file in a field named "timetable"');
}

$file    = $_FILES['timetable'];
$tmpPath = $file['tmp_name'];
$origName = basename($file['name']);

if ($file['error'] !== UPLOAD_ERR_OK) {
    error('File upload error: ' . $file['error']);
}

// ── Validate size (max 10 MB) ─────────────────────────────────────────────────
$maxBytes = 10 * 1024 * 1024;
if ($file['size'] > $maxBytes) {
    error('File too large — maximum size is 10 MB');
}

// ── Validate MIME type (image or document) ────────────────────────────────────
$allowedMimes = [
    'image/jpeg', 'image/png', 'image/webp', 'image/heic',
    'application/pdf',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'text/csv',
];
$finfo = new finfo(FILEINFO_MIME_TYPE);
$detectedMime = $finfo->file($tmpPath);
if (!in_array($detectedMime, $allowedMimes, true)) {
    error('Unsupported file type — upload an image, PDF, Excel, or CSV');
}

// ── Build destination path ────────────────────────────────────────────────────
$uploadDir = __DIR__ . '/../../../../uploads/timetables/';
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0755, true);
}

$ext      = strtolower(pathinfo($origName, PATHINFO_EXTENSION));
$newName  = 'timetable_' . $user['id'] . '_' . time() . '.' . $ext;
$destPath = $uploadDir . $newName;

if (!move_uploaded_file($tmpPath, $destPath)) {
    error('Failed to save file — please try again', 500);
}

// ── Persist URL in users table (reuse avatar_url column pattern) ──────────────
// Store in a timetable_url column; add it if the table doesn't yet have it.
$db = getDB();
try {
    $db->exec("ALTER TABLE users ADD COLUMN timetable_url VARCHAR(500) DEFAULT NULL");
} catch (PDOException $e) {
    // Column already exists — ignore
}

$urlPath = '/uploads/timetables/' . $newName;   // relative URL the app can construct
$db->prepare("UPDATE users SET timetable_url = ? WHERE id = ?")
   ->execute([$urlPath, $user['id']]);

respond([
    'message'      => 'Timetable uploaded successfully',
    'timetable_url' => $urlPath,
]);
