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

// CreateLedgerEntry creates a new ledger entry (credit or debit)
func CreateLedgerEntry(w http.ResponseWriter, r *http.Request) {
	// Get user ID from JWT token
	userID, err := getUserIDFromToken(r)
	if err != nil {
		writeJSON(w, http.StatusUnauthorized, map[string]interface{}{"success": false, "error": "unauthorized", "message": "Invalid token"})
		return
	}

	var entryReq models.LedgerEntryRequest
	err = json.NewDecoder(r.Body).Decode(&entryReq)
	if err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]interface{}{"success": false, "error": "invalid_request", "message": "Invalid request body"})
		return
	}

	// Validate required fields
	if entryReq.CustomerID <= 0 {
		writeJSON(w, http.StatusBadRequest, map[string]interface{}{"success": false, "error": "invalid_customer", "message": "Valid customer ID is required"})
		return
	}

	if entryReq.Type != "credit" && entryReq.Type != "debit" {
		writeJSON(w, http.StatusBadRequest, map[string]interface{}{"success": false, "error": "invalid_type", "message": "Type must be 'credit' or 'debit'"})
		return
	}

	if entryReq.Amount <= 0 {
		writeJSON(w, http.StatusBadRequest, map[string]interface{}{"success": false, "error": "invalid_amount", "message": "Amount must be greater than 0"})
		return
	}

	if entryReq.Method != "cash" && entryReq.Method != "upi" && entryReq.Method != "bank" {
		writeJSON(w, http.StatusBadRequest, map[string]interface{}{"success": false, "error": "invalid_method", "message": "Method must be 'cash', 'upi', or 'bank'"})
		return
	}

	// Verify customer exists and belongs to user
	var customerUserID int
	err = database.DB.QueryRow("SELECT user_id FROM customers WHERE id = ?", entryReq.CustomerID).Scan(&customerUserID)
	if err != nil {
		if err == sql.ErrNoRows {
			writeJSON(w, http.StatusNotFound, map[string]interface{}{"success": false, "error": "customer_not_found", "message": "Customer not found"})
			return
		}
		logger.L.WithField("error", err).Error("Error checking customer ownership")
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not verify customer"})
		return
	}

	if customerUserID != userID {
		writeJSON(w, http.StatusForbidden, map[string]interface{}{"success": false, "error": "forbidden", "message": "Customer does not belong to this user"})
		return
	}

	// Set default date if not provided
	entryDate := time.Now()
	if !entryReq.Date.IsZero() {
		entryDate = entryReq.Date
	}

	// Use transaction for atomic operation
	tx, err := database.DB.Begin()
	if err != nil {
		logger.L.WithField("error", err).Error("Could not start transaction")
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not process request"})
		return
	}

	// Insert ledger entry
	result, err := tx.Exec(`
		INSERT INTO ledger_entries (customer_id, type, amount, method, note, date, user_id)
		VALUES (?, ?, ?, ?, ?, ?, ?)`,
		entryReq.CustomerID, entryReq.Type, entryReq.Amount, entryReq.Method,
		entryReq.Note, entryDate.Format("2006-01-02"), userID)
	if err != nil {
		tx.Rollback()
		logger.L.WithField("error", err).Error("Error inserting ledger entry")
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not create ledger entry"})
		return
	}

	entryID, err := result.LastInsertId()
	if err != nil {
		tx.Rollback()
		logger.L.WithField("error", err).Error("Error getting inserted entry ID")
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not create ledger entry"})
		return
	}

	// Update customer balance
	var balanceUpdate float64
	if entryReq.Type == "credit" {
		balanceUpdate = entryReq.Amount
	} else {
		balanceUpdate = -entryReq.Amount
	}

	_, err = tx.Exec(`
		UPDATE customers
		SET balance = balance + ?, updated_at = CURRENT_TIMESTAMP
		WHERE id = ?`,
		balanceUpdate, entryReq.CustomerID)
	if err != nil {
		tx.Rollback()
		logger.L.WithField("error", err).Error("Error updating customer balance")
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not update customer balance"})
		return
	}

	if err := tx.Commit(); err != nil {
		logger.L.WithField("error", err).Error("Error committing transaction")
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not create ledger entry"})
		return
	}

	logger.L.WithFields(map[string]interface{}{
		"entry_id": entryID,
		"user_id":  userID,
		"type":     entryReq.Type,
		"amount":   entryReq.Amount,
	}).Info("Ledger entry created successfully")

	// Create response entry
	entry := models.LedgerEntry{
		ID:         int(entryID),
		CustomerID: entryReq.CustomerID,
		Type:       entryReq.Type,
		Amount:     entryReq.Amount,
		Method:     entryReq.Method,
		Note:       entryReq.Note,
		Date:       entryDate,
		UserID:     userID,
		CreatedAt:  time.Now(),
		UpdatedAt:  time.Now(),
	}

	writeJSON(w, http.StatusCreated, map[string]interface{}{
		"success": true,
		"message": "Ledger entry created successfully",
		"entry":   entry,
	})
}

