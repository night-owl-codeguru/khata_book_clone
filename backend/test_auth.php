<?php
// Authentication Test Script
// Run this script to test the authentication system
// Usage: php test_auth.php

require_once 'config/database.php';
require_once 'models/User.php';
require_once 'models/JWT.php';
require_once 'controllers/AuthController.php';

echo "=== KhataBook Authentication Test ===\n\n";

try {
    // Test 1: User Registration
    echo "1. Testing User Registration...\n";

    $user = new User();
    $result = $user->signUp(
        'Test User',
        '+1234567890',
        'test@example.com',
        'password123',
        'Test Address'
    );

    if ($result['success']) {
        echo "✓ User registration successful\n";
        echo "  Token: " . substr($result['token'], 0, 50) . "...\n";
        $testToken = $result['token'];
    } else {
        echo "✗ User registration failed: " . $result['message'] . "\n";
        exit(1);
    }

    // Test 2: User Login
    echo "\n2. Testing User Login...\n";

    $loginResult = $user->login('test@example.com', 'password123');

    if ($loginResult['success']) {
        echo "✓ User login successful\n";
        echo "  Token: " . substr($loginResult['token'], 0, 50) . "...\n";
        $testToken = $loginResult['token'];
    } else {
        echo "✗ User login failed: " . $loginResult['message'] . "\n";
        exit(1);
    }

    // Test 3: JWT Token Validation
    echo "\n3. Testing JWT Token Validation...\n";

    $payload = JWT::decode($testToken);
    if ($payload && isset($payload['user_id'])) {
        echo "✓ JWT token is valid\n";
        echo "  User ID: " . $payload['user_id'] . "\n";
        echo "  Email: " . $payload['email'] . "\n";
    } else {
        echo "✗ JWT token validation failed\n";
        exit(1);
    }

    // Test 4: Get User Profile
    echo "\n4. Testing Get User Profile...\n";

    $userData = $user->getByEmail('test@example.com');
    if ($userData) {
        echo "✓ User profile retrieved successfully\n";
        echo "  Name: " . $userData['name'] . "\n";
        echo "  Email: " . $userData['email'] . "\n";
        echo "  Phone: " . $userData['phone'] . "\n";
    } else {
        echo "✗ Failed to retrieve user profile\n";
        exit(1);
    }

    // Test 5: Invalid Login
    echo "\n5. Testing Invalid Login...\n";

    $invalidResult = $user->login('test@example.com', 'wrongpassword');

    if (!$invalidResult['success']) {
        echo "✓ Invalid login correctly rejected\n";
        echo "  Message: " . $invalidResult['message'] . "\n";
    } else {
        echo "✗ Invalid login was not rejected\n";
        exit(1);
    }

    // Test 6: Duplicate Email Registration
    echo "\n6. Testing Duplicate Email Registration...\n";

    $duplicateResult = $user->signUp(
        'Another User',
        '+0987654321',
        'test@example.com', // Same email
        'password456',
        'Another Address'
    );

    if (!$duplicateResult['success']) {
        echo "✓ Duplicate email correctly rejected\n";
        echo "  Message: " . $duplicateResult['message'] . "\n";
    } else {
        echo "✗ Duplicate email was not rejected\n";
        exit(1);
    }

    echo "\n=== All Authentication Tests Passed! ===\n";
    echo "\nNext steps:\n";
    echo "1. Start your backend server: php -S localhost:8000\n";
    echo "2. Update the API URL in frontend/lib/services/auth_service.dart\n";
    echo "3. Run the Flutter app: flutter run\n";
    echo "4. Test the complete authentication flow\n";

} catch (Exception $e) {
    echo "\n❌ Test failed with exception: " . $e->getMessage() . "\n";
    exit(1);
}
?>