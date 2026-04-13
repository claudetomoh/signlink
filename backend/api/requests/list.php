<?php
// GET /api/requests/list.php
// Header: Authorization: Bearer <token>
// Returns: { requests: [...] }
//   student   → their own requests
//   interpreter → their accepted + all pending
//   admin     → all requests
require_once __DIR__ . '/../config/helpers.php';
cors();

$user = requireAuth();
$db   = getDB();

$baseSelect = "SELECT r.*,
    u_s.name        AS student_name,
    u_s.email       AS student_email,
    u_s.avatar_url  AS student_avatar,
    u_i.name        AS interpreter_name,
    u_i.email       AS interpreter_email,
    u_i.avatar_url  AS interpreter_avatar
    FROM interpreter_requests r
    JOIN  users u_s ON r.student_id     = u_s.id
    LEFT JOIN users u_i ON r.interpreter_id  = u_i.id";

if ($user['role'] === 'student') {
    $stmt = $db->prepare("$baseSelect WHERE r.student_id = ? ORDER BY r.created_at DESC");
    $stmt->execute([$user['id']]);
} elseif ($user['role'] === 'interpreter') {
    $stmt = $db->prepare(
        "$baseSelect
         WHERE (r.interpreter_id = ? OR r.status = 'pending')
         ORDER BY r.created_at DESC"
    );
    $stmt->execute([$user['id']]);
} else {
    // admin
    $stmt = $db->query("$baseSelect ORDER BY r.created_at DESC");
}

$rows = $stmt->fetchAll();

$requests = array_map(static function (array $r): array {
    return [
        'id'             => $r['id'],
        'studentId'      => $r['student_id'],
        'interpreterId'  => $r['interpreter_id'],
        'requestType'    => $r['request_type'],
        'eventTitle'     => $r['event_title'],
        'location'       => $r['location'],
        'eventDate'      => $r['event_date'],
        'eventTime'      => $r['event_time'],
        'notes'          => $r['notes'],
        'status'         => $r['status'],
        'createdAt'      => $r['created_at'],
        'student' => $r['student_id'] ? [
            'name'      => $r['student_name'],
            'email'     => $r['student_email'],
            'avatarUrl' => $r['student_avatar'],
        ] : null,
        'interpreter' => $r['interpreter_id'] ? [
            'name'      => $r['interpreter_name'],
            'email'     => $r['interpreter_email'],
            'avatarUrl' => $r['interpreter_avatar'],
        ] : null,
        'isRated'     => (bool)($r['is_rated'] ?? 0),
    ];
}, $rows);

respond(['requests' => $requests]);
