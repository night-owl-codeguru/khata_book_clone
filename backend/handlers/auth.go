package handlers

import (
	"database/sql"
	"encoding/json"
	"net/http"
	"os"
	"regexp"
	"strings"
	"time"

	"khata-book-backend/database"
	"khata-book-backend/models"
	"khata-book-backend/pkg/logger"

	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

var jwtSecret []byte

// writeJSON writes a JSON response with headers
func writeJSON(w http.ResponseWriter, status int, payload interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(payload)
}

func init() {
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		logger.L.Fatal("JWT_SECRET environment variable is required")
	}
	jwtSecret = []byte(secret)
}

func SignUp(w http.ResponseWriter, r *http.Request) {
	var userReq models.UserRequest

	err := json.NewDecoder(r.Body).Decode(&userReq)
	if err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]interface{}{"success": false, "error": "invalid_request", "message": "Invalid request body"})
		return
	}

	// Validate email format
	emailRegex := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
	if !emailRegex.MatchString(userReq.Email) {
		writeJSON(w, http.StatusBadRequest, map[string]interface{}{"success": false, "error": "invalid_email", "message": "Invalid email format"})
		return
	}

	phoneRegex := regexp.MustCompile(`^[0-9+()\-\s]{6,20}$`)
	if userReq.Phone != "" && !phoneRegex.MatchString(userReq.Phone) {
		writeJSON(w, http.StatusBadRequest, map[string]interface{}{"success": false, "error": "invalid_phone", "message": "Invalid phone number"})
		return
	}

	// Check if email or phone already exists (use index enforcement too)
	var existingID int
	err = database.DB.QueryRow(`SELECT id FROM users WHERE email = ? LIMIT 1`, userReq.Email).Scan(&existingID)
	if err == nil {
		logger.L.WithField("email", userReq.Email).Warn("Signup attempt with existing email")
		writeJSON(w, http.StatusConflict, map[string]interface{}{"success": false, "error": "email_exists", "message": "Email already registered"})
		return
	} else if err != sql.ErrNoRows {
		logger.L.WithField("error", err).Error("Database error checking existing email")
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not process request"})
		return
	}

	if userReq.Phone != "" {
		err = database.DB.QueryRow(`SELECT id FROM users WHERE phone = ? LIMIT 1`, userReq.Phone).Scan(&existingID)
		if err == nil {
			logger.L.WithField("phone", userReq.Phone).Warn("Signup attempt with existing phone")
			writeJSON(w, http.StatusConflict, map[string]interface{}{"success": false, "error": "phone_exists", "message": "Phone number already registered"})
			return
		} else if err != sql.ErrNoRows {
			logger.L.WithField("error", err).Error("Database error checking existing phone")
			writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not process request"})
			return
		}
	}

	// Hash password
	// Hash password
	if len(userReq.Password) < 8 {
		writeJSON(w, http.StatusBadRequest, map[string]interface{}{"success": false, "error": "weak_password", "message": "Password must be at least 8 characters"})
		return
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(userReq.Password), bcrypt.DefaultCost)
	if err != nil {
		logger.L.WithField("error", err).Error("Error hashing password")
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not process request"})
		return
	}

	// Use transaction for create
	tx, err := database.DB.Begin()
	if err != nil {
		logger.L.WithField("error", err).Error("Could not start transaction for user create")
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not process request"})
		return
	}

	result, err := tx.Exec(`INSERT INTO users (name, phone, email, address, password_hash) VALUES (?, ?, ?, ?, ?)`, userReq.Name, userReq.Phone, userReq.Email, userReq.Address, string(hashedPassword))
	if err != nil {
		tx.Rollback()
		// Check if it's a duplicate entry error
		if strings.Contains(err.Error(), "Duplicate entry") || strings.Contains(err.Error(), "UNIQUE constraint") {
			logger.L.WithField("error", err).Warn("Unique constraint violation during user creation")
			if strings.Contains(err.Error(), "email") {
				writeJSON(w, http.StatusConflict, map[string]interface{}{"success": false, "error": "email_exists", "message": "An account with this email already exists"})
				return
			} else if strings.Contains(err.Error(), "phone") {
				writeJSON(w, http.StatusConflict, map[string]interface{}{"success": false, "error": "phone_exists", "message": "An account with this phone number already exists"})
				return
			}
		}
		logger.L.WithField("error", err).Error("Error inserting user")
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not create user"})
		return
	}

	userID, err := result.LastInsertId()
	if err != nil {
		tx.Rollback()
		logger.L.WithField("error", err).Error("Error getting inserted user ID")
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not create user"})
		return
	}

	if err := tx.Commit(); err != nil {
		logger.L.WithField("error", err).Error("Error committing user creation transaction")
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not create user"})
		return
	}

	logger.L.WithFields(map[string]interface{}{"user_id": userID, "email": userReq.Email}).Info("User created successfully")

	// Generate JWT token
	token, err := generateJWT(int(userID), userReq.Email)
	if err != nil {
		logger.L.WithField("error", err).Error("Error generating JWT")
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not create session"})
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

	writeJSON(w, http.StatusCreated, map[string]interface{}{"success": true, "message": "User created successfully", "user": response.User, "token": response.Token})
}

