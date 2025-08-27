<?php
// Load environment variables if .env file exists
if (file_exists('.env')) {
    $env = parse_ini_file('.env');
    foreach ($env as $key => $value) {
        putenv("$key=$value");
    }
}

// Include the API routes
require_once 'routes/api.php';
?>