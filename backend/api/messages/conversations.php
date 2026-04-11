<?php
// GET /api/messages/conversations.php
// Header: Authorization: Bearer <token>
// Returns: { conversations: [...] }
require_once __DIR__ . '/../config/helpers.php';
cors();

$user = requireAuth();
$db   = getDB();

$stmt = $db->prepare(
    "SELECT c.*,
        CASE WHEN c.participant_a_id = ? THEN c.participant_b_id
             ELSE c.participant_a_id END                      AS other_id,
        u.name                                                AS other_name,
        u.role                                                AS other_role,
        u.avatar_url                                          AS other_avatar,
        (SELECT COUNT(*) FROM messages m
         WHERE m.conversation_id = c.id
           AND m.sender_id != ?
           AND m.is_read = 0)                                AS unread_count
    FROM conversations c
    JOIN users u ON u.id = CASE WHEN c.participant_a_id = ? THEN c.participant_b_id
                                ELSE c.participant_a_id END
    WHERE c.participant_a_id = ? OR c.participant_b_id = ?
    ORDER BY c.last_message_at DESC"
);
$stmt->execute([
    $user['id'],
    $user['id'],
    $user['id'],
    $user['id'],
    $user['id'],
]);
$rows = $stmt->fetchAll();

$conversations = array_map(static function (array $c): array {
    return [
        'id'            => $c['id'],
        'otherUser'     => [
            'id'        => $c['other_id'],
            'name'      => $c['other_name'],
            'role'      => $c['other_role'],
            'avatarUrl' => $c['other_avatar'],
        ],
        'lastMessage'   => $c['last_message'],
        'lastMessageAt' => $c['last_message_at'],
        'unreadCount'   => (int)$c['unread_count'],
    ];
}, $rows);

respond(['conversations' => $conversations]);