func Login(w http.ResponseWriter, r *http.Request) {
	var userReq models.UserRequest

	err := json.NewDecoder(r.Body).Decode(&userReq)
	if err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]interface{}{"success": false, "error": "invalid_request", "message": "Invalid request body"})
		return
	}

	logger.L.WithField("email", userReq.Email).Info("Login attempt")

	// Check if any users exist in the database
	var userCount int
	err = database.DB.QueryRow("SELECT COUNT(*) FROM users").Scan(&userCount)
	if err != nil {
		logger.L.WithField("error", err).Warn("Error counting users")
	} else {
		logger.L.WithField("count", userCount).Debug("Total users in database")
	}

	// Get user from database
	var user models.User
	var createdAtStr string
	err = database.DB.QueryRow(`
		SELECT id, name, phone, email, address, password_hash, created_at 
		FROM users 
		WHERE email = ?
	`, userReq.Email).Scan(&user.ID, &user.Name, &user.Phone, &user.Email, &user.Address, &user.PasswordHash, &createdAtStr)
	if err != nil {
		logger.L.WithField("error", err).Warn("Database error fetching user by email")
		if err == sql.ErrNoRows {
			logger.L.WithField("email", userReq.Email).Info("No user found for login")
		}
		writeJSON(w, http.StatusUnauthorized, map[string]interface{}{"success": false, "error": "invalid_credentials", "message": "Invalid email or password"})
		return
	}

	// Parse created_at timestamp
	user.CreatedAt, err = time.Parse("2006-01-02 15:04:05", createdAtStr)
	if err != nil {
		logger.L.WithField("error", err).Warn("Error parsing created_at for user, using now as fallback")
		user.CreatedAt = time.Now()
	}

	logger.L.WithFields(map[string]interface{}{"user_id": user.ID, "email": user.Email, "hash_len": len(user.PasswordHash)}).Info("User retrieved for login")

	// Verify password
	err = bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(userReq.Password))
	if err != nil {
		logger.L.WithField("user_id", user.ID).Warn("Password comparison failed")
		writeJSON(w, http.StatusUnauthorized, map[string]interface{}{"success": false, "error": "invalid_credentials", "message": "Invalid email or password"})
		return
	}

	logger.L.WithField("user_id", user.ID).Info("Password verification successful")

	// Generate JWT token
	token, err := generateJWT(user.ID, user.Email)
	if err != nil {
		logger.L.WithField("error", err).Error("Error generating JWT")
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not create session"})
		return
	}

	response := models.LoginResponse{
		Token: token,
		User:  user,
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{"success": true, "message": "Login successful", "user": response.User, "token": response.Token})
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
		writeJSON(w, http.StatusUnauthorized, map[string]interface{}{"success": false, "error": "unauthorized", "message": "Authorization token required"})
		return
	}

	tokenString := authHeader[7:]

	// Parse and validate token
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		return jwtSecret, nil
	})

	if err != nil || !token.Valid {
		writeJSON(w, http.StatusUnauthorized, map[string]interface{}{"success": false, "error": "invalid_token", "message": "Invalid or expired token"})
		return
	}

	// Get claims
	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		writeJSON(w, http.StatusUnauthorized, map[string]interface{}{"success": false, "error": "invalid_token", "message": "Invalid token claims"})
		return
	}

	userID := int(claims["user_id"].(float64))

	// Get user from database
	var user models.User
	var createdAtStr string
	err = database.DB.QueryRow(`
		SELECT id, name, phone, email, address, created_at 
		FROM users 
		WHERE id = ?
	`, userID).Scan(&user.ID, &user.Name, &user.Phone, &user.Email, &user.Address, &createdAtStr)
	if err != nil {
		logger.L.WithField("error", err).Error("Error getting user profile")
		writeJSON(w, http.StatusNotFound, map[string]interface{}{"success": false, "error": "not_found", "message": "User not found"})
		return
	}

	// Parse created_at timestamp
	user.CreatedAt, err = time.Parse("2006-01-02 15:04:05", createdAtStr)
	if err != nil {
		logger.L.WithField("error", err).Warn("Error parsing created_at for profile; using now as fallback")
		user.CreatedAt = time.Now()
	}

	// Remove password hash from response
	user.PasswordHash = ""

	writeJSON(w, http.StatusOK, map[string]interface{}{"success": true, "user": user})
}
