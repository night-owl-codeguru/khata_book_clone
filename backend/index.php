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
$path_info = $_SERVER['PATH_INFO'] ?? '';
$query_string = $_SERVER['QUERY_STRING'] ?? '';

// Handle different URL patterns that might occur on different hosting platforms
$is_api_request = false;

// Check for /api/ in REQUEST_URI
if (strpos($request_uri, '/api') !== false) {
    $is_api_request = true;
}
// Check for api in query string (for some hosting platforms)
elseif (strpos($query_string, 'api') !== false) {
    $is_api_request = true;
}
// Check PATH_INFO for /api/
elseif (strpos($path_info, '/api') !== false) {
    $is_api_request = true;
}
// Check if REQUEST_URI contains api but not at the beginning (some CDNs do this)
elseif (preg_match('/\/api\//', $request_uri)) {
    $is_api_request = true;
}

if ($is_api_request) {
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