package mocks

// MockMailService creates a mock implementation of mail service
type MockMailService struct {
	SendMailCalled bool
	SendMailError  error
}

// NewMockMailService creates a new MockMailService
func NewMockMailService() *MockMailService {
	return &MockMailService{
		SendMailCalled: false,
		SendMailError:  nil,
	}
}

// SendMail mock implementation of SendMail function of MailService
func (m *MockMailService) SendMail(to, subject, body string) error {
	m.SendMailCalled = true
	return m.SendMailError
}
