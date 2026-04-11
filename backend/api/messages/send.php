<?php
// POST /api/messages/send.php
// Header: Authorization: Bearer <token>
// Body: { conversationId, text }
// Returns: { message: {...} }
require_once __DIR__ . '/../config/helpers.php';
cors();

$user   = requireAuth();
$body   = body();
$convId = $body['conversationId'] ?? $body['conversation_id'] ?? '';
$text   = trim($body['text'] ?? '');

if (empty($convId) || empty($text)) error('conversationId and text are required');
if (mb_strlen($text) > 5000) error('Message is too long (max 5000 chars)');

$db = getDB();

// Verify current user is a participant
$stmt = $db->prepare(
    "SELECT * FROM conversations WHERE id = ?
     AND (participant_a_id = ? OR participant_b_id = ?)"
);
$stmt->execute([$convId, $user['id'], $user['id']]);
$conv = $stmt->fetch();
if (!$conv) error('Conversation not found', 404);

$msgId = uuid();
$db->prepare(
    "INSERT INTO messages (id, conversation_id, sender_id, text) VALUES (?, ?, ?, ?)"
)->execute([$msgId, $convId, $user['id'], $text]);

// Update conversation summary
$db->prepare(
    "UPDATE conversations SET last_message = ?, last_message_at = NOW() WHERE id = ?"
)->execute([$text, $convId]);

// Notify the other participant
$otherId = $conv['participant_a_id'] === $user['id']
    ? $conv['participant_b_id']
    : $conv['participant_a_id'];

sendNotification($otherId, "New message from {$user['name']}", $text, 'message', $convId);

respond([
    'message' => [
        'id'             => $msgId,
        'conversationId' => $convId,
        'senderId'       => $user['id'],
        'text'           => $text,
        'isRead'         => false,
        'isMe'           => true,
        'createdAt'      => date('c'),
    ],
], 201);
