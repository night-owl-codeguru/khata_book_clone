<?php
require_once __DIR__ . '/../../config/database.php';

class Customer {
    private $db;
    
    public function __construct() {
        $this->db = Database::getInstance();
    }
    
    public function create($data) {
        $data['created_at'] = date('Y-m-d H:i:s');
        $data['updated_at'] = date('Y-m-d H:i:s');
        
        return $this->db->insert('customers', $data);
    }
    
    public function findById($id, $userId) {
        return $this->db->fetch(
            'SELECT * FROM customers WHERE id = ? AND user_id = ?',
            [$id, $userId]
        );
    }
    
    public function findByUserId($userId, $page = 1, $limit = 20, $search = '') {
        $offset = ($page - 1) * $limit;
        
        $sql = 'SELECT * FROM customers WHERE user_id = ?';
        $params = [$userId];
        
        if (!empty($search)) {
            $sql .= ' AND (name LIKE ? OR phone LIKE ? OR email LIKE ?)';
            $searchTerm = "%$search%";
            $params[] = $searchTerm;
            $params[] = $searchTerm;
            $params[] = $searchTerm;
        }
        
        $sql .= ' ORDER BY name ASC LIMIT ? OFFSET ?';
        $params[] = $limit;
        $params[] = $offset;
        
        return $this->db->fetchAll($sql, $params);
    }
    
    public function getCount($userId, $search = '') {
        $sql = 'SELECT COUNT(*) as count FROM customers WHERE user_id = ?';
        $params = [$userId];
        
        if (!empty($search)) {
            $sql .= ' AND (name LIKE ? OR phone LIKE ? OR email LIKE ?)';
            $searchTerm = "%$search%";
            $params[] = $searchTerm;
            $params[] = $searchTerm;
            $params[] = $searchTerm;
        }
        
        $result = $this->db->fetch($sql, $params);
        return $result['count'];
    }
    
    public function update($id, $userId, $data) {
        $data['updated_at'] = date('Y-m-d H:i:s');
        
        return $this->db->update('customers', $data, 'id = ? AND user_id = ?', [$id, $userId]);
    }
    
    public function delete($id, $userId) {
        return $this->db->delete('customers', 'id = ? AND user_id = ?', [$id, $userId]);
    }
    
    public function getBalance($customerId) {
        $sql = '
            SELECT 
                COALESCE(SUM(CASE WHEN type = "credit" THEN amount ELSE -amount END), 0) as balance
            FROM transactions 
            WHERE customer_id = ?
        ';
        
        $result = $this->db->fetch($sql, [$customerId]);
        return $result['balance'];
    }
    
    public function getCustomersWithBalance($userId, $page = 1, $limit = 20) {
        $offset = ($page - 1) * $limit;
        
        $sql = '
            SELECT 
                c.*,
                COALESCE(SUM(CASE WHEN t.type = "credit" THEN t.amount ELSE -t.amount END), 0) as balance
            FROM customers c
            LEFT JOIN transactions t ON c.id = t.customer_id
            WHERE c.user_id = ?
            GROUP BY c.id
            ORDER BY c.name ASC
            LIMIT ? OFFSET ?
        ';
        
        return $this->db->fetchAll($sql, [$userId, $limit, $offset]);
    }
    
    public function phoneExists($phone, $userId, $excludeId = null) {
        $sql = 'SELECT COUNT(*) as count FROM customers WHERE phone = ? AND user_id = ?';
        $params = [$phone, $userId];
        
        if ($excludeId) {
            $sql .= ' AND id != ?';
            $params[] = $excludeId;
        }
        
        $result = $this->db->fetch($sql, $params);
        return $result['count'] > 0;
    }
}
