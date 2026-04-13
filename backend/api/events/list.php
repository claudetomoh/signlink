<?php
// GET /api/events/list.php
// Header: Authorization: Bearer <token>
// Query:  ?search=&tab=upcoming|past|all
// Returns: { events: [...] }
require_once __DIR__ . '/../config/helpers.php';
cors();

$user   = requireAuth();
$db     = getDB();
$search = trim($_GET['search'] ?? '');
$tab    = $_GET['tab'] ?? 'all';

$conditions = ['e.is_active = 1'];
$params     = [$user['id'], $user['id']]; // for subquery

if (!empty($search)) {
    $conditions[] = '(e.title LIKE ? OR e.location LIKE ? OR e.description LIKE ?)';
    $params = array_merge([$user['id'], $user['id']], ["%$search%", "%$search%", "%$search%"]);
}

if ($tab === 'upcoming') {
    $conditions[] = 'e.event_date >= NOW()';
} elseif ($tab === 'past') {
    $conditions[] = 'e.event_date < NOW()';
}

$where = 'WHERE ' . implode(' AND ', $conditions);

// count sign-ups and flag whether current student is signed up
$sql = "SELECT e.*,
        (SELECT COUNT(*) FROM event_signups es WHERE es.event_id = e.id) AS signed_up_count,
        (SELECT COUNT(*) FROM event_signups es WHERE es.event_id = e.id AND es.student_id = ?) AS is_signed_up_raw
        FROM events e
        $where
        ORDER BY e.event_date ASC";

// Rebuild params: student_id for subqueries first, then search params
if (!empty($search)) {
    $finalParams = [$user['id'], "%$search%", "%$search%", "%$search%"];
} else {
    $finalParams = [$user['id']];
}

$stmt = $db->prepare($sql);
$stmt->execute($finalParams);
$rows = $stmt->fetchAll();

$events = array_map(static function (array $e): array {
    $cap      = (int)$e['capacity'];
    $signedUp = (int)$e['signed_up_count'];
    return [
        'id'              => $e['id'],
        'title'           => $e['title'],
        'description'     => $e['description'] ?? '',
        'location'        => $e['location'],
        'date'            => $e['event_date'],
        'capacity'        => $cap,
        'signedUpCount'   => $signedUp,
        'capacityPercent' => $cap > 0 ? round($signedUp / $cap, 2) : 0.0,
        'isSignedUp'      => (bool)$e['is_signed_up_raw'],
        'imageUrl'        => $e['image_url'],
        'isPast'          => strtotime($e['event_date']) < time(),
        'createdBy'       => $e['created_by'] ?? '',
    ];
}, $rows);

respond(['events' => $events]);
