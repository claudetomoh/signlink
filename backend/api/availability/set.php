<?php
// POST /api/availability/set.php
// Header: Authorization: Bearer <token>  (interpreter only)
// Body: { startDate, endDate, recurring, days }
//   days: array of 0-6 integers (0=Mon … 6=Sun), only used when recurring=true
// Returns: { message }
require_once __DIR__ . '/../../config/helpers.php';
cors();

$user = requireAuth();
requireRole($user, 'interpreter');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') error('Method not allowed', 405);

$body      = body();
$startDate = $body['startDate'] ?? '';
$endDate   = $body['endDate']   ?? '';
$recurring = !empty($body['recurring']);
$days      = is_array($body['days'] ?? null)
    ? implode(',', array_filter($body['days'], fn($d) => is_int($d) && $d >= 0 && $d <= 6))
    : '';

if (empty($startDate) || empty($endDate)) error('startDate and endDate are required');

// Basic date format validation
if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $startDate) ||
    !preg_match('/^\d{4}-\d{2}-\d{2}$/', $endDate)) {
    error('Dates must be in YYYY-MM-DD format');
}
if ($startDate > $endDate) error('startDate must be before endDate');

$db = getDB();

// Upsert: delete old, insert new
$db->prepare(
    "DELETE FROM interpreter_availability WHERE interpreter_id = ?"
)->execute([$user['id']]);

$db->prepare(
    "INSERT INTO interpreter_availability (interpreter_id, start_date, end_date, is_recurring, recurring_days)
     VALUES (?, ?, ?, ?, ?)"
)->execute([$user['id'], $startDate, $endDate, $recurring ? 1 : 0, $days]);

respond(['message' => 'Availability updated successfully']);
