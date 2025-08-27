<?php
require_once __DIR__ . '/JWT.php';

class AuthMiddleware {
    public static function validateToken() {
        $userData = JWT::getUserFromToken();

        if (!$userData) {
            http_response_code(401);
            echo json_encode(['success' => false, 'message' => 'Unauthorized - Invalid or missing token']);
            exit();
        }

        return $userData;
    }

    public static function optionalToken() {
        return JWT::getUserFromToken();
    }
}
?>