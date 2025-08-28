package database

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	_ "github.com/go-sql-driver/mysql"
	"github.com/joho/godotenv"
)

var DB *sql.DB

func InitDB() {
	// Load environment variables from .env file
	err := godotenv.Load()
	if err != nil {
		log.Printf("Warning: Could not load .env file: %v", err)
	}

	// Get environment variables
	host := os.Getenv("DB_HOST")
	port := os.Getenv("DB_PORT")
	user := os.Getenv("DB_USER")
	password := os.Getenv("DB_PASSWORD")
	dbname := os.Getenv("DB_NAME")

	log.Printf("Database config - Host: %s, Port: %s, User: %s, DB: %s", host, port, user, dbname)

	// Create DSN
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?tls=skip-verify", user, password, host, port, dbname)

	// Open database connection
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

	// Check if we need to recreate the table
	var tableName string
	err = DB.QueryRow("SHOW TABLES LIKE 'users'").Scan(&tableName)
	if err != nil && err != sql.ErrNoRows {
		log.Printf("Error checking table existence: %v", err)
	} else if err == sql.ErrNoRows {
		// Table doesn't exist, create it
		createTableQuery := `
			CREATE TABLE users (
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
		fmt.Println("Created users table successfully")
	} else {
		// Table exists, check if it has the required columns
		fmt.Printf("Table 'users' exists, checking schema...\n")
		var columnCount int
		err = DB.QueryRow("SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = ? AND TABLE_NAME = 'users' AND COLUMN_NAME = 'name'", dbname).Scan(&columnCount)
		if err != nil {
			log.Printf("Error checking columns: %v", err)
			columnCount = 0
		}

		if columnCount == 0 {
			// Drop and recreate table if columns are missing
			fmt.Println("Recreating users table with updated schema...")
			_, err = DB.Exec("DROP TABLE users")
			if err != nil {
				log.Printf("Warning: Could not drop table: %v", err)
			}

			createTableQuery := `
				CREATE TABLE users (
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
				log.Fatal("Error recreating users table: ", err)
			}
			fmt.Println("Recreated users table successfully")
		} else {
			fmt.Println("Users table already exists with correct schema")
		}
	}
}
