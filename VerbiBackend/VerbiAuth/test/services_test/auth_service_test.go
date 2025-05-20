package services_test

import (
	"VerbiAuth/internal/interfaces"
	"VerbiAuth/internal/models"
	"VerbiAuth/internal/repositories"
	"VerbiAuth/internal/services"
	"VerbiAuth/internal/utils"
	"VerbiAuth/test/mocks"
	"github.com/stretchr/testify/assert"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"os"
	"testing"
)

// setupTestDB creates and sets up a temporary database in memory
func setupTestDB() (*gorm.DB, error) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	if err != nil {
		return nil, err
	}
	err = db.AutoMigrate(&models.User{}, &models.UserCode{}, &models.RefreshToken{})
	if err != nil {
		return nil, err
	}
	return db, nil
}

// setupAuthService sets up the AuthService with test dependencies
func setupAuthService(db *gorm.DB, mailService interfaces.MailServiceInterface) (*services.AuthService, error) {
	userRepo := repositories.NewUserRepository(db)
	refreshTokenRepo := repositories.NewRefreshTokenRepository(db)
	codeRepo := repositories.NewUserCodeRepository(db)
	return services.NewAuthService(userRepo, refreshTokenRepo, codeRepo, mailService), nil
}

// TestMain sets up the test environment
func TestMain(m *testing.M) {
	err := os.Setenv("JWT_SECRET", "test_secret")
	if err != nil {
		panic(err)
	}
	os.Exit(m.Run())
}

// TestRegister tests user registration
func TestRegister(t *testing.T) {
	db, err := setupTestDB()
	assert.NoError(t, err)
	mockMailService := mocks.NewMockMailService()
	authService, err := setupAuthService(db, mockMailService)
	assert.NoError(t, err)

	err = authService.Register("test@example.com", "testuser", "password")
	assert.NoError(t, err)
	assert.True(t, mockMailService.SendMailCalled)

	user, err := authService.UserRepository.GetUserByEmail("test@example.com")
	assert.NoError(t, err)
	assert.Equal(t, "testuser", user.Username)
	assert.False(t, user.IsEmailConfirmed)

	err = authService.Register("test@example.com", "testuser2", "password")
	assert.Error(t, err)

	err = authService.Register("test2@example.com", "testuser", "password")
	assert.Error(t, err)
}

// TestConfirmEmail tests email confirmation
func TestConfirmEmail(t *testing.T) {
	db, err := setupTestDB()
	assert.NoError(t, err)
	mockMailService := mocks.NewMockMailService()
	authService, err := setupAuthService(db, mockMailService)
	assert.NoError(t, err)

	err = authService.Register("test@example.com", "testuser", "password")
	assert.NoError(t, err)

	user, err := authService.UserRepository.GetUserByEmail("test@example.com")
	assert.NoError(t, err)
	assert.False(t, user.IsEmailConfirmed)

	err = authService.ConfirmEmail("test@example.com", "wrongcode")
	assert.Error(t, err)

	userCode, err := authService.CodeRepository.GetUserCode("test@example.com", models.EmailConfirmation.String())
	assert.NoError(t, err)
	assert.NotNil(t, userCode)

	err = authService.ConfirmEmail("test@example.com", userCode.Code)
	assert.NoError(t, err)

	user, err = authService.UserRepository.GetUserByEmail("test@example.com")
	assert.NoError(t, err)
	assert.True(t, user.IsEmailConfirmed)
}

// TestResetPassword tests password reset process
func TestResetPassword(t *testing.T) {
	db, err := setupTestDB()
	assert.NoError(t, err)
	mockMailService := mocks.NewMockMailService()
	authService, err := setupAuthService(db, mockMailService)
	assert.NoError(t, err)

	err = authService.Register("test@example.com", "testuser", "password")
	assert.NoError(t, err)

	err = authService.ResetPassword("test@example.com")
	assert.NoError(t, err)

	userCode, err := authService.CodeRepository.GetUserCode("test@example.com", models.PasswordReset.String())
	assert.NoError(t, err)
	assert.NotNil(t, userCode)

	err = authService.ConfirmResetPassword("test@example.com", "newpassword", "wrongcode")
	assert.Error(t, err)

	err = authService.ConfirmResetPassword("test@example.com", "newpassword", userCode.Code)
	assert.NoError(t, err)

	user, err := authService.UserRepository.GetUserByEmail("test@example.com")
	assert.NoError(t, err)
	assert.True(t, utils.CheckPasswordHash("newpassword", user.Password))
}

// TestResendCode tests code resend
func TestResendCode(t *testing.T) {
	db, err := setupTestDB()
	assert.NoError(t, err)
	mockMailService := mocks.NewMockMailService()
	authService, err := setupAuthService(db, mockMailService)
	assert.NoError(t, err)

	err = authService.Register("test@example.com", "testuser", "password")
	assert.NoError(t, err)

	err = authService.ResendCode("test@example.com", models.EmailConfirmation.String())
	assert.NoError(t, err)
	assert.True(t, mockMailService.SendMailCalled)

	userCode, err := authService.CodeRepository.GetUserCode("test@example.com", models.EmailConfirmation.String())
	assert.NoError(t, err)
	assert.NotNil(t, userCode)

	err = authService.ResendCode("test@example.com", models.EmailConfirmation.String())
	assert.NoError(t, err)
	assert.True(t, mockMailService.SendMailCalled)
}

// TestLogin tests login process
func TestLogin(t *testing.T) {
	db, err := setupTestDB()
	assert.NoError(t, err)
	mockMailService := mocks.NewMockMailService()
	authService, err := setupAuthService(db, mockMailService)
	assert.NoError(t, err)

	err = authService.Register("test@example.com", "testuser", "password")
	assert.NoError(t, err)

	response, err := authService.Login("test@example.com", "wrongpassword")
	assert.Error(t, err)
	assert.Nil(t, response)

	response, err = authService.Login("test@example.com", "password")
	assert.NoError(t, err)
	assert.NotEmpty(t, response.AccessToken)
	assert.NotEmpty(t, response.RefreshToken)

	var refreshTokenModel models.RefreshToken
	err = db.Where("token = ?", response.RefreshToken).First(&refreshTokenModel).Error
	assert.NoError(t, err)
	assert.Equal(t, response.RefreshToken, refreshTokenModel.Token)
}

// TestLogout tests logout process
func TestLogout(t *testing.T) {
	db, err := setupTestDB()
	assert.NoError(t, err)
	mockMailService := mocks.NewMockMailService()
	authService, err := setupAuthService(db, mockMailService)
	assert.NoError(t, err)

	err = authService.Register("test@example.com", "testuser", "password")
	assert.NoError(t, err)

	response, err := authService.Login("test@example.com", "password")
	assert.NoError(t, err)
	assert.NotEmpty(t, response.AccessToken)
	assert.NotEmpty(t, response.RefreshToken)

	err = authService.Logout(response.RefreshToken)
	assert.NoError(t, err)

	var refreshTokenModel models.RefreshToken
	err = db.Where("token = ?", response.RefreshToken).First(&refreshTokenModel).Error
	assert.Error(t, err)
}
