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
}
