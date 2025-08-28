package models

import (
	"time"
)

type LedgerEntry struct {
	ID         int       `json:"id"`
	CustomerID int       `json:"customer_id"`
	Type       string    `json:"type"` // "credit" or "debit"
	Amount     float64   `json:"amount"`
	Method     string    `json:"method"` // "cash", "upi", "bank"
	Note       *string   `json:"note,omitempty"`
	Date       time.Time `json:"date"`
	UserID     int       `json:"user_id"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
}

type LedgerEntryRequest struct {
	CustomerID int       `json:"customer_id"`
	Type       string    `json:"type"`
	Amount     float64   `json:"amount"`
	Method     string    `json:"method"`
	Note       *string   `json:"note,omitempty"`
	Date       time.Time `json:"date,omitempty"`
}
