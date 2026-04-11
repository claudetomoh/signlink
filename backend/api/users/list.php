<?php
// GET /api/users/list.php
// Header: Authorization: Bearer <token>  (admin only)
// Query:  ?search=&role=student|interpreter|admin
// Returns: { users: [...] }
require_once __DIR__ . '/../config/helpers.php';
cors();

$user = requireAuth();
requireRole($user, 'admin');

$db     = getDB();
$search = trim($_GET['search'] ?? '');
$role   = $_GET['role'] ?? '';

$conditions = ['is_active = 1'];
$params     = [];

if (!empty($search)) {
    $conditions[] = '(name LIKE ? OR email LIKE ?)';
    $params[]     = "%$search%";
    $params[]     = "%$search%";
}

if (!empty($role) && in_array($role, ['student', 'interpreter', 'admin'], true)) {
    $conditions[] = 'role = ?';
    $params[]     = $role;
}

$where = 'WHERE ' . implode(' AND ', $conditions);

$stmt = $db->prepare(
    "SELECT id, name, email, role, avatar_url, bio, languages, rating,
            is_suspended, created_at
     FROM users $where ORDER BY name ASC"
);
$stmt->execute($params);
$rows = $stmt->fetchAll();

$users = array_map(static function (array $u): array {
    return [
        'id'          => $u['id'],
        'name'        => $u['name'],
        'email'       => $u['email'],
        'role'        => $u['role'],
        'avatarUrl'   => $u['avatar_url'],
        'bio'         => $u['bio'] ?? '',
        'languages'   => !empty($u['languages']) ? explode(',', $u['languages']) : [],
        'rating'      => (float)$u['rating'],
        'isSuspended' => (bool)$u['is_suspended'],
        'createdAt'   => $u['created_at'],
    ];
}, $rows);

respond(['users' => $users]);
