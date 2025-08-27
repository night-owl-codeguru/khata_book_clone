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
            try {
                $pdo->exec($statement);
                echo "✓ Executed: " . substr($statement, 0, 50) . "...\n";
            } catch (PDOException $e) {
                $sqlErrNo = isset($e->errorInfo[1]) ? $e->errorInfo[1] : null;
                // MySQL error 1061 = Duplicate key name
                if ($sqlErrNo == 1061 || stripos($e->getMessage(), 'Duplicate key name') !== false) {
                    echo "⚠️  Skipped (duplicate key/index): " . substr($statement, 0, 80) . "...\n";
                    continue;
                }
                // For other errors, rethrow so deployment logs the failure
                throw $e;
            }
        }
    }

    echo "\n✅ Database schema created successfully!\n";

} catch (Exception $e) {
    echo "❌ Database initialization failed: " . $e->getMessage() . "\n";
    exit(1);
}
?>