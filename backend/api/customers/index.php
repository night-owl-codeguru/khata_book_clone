<?php
require_once __DIR__ . '/../../config/constants.php';
require_once __DIR__ . '/../../middleware/auth.php';
require_once __DIR__ . '/../../middleware/validation.php';
require_once __DIR__ . '/../../models/Customer.php';
require_once __DIR__ . '/../../utils/helpers.php';

global $method, $segments;

// Authenticate user for all requests
if (!AuthMiddleware::authenticate()) {
    exit();
}

$currentUser = AuthMiddleware::getCurrentUser();
$customerModel = new Customer();

switch ($method) {
    case 'GET':
        if (isset($segments[1]) && is_numeric($segments[1])) {
            handleGetCustomer($customerModel, $segments[1], $currentUser);
        } else {
            handleGetCustomers($customerModel, $currentUser);
        }
        break;
    
    case 'POST':
        handleCreateCustomer($customerModel, $currentUser);
        break;
    
    case 'PUT':
        if (isset($segments[1]) && is_numeric($segments[1])) {
            handleUpdateCustomer($customerModel, $segments[1], $currentUser);
        } else {
            ResponseHelper::error('Customer ID required', 400);
        }
        break;
    
    case 'DELETE':
        if (isset($segments[1]) && is_numeric($segments[1])) {
            handleDeleteCustomer($customerModel, $segments[1], $currentUser);
        } else {
            ResponseHelper::error('Customer ID required', 400);
        }
        break;
    
    default:
        ResponseHelper::error('Method not allowed', 405);
        break;
}

function handleGetCustomers($customerModel, $currentUser) {
    $page = $_GET['page'] ?? 1;
    $limit = min($_GET['limit'] ?? DEFAULT_PAGE_SIZE, MAX_PAGE_SIZE);
    $search = $_GET['search'] ?? '';
    $withBalance = $_GET['with_balance'] ?? false;
    
    try {
        if ($withBalance) {
            $customers = $customerModel->getCustomersWithBalance($currentUser['user_id'], $page, $limit);
        } else {
            $customers = $customerModel->findByUserId($currentUser['user_id'], $page, $limit, $search);
        }
        
        $total = $customerModel->getCount($currentUser['user_id'], $search);
        
        $response = ResponseHelper::paginated($customers, $total, $page, $limit);
        
        ResponseHelper::success($response);
        
    } catch (Exception $e) {
        ResponseHelper::error('Failed to fetch customers: ' . $e->getMessage(), 500);
    }
}

function handleGetCustomer($customerModel, $customerId, $currentUser) {
    try {
        $customer = $customerModel->findById($customerId, $currentUser['user_id']);
        
        if (!$customer) {
            ResponseHelper::error('Customer not found', 404);
        }
        
        // Get customer balance
        $balance = $customerModel->getBalance($customerId);
        $customer['balance'] = $balance;
        
        ResponseHelper::success($customer);
        
    } catch (Exception $e) {
        ResponseHelper::error('Failed to fetch customer: ' . $e->getMessage(), 500);
    }
}

function handleCreateCustomer($customerModel, $currentUser) {
    $input = json_decode(file_get_contents('php://input'), true);
    
    // Validate required fields
    ValidationMiddleware::validateRequired($input, ['name', 'phone']);
    
    // Sanitize input
    $input = ValidationMiddleware::sanitizeInput($input);
    
    // Validate phone
    ValidationMiddleware::validatePhone($input['phone']);
    
    // Validate email if provided
    if (!empty($input['email'])) {
        ValidationMiddleware::validateEmail($input['email']);
    }
    
    try {
        // Check if phone already exists for this user
        if ($customerModel->phoneExists($input['phone'], $currentUser['user_id'])) {
            ResponseHelper::error('Customer with this phone number already exists', 400);
        }
        
        // Prepare data
        $data = [
            'user_id' => $currentUser['user_id'],
            'name' => $input['name'],
            'phone' => $input['phone'],
            'email' => $input['email'] ?? null,
            'address' => $input['address'] ?? null,
            'category' => $input['category'] ?? null,
            'credit_limit' => $input['credit_limit'] ?? 0
        ];
        
        // Create customer
        $customerId = $customerModel->create($data);
        
        // Get created customer
        $customer = $customerModel->findById($customerId, $currentUser['user_id']);
        
        ResponseHelper::success($customer, 'Customer created successfully', 201);
        
    } catch (Exception $e) {
        ResponseHelper::error('Failed to create customer: ' . $e->getMessage(), 500);
    }
}

function handleUpdateCustomer($customerModel, $customerId, $currentUser) {
    $input = json_decode(file_get_contents('php://input'), true);
    
    // Sanitize input
    $input = ValidationMiddleware::sanitizeInput($input);
    
    // Remove fields that shouldn't be updated
    unset($input['id'], $input['user_id'], $input['created_at'], $input['updated_at']);
    
    try {
        // Validate phone if provided
        if (isset($input['phone'])) {
            ValidationMiddleware::validatePhone($input['phone']);
            
            if ($customerModel->phoneExists($input['phone'], $currentUser['user_id'], $customerId)) {
                ResponseHelper::error('Customer with this phone number already exists', 400);
            }
        }
        
        // Validate email if provided
        if (isset($input['email']) && !empty($input['email'])) {
            ValidationMiddleware::validateEmail($input['email']);
        }
        
        // Update customer
        $updated = $customerModel->update($customerId, $currentUser['user_id'], $input);
        
        if (!$updated) {
            ResponseHelper::error('Customer not found or no changes made', 404);
        }
        
        // Get updated customer
        $customer = $customerModel->findById($customerId, $currentUser['user_id']);
        
        ResponseHelper::success($customer, 'Customer updated successfully');
        
    } catch (Exception $e) {
        ResponseHelper::error('Failed to update customer: ' . $e->getMessage(), 500);
    }
}

function handleDeleteCustomer($customerModel, $customerId, $currentUser) {
    try {
        $deleted = $customerModel->delete($customerId, $currentUser['user_id']);
        
        if (!$deleted) {
            ResponseHelper::error('Customer not found', 404);
        }
        
        ResponseHelper::success(null, 'Customer deleted successfully');
        
    } catch (Exception $e) {
        ResponseHelper::error('Failed to delete customer: ' . $e->getMessage(), 500);
    }
}
