<?php
// Database Migration Script for Authentication
// Run this script to update your existing database schema to support authentication

require_once __DIR__ . '/config/database.php';

try {
    // Add password column to users table
    $sql1 = "ALTER TABLE users ADD COLUMN password VARCHAR(255) NOT NULL AFTER email";
    $pdo->exec($sql1);
    echo "✓ Added password column to users table\n";

    // Make email unique
    $sql2 = "ALTER TABLE users ADD CONSTRAINT unique_email UNIQUE (email)";
    $pdo->exec($sql2);
    echo "✓ Made email column unique\n";

    // Insert a sample user for testing
    $hashedPassword = password_hash('password123', PASSWORD_DEFAULT);
    $sql3 = "INSERT INTO users (name, phone, email, password, address, created_at) VALUES (?, ?, ?, ?, ?, NOW())";
    $stmt = $pdo->prepare($sql3);
    $stmt->execute(['John Doe', '+1234567890', 'john@example.com', $hashedPassword, '123 Main St']);
    echo "✓ Inserted sample user (email: john@example.com, password: password123)\n";

    echo "\n✅ Database migration completed successfully!\n";
    echo "You can now use the authentication system.\n";

} catch (PDOException $e) {
    if ($e->getCode() == '42S21') {
        echo "⚠️  Password column already exists, skipping...\n";
    } elseif ($e->getCode() == '23000') {
        echo "⚠️  Email uniqueness constraint already exists, skipping...\n";
    } else {
        echo "❌ Migration failed: " . $e->getMessage() . "\n";
        exit(1);
    }
}

echo "\n✅ Migration check completed!\n";
?>