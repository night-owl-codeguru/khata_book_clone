package handlers

import (
	"database/sql"
	"net/http"
	"strconv"
	"time"

	"khata-book-backend/database"
	"khata-book-backend/models"
	"khata-book-backend/pkg/logger"

	"github.com/golang-jwt/jwt/v5"
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

// GetMonthlyReports returns detailed monthly analytics
func GetMonthlyReports(w http.ResponseWriter, r *http.Request) {
	// Get user ID from JWT token
	userID, err := getUserIDFromToken(r)
	if err != nil {
		writeJSON(w, http.StatusUnauthorized, map[string]interface{}{"success": false, "error": "unauthorized", "message": "Invalid token"})
		return
	}

	// Parse query parameters
	yearStr := r.URL.Query().Get("year")
	monthStr := r.URL.Query().Get("month")

	year := 0
	month := 0

	if yearStr != "" {
		if parsedYear, err := strconv.Atoi(yearStr); err == nil && parsedYear > 2000 && parsedYear <= 2100 {
			year = parsedYear
		}
	}

	if monthStr != "" {
		if parsedMonth, err := strconv.Atoi(monthStr); err == nil && parsedMonth >= 1 && parsedMonth <= 12 {
			month = parsedMonth
		}
	}

	// Get monthly reports
	reports, err := getMonthlyReports(userID, year, month)
	if err != nil {
		logger.L.WithField("error", err).Error("Error getting monthly reports")
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not fetch monthly reports"})
		return
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{
		"success": true,
		"reports": reports,
	})
}

// GetCategoryReports returns category-wise analytics
func GetCategoryReports(w http.ResponseWriter, r *http.Request) {
	// Get user ID from JWT token
	userID, err := getUserIDFromToken(r)
	if err != nil {
		writeJSON(w, http.StatusUnauthorized, map[string]interface{}{"success": false, "error": "unauthorized", "message": "Invalid token"})
		return
	}

	// Parse query parameters
	startDateStr := r.URL.Query().Get("start_date")
	endDateStr := r.URL.Query().Get("end_date")

	var startDate, endDate *time.Time

	if startDateStr != "" {
		if parsedDate, err := time.Parse("2006-01-02", startDateStr); err == nil {
			startDate = &parsedDate
		}
	}

	if endDateStr != "" {
		if parsedDate, err := time.Parse("2006-01-02", endDateStr); err == nil {
			endDate = &parsedDate
		}
	}

	// Get category reports
	reports, err := getCategoryReports(userID, startDate, endDate)
	if err != nil {
		logger.L.WithField("error", err).Error("Error getting category reports")
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not fetch category reports"})
		return
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{
		"success": true,
		"reports": reports,
	})
}

// GetPaymentMethodReports returns payment method analytics
func GetPaymentMethodReports(w http.ResponseWriter, r *http.Request) {
	// Get user ID from JWT token
	userID, err := getUserIDFromToken(r)
	if err != nil {
		writeJSON(w, http.StatusUnauthorized, map[string]interface{}{"success": false, "error": "unauthorized", "message": "Invalid token"})
		return
	}

	// Parse query parameters
	startDateStr := r.URL.Query().Get("start_date")
	endDateStr := r.URL.Query().Get("end_date")

	var startDate, endDate *time.Time

	if startDateStr != "" {
		if parsedDate, err := time.Parse("2006-01-02", startDateStr); err == nil {
			startDate = &parsedDate
		}
	}

	if endDateStr != "" {
		if parsedDate, err := time.Parse("2006-01-02", endDateStr); err == nil {
			endDate = &parsedDate
		}
	}

	// Get payment method reports
	reports, err := getPaymentMethodReports(userID, startDate, endDate)
	if err != nil {
		logger.L.WithField("error", err).Error("Error getting payment method reports")
		writeJSON(w, http.StatusInternalServerError, map[string]interface{}{"success": false, "error": "server_error", "message": "Could not fetch payment method reports"})
		return
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{
		"success": true,
		"reports": reports,
	})
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

	tokenString := authHeader[7:]

	// Parse and validate token
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		return jwtSecret, nil
	})

	if err != nil || !token.Valid {
		return 0, err
	}

	// Get claims
	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		return 0, http.ErrNoCookie
	}

	userID := int(claims["user_id"].(float64))
	return userID, nil
}

