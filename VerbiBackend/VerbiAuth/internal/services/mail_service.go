package services

import (
	"errors"
	"fmt"
	"log"
	"net/smtp"
	"os"
)

// MailService to send emails to users
type MailService struct {
	SMTPHost string
	SMTPPort string
	From     string
	Password string
}

// NewMailService creates a mail service
func NewMailService() (*MailService, error) {
	from := os.Getenv("MAIL_SENDER_EMAIL") + "@gmail.com"
	password := os.Getenv("MAIL_SENDER_PASSWORD")
	fmt.Print("From: " + from + "\n")
	fmt.Print("Password: " + password + "\n")
	if from == "@gmail.com" || password == "" {
		return nil, errors.New("MAIL_SENDER environment variable not set")
	}

	smtpHost := os.Getenv("SMTP_HOST")
	if smtpHost == "" {
		smtpHost = "smtp.gmail.com"
	}

	smtpPort := os.Getenv("SMTP_PORT")
	if smtpPort == "" {
		smtpPort = "587"
	}

	return &MailService{
		SMTPHost: smtpHost,
		SMTPPort: smtpPort,
		From:     from,
		Password: password,
	}, nil
}

// SendMail function to send emails to users
func (m *MailService) SendMail(to, subject, body string) error {
	auth := smtp.PlainAuth("", m.From, m.Password, m.SMTPHost)

	message := []byte("To: " + to + "\r\n" + "Subject: " + subject + "\r\n" + "\r\n" + body + "\r\n")

	err := smtp.SendMail(m.SMTPHost+":"+m.SMTPPort, auth, m.From, []string{to}, message)
	if err != nil {
		log.Printf("Error sending mail: %v", err)
		return err
	}

	log.Printf("Mail sent successfully on %s", to)
	return nil
}
