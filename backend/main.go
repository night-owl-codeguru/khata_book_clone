package main

import (
	// "log"
	"net/http"
	"os"

	"khata-book-backend/database"
	"khata-book-backend/handlers"
	"khata-book-backend/pkg/logger"

	"github.com/gorilla/mux"
	"github.com/joho/godotenv"
)

func main() {
	// Load environment variables from .env file if it exists (for local development)
	err := godotenv.Load()
	if err != nil {
		logger.L.WithField("stage", "env_load").Warn("No .env file found, using environment variables from environment")
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
	r.HandleFunc("/api/health", handlers.HealthCheck).Methods("GET")
	r.HandleFunc("/api/profile", handlers.GetProfile).Methods("GET")
	r.HandleFunc("/api/dashboard", handlers.GetDashboardSummary).Methods("GET")

	// Catch-all OPTIONS handler for CORS preflight requests
	r.PathPrefix("/").Methods("OPTIONS").HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// The corsMiddleware will already have set the necessary headers.
		w.WriteHeader(http.StatusOK)
	})

	// Get server port
	port := os.Getenv("SERVER_PORT")
	if port == "" {
		port = "8080"
	}

	logger.L.WithField("port", port).Info("Server starting")
	logger.L.Fatal(http.ListenAndServe(":"+port, r))
}

func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Set CORS headers
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Requested-With, X-User-ID")
		w.Header().Set("Access-Control-Max-Age", "3600")

		// Handle preflight OPTIONS requests
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}
