<?php
// GET /api/messages/list.php?conversation_id=<id>
//   OR  GET /api/messages/list.php?user_id=<other_user_id>  (auto-creates conversation)
// Header: Authorization: Bearer <token>
// Returns: { conversationId, messages: [...] }
require_once __DIR__ . '/../config/helpers.php';
cors();

$user   = requireAuth();
$db     = getDB();
$convId = trim($_GET['conversation_id'] ?? $_GET['conv'] ?? '');

if (empty($convId)) {
    // Resolve by other user id — get or create the conversation
    $otherId = trim($_GET['user_id'] ?? '');
    if (empty($otherId)) error('conversation_id or user_id is required');

    $stmt = $db->prepare(
        "SELECT id FROM conversations
         WHERE (participant_a_id = ? AND participant_b_id = ?)
            OR (participant_a_id = ? AND participant_b_id = ?)"
    );
    $stmt->execute([$user['id'], $otherId, $otherId, $user['id']]);
    $conv = $stmt->fetch();

    if ($conv) {
        $convId = $conv['id'];
    } else {
        $convId = uuid();
        $db->prepare(
            "INSERT INTO conversations (id, participant_a_id, participant_b_id) VALUES (?, ?, ?)"
        )->execute([$convId, $user['id'], $otherId]);
    }
}

// Ensure current user is a participant
$stmt = $db->prepare(
    "SELECT id FROM conversations WHERE id = ?
     AND (participant_a_id = ? OR participant_b_id = ?)"
);
$stmt->execute([$convId, $user['id'], $user['id']]);
if (!$stmt->fetch()) error('Conversation not found', 404);

// Mark incoming messages as read
$db->prepare(
    "UPDATE messages SET is_read = 1 WHERE conversation_id = ? AND sender_id != ?"
)->execute([$convId, $user['id']]);

// Fetch messages (newest 100)
$stmt = $db->prepare(
    "SELECT * FROM messages WHERE conversation_id = ? ORDER BY created_at ASC LIMIT 100"
);
$stmt->execute([$convId]);
$rows = $stmt->fetchAll();

$messages = array_map(static function (array $m) use ($user): array {
    return [
        'id'             => $m['id'],
        'conversationId' => $m['conversation_id'],
        'senderId'       => $m['sender_id'],
        'text'           => $m['text'],
        'isRead'         => (bool)$m['is_read'],
        'isMe'           => $m['sender_id'] === $user['id'],
        'createdAt'      => $m['created_at'],
    ];
}, $rows);

respond(['conversationId' => $convId, 'messages' => $messages]);
