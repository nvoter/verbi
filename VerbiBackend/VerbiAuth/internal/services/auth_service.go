package services

import (
	"VerbiAuth/internal/interfaces"
	"VerbiAuth/internal/models"
	"VerbiAuth/internal/models/responses"
	"VerbiAuth/internal/repositories"
	"VerbiAuth/internal/utils"
	"errors"
	"log"
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
		log.Println("[AUTH] Register: Email already taken")
		return errors.New("user with this email already exists")
	}

	_, err = s.UserRepository.GetUserByUsername(username)
	if err == nil {
		log.Println("[AUTH] Register: Username already taken")
		return errors.New("user with this username already exists")
	}

	hashedPassword, err := utils.HashPassword(password)
	if err != nil {
		log.Println("[AUTH] Register: Error hashing password")
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
		log.Println("[AUTH] Register: Error creating user")
		return errors.New("could not create temporary user")
	}

	err = s.sendCode(user.Email, models.EmailConfirmation.String())
	if err != nil {
		log.Println("[AUTH] Register: Error sending code")
		return errors.New("could not send code")
	}

	return nil
}

// ConfirmEmail confirms user email if the confirmation code is correct
func (s *AuthService) ConfirmEmail(email, code string) error {
	user, err := s.UserRepository.GetUserByEmail(email)
	if err != nil {
		log.Println("[AUTH] Confirm Email: Error getting user")
		return errors.New("could not get user by email")
	}

	err = s.checkCode(email, code, models.EmailConfirmation.String())
	if err != nil {
		log.Println("[AUTH] Confirm Email: Error checking code", err.Error())
		return errors.New(err.Error())
	}

	user.IsEmailConfirmed = true
	err = s.UserRepository.UpdateUser(user)
	if err != nil {
		log.Println("[AUTH] Confirm Email: Error updating user")
		return errors.New("could not update user")
	}

	err = s.CodeRepository.DeleteCode(email, models.EmailConfirmation.String())
	if err != nil {
		log.Println("[AUTH] Confirm Email: Error deleting code")
		return errors.New("could not delete code")
	}

	return nil
}

// ResetPassword starts reset password process
func (s *AuthService) ResetPassword(email string) error {
	user, err := s.UserRepository.GetUserByEmail(email)
	if err != nil {
		log.Println("[AUTH] Reset Password: Error getting user")
		return errors.New("user with this email doesn't exist")
	}

	err = s.sendCode(user.Email, models.PasswordReset.String())
	if err != nil {
		log.Println("[AUTH] Reset Password: Error sending code")
		return errors.New("could not send code")
	}

	return nil
}

// ConfirmResetPassword confirms the password reset if the code is correct
func (s *AuthService) ConfirmResetPassword(email, newPassword, code string) error {
	user, err := s.UserRepository.GetUserByEmail(email)
	if err != nil {
		log.Println("[AUTH] Confirm Reset Password: Error getting user")
		return errors.New("user with this email doesn't exist")
	}

	err = s.checkCode(email, code, models.PasswordReset.String())
	if err != nil {
		log.Println("[AUTH] Confirm Reset Password: Error checking code", err.Error())
		return errors.New(err.Error())
	}

	err = s.CodeRepository.DeleteCode(email, models.PasswordReset.String())
	if err != nil {
		log.Println("[AUTH] Confirm Reset Password: Error deleting code")
		return errors.New("could not delete code")
	}

	hashedPassword, err := utils.HashPassword(newPassword)
	if err != nil {
		log.Println("[AUTH] Confirm Reset Password: Error hashing password")
		return errors.New("could not hash password")
	}

	user.Password = hashedPassword

	err = s.UserRepository.UpdateUser(user)
	if err != nil {
		log.Println("[AUTH] Confirm Reset Password: Error updating user")
		return errors.New("could not update user")
	}

	return nil
}

