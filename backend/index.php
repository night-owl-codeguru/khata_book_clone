<?php
// Load environment variables if .env file exists
if (file_exists(__DIR__ . '/.env')) {
    $env = parse_ini_file(__DIR__ . '/.env');
    foreach ($env as $key => $value) {
        putenv("$key=$value");
    }
}

// Check if this is an API request
$request_uri = $_SERVER['REQUEST_URI'];
if (strpos($request_uri, '/api') === 0) {
    // Include the API routes
    require_once __DIR__ . '/routes/api.php';
} else {
    // Return API information for root requests
    header('Content-Type: application/json');
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Khata Book API Server',
        'version' => '1.0.0',
        'endpoints' => [
            'users' => '/api/users',
            'transactions' => '/api/transactions',
            'auth' => '/api/auth'
        ],
        'documentation' => 'See README.md for API documentation'
    ]);
}
?>