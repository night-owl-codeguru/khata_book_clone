<?php
require_once __DIR__ . '/../../config/database.php';

class User {
    private $db;
    
    public function __construct() {
        $this->db = Database::getInstance();
    }
    
    public function create($data) {
        // Hash password
        $data['password_hash'] = password_hash($data['password'], PASSWORD_BCRYPT, ['cost' => $_ENV['BCRYPT_COST']]);
        unset($data['password']);
        
        $data['created_at'] = date('Y-m-d H:i:s');
        $data['updated_at'] = date('Y-m-d H:i:s');
        $data['is_active'] = 1;
        
        return $this->db->insert('users', $data);
    }
    
    public function findByEmail($email) {
        return $this->db->fetch(
            'SELECT * FROM users WHERE email = ? AND is_active = 1',
            [$email]
        );
    }
    
    public function findByPhone($phone) {
        return $this->db->fetch(
            'SELECT * FROM users WHERE phone = ? AND is_active = 1',
            [$phone]
        );
    }
    
    public function findById($id) {
        return $this->db->fetch(
            'SELECT id, name, email, phone, profile_image, created_at, updated_at FROM users WHERE id = ? AND is_active = 1',
            [$id]
        );
    }
    
    public function verifyPassword($password, $hash) {
        return password_verify($password, $hash);
    }
    
    public function update($id, $data) {
        $data['updated_at'] = date('Y-m-d H:i:s');
        
        if (isset($data['password'])) {
            $data['password_hash'] = password_hash($data['password'], PASSWORD_BCRYPT, ['cost' => $_ENV['BCRYPT_COST']]);
            unset($data['password']);
        }
        
        return $this->db->update('users', $data, 'id = ?', [$id]);
    }
    
    public function delete($id) {
        return $this->db->update('users', ['is_active' => 0], 'id = ?', [$id]);
    }
    
    public function emailExists($email, $excludeId = null) {
        $sql = 'SELECT COUNT(*) as count FROM users WHERE email = ? AND is_active = 1';
        $params = [$email];
        
        if ($excludeId) {
            $sql .= ' AND id != ?';
            $params[] = $excludeId;
        }
        
        $result = $this->db->fetch($sql, $params);
        return $result['count'] > 0;
    }
    
    public function phoneExists($phone, $excludeId = null) {
        $sql = 'SELECT COUNT(*) as count FROM users WHERE phone = ? AND is_active = 1';
        $params = [$phone];
        
        if ($excludeId) {
            $sql .= ' AND id != ?';
            $params[] = $excludeId;
        }
        
        $result = $this->db->fetch($sql, $params);
        return $result['count'] > 0;
    }
}
