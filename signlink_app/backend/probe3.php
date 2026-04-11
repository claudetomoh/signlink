<?php
if (!isset($_GET['t']) || $_GET['t'] !== 'sl_probe_2026') { die('Forbidden'); }

echo '<pre>';
// Try TCP vs socket and more username combinations
$host_options = ['127.0.0.1', 'localhost'];
$users = [
    'tomoh.ikfingeh', 'tomoh_ikfingeh', 'tomohikfingeh',
    'tomoh', 'signlink', 'student'
];
$passwords = ['STCLAUDE20@?'];

echo "=== MySQL connection attempts ===\n";
foreach ($host_options as $h) {
    foreach ($users as $u) {
        foreach ($passwords as $pw) {
            try {
                if ($h === 'localhost') {
                    $dsn = "mysql:host=localhost;unix_socket=/var/run/mysqld/mysqld.sock";
                } else {
                    $dsn = "mysql:host=127.0.0.1;port=3306";
                }
                $pdo = new PDO($dsn, $u, $pw, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
                echo "SUCCESS host=$h user=$u\n";
                $dbs = $pdo->query("SHOW DATABASES")->fetchAll(PDO::FETCH_COLUMN);
                echo "  DBs: " . implode(', ', $dbs) . "\n";
                $pdo = null;
            } catch (PDOException $e) {
                $msg = $e->getMessage();
                // Show full message for debugging
                echo "FAIL host=$h user=$u: $msg\n";
            }
        }
    }
}

// Show phpinfo MySQL section
echo "\n=== PHP MySQL config ===\n";
ob_start();
phpinfo(INFO_CONFIGURATION);
$pi = ob_get_clean();
preg_match_all('/mysql[^<>]*<\/td>[^<>]*<td[^>]*>[^<>]*<\/td>[^<>]*<td[^>]*>([^<>]+)/i', $pi, $m);
foreach ($m[0] as $line) {
    echo strip_tags($line) . "\n";
}

// Look for any PHP config file with DB settings
echo "\n=== Apache user ===\n";
echo posix_getpwuid(posix_geteuid())['name'] ?? exec('whoami');
echo "\n";
echo '</pre>';
