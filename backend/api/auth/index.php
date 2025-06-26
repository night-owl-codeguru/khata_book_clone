<?php
require_once __DIR__ . '/../../config/constants.php';
require_once __DIR__ . '/../../middleware/validation.php';
require_once __DIR__ . '/../../models/User.php';
require_once __DIR__ . '/../../utils/helpers.php';

global $method, $segments;

$userModel = new User();

switch ($method) {
    case 'POST':
        if ($segments[1] === 'register') {
            handleRegister($userModel);
        } elseif ($segments[1] === 'login') {
            handleLogin($userModel);
        } else {
            ResponseHelper::error('Endpoint not found', 404);
        }
        break;
    
    default:
        ResponseHelper::error('Method not allowed', 405);
        break;
}

function handleRegister($userModel) {
    $input = json_decode(file_get_contents('php://input'), true);
    
    // Validate required fields
    ValidationMiddleware::validateRequired($input, ['name', 'email', 'phone', 'password']);
    
    // Sanitize input
    $input = ValidationMiddleware::sanitizeInput($input);
    
    // Validate email and phone
    ValidationMiddleware::validateEmail($input['email']);
    ValidationMiddleware::validatePhone($input['phone']);
    ValidationMiddleware::validatePassword($input['password']);
    
    try {
        // Check if email already exists
        if ($userModel->emailExists($input['email'])) {
            ResponseHelper::error('Email already exists', 400);
        }
        
        // Check if phone already exists
        if ($userModel->phoneExists($input['phone'])) {
            ResponseHelper::error('Phone number already exists', 400);
        }
        
        // Create user
        $userId = $userModel->create([
            'name' => $input['name'],
            'email' => $input['email'],
            'phone' => $input['phone'],
            'password' => $input['password']
        ]);
        
        // Generate JWT token
        $payload = [
            'user_id' => $userId,
            'email' => $input['email'],
            'name' => $input['name']
        ];
        
        $token = JWTHelper::generateToken($payload);
        
        ResponseHelper::success([
            'user' => [
                'id' => $userId,
                'name' => $input['name'],
                'email' => $input['email'],
                'phone' => $input['phone']
            ],
            'token' => $token
        ], 'User registered successfully', 201);
        
    } catch (Exception $e) {
        ResponseHelper::error('Registration failed: ' . $e->getMessage(), 500);
    }
}

function handleLogin($userModel) {
    $input = json_decode(file_get_contents('php://input'), true);
    
    // Validate required fields
    ValidationMiddleware::validateRequired($input, ['email', 'password']);
    
    // Sanitize input
    $input = ValidationMiddleware::sanitizeInput($input);
    
    try {
        // Find user by email
        $user = $userModel->findByEmail($input['email']);
        
        if (!$user) {
            ResponseHelper::error('Invalid email or password', 401);
        }
        
        // Verify password
        if (!$userModel->verifyPassword($input['password'], $user['password_hash'])) {
            ResponseHelper::error('Invalid email or password', 401);
        }
        
        // Generate JWT token
        $payload = [
            'user_id' => $user['id'],
            'email' => $user['email'],
            'name' => $user['name']
        ];
        
        $token = JWTHelper::generateToken($payload);
        
        ResponseHelper::success([
            'user' => [
                'id' => $user['id'],
                'name' => $user['name'],
                'email' => $user['email'],
                'phone' => $user['phone']
            ],
            'token' => $token
        ], 'Login successful');
        
    } catch (Exception $e) {
        ResponseHelper::error('Login failed: ' . $e->getMessage(), 500);
    }
}
