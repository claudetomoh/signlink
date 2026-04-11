<?php
// GET /api/notifications/list.php
// Header: Authorization: Bearer <token>
// Returns: { notifications: [...], unreadCount: int }
require_once __DIR__ . '/../config/helpers.php';
cors();

$user = requireAuth();
$db   = getDB();

$stmt = $db->prepare(
    "SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT 100"
);
$stmt->execute([$user['id']]);
$rows = $stmt->fetchAll();

$notifications = array_map(static function (array $n): array {
    return [
        'id'        => $n['id'],
        'userId'    => $n['user_id'],
        'title'     => $n['title'],
        'body'      => $n['body'],
        'type'      => $n['type'],
        'relatedId' => $n['related_id'],
        'isRead'    => (bool)$n['is_read'],
        'createdAt' => $n['created_at'],
    ];
}, $rows);

$unreadCount = count(array_filter($notifications, static fn($n) => !$n['isRead']));

respond(['notifications' => $notifications, 'unreadCount' => $unreadCount]);
