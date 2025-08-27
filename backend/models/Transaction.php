<?php
require_once '../config/database.php';

class Transaction {
    private $pdo;

    public function __construct() {
        global $pdo;
        $this->pdo = $pdo;
    }

    // Create a new transaction
    public function create($user_id, $type, $amount, $description = null, $date = null) {
        $date = $date ?: date('Y-m-d H:i:s');
        $sql = "INSERT INTO transactions (user_id, type, amount, description, date, created_at) VALUES (?, ?, ?, ?, ?, NOW())";
        $stmt = $this->pdo->prepare($sql);
        return $stmt->execute([$user_id, $type, $amount, $description, $date]);
    }

    // Get all transactions for a user
    public function getByUserId($user_id) {
        $sql = "SELECT * FROM transactions WHERE user_id = ? ORDER BY date DESC";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute([$user_id]);
        return $stmt->fetchAll();
    }

    // Get all transactions
    public function getAll($limit = null, $offset = 0) {
        $sql = "SELECT t.*, u.name as user_name FROM transactions t
                JOIN users u ON t.user_id = u.id
                ORDER BY t.date DESC";
        if ($limit) {
            $sql .= " LIMIT ? OFFSET ?";
        }
        $stmt = $this->pdo->prepare($sql);
        if ($limit) {
            $stmt->execute([$limit, $offset]);
        } else {
            $stmt->execute();
        }
        return $stmt->fetchAll();
    }

    // Get transaction by ID
    public function getById($id) {
        $sql = "SELECT t.*, u.name as user_name FROM transactions t
                JOIN users u ON t.user_id = u.id
                WHERE t.id = ?";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute([$id]);
        return $stmt->fetch();
    }

    // Update transaction
    public function update($id, $type, $amount, $description = null, $date = null) {
        $sql = "UPDATE transactions SET type = ?, amount = ?, description = ?, date = ? WHERE id = ?";
        $stmt = $this->pdo->prepare($sql);
        return $stmt->execute([$type, $amount, $description, $date, $id]);
    }

    // Delete transaction
    public function delete($id) {
        $sql = "DELETE FROM transactions WHERE id = ?";
        $stmt = $this->pdo->prepare($sql);
        return $stmt->execute([$id]);
    }

    // Get transactions by date range
    public function getByDateRange($start_date, $end_date) {
        $sql = "SELECT t.*, u.name as user_name FROM transactions t
                JOIN users u ON t.user_id = u.id
                WHERE t.date BETWEEN ? AND ?
                ORDER BY t.date DESC";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute([$start_date, $end_date]);
        return $stmt->fetchAll();
    }

    // Get summary statistics
    public function getSummary() {
        $sql = "SELECT
                    COUNT(*) as total_transactions,
                    SUM(CASE WHEN type = 'credit' THEN amount ELSE 0 END) as total_credit,
                    SUM(CASE WHEN type = 'debit' THEN amount ELSE 0 END) as total_debit,
                    SUM(CASE WHEN type = 'credit' THEN amount ELSE 0 END) -
                    SUM(CASE WHEN type = 'debit' THEN amount ELSE 0 END) as net_balance
                FROM transactions";
        $stmt = $this->pdo->query($sql);
        return $stmt->fetch();
    }
}
?>