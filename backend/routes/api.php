<?php
// Use absolute paths relative to this file so includes work when index.php includes routes
require_once __DIR__ . '/../controllers/UserController.php';
require_once __DIR__ . '/../controllers/TransactionController.php';
require_once __DIR__ . '/../controllers/AuthController.php';

// Set headers for API
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

// Get the request URI and method
$request_uri = $_SERVER['REQUEST_URI'];
$request_method = $_SERVER['REQUEST_METHOD'];

// Remove query string from URI
$uri_parts = explode('?', $request_uri);
$path = $uri_parts[0];

// Only process API routes - if not starting with /api/, return 404
if (strpos($path, '/api') !== 0) {
    http_response_code(404);
    echo json_encode(['success' => false, 'message' => 'API endpoint not found']);
    exit;
}

// Remove the base path (/api/)
$path = str_replace('/api', '', $path);

// Split the path into segments
$path_segments = array_filter(explode('/', $path));

// Route handling
try {
    switch ($path_segments[1] ?? '') {
        case 'auth':
            $authController = new AuthController();
            $action = $path_segments[2] ?? '';

            switch ($request_method) {
                case 'POST':
                    if ($action === 'signup') {
                        $authController->signUp();
                    } elseif ($action === 'login') {
                        $authController->login();
                    } else {
                        throw new Exception('Invalid auth action');
                    }
                    break;
                case 'GET':
                    if ($action === 'profile') {
                        $authController->profile();
                    } else {
                        throw new Exception('Invalid auth action');
                    }
                    break;
                default:
                    throw new Exception('Method not allowed');
            }
            break;

        case 'users':
            $userController = new UserController();
            $user_id = $path_segments[2] ?? null;

            switch ($request_method) {
                case 'GET':
                    if ($user_id) {
                        $userController->show($user_id);
                    } else {
                        $userController->index();
                    }
                    break;
                case 'POST':
                    $userController->create();
                    break;
                case 'PUT':
                    if ($user_id) {
                        $userController->update($user_id);
                    } else {
                        throw new Exception('User ID required for update');
                    }
                    break;
                case 'DELETE':
                    if ($user_id) {
                        $userController->delete($user_id);
                    } else {
                        throw new Exception('User ID required for delete');
                    }
                    break;
                default:
                    throw new Exception('Method not allowed');
            }
            break;

        case 'transactions':
            $transactionController = new TransactionController();
            $transaction_id = $path_segments[2] ?? null;

            switch ($request_method) {
                case 'GET':
                    if ($transaction_id) {
                        $transactionController->show($transaction_id);
                    } elseif (isset($_GET['user_id'])) {
                        $transactionController->getByUser($_GET['user_id']);
                    } elseif (isset($_GET['start_date']) || isset($_GET['end_date'])) {
                        $transactionController->getByDateRange();
                    } elseif (isset($_GET['summary'])) {
                        $transactionController->getSummary();
                    } else {
                        $transactionController->index();
                    }
                    break;
                case 'POST':
                    $transactionController->create();
                    break;
                case 'PUT':
                    if ($transaction_id) {
                        $transactionController->update($transaction_id);
                    } else {
                        throw new Exception('Transaction ID required for update');
                    }
                    break;
                case 'DELETE':
                    if ($transaction_id) {
                        $transactionController->delete($transaction_id);
                    } else {
                        throw new Exception('Transaction ID required for delete');
                    }
                    break;
                default:
                    throw new Exception('Method not allowed');
            }
            break;

        default:
            http_response_code(404);
            echo json_encode(['success' => false, 'message' => 'Endpoint not found']);
            break;
    }
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}
?>