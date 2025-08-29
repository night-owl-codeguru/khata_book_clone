package handlers

import (
	"database/sql"
	"encoding/json"
	"net/http"
	"strconv"
	"strings"
	"time"

	"khata-book-backend/database"
	"khata-book-backend/models"
	"khata-book-backend/pkg/logger"
)

// GetReminders retrieves all reminders for the authenticated user
func GetReminders(w http.ResponseWriter, r *http.Request) {
	// Get user ID from JWT token
	userID, err := getUserIDFromToken(r)
	if err != nil {
		writeJSON(w, http.StatusUnauthorized, map[string]interface{}{"success": false, "error": "unauthorized", "message": "Invalid token"})
		return
	}

	// Parse query parameters
	status := r.URL.Query().Get("status")
	customerIDStr := r.URL.Query().Get("customer_id")

	// Build query
	query := `
		SELECT r.id, r.customer_id, r.due_amount, r.due_date, r.channel, r.status, r.created_at, r.updated_at,
			   c.name as customer_name
		FROM reminders r
		JOIN customers c ON r.customer_id = c.id
		WHERE r.user_id = ?`
	args := []interface{}{userID}

	if status != "" && (status == "pending" || status == "sent" || status == "snoozed" || status == "paid") {
		query += " AND r.status = ?"
		args = append(args, status)
	}

	if customerIDStr != "" {
		if customerID, err := strconv.Atoi(customerIDStr); err == nil {
			query += " AND r.customer_id = ?"
			args = append(args, customerID)
		}
	}

	query += " ORDER BY r.due_date ASC, r.created_at DESC"

	rows, err := database.DB.Query(query, args...)
	if err != nil {
		logger.L.WithField("error", err).Error("Error querying reminders")
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not fetch reminders"})
		return
	}
	defer rows.Close()

	var reminders []map[string]interface{}
	for rows.Next() {
		var reminder models.Reminder
		var customerName string
		var createdAtStr, updatedAtStr, dueDateStr string

		err := rows.Scan(
			&reminder.ID, &reminder.CustomerID, &reminder.DueAmount, &dueDateStr,
			&reminder.Channel, &reminder.Status, &createdAtStr, &updatedAtStr, &customerName,
		)
		if err != nil {
			logger.L.WithField("error", err).Error("Error scanning reminder")
			continue
		}

		reminder.CreatedAt, _ = time.Parse("2006-01-02 15:04:05", createdAtStr)
		reminder.UpdatedAt, _ = time.Parse("2006-01-02 15:04:05", updatedAtStr)
		reminder.DueDate, _ = time.Parse("2006-01-02", dueDateStr)

		reminderMap := map[string]interface{}{
			"id":            reminder.ID,
			"customer_id":   reminder.CustomerID,
			"customer_name": customerName,
			"due_amount":    reminder.DueAmount,
			"due_date":      dueDateStr,
			"channel":       reminder.Channel,
			"status":        reminder.Status,
			"created_at":    createdAtStr,
			"updated_at":    updatedAtStr,
		}
		reminders = append(reminders, reminderMap)
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{
		"success":   true,
		"reminders": reminders,
		"count":     len(reminders),
	})
}

