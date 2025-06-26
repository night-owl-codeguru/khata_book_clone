<?php
require_once __DIR__ . '/vendor/autoload.php';
require_once __DIR__ . '/config/database.php';
require_once __DIR__ . '/config/cors.php';

// Load environment variables
$dotenv = Dotenv\Dotenv::createImmutable(__DIR__);
$dotenv->load();

// Set error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Set content type
header('Content-Type: application/json');

// Handle CORS
handleCORS();

// Get request method and URI
$method = $_SERVER['REQUEST_METHOD'];
$uri = $_SERVER['REQUEST_URI'];

// Remove query string and decode URI
$uri = strtok($uri, '?');
$uri = urldecode($uri);

// Remove base path if exists
$basePath = '/api';
if (strpos($uri, $basePath) === 0) {
    $uri = substr($uri, strlen($basePath));
}

// Split URI into segments
$segments = explode('/', trim($uri, '/'));

// Route the request
try {
    if (empty($segments[0])) {
        http_response_code(200);
        echo json_encode(['message' => 'KhataBook API v1.0', 'status' => 'running']);
        exit;
    }

    $controller = $segments[0];
    $action = isset($segments[1]) ? $segments[1] : 'index';
    $id = isset($segments[2]) ? $segments[2] : null;

    // Route to appropriate controller
    switch ($controller) {
        case 'auth':
            require_once __DIR__ . '/api/auth/index.php';
            break;
        case 'users':
            require_once __DIR__ . '/api/users/index.php';
            break;
        case 'customers':
            require_once __DIR__ . '/api/customers/index.php';
            break;
        case 'transactions':
            require_once __DIR__ . '/api/transactions/index.php';  
            break;
        case 'reports':
            require_once __DIR__ . '/api/reports/index.php';
            break;
        default:
            http_response_code(404);
            echo json_encode(['error' => 'Endpoint not found']);
            break;
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Internal server error', 'message' => $e->getMessage()]);
}
