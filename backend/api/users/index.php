<?php
require_once __DIR__ . '/../../config/constants.php';
require_once __DIR__ . '/../../middleware/auth.php';
require_once __DIR__ . '/../../middleware/validation.php';
require_once __DIR__ . '/../../models/User.php';
require_once __DIR__ . '/../../utils/helpers.php';

global $method, $segments;

// Authenticate user for all requests
if (!AuthMiddleware::authenticate()) {
    exit();
}

$currentUser = AuthMiddleware::getCurrentUser();
$userModel = new User();

switch ($method) {
    case 'GET':
        if (isset($segments[1]) && is_numeric($segments[1])) {
            handleGetUser($userModel, $segments[1], $currentUser);
        } else {
            handleGetCurrentUser($userModel, $currentUser);
        }
        break;
    
    case 'PUT':
        if (isset($segments[1]) && is_numeric($segments[1])) {
            handleUpdateUser($userModel, $segments[1], $currentUser);
        } else {
            ResponseHelper::error('User ID required', 400);
        }
        break;
    
    case 'DELETE':
        if (isset($segments[1]) && is_numeric($segments[1])) {
            handleDeleteUser($userModel, $segments[1], $currentUser);
        } else {
            ResponseHelper::error('User ID required', 400);
        }
        break;
    
    default:
        ResponseHelper::error('Method not allowed', 405);
        break;
}

function handleGetCurrentUser($userModel, $currentUser) {
    try {
        $user = $userModel->findById($currentUser['user_id']);
        
        if (!$user) {
            ResponseHelper::error('User not found', 404);
        }
        
        ResponseHelper::success($user);
        
    } catch (Exception $e) {
        ResponseHelper::error('Failed to fetch user: ' . $e->getMessage(), 500);
    }
}

function handleGetUser($userModel, $userId, $currentUser) {
    // Users can only access their own data
    if ($userId != $currentUser['user_id']) {
        ResponseHelper::error('Access denied', 403);
    }
    
    try {
        $user = $userModel->findById($userId);
        
        if (!$user) {
            ResponseHelper::error('User not found', 404);
        }
        
        ResponseHelper::success($user);
        
    } catch (Exception $e) {
        ResponseHelper::error('Failed to fetch user: ' . $e->getMessage(), 500);
    }
}

function handleUpdateUser($userModel, $userId, $currentUser) {
    // Users can only update their own data
    if ($userId != $currentUser['user_id']) {
        ResponseHelper::error('Access denied', 403);
    }
    
    $input = json_decode(file_get_contents('php://input'), true);
    
    // Sanitize input
    $input = ValidationMiddleware::sanitizeInput($input);
    
    // Remove fields that shouldn't be updated
    unset($input['id'], $input['created_at'], $input['updated_at']);
    
    try {
        // Validate email if provided
        if (isset($input['email'])) {
            ValidationMiddleware::validateEmail($input['email']);
            
            if ($userModel->emailExists($input['email'], $userId)) {
                ResponseHelper::error('Email already exists', 400);
            }
        }
        
        // Validate phone if provided
        if (isset($input['phone'])) {
            ValidationMiddleware::validatePhone($input['phone']);
            
            if ($userModel->phoneExists($input['phone'], $userId)) {
                ResponseHelper::error('Phone number already exists', 400);
            }
        }
        
        // Validate password if provided
        if (isset($input['password'])) {
            ValidationMiddleware::validatePassword($input['password']);
        }
        
        // Update user
        $updated = $userModel->update($userId, $input);
        
        if (!$updated) {
            ResponseHelper::error('User not found or no changes made', 404);
        }
        
        // Get updated user data
        $user = $userModel->findById($userId);
        
        ResponseHelper::success($user, 'User updated successfully');
        
    } catch (Exception $e) {
        ResponseHelper::error('Failed to update user: ' . $e->getMessage(), 500);
    }
}

function handleDeleteUser($userModel, $userId, $currentUser) {
    // Users can only delete their own account
    if ($userId != $currentUser['user_id']) {
        ResponseHelper::error('Access denied', 403);
    }
    
    try {
        $deleted = $userModel->delete($userId);
        
        if (!$deleted) {
            ResponseHelper::error('User not found', 404);
        }
        
        ResponseHelper::success(null, 'User deleted successfully');
        
    } catch (Exception $e) {
        ResponseHelper::error('Failed to delete user: ' . $e->getMessage(), 500);
    }
}
