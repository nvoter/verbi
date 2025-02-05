package models

import (
	"gorm.io/gorm"
	"time"
)

// UserCode model for saving temporary codes
type UserCode struct {
	gorm.Model
	ID        uint      `gorm:"primaryKey"`
	UserID    uint      `gorm:"not null;index"`
	Code      string    `gorm:"size:6;not null"`
	Type      string    `gorm:"size:20;not null"`
	ExpiresAt time.Time `gorm:"not null"`
}

// BeforeCreate callback to set ExpiresAt
func (uc *UserCode) BeforeCreate(_ *gorm.DB) error {
	uc.ExpiresAt = time.Now().Add(10 * time.Minute)
	return nil
}
