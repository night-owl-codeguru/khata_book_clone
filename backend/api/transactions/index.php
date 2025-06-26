<?php
require_once __DIR__ . '/../../config/constants.php';
require_once __DIR__ . '/../../middleware/auth.php';
require_once __DIR__ . '/../../middleware/validation.php';
require_once __DIR__ . '/../../models/Transaction.php';
require_once __DIR__ . '/../../models/Customer.php';
require_once __DIR__ . '/../../utils/helpers.php';

global $method, $segments;

// Authenticate user for all requests
if (!AuthMiddleware::authenticate()) {
    exit();
}

$currentUser = AuthMiddleware::getCurrentUser();
$transactionModel = new Transaction();
$customerModel = new Customer();

switch ($method) {
    case 'GET':
        if (isset($segments[1]) && is_numeric($segments[1])) {
            handleGetTransaction($transactionModel, $segments[1], $currentUser);
        } else {
            handleGetTransactions($transactionModel, $currentUser);
        }
        break;
    
    case 'POST':
        handleCreateTransaction($transactionModel, $customerModel, $currentUser);
        break;
    
    case 'PUT':
        if (isset($segments[1]) && is_numeric($segments[1])) {
            handleUpdateTransaction($transactionModel, $customerModel, $segments[1], $currentUser);
        } else {
            ResponseHelper::error('Transaction ID required', 400);
        }
        break;
    
    case 'DELETE':
        if (isset($segments[1]) && is_numeric($segments[1])) {
            handleDeleteTransaction($transactionModel, $segments[1], $currentUser);
        } else {
            ResponseHelper::error('Transaction ID required', 400);
        }
        break;
    
    default:
        ResponseHelper::error('Method not allowed', 405);
        break;
}

function handleGetTransactions($transactionModel, $currentUser) {
    $filters = [
        'page' => $_GET['page'] ?? 1,
        'limit' => min($_GET['limit'] ?? DEFAULT_PAGE_SIZE, MAX_PAGE_SIZE),
        'customer_id' => $_GET['customer_id'] ?? null,
        'type' => $_GET['type'] ?? null,
        'start_date' => $_GET['start_date'] ?? null,
        'end_date' => $_GET['end_date'] ?? null,
        'search' => $_GET['search'] ?? ''
    ];
    
    try {
        $transactions = $transactionModel->findByUserId($currentUser['user_id'], $filters);
        $total = $transactionModel->getCount($currentUser['user_id'], $filters);
        
        $response = ResponseHelper::paginated($transactions, $total, $filters['page'], $filters['limit']);
        
        ResponseHelper::success($response);
        
    } catch (Exception $e) {
        ResponseHelper::error('Failed to fetch transactions: ' . $e->getMessage(), 500);
    }
}

function handleGetTransaction($transactionModel, $transactionId, $currentUser) {
    try {
        $transaction = $transactionModel->findById($transactionId, $currentUser['user_id']);
        
        if (!$transaction) {
            ResponseHelper::error('Transaction not found', 404);
        }
        
        ResponseHelper::success($transaction);
        
    } catch (Exception $e) {
        ResponseHelper::error('Failed to fetch transaction: ' . $e->getMessage(), 500);
    }
}

function handleCreateTransaction($transactionModel, $customerModel, $currentUser) {
    $input = json_decode(file_get_contents('php://input'), true);
    
    // Validate required fields
    ValidationMiddleware::validateRequired($input, ['customer_id', 'type', 'amount', 'description']);
    
    // Sanitize input
    $input = ValidationMiddleware::sanitizeInput($input);
    
    // Validate amount
    ValidationMiddleware::validateAmount($input['amount']);
    
    // Validate type
    if (!in_array($input['type'], [TRANSACTION_CREDIT, TRANSACTION_DEBIT])) {
        ResponseHelper::error('Invalid transaction type. Must be credit or debit', 400);
    }
    
    // Validate date if provided
    if (isset($input['date']) && !DateHelper::isValidDate($input['date'])) {
        ResponseHelper::error('Invalid date format. Use YYYY-MM-DD', 400);
    }
    
    try {
        // Verify customer exists and belongs to user
        $customer = $customerModel->findById($input['customer_id'], $currentUser['user_id']);
        if (!$customer) {
            ResponseHelper::error('Customer not found', 404);
        }
        
        // Prepare data
        $data = [
            'user_id' => $currentUser['user_id'],
            'customer_id' => $input['customer_id'],
            'type' => $input['type'],
            'amount' => $input['amount'],
            'description' => $input['description'],
            'category' => $input['category'] ?? null,
            'date' => $input['date'] ?? date('Y-m-d'),
            'image_url' => $input['image_url'] ?? null
        ];
        
        // Create transaction
        $transactionId = $transactionModel->create($data);
        
        // Get created transaction
        $transaction = $transactionModel->findById($transactionId, $currentUser['user_id']);
        
        ResponseHelper::success($transaction, 'Transaction created successfully', 201);
        
    } catch (Exception $e) {
        ResponseHelper::error('Failed to create transaction: ' . $e->getMessage(), 500);
    }
}

function handleUpdateTransaction($transactionModel, $customerModel, $transactionId, $currentUser) {
    $input = json_decode(file_get_contents('php://input'), true);
    
    // Sanitize input
    $input = ValidationMiddleware::sanitizeInput($input);
    
    // Remove fields that shouldn't be updated
    unset($input['id'], $input['user_id'], $input['created_at'], $input['updated_at']);
    
    try {
        // Validate amount if provided
        if (isset($input['amount'])) {
            ValidationMiddleware::validateAmount($input['amount']);
        }
        
        // Validate type if provided
        if (isset($input['type']) && !in_array($input['type'], [TRANSACTION_CREDIT, TRANSACTION_DEBIT])) {
            ResponseHelper::error('Invalid transaction type. Must be credit or debit', 400);
        }
        
        // Validate date if provided
        if (isset($input['date']) && !DateHelper::isValidDate($input['date'])) {
            ResponseHelper::error('Invalid date format. Use YYYY-MM-DD', 400);
        }
        
        // Verify customer exists and belongs to user if customer_id is being updated
        if (isset($input['customer_id'])) {
            $customer = $customerModel->findById($input['customer_id'], $currentUser['user_id']);
            if (!$customer) {
                ResponseHelper::error('Customer not found', 404);
            }
        }
        
        // Update transaction
        $updated = $transactionModel->update($transactionId, $currentUser['user_id'], $input);
        
        if (!$updated) {
            ResponseHelper::error('Transaction not found or no changes made', 404);
        }
        
        // Get updated transaction
        $transaction = $transactionModel->findById($transactionId, $currentUser['user_id']);
        
        ResponseHelper::success($transaction, 'Transaction updated successfully');
        
    } catch (Exception $e) {
        ResponseHelper::error('Failed to update transaction: ' . $e->getMessage(), 500);
    }
}

function handleDeleteTransaction($transactionModel, $transactionId, $currentUser) {
    try {
        $deleted = $transactionModel->delete($transactionId, $currentUser['user_id']);
        
        if (!$deleted) {
            ResponseHelper::error('Transaction not found', 404);
        }
        
        ResponseHelper::success(null, 'Transaction deleted successfully');
        
    } catch (Exception $e) {
        ResponseHelper::error('Failed to delete transaction: ' . $e->getMessage(), 500);
    }
}
