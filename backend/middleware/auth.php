<?php
require_once __DIR__ . '/../../vendor/autoload.php';

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class AuthMiddleware {
    
    public static function authenticate() {
        $headers = apache_request_headers();
        
        if (!isset($headers['Authorization'])) {
            self::unauthorizedResponse('Authorization header missing');
            return false;
        }
        
        $authHeader = $headers['Authorization'];
        
        if (!preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
            self::unauthorizedResponse('Invalid authorization header format');
            return false;
        }
        
        $token = $matches[1];
        
        try {
            $decoded = JWT::decode($token, new Key($_ENV['JWT_SECRET'], 'HS256'));
            
            // Store user data in global variable for use in controllers
            $GLOBALS['current_user'] = (array) $decoded;
            
            return true;
        } catch (Exception $e) {
            self::unauthorizedResponse('Invalid or expired token');
            return false;
        }
    }
    
    public static function getCurrentUser() {
        return isset($GLOBALS['current_user']) ? $GLOBALS['current_user'] : null;
    }
    
    private static function unauthorizedResponse($message) {
        http_response_code(401);
        echo json_encode(['error' => $message]);
        exit();
    }
}