// getMonthlyReports returns monthly analytics for the user
func getMonthlyReports(userID int, year int, month int) ([]models.ReportSummary, error) {
	var query string
	var args []interface{}

	if year > 0 && month > 0 {
		// Specific month
		query = `
			SELECT
				DATE_FORMAT(date, '%Y-%m') as month,
				COALESCE(SUM(CASE WHEN type = 'credit' THEN amount ELSE 0 END), 0) as total_credit,
				COALESCE(SUM(CASE WHEN type = 'debit' THEN amount ELSE 0 END), 0) as total_debit,
				COALESCE(SUM(CASE WHEN type = 'credit' THEN amount ELSE -amount END), 0) as balance
			FROM ledger_entries
			WHERE user_id = ? AND YEAR(date) = ? AND MONTH(date) = ?
			GROUP BY DATE_FORMAT(date, '%Y-%m')
			ORDER BY month DESC`
		args = []interface{}{userID, year, month}
	} else if year > 0 {
		// Specific year
		query = `
			SELECT
				DATE_FORMAT(date, '%Y-%m') as month,
				COALESCE(SUM(CASE WHEN type = 'credit' THEN amount ELSE 0 END), 0) as total_credit,
				COALESCE(SUM(CASE WHEN type = 'debit' THEN amount ELSE 0 END), 0) as total_debit,
				COALESCE(SUM(CASE WHEN type = 'credit' THEN amount ELSE -amount END), 0) as balance
			FROM ledger_entries
			WHERE user_id = ? AND YEAR(date) = ?
			GROUP BY DATE_FORMAT(date, '%Y-%m')
			ORDER BY month DESC`
		args = []interface{}{userID, year}
	} else {
		// Last 12 months
		query = `
			SELECT
				DATE_FORMAT(date, '%Y-%m') as month,
				COALESCE(SUM(CASE WHEN type = 'credit' THEN amount ELSE 0 END), 0) as total_credit,
				COALESCE(SUM(CASE WHEN type = 'debit' THEN amount ELSE 0 END), 0) as total_debit,
				COALESCE(SUM(CASE WHEN type = 'credit' THEN amount ELSE -amount END), 0) as balance
			FROM ledger_entries
			WHERE user_id = ? AND date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
			GROUP BY DATE_FORMAT(date, '%Y-%m')
			ORDER BY month DESC`
		args = []interface{}{userID}
	}

	rows, err := database.DB.Query(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var reports []models.ReportSummary
	for rows.Next() {
		var report models.ReportSummary
		err := rows.Scan(&report.Month, &report.TotalCredit, &report.TotalDebit, &report.Balance)
		if err != nil {
			return nil, err
		}
		reports = append(reports, report)
	}

	return reports, nil
}

// getCategoryReports returns category-wise analytics (by customer)
func getCategoryReports(userID int, startDate, endDate *time.Time) ([]map[string]interface{}, error) {
	var query string
	var args []interface{}

	query = `
		SELECT
			c.name as customer_name,
			c.id as customer_id,
			COALESCE(SUM(CASE WHEN le.type = 'credit' THEN le.amount ELSE 0 END), 0) as total_credit,
			COALESCE(SUM(CASE WHEN le.type = 'debit' THEN le.amount ELSE 0 END), 0) as total_debit,
			COALESCE(SUM(CASE WHEN le.type = 'credit' THEN le.amount ELSE -le.amount END), 0) as balance,
			COUNT(le.id) as transaction_count
		FROM customers c
		LEFT JOIN ledger_entries le ON c.id = le.customer_id AND le.user_id = ?
		WHERE c.user_id = ?`

	args = []interface{}{userID, userID}

	if startDate != nil {
		query += " AND le.date >= ?"
		args = append(args, startDate.Format("2006-01-02"))
	}

	if endDate != nil {
		query += " AND le.date <= ?"
		args = append(args, endDate.Format("2006-01-02"))
	}

	query += " GROUP BY c.id, c.name ORDER BY balance DESC"

	rows, err := database.DB.Query(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var reports []map[string]interface{}
	for rows.Next() {
		var customerName string
		var customerID int
		var totalCredit, totalDebit, balance float64
		var transactionCount int

		err := rows.Scan(&customerName, &customerID, &totalCredit, &totalDebit, &balance, &transactionCount)
		if err != nil {
			return nil, err
		}

		report := map[string]interface{}{
			"customer_id":       customerID,
			"customer_name":     customerName,
			"total_credit":      totalCredit,
			"total_debit":       totalDebit,
			"balance":           balance,
			"transaction_count": transactionCount,
		}
		reports = append(reports, report)
	}

	return reports, nil
}

// getPaymentMethodReports returns payment method analytics
func getPaymentMethodReports(userID int, startDate, endDate *time.Time) ([]map[string]interface{}, error) {
	var query string
	var args []interface{}

	query = `
		SELECT
			method,
			COUNT(*) as transaction_count,
			SUM(amount) as total_amount,
			AVG(amount) as average_amount
		FROM ledger_entries
		WHERE user_id = ?`

	args = []interface{}{userID}

	if startDate != nil {
		query += " AND date >= ?"
		args = append(args, startDate.Format("2006-01-02"))
	}

	if endDate != nil {
		query += " AND date <= ?"
		args = append(args, endDate.Format("2006-01-02"))
	}

	query += " GROUP BY method ORDER BY total_amount DESC"

	rows, err := database.DB.Query(query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var reports []map[string]interface{}
	for rows.Next() {
		var method string
		var transactionCount int
		var totalAmount, averageAmount float64

		err := rows.Scan(&method, &transactionCount, &totalAmount, &averageAmount)
		if err != nil {
			return nil, err
		}

		report := map[string]interface{}{
			"method":            method,
			"transaction_count": transactionCount,
			"total_amount":      totalAmount,
			"average_amount":    averageAmount,
		}
		reports = append(reports, report)
	}

	return reports, nil
}
