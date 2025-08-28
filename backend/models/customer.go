package models

import (
	"time"
)

type Customer struct {
	ID        int       `json:"id"`
	Name      string    `json:"name"`
	Phone     *string   `json:"phone,omitempty"`
	Note      *string   `json:"note,omitempty"`
	UserID    int       `json:"user_id"`
	Balance   float64   `json:"balance"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type CustomerRequest struct {
	Name    string  `json:"name"`
	Phone   *string `json:"phone,omitempty"`
	Note    *string `json:"note,omitempty"`
	Balance float64 `json:"balance,omitempty"`
}
