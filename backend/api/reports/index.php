<?php
require_once __DIR__ . '/../../config/constants.php';
require_once __DIR__ . '/../../middleware/auth.php';
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
        if (isset($segments[1])) {
            switch ($segments[1]) {
                case 'balance':
                    handleBalanceReport($transactionModel, $currentUser);
                    break;
                case 'summary':
                    handleSummaryReport($transactionModel, $currentUser);
                    break;
                case 'customer':
                    handleCustomerReport($transactionModel, $customerModel, $currentUser);
                    break;
                default:
                    ResponseHelper::error('Report type not found', 404);
            }
        } else {
            ResponseHelper::error('Report type required', 400);
        }
        break;
    
    default:
        ResponseHelper::error('Method not allowed', 405);
        break;
}

function handleBalanceReport($transactionModel, $currentUser) {
    $customerId = $_GET['customer_id'] ?? null;
    
    try {
        $balance = $transactionModel->getBalance($currentUser['user_id'], $customerId);
        
        $response = [
            'balance' => $balance,
            'formatted_balance' => NumberHelper::formatCurrency($balance)
        ];
        
        if ($customerId) {
            $response['customer_id'] = $customerId;
        }
        
        ResponseHelper::success($response);
        
    } catch (Exception $e) {
        ResponseHelper::error('Failed to fetch balance report: ' . $e->getMessage(), 500);
    }
}

function handleSummaryReport($transactionModel, $currentUser) {
    $startDate = $_GET['start_date'] ?? null;
    $endDate = $_GET['end_date'] ?? null;
    
    try {
        $summary = $transactionModel->getTransactionSummary($currentUser['user_id'], $startDate, $endDate);
        
        $response = [
            'period' => [
                'start_date' => $startDate,
                'end_date' => $endDate
            ],
            'summary' => []
        ];
        
        $totalCredit = 0;
        $totalDebit = 0;
        $creditCount = 0;
        $debitCount = 0;
        
        foreach ($summary as $item) {
            $response['summary'][$item['type']] = [
                'count' => (int)$item['count'],
                'total_amount' => (float)$item['total_amount'],
                'formatted_amount' => NumberHelper::formatCurrency($item['total_amount'])
            ];
            
            if ($item['type'] === TRANSACTION_CREDIT) {
                $totalCredit = $item['total_amount'];
                $creditCount = $item['count'];
            } else {
                $totalDebit = $item['total_amount'];
                $debitCount = $item['count'];
            }
        }
        
        $netBalance = $totalCredit - $totalDebit;
        
        $response['totals'] = [
            'total_credit' => $totalCredit,
            'total_debit' => $totalDebit,
            'net_balance' => $netBalance,
            'formatted_net_balance' => NumberHelper::formatCurrency($netBalance),
            'total_transactions' => $creditCount + $debitCount
        ];
        
        ResponseHelper::success($response);
        
    } catch (Exception $e) {
        ResponseHelper::error('Failed to fetch summary report: ' . $e->getMessage(), 500);
    }
}

function handleCustomerReport($transactionModel, $customerModel, $currentUser) {
    $customerId = $_GET['customer_id'] ?? null;
    $startDate = $_GET['start_date'] ?? null;
    $endDate = $_GET['end_date'] ?? null;
    
    if (!$customerId) {
        ResponseHelper::error('Customer ID is required', 400);
    }
    
    try {
        // Get customer details
        $customer = $customerModel->findById($customerId, $currentUser['user_id']);
        
        if (!$customer) {
            ResponseHelper::error('Customer not found', 404);
        }
        
        // Get customer transactions
        $filters = [
            'customer_id' => $customerId,
            'start_date' => $startDate,
            'end_date' => $endDate,
            'page' => 1,
            'limit' => 1000 // Large limit for report
        ];
        
        $transactions = $transactionModel->findByUserId($currentUser['user_id'], $filters);
        
        // Calculate summary
        $totalCredit = 0;
        $totalDebit = 0;
        $creditCount = 0;
        $debitCount = 0;
        
        foreach ($transactions as $transaction) {
            if ($transaction['type'] === TRANSACTION_CREDIT) {
                $totalCredit += $transaction['amount'];
                $creditCount++;
            } else {
                $totalDebit += $transaction['amount'];
                $debitCount++;
            }
        }
        
        $netBalance = $totalCredit - $totalDebit;
        
        $response = [
            'customer' => $customer,
            'period' => [
                'start_date' => $startDate,
                'end_date' => $endDate
            ],
            'summary' => [
                'total_credit' => $totalCredit,
                'total_debit' => $totalDebit,
                'net_balance' => $netBalance,
                'formatted_net_balance' => NumberHelper::formatCurrency($netBalance),
                'credit_count' => $creditCount,
                'debit_count' => $debitCount,
                'total_transactions' => $creditCount + $debitCount
            ],
            'transactions' => $transactions
        ];
        
        ResponseHelper::success($response);
        
    } catch (Exception $e) {
        ResponseHelper::error('Failed to fetch customer report: ' . $e->getMessage(), 500);
    }
}