// CreateReminder creates a new reminder for the authenticated user
func CreateReminder(w http.ResponseWriter, r *http.Request) {
	// Get user ID from JWT token
	userID, err := getUserIDFromToken(r)
	if err != nil {
		writeJSON(w, http.StatusUnauthorized, map[string]interface{}{"success": false, "error": "unauthorized", "message": "Invalid token"})
		return
	}

	var reminderReq models.ReminderRequest
	err = json.NewDecoder(r.Body).Decode(&reminderReq)
	if err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]interface{}{"success": false, "error": "invalid_request", "message": "Invalid request body"})
		return
	}

	// Validate required fields
	if reminderReq.CustomerID <= 0 {
		writeJSON(w, http.StatusBadRequest, map[string]interface{}{"success": false, "error": "invalid_customer", "message": "Valid customer ID is required"})
		return
	}

	if reminderReq.DueAmount <= 0 {
		writeJSON(w, http.StatusBadRequest, map[string]interface{}{"success": false, "error": "invalid_amount", "message": "Due amount must be greater than 0"})
		return
	}

	if reminderReq.Channel != "sms" && reminderReq.Channel != "whatsapp" && reminderReq.Channel != "email" {
		writeJSON(w, http.StatusBadRequest, map[string]interface{}{"success": false, "error": "invalid_channel", "message": "Channel must be 'sms', 'whatsapp', or 'email'"})
		return
	}

	// Verify customer exists and belongs to user
	var customerUserID int
	err = database.DB.QueryRow("SELECT user_id FROM customers WHERE id = ?", reminderReq.CustomerID).Scan(&customerUserID)
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

	// Insert reminder
	result, err := database.DB.Exec(`
		INSERT INTO reminders (customer_id, due_amount, due_date, channel, status, user_id)
		VALUES (?, ?, ?, ?, 'pending', ?)`,
		reminderReq.CustomerID, reminderReq.DueAmount, reminderReq.DueDate.Format("2006-01-02"),
		reminderReq.Channel, userID)
	if err != nil {
		logger.L.WithField("error", err).Error("Error inserting reminder")
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not create reminder"})
		return
	}

	reminderID, err := result.LastInsertId()
	if err != nil {
		logger.L.WithField("error", err).Error("Error getting inserted reminder ID")
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not create reminder"})
		return
	}

	logger.L.WithFields(map[string]interface{}{
		"reminder_id": reminderID,
		"user_id":     userID,
		"customer_id": reminderReq.CustomerID,
		"due_amount":  reminderReq.DueAmount,
	}).Info("Reminder created successfully")

	// Create response reminder
	reminder := models.Reminder{
		ID:         int(reminderID),
		CustomerID: reminderReq.CustomerID,
		DueAmount:  reminderReq.DueAmount,
		DueDate:    reminderReq.DueDate,
		Channel:    reminderReq.Channel,
		Status:     "pending",
		UserID:     userID,
		CreatedAt:  time.Now(),
		UpdatedAt:  time.Now(),
	}

	writeJSON(w, http.StatusCreated, map[string]interface{}{
		"success":  true,
		"message":  "Reminder created successfully",
		"reminder": reminder,
	})
}

