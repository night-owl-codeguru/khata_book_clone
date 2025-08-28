package handlers

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"regexp"
	"time"

	"khata-book-backend/database"
	"khata-book-backend/models"

	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

var jwtSecret []byte

func init() {
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		log.Fatal("JWT_SECRET environment variable is required")
	}
	jwtSecret = []byte(secret)
}

func SignUp(w http.ResponseWriter, r *http.Request) {
	var userReq models.UserRequest

	err := json.NewDecoder(r.Body).Decode(&userReq)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// Validate email format
	emailRegex := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
	if !emailRegex.MatchString(userReq.Email) {
		http.Error(w, "Invalid email format", http.StatusBadRequest)
		return
	}

	// Check if email already exists
	var existingID int
	err = database.DB.QueryRow("SELECT id FROM users WHERE email = ?", userReq.Email).Scan(&existingID)
	if err == nil {
		http.Error(w, "Email already exists", http.StatusConflict)
		return
	}

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(userReq.Password), bcrypt.DefaultCost)
	if err != nil {
		log.Printf("Error hashing password: %v", err)
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	// Insert user into database
	result, err := database.DB.Exec("INSERT INTO users (name, phone, email, address, password_hash) VALUES (?, ?, ?, ?, ?)", userReq.Name, userReq.Phone, userReq.Email, userReq.Address, string(hashedPassword))
	if err != nil {
		log.Printf("Error inserting user: %v", err)
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	// Get the inserted user ID
	userID, err := result.LastInsertId()
	if err != nil {
		log.Printf("Error getting user ID: %v", err)
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	// Generate JWT token
	token, err := generateJWT(int(userID), userReq.Email)
	if err != nil {
		log.Printf("Error generating JWT: %v", err)
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	// Create user object for response
	user := models.User{
		ID:      int(userID),
		Name:    userReq.Name,
		Phone:   userReq.Phone,
		Email:   userReq.Email,
		Address: userReq.Address,
	}

	response := models.LoginResponse{
		Token: token,
		User:  user,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"message": "User created successfully",
		"user":    response.User,
		"token":   response.Token,
	})
}

func Login(w http.ResponseWriter, r *http.Request) {
	var userReq models.UserRequest

	err := json.NewDecoder(r.Body).Decode(&userReq)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// Get user from database
	var user models.User
	err = database.DB.QueryRow("SELECT id, name, phone, email, address, password_hash, created_at FROM users WHERE email = ?", userReq.Email).Scan(&user.ID, &user.Name, &user.Phone, &user.Email, &user.Address, &user.PasswordHash, &user.CreatedAt)
	if err != nil {
		http.Error(w, "Invalid credentials", http.StatusUnauthorized)
		return
	}

	// Verify password
	err = bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(userReq.Password))
	if err != nil {
		http.Error(w, "Invalid credentials", http.StatusUnauthorized)
		return
	}

	// Generate JWT token
	token, err := generateJWT(user.ID, user.Email)
	if err != nil {
		log.Printf("Error generating JWT: %v", err)
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	response := models.LoginResponse{
		Token: token,
		User:  user,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"message": "Login successful",
		"user":    response.User,
		"token":   response.Token,
	})
}

func generateJWT(userID int, email string) (string, error) {
	claims := jwt.MapClaims{
		"user_id": userID,
		"email":   email,
		"exp":     time.Now().Add(24 * time.Hour).Unix(),
		"iat":     time.Now().Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(jwtSecret)
}

func HealthCheck(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	response := map[string]interface{}{
		"status":    "healthy",
		"message":   "Server is ready",
		"timestamp": time.Now().Unix(),
	}
	json.NewEncoder(w).Encode(response)
}

func GetProfile(w http.ResponseWriter, r *http.Request) {
	// Get token from Authorization header
	authHeader := r.Header.Get("Authorization")
	if authHeader == "" || len(authHeader) < 7 || authHeader[:7] != "Bearer " {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	tokenString := authHeader[7:]

	// Parse and validate token
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		return jwtSecret, nil
	})

	if err != nil || !token.Valid {
		http.Error(w, "Invalid token", http.StatusUnauthorized)
		return
	}

	// Get claims
	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		http.Error(w, "Invalid token claims", http.StatusUnauthorized)
		return
	}

	userID := int(claims["user_id"].(float64))

	// Get user from database
	var user models.User
	err = database.DB.QueryRow("SELECT id, name, phone, email, address, created_at FROM users WHERE id = ?", userID).Scan(&user.ID, &user.Name, &user.Phone, &user.Email, &user.Address, &user.CreatedAt)
	if err != nil {
		log.Printf("Error getting user profile: %v", err)
		http.Error(w, "User not found", http.StatusNotFound)
		return
	}

	// Remove password hash from response
	user.PasswordHash = ""

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"user":    user,
	})
}
