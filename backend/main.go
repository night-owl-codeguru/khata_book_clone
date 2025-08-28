package main

import (
	"log"
	"net/http"
	"os"

	"khata-book-backend/database"
	"khata-book-backend/handlers"

	"github.com/gorilla/mux"
	"github.com/joho/godotenv"
)

func main() {
	// Load environment variables from .env file if it exists (for local development)
	err := godotenv.Load()
	if err != nil {
		log.Println("No .env file found, using environment variables from Render")
	}

	// Initialize database
	database.InitDB()

	// Create router
	r := mux.NewRouter()

	// Add CORS middleware
	r.Use(corsMiddleware)

	// Define routes
	r.HandleFunc("/api/signup", handlers.SignUp).Methods("POST")
	r.HandleFunc("/api/login", handlers.Login).Methods("POST")

	// Get server port
	port := os.Getenv("SERVER_PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Server starting on port %s", port)
	log.Fatal(http.ListenAndServe(":"+port, r))
}

func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}
