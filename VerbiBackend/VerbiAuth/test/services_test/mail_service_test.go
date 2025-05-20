package services_test

import (
	"VerbiAuth/internal/services"
	"github.com/joho/godotenv"
	"github.com/stretchr/testify/assert"
	"testing"
)

// TestSendMail tests sending an email with mock service
func TestSendMail(t *testing.T) {
	err := godotenv.Load("mock.env")
	assert.NoError(t, err)

	mailService, err := services.NewMailService()
	assert.NoError(t, err)

	to := "test@example.com"
	subject := "Test"
	body := "Test email body"

	err = mailService.SendMail(to, subject, body)
	assert.NoError(t, err)
}
