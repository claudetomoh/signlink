<?php
// ┌─────────────────────────────────────────────────────────────────────────┐
// │  SignLink — Database Configuration                                      │
// │  Server: 169.239.251.102:280  MySQL user: tomoh.ikfingeh               │
// └─────────────────────────────────────────────────────────────────────────┘
//
// SSH into the server once to find your MySQL credentials:
//
//   ssh -C tomoh.ikfingeh@169.239.251.102 -p 222
//   # enter password: STCLAUDE20@?
//
//   cat ~/mysql_instructions.txt          # check if credentials are listed
//
//   # If no credentials found, set them up:
//   mysql -u root -p                      # try root (may not need password)
//   # OR: mysql -u tomoh.ikfingeh -p
//   # enter password: STCLAUDE20@?
//
//   # Once in MySQL:
//   CREATE DATABASE IF NOT EXISTS signlink_db;
//   CREATE USER IF NOT EXISTS 'signlink_user'@'localhost' IDENTIFIED BY 'STCLAUDE20@?';
//   GRANT ALL PRIVILEGES ON signlink_db.* TO 'signlink_user'@'localhost';
//   FLUSH PRIVILEGES;
//   EXIT;
//
//   # Then update DB_USER / DB_NAME below accordingly.

define('DB_HOST', 'localhost');
define('DB_PORT', '3306');
define('DB_USER', 'tomoh.ikfingeh');
define('DB_PASS', 'SqlUssd@2026');
define('DB_NAME', 'mobileapps_2026B_tomoh_ikfingeh');

function getDB(): PDO
{
    static $pdo = null;
    if ($pdo === null) {
        try {
            $dsn = sprintf(
                'mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4',
                DB_HOST, DB_PORT, DB_NAME
            );
            $pdo = new PDO($dsn, DB_USER, DB_PASS, [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES   => false,
                PDO::ATTR_PERSISTENT         => false,
            ]);
        } catch (PDOException $e) {
            http_response_code(500);
            header('Content-Type: application/json');
            echo json_encode(['error' => 'Database connection failed. Check db.php configuration.']);
            exit;
        }
    }
    return $pdo;
}
