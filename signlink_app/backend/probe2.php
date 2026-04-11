<?php
// TEMPORARY PROBE v2 - DELETE AFTER USE
if (!isset($_GET['t']) || $_GET['t'] !== 'sl_probe_2026') {
    http_response_code(403); die('Forbidden');
}
echo '<pre>';

// Try all likely paths for mysql_instructions.txt
$paths = [
    '/home/tomoh.ikfingeh/mysql_instructions.txt',
    '/home/tomoh.ikfingeh/mysql_instructions.txt',
    '/var/www/html/~tomoh.ikfingeh/../../../home/tomoh.ikfingeh/mysql_instructions.txt',
];
foreach ($paths as $p) {
    if (@file_exists($p)) {
        echo "=== Found: $p ===\n";
        echo htmlspecialchars(@file_get_contents($p));
        echo "\n";
    } else {
        echo "Not found: $p\n";
    }
}

// List home directory if accessible
$homeDir = '/home/tomoh.ikfingeh/';
if (@is_dir($homeDir)) {
    echo "\n=== Home dir listing ===\n";
    $files = @scandir($homeDir);
    if ($files) foreach ($files as $f) echo "  $f\n";
}

echo "\n=== MySQL Tests ===\n";
$users = [
    'tomoh.ikfingeh',
    'tomoh_ikfingeh', 
    'tomohikfingeh',
    'signlink',
    'root',
];
$passwords = ['STCLAUDE20@?', '97482027', ''];
foreach ($users as $u) {
    foreach ($passwords as $pw) {
        try {
            $pdo = new PDO("mysql:host=localhost", $u, $pw, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
            echo "SUCCESS: user='$u' pass='$pw'\n";
            $dbs = $pdo->query("SHOW DATABASES")->fetchAll(PDO::FETCH_COLUMN);
            echo "Databases: " . implode(', ', $dbs) . "\n";
            $pdo = null;
        } catch (PDOException $e) {
            $msg = $e->getMessage();
            // Only print if it's not just "access denied"
            if (strpos($msg, 'Access denied') === false) {
                echo "user='$u' pass='$pw': $msg\n";
            }
        }
    }
}

// Check if there's a .my.cnf config
$mycnf = '/home/tomoh.ikfingeh/.my.cnf';
if (@file_exists($mycnf)) {
    echo "\n=== .my.cnf ===\n";
    echo htmlspecialchars(@file_get_contents($mycnf));
}

echo "\nScript path: " . __FILE__ . "\n";
echo "DOCUMENT_ROOT: " . ($_SERVER['DOCUMENT_ROOT'] ?? 'n/a') . "\n";
echo '</pre>';
