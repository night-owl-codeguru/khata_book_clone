<?php

// API Configuration
define('API_VERSION', '1.0');
define('API_NAME', 'KhataBook API');

// Response codes
define('HTTP_OK', 200);
define('HTTP_CREATED', 201);
define('HTTP_BAD_REQUEST', 400);
define('HTTP_UNAUTHORIZED', 401);
define('HTTP_FORBIDDEN', 403);
define('HTTP_NOT_FOUND', 404);
define('HTTP_METHOD_NOT_ALLOWED', 405);
define('HTTP_INTERNAL_ERROR', 500);

// Transaction types
define('TRANSACTION_CREDIT', 'credit');
define('TRANSACTION_DEBIT', 'debit');

// User roles
define('ROLE_ADMIN', 'admin');
define('ROLE_USER', 'user');

// Default pagination
define('DEFAULT_PAGE_SIZE', 20);
define('MAX_PAGE_SIZE', 100);
