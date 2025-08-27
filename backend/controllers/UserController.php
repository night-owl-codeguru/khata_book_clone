<?php
require_once __DIR__ . '/../models/User.php';

class UserController {
    private $user;

    public function __construct() {
        $this->user = new User();
    }

    // Get all users
    public function index() {
        $users = $this->user->getAll();
        echo json_encode(['success' => true, 'data' => $users]);
    }

    // Get user by ID
    public function show($id) {
        $user = $this->user->getById($id);
        if ($user) {
            $user['balance'] = $this->user->getBalance($id);
            echo json_encode(['success' => true, 'data' => $user]);
        } else {
            http_response_code(404);
            echo json_encode(['success' => false, 'message' => 'User not found']);
        }
    }

    // Create new user
    public function create() {
        $data = json_decode(file_get_contents('php://input'), true);

        if (!isset($data['name']) || !isset($data['phone'])) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Name and phone are required']);
            return;
        }

        $result = $this->user->create(
            $data['name'],
            $data['phone'],
            $data['email'] ?? null,
            $data['address'] ?? null
        );

        if ($result) {
            echo json_encode(['success' => true, 'message' => 'User created successfully']);
        } else {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Failed to create user']);
        }
    }

    // Update user
    public function update($id) {
        $data = json_decode(file_get_contents('php://input'), true);

        if (!isset($data['name']) || !isset($data['phone'])) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Name and phone are required']);
            return;
        }

        $result = $this->user->update(
            $id,
            $data['name'],
            $data['phone'],
            $data['email'] ?? null,
            $data['address'] ?? null
        );

        if ($result) {
            echo json_encode(['success' => true, 'message' => 'User updated successfully']);
        } else {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Failed to update user']);
        }
    }

    // Delete user
    public function delete($id) {
        $result = $this->user->delete($id);

        if ($result) {
            echo json_encode(['success' => true, 'message' => 'User deleted successfully']);
        } else {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Failed to delete user']);
        }
    }
}
?>