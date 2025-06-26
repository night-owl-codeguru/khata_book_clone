<?php
require_once __DIR__ . '/../../vendor/autoload.php';

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class JWTHelper {
    
    public static function generateToken($payload) {
        $payload['iat'] = time();
        $payload['exp'] = time() + $_ENV['JWT_EXPIRE_TIME'];
        
        return JWT::encode($payload, $_ENV['JWT_SECRET'], 'HS256');
    }
    
    public static function validateToken($token) {
        try {
            return JWT::decode($token, new Key($_ENV['JWT_SECRET'], 'HS256'));
        } catch (Exception $e) {
            return false;
        }
    }
}

class ResponseHelper {
    
    public static function success($data = null, $message = 'Success', $code = 200) {
        http_response_code($code);
        $response = ['success' => true, 'message' => $message];
        
        if ($data !== null) {
            $response['data'] = $data;
        }
        
        echo json_encode($response);
        exit();
    }
    
    public static function error($message = 'Error', $code = 400, $details = null) {
        http_response_code($code);
        $response = ['success' => false, 'error' => $message];
        
        if ($details !== null) {
            $response['details'] = $details;
        }
        
        echo json_encode($response);
        exit();
    }
    
    public static function paginated($data, $total, $page, $limit) {
        $totalPages = ceil($total / $limit);
        
        return [
            'data' => $data,
            'pagination' => [
                'current_page' => (int)$page,
                'per_page' => (int)$limit,
                'total' => (int)$total,
                'total_pages' => $totalPages,
                'has_next' => $page < $totalPages,
                'has_prev' => $page > 1
            ]
        ];
    }
}

class FileHelper {
    
    public static function uploadFile($file, $allowedTypes = ['image/jpeg', 'image/png', 'image/gif']) {
        if (!isset($file) || $file['error'] !== UPLOAD_ERR_OK) {
            throw new Exception('File upload failed');
        }
        
        if (!in_array($file['type'], $allowedTypes)) {
            throw new Exception('Invalid file type');
        }
        
        if ($file['size'] > $_ENV['MAX_FILE_SIZE']) {
            throw new Exception('File size too large');
        }
        
        $uploadDir = __DIR__ . '/../' . $_ENV['UPLOAD_DIR'];
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0755, true);
        }
        
        $extension = pathinfo($file['name'], PATHINFO_EXTENSION);
        $filename = uniqid() . '.' . $extension;
        $filepath = $uploadDir . $filename;
        
        if (!move_uploaded_file($file['tmp_name'], $filepath)) {
            throw new Exception('Failed to save file');
        }
        
        return $_ENV['UPLOAD_DIR'] . $filename;
    }
}

class DateHelper {
    
    public static function formatDate($date, $format = 'Y-m-d H:i:s') {
        return date($format, strtotime($date));
    }
    
    public static function isValidDate($date, $format = 'Y-m-d') {
        $d = DateTime::createFromFormat($format, $date);
        return $d && $d->format($format) === $date;
    }
}

class NumberHelper {
    
    public static function formatCurrency($amount, $currency = '₹') {
        return $currency . number_format($amount, 2);
    }
    
    public static function formatNumber($number, $decimals = 2) {
        return number_format($number, $decimals);
    }
}
