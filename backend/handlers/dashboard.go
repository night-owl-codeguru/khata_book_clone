package handlers

import (
	"database/sql"
	"net/http"
	"strconv"

	"khata-book-backend/database"
	"khata-book-backend/models"
	"khata-book-backend/pkg/logger"
)

// DashboardEntry represents a ledger entry with customer name for dashboard display
type DashboardEntry struct {
	ID           int     `json:"id"`
	CustomerID   int     `json:"customer_id"`
	CustomerName string  `json:"customer_name"`
	Type         string  `json:"type"`
	Amount       float64 `json:"amount"`
	Method       string  `json:"method"`
	Note         *string `json:"note,omitempty"`
	Date         string  `json:"date"`
}

// GetDashboardSummary returns the dashboard summary data for the authenticated user
func GetDashboardSummary(w http.ResponseWriter, r *http.Request) {
	// Get user ID from JWT token
	userID, err := getUserIDFromToken(r)
	if err != nil {
		writeJSON(w, http.StatusUnauthorized, map[string]interface{}{"success": false, "error": "unauthorized", "message": "Invalid token"})
		return
	}

	// Get summary data
	summary, err := getDashboardSummary(userID)
	if err != nil {
		logger.L.WithField("error", err).Error("Error getting dashboard summary")
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not fetch dashboard data"})
		return
	}

	// Get latest entries
	latestEntries, err := getLatestEntriesWithNames(userID, 5)
	if err != nil {
		logger.L.WithField("error", err).Error("Error getting latest entries")
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not fetch latest entries"})
		return
	}

	response := map[string]interface{}{
		"total_credit":   summary.TotalCredit,
		"total_debit":    summary.TotalDebit,
		"balance":        summary.Balance,
		"latest_entries": latestEntries,
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{"success": true, "data": response})
}

// getDashboardSummary calculates total credits, debits, and balance for a user
func getDashboardSummary(userID int) (*models.ReportSummary, error) {
	query := `
		SELECT
			COALESCE(SUM(CASE WHEN type = 'credit' THEN amount ELSE 0 END), 0) as total_credit,
			COALESCE(SUM(CASE WHEN type = 'debit' THEN amount ELSE 0 END), 0) as total_debit,
			COALESCE(SUM(CASE WHEN type = 'credit' THEN amount ELSE -amount END), 0) as balance
		FROM ledger_entries
		WHERE user_id = ?`

	var summary models.ReportSummary
	err := database.DB.QueryRow(query, userID).Scan(&summary.TotalCredit, &summary.TotalDebit, &summary.Balance)
	if err != nil {
		return nil, err
	}

	return &summary, nil
}

// getLatestEntriesWithNames returns the most recent ledger entries with customer names
func getLatestEntriesWithNames(userID int, limit int) ([]DashboardEntry, error) {
	query := `
		SELECT le.id, le.customer_id, le.type, le.amount, le.method, le.note, le.date,
			   c.name as customer_name
		FROM ledger_entries le
		JOIN customers c ON le.customer_id = c.id
		WHERE le.user_id = ?
		ORDER BY le.created_at DESC
		LIMIT ?`

	rows, err := database.DB.Query(query, userID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var entries []DashboardEntry
	for rows.Next() {
		var entry DashboardEntry
		var note sql.NullString

		err := rows.Scan(
			&entry.ID, &entry.CustomerID, &entry.Type, &entry.Amount,
			&entry.Method, &note, &entry.Date, &entry.CustomerName,
		)
		if err != nil {
			return nil, err
		}

		if note.Valid {
			entry.Note = &note.String
		}

		entries = append(entries, entry)
	}

	return entries, nil
}

// getUserIDFromToken extracts user ID from JWT token
func getUserIDFromToken(r *http.Request) (int, error) {
	// Get token from Authorization header
	authHeader := r.Header.Get("Authorization")
	if authHeader == "" || len(authHeader) < 7 || authHeader[:7] != "Bearer " {
		return 0, http.ErrNoCookie
	}

	// Temporary implementation - extract user ID from a custom header for testing
	userIDStr := r.Header.Get("X-User-ID")
	if userIDStr == "" {
		return 0, http.ErrNoCookie
	}

	userID, err := strconv.Atoi(userIDStr)
	if err != nil {
		return 0, err
	}

	return userID, nil
}
