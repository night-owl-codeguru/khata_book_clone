<?php

class ValidationMiddleware {
    
    public static function validateRequired($data, $requiredFields) {
        $errors = [];
        
        foreach ($requiredFields as $field) {
            if (!isset($data[$field]) || empty(trim($data[$field]))) {
                $errors[] = "Field '$field' is required";
            }
        }
        
        if (!empty($errors)) {
            http_response_code(400);
            echo json_encode(['error' => 'Validation failed', 'details' => $errors]);
            exit();
        }
    }
    
    public static function validateEmail($email) {
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            http_response_code(400);
            echo json_encode(['error' => 'Invalid email format']);
            exit();
        }
    }
    
    public static function validatePhone($phone) {
        if (!preg_match('/^\+?[1-9]\d{1,14}$/', $phone)) {
            http_response_code(400);
            echo json_encode(['error' => 'Invalid phone number format']);
            exit();
        }
    }
    
    public static function sanitizeInput($data) {
        if (is_array($data)) {
            return array_map([self::class, 'sanitizeInput'], $data);
        }
        
        return htmlspecialchars(strip_tags(trim($data)), ENT_QUOTES, 'UTF-8');
    }
    
    public static function validatePassword($password) {
        if (strlen($password) < 6) {
            http_response_code(400);
            echo json_encode(['error' => 'Password must be at least 6 characters long']);
            exit();
        }
    }
    
    public static function validateAmount($amount) {
        if (!is_numeric($amount) || $amount < 0) {
            http_response_code(400);
            echo json_encode(['error' => 'Amount must be a positive number']);
            exit();
        }
    }
}
