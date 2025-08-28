package models

import (
	"time"
)

type Reminder struct {
	ID         int       `json:"id"`
	CustomerID int       `json:"customer_id"`
	DueAmount  float64   `json:"due_amount"`
	DueDate    time.Time `json:"due_date"`
	Channel    string    `json:"channel"` // "sms", "whatsapp", "email"
	Status     string    `json:"status"`  // "pending", "sent", "snoozed", "paid"
	UserID     int       `json:"user_id"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
}

type ReminderRequest struct {
	CustomerID int       `json:"customer_id"`
	DueAmount  float64   `json:"due_amount"`
	DueDate    time.Time `json:"due_date"`
	Channel    string    `json:"channel"`
}
