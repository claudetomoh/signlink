<?php
// SignLink — Shared helpers (CORS, auth middleware, response format, utilities)
require_once __DIR__ . '/db.php';

// ── CORS ──────────────────────────────────────────────────────────────────────
function cors(): void
{
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization');
    header('Content-Type: application/json; charset=utf-8');
    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(200);
        exit;
    }
}

// ── Response helpers ─────────────────────────────────────────────────────────
function respond(array $data, int $code = 200): void
{
    http_response_code($code);
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function error(string $message, int $code = 400): void
{
    respond(['error' => $message], $code);
}

// ── Request body ─────────────────────────────────────────────────────────────
function body(): array
{
    $raw = file_get_contents('php://input');
    if (empty($raw)) return [];
    $decoded = json_decode($raw, true);
    return is_array($decoded) ? $decoded : [];
}

// ── Authentication middleware ─────────────────────────────────────────────────
function requireAuth(): array
{
    $headers = function_exists('getallheaders') ? getallheaders() : [];
    // Apache may lowercase header keys
    $auth = $headers['Authorization'] ?? $headers['authorization'] ?? '';
    if (!preg_match('/^Bearer\s+(.+)$/i', trim($auth), $m)) {
        error('Unauthorized — missing or malformed Authorization header', 401);
    }
    $token = $m[1];

    $db = getDB();
    $stmt = $db->prepare(
        "SELECT u.* FROM auth_tokens t
         JOIN users u ON t.user_id = u.id
         WHERE t.token = ?
           AND t.expires_at > NOW()
           AND u.is_active = 1
           AND u.is_suspended = 0"
    );
    $stmt->execute([$token]);
    $user = $stmt->fetch();
    if (!$user) error('Unauthorized — invalid or expired token', 401);
    return $user;
}

function requireRole(array $user, string ...$roles): void
{
    if (!in_array($user['role'], $roles, true)) {
        error('Forbidden — insufficient role', 403);
    }
}

// ── UUID v4 ───────────────────────────────────────────────────────────────────
function uuid(): string
{
    $data = random_bytes(16);
    $data[6] = chr(ord($data[6]) & 0x0f | 0x40);
    $data[8] = chr(ord($data[8]) & 0x3f | 0x80);
    return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($data), 4));
}

// ── Notification helper ───────────────────────────────────────────────────────
function sendNotification(
    string $userId,
    string $title,
    string $body,
    string $type,
    ?string $relatedId = null
): void {
    try {
        $db = getDB();
        $stmt = $db->prepare(
            "INSERT INTO notifications (id, user_id, title, body, type, related_id)
             VALUES (?, ?, ?, ?, ?, ?)"
        );
        $stmt->execute([uuid(), $userId, $title, $body, $type, $relatedId]);
    } catch (Throwable $e) {
        // Notification failure must not break the caller flow
    }
}

// ── User sanitise (remove password_hash before sending to client) ────────────
function sanitiseUser(array $user): array
{
    unset($user['password_hash']);
    $user['languages'] = !empty($user['languages'])
        ? explode(',', $user['languages'])
        : [];
    $user['isSuspended'] = (bool)($user['is_suspended'] ?? 0);
    $user['isActive']    = (bool)($user['is_active'] ?? 1);
    unset($user['is_suspended'], $user['is_active']);
    return $user;
}
