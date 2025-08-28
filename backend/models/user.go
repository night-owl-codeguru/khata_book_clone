package models

import (
	"time"
)

type User struct {
	ID           int       `json:"id"`
	Name         string    `json:"name,omitempty"`
	Phone        string    `json:"phone,omitempty"`
	Email        string    `json:"email"`
	Address      string    `json:"address,omitempty"`
	PasswordHash string    `json:"-"`
	CreatedAt    time.Time `json:"created_at"`
}

type UserRequest struct {
	Name     string `json:"name,omitempty"`
	Phone    string `json:"phone,omitempty"`
	Email    string `json:"email"`
	Password string `json:"password"`
	Address  string `json:"address,omitempty"`
}

type LoginResponse struct {
	Token string `json:"token"`
	User  User   `json:"user"`
}
