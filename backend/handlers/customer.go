package handlers

import (
	"database/sql"
	"encoding/json"
	"net/http"
	"strconv"
	"time"

	"khata-book-backend/database"
	"khata-book-backend/models"
	"khata-book-backend/pkg/logger"
)

// GetCustomers retrieves all customers for the authenticated user
func GetCustomers(w http.ResponseWriter, r *http.Request) {
	// Get user ID from JWT token
	userID, err := getUserIDFromToken(r)
	if err != nil {
		writeJSON(w, http.StatusUnauthorized, map[string]interface{}{"success": false, "error": "unauthorized", "message": "Invalid token"})
		return
	}

	// Query customers
	rows, err := database.DB.Query(`
		SELECT id, name, phone, note, balance, created_at, updated_at
		FROM customers
		WHERE user_id = ?
		ORDER BY name ASC`, userID)
	if err != nil {
		logger.L.WithField("error", err).Error("Error querying customers")
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not fetch customers"})
		return
	}
	defer rows.Close()

	var customers []map[string]interface{}
	for rows.Next() {
		var customer models.Customer
		var phone sql.NullString
		var note sql.NullString
		var createdAtStr, updatedAtStr string

		err := rows.Scan(
			&customer.ID, &customer.Name, &phone, &note,
			&customer.Balance, &createdAtStr, &updatedAtStr,
		)
		if err != nil {
			logger.L.WithField("error", err).Error("Error scanning customer")
			continue
		}

		if phone.Valid {
			customer.Phone = &phone.String
		}
		if note.Valid {
			customer.Note = &note.String
		}

		customer.CreatedAt, _ = time.Parse("2006-01-02 15:04:05", createdAtStr)
		customer.UpdatedAt, _ = time.Parse("2006-01-02 15:04:05", updatedAtStr)

		customerMap := map[string]interface{}{
			"id":         customer.ID,
			"name":       customer.Name,
			"phone":      customer.Phone,
			"note":       customer.Note,
			"balance":    customer.Balance,
			"created_at": createdAtStr,
			"updated_at": updatedAtStr,
		}
		customers = append(customers, customerMap)
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{
		"success":   true,
		"customers": customers,
	})
}

// CreateCustomer creates a new customer for the authenticated user
func CreateCustomer(w http.ResponseWriter, r *http.Request) {
	// Get user ID from JWT token
	userID, err := getUserIDFromToken(r)
	if err != nil {
		writeJSON(w, http.StatusUnauthorized, map[string]interface{}{"success": false, "error": "unauthorized", "message": "Invalid token"})
		return
	}

	var customerReq models.CustomerRequest
	err = json.NewDecoder(r.Body).Decode(&customerReq)
	if err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]interface{}{"success": false, "error": "invalid_request", "message": "Invalid request body"})
		return
	}

	// Validate required fields
	if customerReq.Name == "" {
		writeJSON(w, http.StatusBadRequest, map[string]interface{}{"success": false, "error": "invalid_name", "message": "Customer name is required"})
		return
	}

	// Insert customer
	result, err := database.DB.Exec(`
		INSERT INTO customers (name, phone, note, balance, user_id)
		VALUES (?, ?, ?, ?, ?)`,
		customerReq.Name, customerReq.Phone, customerReq.Note, customerReq.Balance, userID)
	if err != nil {
		logger.L.WithField("error", err).Error("Error inserting customer")
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not create customer"})
		return
	}

	customerID, err := result.LastInsertId()
	if err != nil {
		logger.L.WithField("error", err).Error("Error getting inserted customer ID")
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not create customer"})
		return
	}

	logger.L.WithFields(map[string]interface{}{
		"customer_id": customerID,
		"user_id":     userID,
		"name":        customerReq.Name,
	}).Info("Customer created successfully")

	// Create response customer
	customer := models.Customer{
		ID:        int(customerID),
		Name:      customerReq.Name,
		Phone:     customerReq.Phone,
		Note:      customerReq.Note,
		Balance:   customerReq.Balance,
		UserID:    userID,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	writeJSON(w, http.StatusCreated, map[string]interface{}{
		"success":  true,
		"message":  "Customer created successfully",
		"customer": customer,
	})
}

// GetCustomer retrieves a specific customer
func GetCustomer(w http.ResponseWriter, r *http.Request) {
	// Get user ID from JWT token
	userID, err := getUserIDFromToken(r)
	if err != nil {
		writeJSON(w, http.StatusUnauthorized, map[string]interface{}{"success": false, "error": "unauthorized", "message": "Invalid token"})
		return
	}

	// Extract customer ID from URL path
	customerIDStr := r.URL.Path[len("/api/customers/"):]
	customerID, err := strconv.Atoi(customerIDStr)
	if err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]interface{}{"success": false, "error": "invalid_id", "message": "Invalid customer ID"})
		return
	}

	// Query the customer
	var customer models.Customer
	var phone sql.NullString
	var note sql.NullString
	var createdAtStr, updatedAtStr string

	err = database.DB.QueryRow(`
		SELECT id, name, phone, note, balance, created_at, updated_at
		FROM customers
		WHERE id = ? AND user_id = ?`, customerID, userID).Scan(
		&customer.ID, &customer.Name, &phone, &note,
		&customer.Balance, &createdAtStr, &updatedAtStr,
	)

	if err != nil {
		if err == sql.ErrNoRows {
			writeJSON(w, http.StatusNotFound, map[string]interface{}{"success": false, "error": "not_found", "message": "Customer not found"})
			return
		}
		logger.L.WithField("error", err).Error("Error querying customer")
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not fetch customer"})
		return
	}

	if phone.Valid {
		customer.Phone = &phone.String
	}
	if note.Valid {
		customer.Note = &note.String
	}

	customer.CreatedAt, _ = time.Parse("2006-01-02 15:04:05", createdAtStr)
	customer.UpdatedAt, _ = time.Parse("2006-01-02 15:04:05", updatedAtStr)

	response := map[string]interface{}{
		"id":         customer.ID,
		"name":       customer.Name,
		"phone":      customer.Phone,
		"note":       customer.Note,
		"balance":    customer.Balance,
		"created_at": createdAtStr,
		"updated_at": updatedAtStr,
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{
		"success":  true,
		"customer": response,
	})
}
