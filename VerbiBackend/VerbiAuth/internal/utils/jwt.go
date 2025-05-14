package utils

import (
	"crypto/rand"
	"encoding/base64"
	"github.com/dgrijalva/jwt-go"
	"os"
	"time"
)

// GenerateAccessToken generates and returns access token
func GenerateAccessToken(userID uint) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": userID,
		"exp":     time.Now().Add(time.Minute * 15).Unix(),
	})

	tokenString, err := token.SignedString([]byte(os.Getenv("JWT_SECRET")))
	if err != nil {
		return "", err
	}

	return tokenString, nil
}

// GenerateRefreshToken generates and returns refresh token
func GenerateRefreshToken() (string, error) {
	tokenBytes := make([]byte, 64)
	_, err := rand.Read(tokenBytes)
	if err != nil {
		return "", err
	}

	return base64.URLEncoding.EncodeToString(tokenBytes), nil
}
