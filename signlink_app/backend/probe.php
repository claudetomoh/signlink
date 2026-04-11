<?php
// TEMPORARY PROBE - DELETE AFTER USE
// Protected by a secret token
if (!isset($_GET['t']) || $_GET['t'] !== 'sl_probe_2026') {
    http_response_code(403); die('Forbidden');
}
echo '<pre>';
// Read mysql instructions
$f = '/home/tomoh.ikfingeh/mysql_instructions.txt';
if (file_exists($f)) {
    echo "=== mysql_instructions.txt ===\n";
    echo htmlspecialchars(file_get_contents($f));
} else {
    echo "mysql_instructions.txt not found at: $f\n";
    // Try relative paths
    $paths = [
        '../mysql_instructions.txt',
        '../../mysql_instructions.txt',
        $_SERVER['HOME'] . '/mysql_instructions.txt',
    ];
    foreach ($paths as $p) {
        if (@file_exists($p)) {
            echo "Found at: $p\n";
            echo htmlspecialchars(file_get_contents($p));
            break;
        }
    }
}
echo "\n\n=== PHP Info ===\n";
echo "PHP Version: " . phpversion() . "\n";
echo "Server: " . ($_SERVER['SERVER_SOFTWARE'] ?? 'unknown') . "\n";
echo "Document Root: " . ($_SERVER['DOCUMENT_ROOT'] ?? 'unknown') . "\n";
echo "HOME: " . ($_SERVER['HOME'] ?? getenv('HOME') ?? 'unknown') . "\n";

// Try to determine MySQL user
echo "\n=== MySQL Connection Test ===\n";
$mysqlUsers = ['tomoh.ikfingeh', 'tomoh_ikfingeh', 'tomoh', 'signlink'];
foreach ($mysqlUsers as $user) {
    try {
        $pdo = new PDO("mysql:host=localhost", $user, 'STCLAUDE20@?');
        echo "MySQL connected with user: $user\n";
        $dbs = $pdo->query("SHOW DATABASES")->fetchAll(PDO::FETCH_COLUMN);
        echo "Databases: " . implode(', ', $dbs) . "\n";
        break;
    } catch (PDOException $e) {
        echo "Failed user '$user': " . $e->getMessage() . "\n";
    }
}
echo '</pre>';
