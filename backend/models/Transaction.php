<?php
require_once __DIR__ . '/../../config/database.php';

class Transaction {
    private $db;
    
    public function __construct() {
        $this->db = Database::getInstance();
    }
    
    public function create($data) {
        $data['created_at'] = date('Y-m-d H:i:s');
        $data['updated_at'] = date('Y-m-d H:i:s');
        
        return $this->db->insert('transactions', $data);
    }
    
    public function findById($id, $userId) {
        $sql = '
            SELECT t.*, c.name as customer_name 
            FROM transactions t
            JOIN customers c ON t.customer_id = c.id
            WHERE t.id = ? AND t.user_id = ?
        ';
        
        return $this->db->fetch($sql, [$id, $userId]);
    }
    
    public function findByUserId($userId, $filters = []) {
        $page = $filters['page'] ?? 1;
        $limit = $filters['limit'] ?? 20;
        $customerId = $filters['customer_id'] ?? null;
        $type = $filters['type'] ?? null;
        $startDate = $filters['start_date'] ?? null;
        $endDate = $filters['end_date'] ?? null;
        $search = $filters['search'] ?? '';
        
        $offset = ($page - 1) * $limit;
        
        $sql = '
            SELECT t.*, c.name as customer_name 
            FROM transactions t
            JOIN customers c ON t.customer_id = c.id
            WHERE t.user_id = ?
        ';
        $params = [$userId];
        
        if ($customerId) {
            $sql .= ' AND t.customer_id = ?';
            $params[] = $customerId;
        }
        
        if ($type) {
            $sql .= ' AND t.type = ?';
            $params[] = $type;
        }
        
        if ($startDate) {
            $sql .= ' AND DATE(t.date) >= ?';
            $params[] = $startDate;
        }
        
        if ($endDate) {
            $sql .= ' AND DATE(t.date) <= ?';
            $params[] = $endDate;
        }
        
        if (!empty($search)) {
            $sql .= ' AND (t.description LIKE ? OR c.name LIKE ?)';
            $searchTerm = "%$search%";
            $params[] = $searchTerm;
            $params[] = $searchTerm;
        }
        
        $sql .= ' ORDER BY t.date DESC, t.created_at DESC LIMIT ? OFFSET ?';
        $params[] = $limit;
        $params[] = $offset;
        
        return $this->db->fetchAll($sql, $params);
    }
    
    public function getCount($userId, $filters = []) {
        $customerId = $filters['customer_id'] ?? null;
        $type = $filters['type'] ?? null;
        $startDate = $filters['start_date'] ?? null;
        $endDate = $filters['end_date'] ?? null;
        $search = $filters['search'] ?? '';
        
        $sql = '
            SELECT COUNT(*) as count 
            FROM transactions t
            JOIN customers c ON t.customer_id = c.id
            WHERE t.user_id = ?
        ';
        $params = [$userId];
        
        if ($customerId) {
            $sql .= ' AND t.customer_id = ?';
            $params[] = $customerId;
        }
        
        if ($type) {
            $sql .= ' AND t.type = ?';
            $params[] = $type;
        }
        
        if ($startDate) {
            $sql .= ' AND DATE(t.date) >= ?';
            $params[] = $startDate;
        }
        
        if ($endDate) {
            $sql .= ' AND DATE(t.date) <= ?';
            $params[] = $endDate;
        }
        
        if (!empty($search)) {
            $sql .= ' AND (t.description LIKE ? OR c.name LIKE ?)';
            $searchTerm = "%$search%";
            $params[] = $searchTerm;
            $params[] = $searchTerm;
        }
        
        $result = $this->db->fetch($sql, $params);
        return $result['count'];
    }
    
    public function update($id, $userId, $data) {
        $data['updated_at'] = date('Y-m-d H:i:s');
        
        return $this->db->update('transactions', $data, 'id = ? AND user_id = ?', [$id, $userId]);
    }
    
    public function delete($id, $userId) {
        return $this->db->delete('transactions', 'id = ? AND user_id = ?', [$id, $userId]);
    }
    
    public function getBalance($userId, $customerId = null) {
        $sql = 'SELECT 
                    COALESCE(SUM(CASE WHEN type = "credit" THEN amount ELSE -amount END), 0) as balance
                FROM transactions 
                WHERE user_id = ?';
        $params = [$userId];
        
        if ($customerId) {
            $sql .= ' AND customer_id = ?';
            $params[] = $customerId;
        }
        
        $result = $this->db->fetch($sql, $params);
        return $result['balance'];
    }
    
    public function getTransactionSummary($userId, $startDate = null, $endDate = null) {
        $sql = '
            SELECT 
                type,
                COUNT(*) as count,
                SUM(amount) as total_amount
            FROM transactions 
            WHERE user_id = ?
        ';
        $params = [$userId];
        
        if ($startDate) {
            $sql .= ' AND DATE(date) >= ?';
            $params[] = $startDate;
        }
        
        if ($endDate) {
            $sql .= ' AND DATE(date) <= ?';
            $params[] = $endDate;
        }
        
        $sql .= ' GROUP BY type';
        
        return $this->db->fetchAll($sql, $params);
    }
}
