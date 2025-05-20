package interfaces

// MailServiceInterface defines the methods for sending emails
type MailServiceInterface interface {
	SendMail(to, subject, body string) error
}
