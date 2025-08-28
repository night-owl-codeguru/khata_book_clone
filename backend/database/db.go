package database

import (
	"database/sql"
	"fmt"
	"os"

	"khata-book-backend/pkg/logger"

	_ "github.com/go-sql-driver/mysql"
	"github.com/joho/godotenv"
)

var DB *sql.DB

func InitDB() {
	// Load environment variables from .env file
	err := godotenv.Load()
	if err != nil {
		logger.L.WithField("error", err).Warn("Could not load .env file")
	}

	// Get environment variables
	host := os.Getenv("DB_HOST")
	port := os.Getenv("DB_PORT")
	user := os.Getenv("DB_USER")
	password := os.Getenv("DB_PASSWORD")
	dbname := os.Getenv("DB_NAME")

	logger.L.WithFields(map[string]interface{}{
		"db_host": host,
		"db_port": port,
		"db_user": user,
		"db_name": dbname,
	}).Info("Database configuration")

	// Create DSN
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?tls=skip-verify", user, password, host, port, dbname)

	// Open database connection
	DB, err = sql.Open("mysql", dsn)
	if err != nil {
		logger.L.WithField("error", err).Fatal("Error opening database")
	}

	// Test the connection
	err = DB.Ping()
	if err != nil {
		logger.L.WithField("error", err).Fatal("Error connecting to database")
	}

	logger.L.Info("Connected to database successfully")

	// Ensure users table exists with required columns and constraints
	createTableQuery := `
		CREATE TABLE IF NOT EXISTS users (
			id INT AUTO_INCREMENT PRIMARY KEY,
			name VARCHAR(255),
			phone VARCHAR(20) UNIQUE,
			email VARCHAR(255) UNIQUE NOT NULL,
			address TEXT,
			password_hash VARCHAR(255) NOT NULL,
			created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
			updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;`

	_, err = DB.Exec(createTableQuery)
	if err != nil {
		logger.L.WithField("error", err).Fatal("Error creating or ensuring users table")
	}

	logger.L.Info("Ensured users table exists")

	// Create customers table
	customersTableQuery := `
		CREATE TABLE IF NOT EXISTS customers (
			id INT AUTO_INCREMENT PRIMARY KEY,
			name VARCHAR(255) NOT NULL,
			phone VARCHAR(20),
			note TEXT,
			user_id INT NOT NULL,
			balance DECIMAL(10,2) DEFAULT 0.00,
			created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
			updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
			FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
			UNIQUE KEY unique_customer_user (name, user_id)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;`

	_, err = DB.Exec(customersTableQuery)
	if err != nil {
		logger.L.WithField("error", err).Fatal("Error creating customers table")
	}

	logger.L.Info("Ensured customers table exists")

	// Create ledger_entries table
	ledgerEntriesTableQuery := `
		CREATE TABLE IF NOT EXISTS ledger_entries (
			id INT AUTO_INCREMENT PRIMARY KEY,
			customer_id INT NOT NULL,
			type ENUM('credit', 'debit') NOT NULL,
			amount DECIMAL(10,2) NOT NULL,
			method ENUM('cash', 'upi', 'bank') NOT NULL,
			note TEXT,
			date DATE NOT NULL,
			user_id INT NOT NULL,
			created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
			updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
			FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
			FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
			INDEX idx_user_date (user_id, date),
			INDEX idx_customer_date (customer_id, date)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;`

	_, err = DB.Exec(ledgerEntriesTableQuery)
	if err != nil {
		logger.L.WithField("error", err).Fatal("Error creating ledger_entries table")
	}

	logger.L.Info("Ensured ledger_entries table exists")

	// Create reminders table
	remindersTableQuery := `
		CREATE TABLE IF NOT EXISTS reminders (
			id INT AUTO_INCREMENT PRIMARY KEY,
			customer_id INT NOT NULL,
			due_amount DECIMAL(10,2) NOT NULL,
			due_date DATE NOT NULL,
			channel ENUM('sms', 'whatsapp', 'email') NOT NULL,
			status ENUM('pending', 'sent', 'snoozed', 'paid') DEFAULT 'pending',
			user_id INT NOT NULL,
			created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
			updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
			FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
			FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
			INDEX idx_user_status (user_id, status),
			INDEX idx_customer_status (customer_id, status)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;`

	_, err = DB.Exec(remindersTableQuery)
	if err != nil {
		logger.L.WithField("error", err).Fatal("Error creating reminders table")
	}

	logger.L.Info("Ensured reminders table exists")
}
