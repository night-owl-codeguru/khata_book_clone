<?php
// Database Initialization Script
// Run this script to create the database schema

require_once __DIR__ . '/config/database.php';

try {
    // Read the schema file
    $schema = file_get_contents(__DIR__ . '/schema.sql');

    // Remove comments and split by semicolon
    $schema = preg_replace('/--.*$/m', '', $schema);
    $statements = array_filter(array_map('trim', explode(';', $schema)));

    foreach ($statements as $statement) {
        if (!empty($statement)) {
            $pdo->exec($statement);
            echo "✓ Executed: " . substr($statement, 0, 50) . "...\n";
        }
    }

    echo "\n✅ Database schema created successfully!\n";

} catch (Exception $e) {
    echo "❌ Database initialization failed: " . $e->getMessage() . "\n";
    exit(1);
}
?>