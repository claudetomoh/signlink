<?php
/**
 * SignLink — One-time database setup script.
 *
 * Visit: http://169.239.251.102:280/~tomoh.ikfingeh/setup.php?key=sl_setup_2026
 *
 * IMPORTANT: Delete this file from the server after first successful run:
 *   rm /home/tomoh.ikfingeh/public_html/setup.php
 */
$key = $_GET['key'] ?? '';
if ($key !== 'sl_setup_2026') {
    http_response_code(403);
    die('Forbidden — append ?key=sl_setup_2026 to the URL');
}

require_once __DIR__ . '/api/config/db.php';

header('Content-Type: text/plain; charset=utf-8');
echo "=== SignLink Database Setup ===\n\n";

$db = getDB();
echo "✓ Connected to MySQL\n\n";

// ── Create tables ───────────────────────────────────────────────────────────────
$tables = [
    'users' => "CREATE TABLE IF NOT EXISTS users (
        id           VARCHAR(36)  PRIMARY KEY,
        name         VARCHAR(255) NOT NULL,
        email        VARCHAR(255) NOT NULL UNIQUE,
        password_hash VARCHAR(255) NOT NULL,
        role         ENUM('student','interpreter','admin') NOT NULL DEFAULT 'student',
        avatar_url   VARCHAR(500) DEFAULT NULL,
        bio          TEXT         DEFAULT NULL,
        languages    VARCHAR(500) DEFAULT NULL,
        rating       DECIMAL(3,2) DEFAULT 0.00,
        is_active    TINYINT(1)   DEFAULT 1,
        is_suspended TINYINT(1)   DEFAULT 0,
        created_at   TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
        updated_at   TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci",

    'auth_tokens' => "CREATE TABLE IF NOT EXISTS auth_tokens (
        id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        user_id    VARCHAR(36) NOT NULL,
        token      VARCHAR(64) NOT NULL UNIQUE,
        expires_at TIMESTAMP   NOT NULL,
        created_at TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci",

    'interpreter_requests' => "CREATE TABLE IF NOT EXISTS interpreter_requests (
        id             VARCHAR(36)  PRIMARY KEY,
        student_id     VARCHAR(36)  NOT NULL,
        interpreter_id VARCHAR(36)  DEFAULT NULL,
        request_type   VARCHAR(100) NOT NULL,
        event_title    VARCHAR(255) NOT NULL,
        location       VARCHAR(255) NOT NULL,
        event_date     DATE         DEFAULT NULL,
        event_time     TIME         DEFAULT NULL,
        notes          TEXT         DEFAULT NULL,
        status         ENUM('pending','approved','declined','completed') DEFAULT 'pending',
        created_at     TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
        updated_at     TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (student_id)     REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (interpreter_id) REFERENCES users(id) ON DELETE SET NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci",

    'events' => "CREATE TABLE IF NOT EXISTS events (
        id          VARCHAR(36)  PRIMARY KEY,
        title       VARCHAR(255) NOT NULL,
        description TEXT         DEFAULT NULL,
        location    VARCHAR(255) NOT NULL,
        event_date  DATETIME     NOT NULL,
        capacity    INT          NOT NULL DEFAULT 50,
        created_by  VARCHAR(36)  DEFAULT NULL,
        image_url   VARCHAR(500) DEFAULT NULL,
        is_active   TINYINT(1)   DEFAULT 1,
        created_at  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci",

    'event_signups' => "CREATE TABLE IF NOT EXISTS event_signups (
        id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        event_id   VARCHAR(36) NOT NULL,
        student_id VARCHAR(36) NOT NULL,
        created_at TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
        UNIQUE KEY unique_signup (event_id, student_id),
        FOREIGN KEY (event_id)   REFERENCES events(id) ON DELETE CASCADE,
        FOREIGN KEY (student_id) REFERENCES users(id)  ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci",

    'notifications' => "CREATE TABLE IF NOT EXISTS notifications (
        id         VARCHAR(36)  PRIMARY KEY,
        user_id    VARCHAR(36)  NOT NULL,
        title      VARCHAR(255) NOT NULL,
        body       TEXT         NOT NULL,
        type       VARCHAR(100) NOT NULL DEFAULT 'general',
        related_id VARCHAR(36)  DEFAULT NULL,
        is_read    TINYINT(1)   DEFAULT 0,
        created_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci",

    'conversations' => "CREATE TABLE IF NOT EXISTS conversations (
        id                VARCHAR(36) PRIMARY KEY,
        participant_a_id  VARCHAR(36) NOT NULL,
        participant_b_id  VARCHAR(36) NOT NULL,
        last_message      TEXT        DEFAULT NULL,
        last_message_at   TIMESTAMP   DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        created_at        TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
        UNIQUE KEY unique_convo (participant_a_id, participant_b_id),
        FOREIGN KEY (participant_a_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (participant_b_id) REFERENCES users(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci",

    'messages' => "CREATE TABLE IF NOT EXISTS messages (
        id              VARCHAR(36) PRIMARY KEY,
        conversation_id VARCHAR(36) NOT NULL,
        sender_id       VARCHAR(36) NOT NULL,
        text            TEXT        NOT NULL,
        is_read         TINYINT(1)  DEFAULT 0,
        created_at      TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
        FOREIGN KEY (sender_id)       REFERENCES users(id)          ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci",
];

echo "--- Creating tables ---\n";
foreach ($tables as $name => $sql) {
    try {
        $db->exec($sql);
        echo "✓ $name\n";
    } catch (PDOException $e) {
        echo "✗ $name — " . $e->getMessage() . "\n";
    }
}

// ── Seed demo users (password: Password1!) ────────────────────────────────────
$hash = password_hash('Password1!', PASSWORD_BCRYPT);

$demoUsers = [
    [
        'id'    => '550e8400-e29b-41d4-a716-446655440001',
        'name'  => 'Alex Johnson',
        'email' => 'alex.johnson@ashesi.edu.gh',
        'role'  => 'student',
        'bio'   => 'Computer Science & Engineering student',
        'langs' => '',
    ],
    [
        'id'    => '550e8400-e29b-41d4-a716-446655440002',
        'name'  => 'Kofi Mensah',
        'email' => 'kofi.mensah@ashesi.edu.gh',
        'role'  => 'interpreter',
        'bio'   => 'Certified Sign Language Interpreter (ASL & GSL)',
        'langs' => 'ASL,GSL',
    ],
    [
        'id'    => '550e8400-e29b-41d4-a716-446655440003',
        'name'  => 'Dr. Sarah Asante',
        'email' => 'sarah.asante@ashesi.edu.gh',
        'role'  => 'admin',
        'bio'   => 'SignLink Programme Administrator',
        'langs' => '',
    ],
];

echo "\n--- Seeding demo users (password: Password1!) ---\n";
foreach ($demoUsers as $u) {
    $stmt = $db->prepare("SELECT id FROM users WHERE email = ?");
    $stmt->execute([$u['email']]);
    if ($stmt->fetch()) {
        echo "→ {$u['email']} already exists, skipped\n";
        continue;
    }
    $db->prepare(
        "INSERT INTO users (id, name, email, password_hash, role, bio, languages)
         VALUES (?, ?, ?, ?, ?, ?, ?)"
    )->execute([$u['id'], $u['name'], $u['email'], $hash, $u['role'], $u['bio'], $u['langs']]);
    echo "✓ {$u['email']} ({$u['role']})\n";
}

// ── Seed sample events ────────────────────────────────────────────────────────
$sampleEvents = [
    [
        'id'    => '660e8400-e29b-41d4-a716-446655440001',
        'title' => 'Tech Summit 2026',
        'desc'  => 'Annual technology conference featuring talks from industry leaders and researchers.',
        'loc'   => 'Main Auditorium',
        'date'  => '2026-05-15 09:00:00',
        'cap'   => 200,
    ],
    [
        'id'    => '660e8400-e29b-41d4-a716-446655440002',
        'title' => 'Career Fair',
        'desc'  => 'Meet top employers and explore internship & graduate opportunities.',
        'loc'   => 'Student Centre',
        'date'  => '2026-05-22 10:00:00',
        'cap'   => 300,
    ],
    [
        'id'    => '660e8400-e29b-41d4-a716-446655440003',
        'title' => 'Graduation Ceremony',
        'desc'  => 'Celebrate the Class of 2026.',
        'loc'   => 'Main Auditorium',
        'date'  => '2026-06-15 14:00:00',
        'cap'   => 500,
    ],
];

echo "\n--- Seeding sample events ---\n";
$adminId = '550e8400-e29b-41d4-a716-446655440003';
foreach ($sampleEvents as $e) {
    $stmt = $db->prepare("SELECT id FROM events WHERE id = ?");
    $stmt->execute([$e['id']]);
    if ($stmt->fetch()) { echo "→ \"{$e['title']}\" already exists, skipped\n"; continue; }
    $db->prepare(
        "INSERT INTO events (id, title, description, location, event_date, capacity, created_by)
         VALUES (?, ?, ?, ?, ?, ?, ?)"
    )->execute([$e['id'], $e['title'], $e['desc'], $e['loc'], $e['date'], $e['cap'], $adminId]);
    echo "✓ {$e['title']}\n";
}

echo "\n=== SETUP COMPLETE ===\n\n";
echo "Demo credentials (all use password: Password1!)\n";
echo "  Student:     alex.johnson\@ashesi.edu.gh\n";
echo "  Interpreter: kofi.mensah\@ashesi.edu.gh\n";
echo "  Admin:       sarah.asante\@ashesi.edu.gh\n\n";
echo "SECURITY: Delete this file now!\n";
echo "  SSH: rm /home/tomoh.ikfingeh/public_html/setup.php\n";
