<?php
// Database configuration for Aiven MySQL
$host = getenv('DB_HOST') ?: 'khatabook-adit-ef94.j.aivencloud.com';
$port = getenv('DB_PORT') ?: 10570;
$user = getenv('DB_USER') ?: 'avnadmin';
$password = getenv('DB_PASSWORD') ?: '';
$database = getenv('DB_NAME') ?: 'defaultdb';
$ssl_mode = getenv('DB_SSL_MODE') ?: 'REQUIRED';

// Create PDO connection
try {
    $dsn = "mysql:host=$host;port=$port;dbname=$database;charset=utf8mb4";
    $options = [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ];

    if ($ssl_mode === 'REQUIRED') {
        $options[PDO::MYSQL_ATTR_SSL_CA] = '/path/to/ca-cert.pem'; // You'll need to download and specify the CA certificate path
    }

    $pdo = new PDO($dsn, $user, $password, $options);
} catch (PDOException $e) {
    die("Database connection failed: " . $e->getMessage());
}
?>