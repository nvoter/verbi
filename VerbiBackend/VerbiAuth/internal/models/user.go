package models

import "gorm.io/gorm"

// User data model
type User struct {
	gorm.Model
	ID               uint   `gorm:"primaryKey"`
	Username         string `gorm:"unique;not null"`
	Email            string `gorm:"unique;not null"`
	Password         string `gorm:"not null"`
	IsEmailConfirmed bool   `gorm:"default:false"`
}