// GetLedgerEntries retrieves ledger entries for the authenticated user
func GetLedgerEntries(w http.ResponseWriter, r *http.Request) {
	// Get user ID from JWT token
	userID, err := getUserIDFromToken(r)
	if err != nil {
		writeJSON(w, http.StatusUnauthorized, map[string]interface{}{"success": false, "error": "unauthorized", "message": "Invalid token"})
		return
	}

	// Parse query parameters
	customerIDStr := r.URL.Query().Get("customer_id")
	entryType := r.URL.Query().Get("type")
	limitStr := r.URL.Query().Get("limit")
	offsetStr := r.URL.Query().Get("offset")

	// Build query
	query := `
		SELECT le.id, le.customer_id, le.type, le.amount, le.method, le.note, le.date, le.created_at, le.updated_at,
			   c.name as customer_name
		FROM ledger_entries le
		JOIN customers c ON le.customer_id = c.id
		WHERE le.user_id = ?`
	args := []interface{}{userID}

	if customerIDStr != "" {
		if customerID, err := strconv.Atoi(customerIDStr); err == nil {
			query += " AND le.customer_id = ?"
			args = append(args, customerID)
		}
	}

	if entryType != "" && (entryType == "credit" || entryType == "debit") {
		query += " AND le.type = ?"
		args = append(args, entryType)
	}

	query += " ORDER BY le.created_at DESC"

	// Add pagination
	limit := 50 // default limit
	if limitStr != "" {
		if parsedLimit, err := strconv.Atoi(limitStr); err == nil && parsedLimit > 0 && parsedLimit <= 100 {
			limit = parsedLimit
		}
	}
	query += " LIMIT ?"
	args = append(args, limit)

	if offsetStr != "" {
		if offset, err := strconv.Atoi(offsetStr); err == nil && offset >= 0 {
			query += " OFFSET ?"
			args = append(args, offset)
		}
	}

	rows, err := database.DB.Query(query, args...)
	if err != nil {
		logger.L.WithField("error", err).Error("Error querying ledger entries")
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not fetch ledger entries"})
		return
	}
	defer rows.Close()

	var entries []map[string]interface{}
	for rows.Next() {
		var entry models.LedgerEntry
		var customerName string
		var note sql.NullString
		var createdAtStr, updatedAtStr, dateStr string

		err := rows.Scan(
			&entry.ID, &entry.CustomerID, &entry.Type, &entry.Amount, &entry.Method,
			&note, &dateStr, &createdAtStr, &updatedAtStr, &customerName,
		)
		if err != nil {
			logger.L.WithField("error", err).Error("Error scanning ledger entry")
			continue
		}

		if note.Valid {
			entry.Note = &note.String
		}

		entry.CreatedAt, _ = time.Parse("2006-01-02 15:04:05", createdAtStr)
		entry.UpdatedAt, _ = time.Parse("2006-01-02 15:04:05", updatedAtStr)
		entry.Date, _ = time.Parse("2006-01-02", dateStr)

		entryMap := map[string]interface{}{
			"id":            entry.ID,
			"customer_id":   entry.CustomerID,
			"customer_name": customerName,
			"type":          entry.Type,
			"amount":        entry.Amount,
			"method":        entry.Method,
			"note":          entry.Note,
			"date":          dateStr,
			"created_at":    createdAtStr,
			"updated_at":    updatedAtStr,
		}
		entries = append(entries, entryMap)
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{
		"success": true,
		"entries": entries,
		"count":   len(entries),
	})
}

// GetLedgerEntry retrieves a specific ledger entry
func GetLedgerEntry(w http.ResponseWriter, r *http.Request) {
	// Get user ID from JWT token
	userID, err := getUserIDFromToken(r)
	if err != nil {
		writeJSON(w, http.StatusUnauthorized, map[string]interface{}{"success": false, "error": "unauthorized", "message": "Invalid token"})
		return
	}

	// Extract entry ID from URL path
	// This assumes the route is /api/ledger/{id}
	entryIDStr := r.URL.Path[len("/api/ledger/"):]
	entryID, err := strconv.Atoi(entryIDStr)
	if err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]interface{}{"success": false, "error": "invalid_id", "message": "Invalid entry ID"})
		return
	}

	// Query the entry
	var entry models.LedgerEntry
	var customerName string
	var note sql.NullString
	var createdAtStr, updatedAtStr, dateStr string

	err = database.DB.QueryRow(`
		SELECT le.id, le.customer_id, le.type, le.amount, le.method, le.note, le.date, le.created_at, le.updated_at,
			   c.name as customer_name
		FROM ledger_entries le
		JOIN customers c ON le.customer_id = c.id
		WHERE le.id = ? AND le.user_id = ?`, entryID, userID).Scan(
		&entry.ID, &entry.CustomerID, &entry.Type, &entry.Amount, &entry.Method,
		&note, &dateStr, &createdAtStr, &updatedAtStr, &customerName,
	)

	if err != nil {
		if err == sql.ErrNoRows {
			writeJSON(w, http.StatusNotFound, map[string]interface{}{"success": false, "error": "not_found", "message": "Ledger entry not found"})
			return
		}
		logger.L.WithField("error", err).Error("Error querying ledger entry")
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not fetch ledger entry"})
		return
	}

	if note.Valid {
		entry.Note = &note.String
	}

	entry.CreatedAt, _ = time.Parse("2006-01-02 15:04:05", createdAtStr)
	entry.UpdatedAt, _ = time.Parse("2006-01-02 15:04:05", updatedAtStr)
	entry.Date, _ = time.Parse("2006-01-02", dateStr)

	response := map[string]interface{}{
		"id":            entry.ID,
		"customer_id":   entry.CustomerID,
		"customer_name": customerName,
		"type":          entry.Type,
		"amount":        entry.Amount,
		"method":        entry.Method,
		"note":          entry.Note,
		"date":          dateStr,
		"created_at":    createdAtStr,
		"updated_at":    updatedAtStr,
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{
		"success": true,
		"entry":   response,
	})
}
