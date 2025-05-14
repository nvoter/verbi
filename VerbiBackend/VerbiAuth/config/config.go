package config

import (
	"errors"
	"github.com/joho/godotenv"
	"gorm.io/gorm"
	"log"
)

var DB *gorm.DB

// LoadEnv function to get variables from .env file
func LoadEnv() error {
	err := godotenv.Load()
	if err != nil {
		log.Printf("Error loading .env file")
		return errors.New("error loading .env file")
	}

	return nil
}
