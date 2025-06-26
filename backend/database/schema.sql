-- KhataBook Clone Database Schema
-- Create database
CREATE DATABASE IF NOT EXISTS khatabook_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE khatabook_db;

-- Users table
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    profile_image VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    INDEX idx_email (email),
    INDEX idx_phone (phone),
    INDEX idx_active (is_active)
);

-- Customers table
CREATE TABLE customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) NULL,
    address TEXT NULL,
    category VARCHAR(50) NULL,
    credit_limit DECIMAL(15,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_phone (phone),
    INDEX idx_name (name),
    INDEX idx_category (category),
    UNIQUE KEY unique_user_phone (user_id, phone)
);

-- Transactions table
CREATE TABLE transactions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    customer_id INT NOT NULL,
    type ENUM('credit', 'debit') NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(50) NULL,
    date DATE NOT NULL,
    image_url VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_customer_id (customer_id),
    INDEX idx_type (type),
    INDEX idx_date (date),
    INDEX idx_category (category),
    INDEX idx_user_date (user_id, date),
    INDEX idx_customer_date (customer_id, date)
);

-- Insert sample data for testing
INSERT INTO users (name, email, phone, password_hash) VALUES 
('John Doe', 'john@example.com', '+1234567890', '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxkUJqikcgCwsVq7l8PooCp.eSW'), -- password: password123
('Jane Smith', 'jane@example.com', '+0987654321', '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxkUJqikcgCwsVq7l8PooCp.eSW'); -- password: password123

INSERT INTO customers (user_id, name, phone, email, address, category, credit_limit) VALUES 
(1, 'Alice Johnson', '+1111111111', 'alice@example.com', '123 Main St', 'regular', 5000.00),
(1, 'Bob Wilson', '+2222222222', 'bob@example.com', '456 Oak Ave', 'vip', 10000.00),
(1, 'Charlie Brown', '+3333333333', 'charlie@example.com', '789 Pine Rd', 'regular', 3000.00);

INSERT INTO transactions (user_id, customer_id, type, amount, description, category, date) VALUES 
(1, 1, 'credit', 1000.00, 'Product purchase', 'supplies', '2025-06-20'),
(1, 1, 'debit', 500.00, 'Payment received', 'payment', '2025-06-22'),
(1, 2, 'credit', 2000.00, 'Bulk order', 'supplies', '2025-06-21'),
(1, 3, 'credit', 750.00, 'Service charge', 'services', '2025-06-23'),
(1, 2, 'debit', 1000.00, 'Partial payment', 'payment', '2025-06-24');