// UpdateReminder updates an existing reminder
func UpdateReminder(w http.ResponseWriter, r *http.Request) {
	// Get user ID from JWT token
	userID, err := getUserIDFromToken(r)
	if err != nil {
		writeJSON(w, http.StatusUnauthorized, map[string]interface{}{"success": false, "error": "unauthorized", "message": "Invalid token"})
		return
	}

	// Extract reminder ID from URL path
	reminderIDStr := r.URL.Path[len("/api/reminders/"):]
	reminderID, err := strconv.Atoi(reminderIDStr)
	if err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]interface{}{"success": false, "error": "invalid_id", "message": "Invalid reminder ID"})
		return
	}

	var updateReq map[string]interface{}
	err = json.NewDecoder(r.Body).Decode(&updateReq)
	if err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]interface{}{"success": false, "error": "invalid_request", "message": "Invalid request body"})
		return
	}

	// Verify reminder exists and belongs to user
	var reminderUserID int
	err = database.DB.QueryRow("SELECT user_id FROM reminders WHERE id = ?", reminderID).Scan(&reminderUserID)
	if err != nil {
		if err == sql.ErrNoRows {
			writeJSON(w, http.StatusNotFound, map[string]interface{}{"success": false, "error": "not_found", "message": "Reminder not found"})
			return
		}
		logger.L.WithField("error", err).Error("Error checking reminder ownership")
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not verify reminder"})
		return
	}

	if reminderUserID != userID {
		writeJSON(w, http.StatusForbidden, map[string]interface{}{"success": false, "error": "forbidden", "message": "Reminder does not belong to this user"})
		return
	}

	// Build update query dynamically
	setParts := []string{}
	args := []interface{}{}

	if dueAmount, ok := updateReq["due_amount"].(float64); ok && dueAmount > 0 {
		setParts = append(setParts, "due_amount = ?")
		args = append(args, dueAmount)
	}

	if dueDateStr, ok := updateReq["due_date"].(string); ok {
		if dueDate, err := time.Parse("2006-01-02", dueDateStr); err == nil {
			setParts = append(setParts, "due_date = ?")
			args = append(args, dueDate.Format("2006-01-02"))
		}
	}

	if channel, ok := updateReq["channel"].(string); ok {
		if channel == "sms" || channel == "whatsapp" || channel == "email" {
			setParts = append(setParts, "channel = ?")
			args = append(args, channel)
		}
	}

	if status, ok := updateReq["status"].(string); ok {
		if status == "pending" || status == "sent" || status == "snoozed" || status == "paid" {
			setParts = append(setParts, "status = ?")
			args = append(args, status)
		}
	}

	if len(setParts) == 0 {
		writeJSON(w, http.StatusBadRequest, map[string]interface{}{"success": false, "error": "no_updates", "message": "No valid fields to update"})
		return
	}

	setParts = append(setParts, "updated_at = CURRENT_TIMESTAMP")
	query := "UPDATE reminders SET " + strings.Join(setParts, ", ") + " WHERE id = ?"
	args = append(args, reminderID)

	_, err = database.DB.Exec(query, args...)
	if err != nil {
		logger.L.WithField("error", err).Error("Error updating reminder")
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not update reminder"})
		return
	}

	logger.L.WithFields(map[string]interface{}{
		"reminder_id": reminderID,
		"user_id":     userID,
	}).Info("Reminder updated successfully")

	writeJSON(w, http.StatusOK, map[string]interface{}{
		"success": true,
		"message": "Reminder updated successfully",
	})
}

// DeleteReminder deletes a reminder
func DeleteReminder(w http.ResponseWriter, r *http.Request) {
	// Get user ID from JWT token
	userID, err := getUserIDFromToken(r)
	if err != nil {
		writeJSON(w, http.StatusUnauthorized, map[string]interface{}{"success": false, "error": "unauthorized", "message": "Invalid token"})
		return
	}

	// Extract reminder ID from URL path
	reminderIDStr := r.URL.Path[len("/api/reminders/"):]
	reminderID, err := strconv.Atoi(reminderIDStr)
	if err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]interface{}{"success": false, "error": "invalid_id", "message": "Invalid reminder ID"})
		return
	}

	// Verify reminder exists and belongs to user
	var reminderUserID int
	err = database.DB.QueryRow("SELECT user_id FROM reminders WHERE id = ?", reminderID).Scan(&reminderUserID)
	if err != nil {
		if err == sql.ErrNoRows {
			writeJSON(w, http.StatusNotFound, map[string]interface{}{"success": false, "error": "not_found", "message": "Reminder not found"})
			return
		}
		logger.L.WithField("error", err).Error("Error checking reminder ownership")
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not verify reminder"})
		return
	}

	if reminderUserID != userID {
		writeJSON(w, http.StatusForbidden, map[string]interface{}{"success": false, "error": "forbidden", "message": "Reminder does not belong to this user"})
		return
	}

	// Delete reminder
	_, err = database.DB.Exec("DELETE FROM reminders WHERE id = ?", reminderID)
	if err != nil {
		logger.L.WithField("error", err).Error("Error deleting reminder")
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not delete reminder"})
		return
	}

	logger.L.WithFields(map[string]interface{}{
		"reminder_id": reminderID,
		"user_id":     userID,
	}).Info("Reminder deleted successfully")

	writeJSON(w, http.StatusOK, map[string]interface{}{
		"success": true,
		"message": "Reminder deleted successfully",
	})
}
