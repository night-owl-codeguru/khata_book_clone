<?php
require_once __DIR__ . '/JWT.php';

class User {
    private $pdo;

    public function __construct() {
        global $pdo;
        $this->pdo = $pdo;
    }

    // Create a new user with authentication
    public function create($name, $phone, $email = null, $password = null, $address = null) {
        // Check if email already exists
        if ($email && $this->getByEmail($email)) {
            return false;
        }

        $hashedPassword = $password ? password_hash($password, PASSWORD_DEFAULT) : null;

        $sql = "INSERT INTO users (name, phone, email, password, address, created_at) VALUES (?, ?, ?, ?, ?, NOW())";
        $stmt = $this->pdo->prepare($sql);
        return $stmt->execute([$name, $phone, $email, $hashedPassword, $address]);
    }

    // Sign up user
    public function signUp($name, $phone, $email, $password, $address = null) {
        if (empty($name) || empty($phone) || empty($email) || empty($password)) {
            return ['success' => false, 'message' => 'All fields are required'];
        }

        if (strlen($password) < 6) {
            return ['success' => false, 'message' => 'Password must be at least 6 characters'];
        }

        if ($this->getByEmail($email)) {
            return ['success' => false, 'message' => 'Email already exists'];
        }

        $result = $this->create($name, $phone, $email, $password, $address);

        if ($result) {
            $user = $this->getByEmail($email);
            $token = JWT::encode(['user_id' => $user['id'], 'email' => $user['email']]);
            return ['success' => true, 'message' => 'User created successfully', 'token' => $token, 'user' => $user];
        }

        return ['success' => false, 'message' => 'Failed to create user'];
    }

    // Login user
    public function login($email, $password) {
        if (empty($email) || empty($password)) {
            return ['success' => false, 'message' => 'Email and password are required'];
        }

        $user = $this->getByEmail($email);

        if (!$user || !password_verify($password, $user['password'])) {
            return ['success' => false, 'message' => 'Invalid email or password'];
        }

        $token = JWT::encode(['user_id' => $user['id'], 'email' => $user['email']]);
        return ['success' => true, 'message' => 'Login successful', 'token' => $token, 'user' => $user];
    }

    // Get user by email
    public function getByEmail($email) {
        $sql = "SELECT id, name, phone, email, address, created_at, updated_at FROM users WHERE email = ?";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute([$email]);
        return $stmt->fetch();
    }

    // Get all users
    public function getAll() {
        $sql = "SELECT id, name, phone, email, address, created_at, updated_at FROM users ORDER BY name";
        $stmt = $this->pdo->query($sql);
        return $stmt->fetchAll();
    }

    // Get user by ID
    public function getById($id) {
        $sql = "SELECT id, name, phone, email, address, created_at, updated_at FROM users WHERE id = ?";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute([$id]);
        return $stmt->fetch();
    }

    // Update user
    public function update($id, $name, $phone, $email = null, $address = null) {
        $sql = "UPDATE users SET name = ?, phone = ?, email = ?, address = ? WHERE id = ?";
        $stmt = $this->pdo->prepare($sql);
        return $stmt->execute([$name, $phone, $email, $address, $id]);
    }

    // Delete user
    public function delete($id) {
        $sql = "DELETE FROM users WHERE id = ?";
        $stmt = $this->pdo->prepare($sql);
        return $stmt->execute([$id]);
    }

    // Get user balance (total credit - total debit)
    public function getBalance($id) {
        $sql = "SELECT
                    COALESCE(SUM(CASE WHEN type = 'credit' THEN amount ELSE 0 END), 0) -
                    COALESCE(SUM(CASE WHEN type = 'debit' THEN amount ELSE 0 END), 0) as balance
                FROM transactions
                WHERE user_id = ?";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute([$id]);
        $result = $stmt->fetch();
        return $result['balance'];
    }
}
?>