// ResendCode resends code to email
func (s *AuthService) ResendCode(email, codeType string) error {
	err := s.CodeRepository.DeleteCode(email, codeType)
	if err != nil {
		log.Println("[AUTH] Resend Code: Error deleting code")
		return errors.New("could not delete old confirmation code")
	}

	err = s.sendCode(email, codeType)
	if err != nil {
		log.Println("[AUTH] Resend Code: Error sending code")
		return errors.New(err.Error())
	}

	return nil
}

// Login processes a login request
func (s *AuthService) Login(emailOrUsername, password string) (*responses.LoginResponse, error) {
	user, err := s.UserRepository.GetUserByEmail(emailOrUsername)
	if err != nil {
		log.Println("[AUTH] Login: User with this email doesn't exist")
		log.Println("[AUTH] email:", emailOrUsername)
		user, err = s.UserRepository.GetUserByUsername(emailOrUsername)
	}
	if err != nil {
		log.Println("[AUTH] Login: User with this username doesn't exist")
		return nil, errors.New("user doesn't exist")
	}

	if !utils.CheckPasswordHash(password, user.Password) {
		log.Println("[AUTH] Login: Invalid password")
		return nil, errors.New("invalid password")
	}

	accessToken, err := utils.GenerateAccessToken(user.ID)
	if err != nil {
		log.Println("[AUTH] Login: Error generating access token")
		return nil, errors.New("could not generate access token")
	}

	refreshTokenString, err := utils.GenerateRefreshToken()
	if err != nil {
		log.Println("[AUTH] Login: Error generating refresh token")
		return nil, errors.New("could not generate refresh token")
	}

	refreshToken := &models.RefreshToken{
		UserID:    user.ID,
		Token:     refreshTokenString,
		ExpiresAt: time.Now().Add(time.Hour * 7 * 24),
	}

	err = s.RefreshTokenRepository.CreateToken(refreshToken)
	if err != nil {
		log.Println("[AUTH] Login: Error saving refresh token")
		return nil, errors.New("could not save refresh token")
	}

	return &responses.LoginResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken.Token,
		ExpiresIn:    "7d",
	}, nil
}

// Logout processes a logout request
func (s *AuthService) Logout(refreshToken string) error {
	err := s.RefreshTokenRepository.DeleteToken(refreshToken)
	if err != nil {
		log.Println("[AUTH] Logout: Error deleting refresh token")
		return errors.New("could not delete refresh token")
	}
	return nil
}

// Refresh function to refresh access token
func (s *AuthService) Refresh(token string) (string, error) {
	refreshToken, err := s.RefreshTokenRepository.GetTokenByValue(token)
	if err != nil {
		log.Println("[AUTH] Refresh: Error getting refresh token")
		return "", errors.New("could not get refresh token")
	}

	if refreshToken.ExpiresAt.Before(time.Now()) {
		log.Println("[AUTH] Refresh: Token expired")
		return "", errors.New("refresh token is expired")
	}

	accessToken, err := utils.GenerateAccessToken(refreshToken.UserID)
	if err != nil {
		log.Println("[AUTH] Refresh: Error generating access token")
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
		log.Println("[AUTH] SendCode: Error creating code")
		return errors.New("could not create confirmation code")
	}

	if codeType == models.EmailConfirmation.String() {
		err = s.MailService.SendMail(email, "Verbi verification code", "To continue setting up your verbi account, please verify your account with the code: "+confirmationCode.Code)
	} else {
		err = s.MailService.SendMail(email, "Reset verbi password", "To reset your password, please confirm your account with the code: "+confirmationCode.Code)
	}
	if err != nil {
		log.Println("[AUTH] SendCode: Error sending code")
		return errors.New("failed to send verification code")
	}

	return nil
}

// checkCode checks if the code is correct
func (s *AuthService) checkCode(email, code string, codeType string) error {
	userCode, err := s.CodeRepository.GetUserCode(email, codeType)
	if err != nil {
		log.Println("[AUTH] CheckCode: Error getting user code")
		return errors.New("could not get code")
	}

	if userCode.Code != code {
		log.Println("[AUTH] CheckCode: User code doesn't match")
		return errors.New("code does not match")
	}

	return nil
}
