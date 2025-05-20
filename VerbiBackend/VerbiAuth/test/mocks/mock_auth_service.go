package mocks

import (
	"VerbiAuth/internal/models/responses"
	"github.com/stretchr/testify/mock"
)

// MockAuthService to test AuthController
type MockAuthService struct {
	mock.Mock
}

// Register mock implementation of Register function of AuthService
func (m *MockAuthService) Register(email, username, password string) error {
	args := m.Called(email, username, password)
	return args.Error(0)
}

// ConfirmEmail mock implementation of ConfirmEmail function of AuthService
func (m *MockAuthService) ConfirmEmail(email, code string) error {
	args := m.Called(email, code)
	return args.Error(0)
}

// Login mock implementation of Login function of AuthService
func (m *MockAuthService) Login(emailOrUsername, password string) (*responses.LoginResponse, error) {
	args := m.Called(emailOrUsername, password)
	return args.Get(0).(*responses.LoginResponse), args.Error(1)
}

// Logout mock implementation of Logout function of AuthService
func (m *MockAuthService) Logout(refreshToken string) error {
	args := m.Called(refreshToken)
	return args.Error(0)
}

// Refresh mock implementation of Refresh function of AuthService
func (m *MockAuthService) Refresh(refreshToken string) (string, error) {
	args := m.Called(refreshToken)
	return args.String(0), args.Error(1)
}

// ResetPassword mock implementation of ResetPassword function of AuthService
func (m *MockAuthService) ResetPassword(email string) error {
	args := m.Called(email)
	return args.Error(0)
}

// ConfirmResetPassword mock implementation of ConfirmResetPassword function of AuthService
func (m *MockAuthService) ConfirmResetPassword(email, newPassword, code string) error {
	args := m.Called(email, newPassword, code)
	return args.Error(0)
}

// ResendCode mock implementation of ResendCode function of AuthService
func (m *MockAuthService) ResendCode(email, codeType string) error {
	args := m.Called(email, codeType)
	return args.Error(0)
}
