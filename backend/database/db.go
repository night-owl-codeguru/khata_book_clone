package database

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	_ "github.com/go-sql-driver/mysql"
)

var DB *sql.DB

func InitDB() {
	// Get environment variables
	host := os.Getenv("DB_HOST")
	port := os.Getenv("DB_PORT")
	user := os.Getenv("DB_USER")
	password := os.Getenv("DB_PASSWORD")
	dbname := os.Getenv("DB_NAME")

	// Create DSN
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?tls=skip-verify", user, password, host, port, dbname)

	// Open database connection
	var err error
	DB, err = sql.Open("mysql", dsn)
	if err != nil {
		log.Fatal("Error opening database: ", err)
	}

	// Test the connection
	err = DB.Ping()
	if err != nil {
		log.Fatal("Error connecting to database: ", err)
	}

	fmt.Println("Connected to database successfully")

	// Create users table if it doesn't exist
	createTableQuery := `
	CREATE TABLE IF NOT EXISTS users (
		id INT AUTO_INCREMENT PRIMARY KEY,
		name VARCHAR(255),
		phone VARCHAR(20),
		email VARCHAR(255) UNIQUE NOT NULL,
		address TEXT,
		password_hash VARCHAR(255) NOT NULL,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	)`
	_, err = DB.Exec(createTableQuery)
	if err != nil {
		log.Fatal("Error creating users table: ", err)
	}

	// Add missing columns if they don't exist (for existing databases)
	alterTableQueries := []string{
		`ALTER TABLE users ADD COLUMN IF NOT EXISTS name VARCHAR(255)`,
		`ALTER TABLE users ADD COLUMN IF NOT EXISTS phone VARCHAR(20)`,
		`ALTER TABLE users ADD COLUMN IF NOT EXISTS address TEXT`,
	}

	for _, query := range alterTableQueries {
		_, err = DB.Exec(query)
		if err != nil {
			log.Printf("Warning: Could not alter table: %v", err)
		}
	}
}
