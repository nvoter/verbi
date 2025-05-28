package config

import (
	"errors"
	"github.com/joho/godotenv"
	"log"
)

func LoadEnv() error {
	err := godotenv.Load()
	if err != nil {
		log.Printf("Error loading .env file")
		return errors.New("error loading .env file")
	}
	return nil
}
