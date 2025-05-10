package services

import (
	"VerbiAuth/internal/interfaces"
	"VerbiAuth/internal/models"
	"VerbiAuth/internal/repositories"
	"VerbiAuth/internal/utils"
	"errors"
	"time"
)

// AuthService to handle authentication actions
type AuthService struct {
	UserRepository         *repositories.UserRepository
	RefreshTokenRepository *repositories.RefreshTokenRepository
	CodeRepository         *repositories.UserCodeRepository
	MailService            interfaces.MailServiceInterface
}

// NewAuthService creates a new authentication service
func NewAuthService(
	userRepository *repositories.UserRepository,
	refreshTokenRepository *repositories.RefreshTokenRepository,
	codeRepository *repositories.UserCodeRepository,
	mailService interfaces.MailServiceInterface,
) *AuthService {
	return &AuthService{
		UserRepository:         userRepository,
		RefreshTokenRepository: refreshTokenRepository,
		CodeRepository:         codeRepository,
		MailService:            mailService,
	}
}

// Register creates an account with user data in the database
func (s *AuthService) Register(email, username, password string) error {
	_, err := s.UserRepository.GetUserByEmail(email)
	if err == nil {
		return errors.New("user with this email already exists")
	}

	_, err = s.UserRepository.GetUserByUsername(username)
	if err == nil {
		return errors.New("user with this username already exists")
	}

	hashedPassword, err := utils.HashPassword(password)
	if err != nil {
		return errors.New("could not hash password")
	}

	user := &models.User{
		Email:            email,
		Username:         username,
		Password:         hashedPassword,
		IsEmailConfirmed: false,
	}
	err = s.UserRepository.CreateUser(user)
	if err != nil {
		return errors.New("could not create temporary user")
	}

	err = s.sendCode(user.Email, models.EmailConfirmation.String())
	if err != nil {
		return errors.New("could not send code")
	}

	return nil
}

// ConfirmEmail confirms user email if the confirmation code is correct
func (s *AuthService) ConfirmEmail(email, code string) error {
	user, err := s.UserRepository.GetUserByEmail(email)
	if err != nil {
		return errors.New("could not get user by email")
	}

	err = s.checkCode(email, code, models.EmailConfirmation.String())
	if err != nil {
		return errors.New(err.Error())
	}

	user.IsEmailConfirmed = true
	err = s.UserRepository.UpdateUser(user)
	if err != nil {
		return errors.New("could not update user")
	}

	err = s.CodeRepository.DeleteCode(email, models.EmailConfirmation.String())
	if err != nil {
		return errors.New("could not delete code")
	}

	return nil
}

// ResetPassword starts reset password process
func (s *AuthService) ResetPassword(email, oldPassword string) error {
	user, err := s.UserRepository.GetUserByEmail(email)
	if err != nil {
		return errors.New("user with this email doesn't exist")
	}

	if !utils.CheckPasswordHash(oldPassword, user.Password) {
		return errors.New("old password doesn't match")
	}

	err = s.sendCode(user.Email, models.PasswordReset.String())
	if err != nil {
		return errors.New("could not send code")
	}

	return nil
}

// ConfirmResetPassword confirms the password reset if the code is correct
func (s *AuthService) ConfirmResetPassword(email, newPassword, code string) error {
	user, err := s.UserRepository.GetUserByEmail(email)
	if err != nil {
		return errors.New("user with this email doesn't exist")
	}

	err = s.checkCode(email, code, models.PasswordReset.String())
	if err != nil {
		return errors.New(err.Error())
	}

	err = s.CodeRepository.DeleteCode(email, models.PasswordReset.String())
	if err != nil {
		return errors.New("could not delete code")
	}

	hashedPassword, err := utils.HashPassword(newPassword)
	if err != nil {
		return errors.New("could not hash password")
	}

	user.Password = hashedPassword

	err = s.UserRepository.UpdateUser(user)
	if err != nil {
		return errors.New("could not update user")
	}

	return nil
}

// ResendCode resends code to email
func (s *AuthService) ResendCode(email, codeType string) error {
	err := s.CodeRepository.DeleteCode(email, codeType)
	if err != nil {
		return errors.New("could not delete old confirmation code")
	}

	err = s.sendCode(email, codeType)
	if err != nil {
		return errors.New(err.Error())
	}

	return nil
}

// Login processes a login request
func (s *AuthService) Login(emailOrUsername, password string) (string, string, error) {
	user, err := s.UserRepository.GetUserByEmail(emailOrUsername)
	if err != nil {
		user, err = s.UserRepository.GetUserByUsername(emailOrUsername)
	}
	if err != nil {
		return "", "", errors.New("user doesn't exist")
	}

	if !utils.CheckPasswordHash(password, user.Password) {
		return "", "", errors.New("invalid password")
	}

	accessToken, err := utils.GenerateAccessToken(user.ID)
	if err != nil {
		return "", "", errors.New("could not generate access token")
	}

	refreshTokenString, err := utils.GenerateRefreshToken()
	if err != nil {
		return "", "", errors.New("could not generate refresh token")
	}

	refreshToken := &models.RefreshToken{
		UserID:    user.ID,
		Token:     refreshTokenString,
		ExpiresAt: time.Now().Add(time.Hour * 7 * 24),
	}

	err = s.RefreshTokenRepository.CreateToken(refreshToken)
	if err != nil {
		return "", "", errors.New("could not save refresh token")
	}

	return accessToken, refreshTokenString, nil
}

// Logout processes a logout request
func (s *AuthService) Logout(refreshToken string) error {
	err := s.RefreshTokenRepository.DeleteToken(refreshToken)
	if err != nil {
		return errors.New("could not delete refresh token")
	}
	return nil
}

// Refresh function to refresh access token
func (s *AuthService) Refresh(token string) (string, error) {
	refreshToken, err := s.RefreshTokenRepository.GetTokenByValue(token)
	if err != nil {
		return "", errors.New("could not get refresh token")
	}

	if refreshToken.ExpiresAt.Before(time.Now()) {
		return "", errors.New("refresh token is expired")
	}

	accessToken, err := utils.GenerateAccessToken(refreshToken.UserID)
	if err != nil {
		return "", errors.New("could not generate access token")
	}

	return accessToken, nil
}

// sendCode sends a code of type codeType to email
func (s *AuthService) sendCode(email string, codeType string) error {
	confirmationCode := &models.UserCode{
		UserEmail: email,
		Code:      utils.GenerateRandomCode(6),
		Type:      codeType,
	}
	err := s.CodeRepository.CreateCode(confirmationCode)
	if err != nil {
		return errors.New("could not create confirmation code")
	}

	if codeType == models.EmailConfirmation.String() {
		err = s.MailService.SendMail(email, "Verbi verification code", "To continue setting up your verbi account, please verify your account with the code: "+confirmationCode.Code)
	} else {
		err = s.MailService.SendMail(email, "Reset verbi password", "To reset your password, please confirm your account with the code: "+confirmationCode.Code)
	}
	if err != nil {
		return errors.New("failed to send verification code")
	}

	return nil
}

// checkCode checks if the code is correct
func (s *AuthService) checkCode(email, code string, codeType string) error {
	userCode, err := s.CodeRepository.GetUserCode(email, codeType)
	if err != nil {
		return errors.New("could not get code")
	}

	if userCode.Code != code {
		return errors.New("code does not match")
	}

	return nil
}
