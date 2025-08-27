<?php
require_once '../models/Transaction.php';

class TransactionController {
    private $transaction;

    public function __construct() {
        $this->transaction = new Transaction();
    }

    // Get all transactions
    public function index() {
        $limit = $_GET['limit'] ?? null;
        $offset = $_GET['offset'] ?? 0;
        $transactions = $this->transaction->getAll($limit, $offset);
        echo json_encode(['success' => true, 'data' => $transactions]);
    }

    // Get transaction by ID
    public function show($id) {
        $transaction = $this->transaction->getById($id);
        if ($transaction) {
            echo json_encode(['success' => true, 'data' => $transaction]);
        } else {
            http_response_code(404);
            echo json_encode(['success' => false, 'message' => 'Transaction not found']);
        }
    }

    // Get transactions by user ID
    public function getByUser($user_id) {
        $transactions = $this->transaction->getByUserId($user_id);
        echo json_encode(['success' => true, 'data' => $transactions]);
    }

    // Create new transaction
    public function create() {
        $data = json_decode(file_get_contents('php://input'), true);

        if (!isset($data['user_id']) || !isset($data['type']) || !isset($data['amount'])) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'User ID, type, and amount are required']);
            return;
        }

        if (!in_array($data['type'], ['credit', 'debit'])) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Type must be credit or debit']);
            return;
        }

        $result = $this->transaction->create(
            $data['user_id'],
            $data['type'],
            $data['amount'],
            $data['description'] ?? null,
            $data['date'] ?? null
        );

        if ($result) {
            echo json_encode(['success' => true, 'message' => 'Transaction created successfully']);
        } else {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Failed to create transaction']);
        }
    }

    // Update transaction
    public function update($id) {
        $data = json_decode(file_get_contents('php://input'), true);

        if (!isset($data['type']) || !isset($data['amount'])) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Type and amount are required']);
            return;
        }

        if (!in_array($data['type'], ['credit', 'debit'])) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Type must be credit or debit']);
            return;
        }

        $result = $this->transaction->update(
            $id,
            $data['type'],
            $data['amount'],
            $data['description'] ?? null,
            $data['date'] ?? null
        );

        if ($result) {
            echo json_encode(['success' => true, 'message' => 'Transaction updated successfully']);
        } else {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Failed to update transaction']);
        }
    }

    // Delete transaction
    public function delete($id) {
        $result = $this->transaction->delete($id);

        if ($result) {
            echo json_encode(['success' => true, 'message' => 'Transaction deleted successfully']);
        } else {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Failed to delete transaction']);
        }
    }

    // Get transactions by date range
    public function getByDateRange() {
        $start_date = $_GET['start_date'] ?? date('Y-m-d', strtotime('-30 days'));
        $end_date = $_GET['end_date'] ?? date('Y-m-d');

        $transactions = $this->transaction->getByDateRange($start_date, $end_date);
        echo json_encode(['success' => true, 'data' => $transactions]);
    }

    // Get summary statistics
    public function getSummary() {
        $summary = $this->transaction->getSummary();
        echo json_encode(['success' => true, 'data' => $summary]);
    }
}
?>