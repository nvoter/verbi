package services

import (
	"VerbiAuth/internal/models"
	"VerbiAuth/internal/repositories"
	"VerbiAuth/internal/utils"
	"errors"
)

// AuthService to handle authentication actions
type AuthService struct {
	UserRepository *repositories.UserRepository
	CodeRepository *repositories.UserCodeRepository
	MailService    *MailService
}

// NewAuthService creates a new authentication service
func NewAuthService(
	userRepository *repositories.UserRepository,
	codeRepository *repositories.UserCodeRepository,
	mailService *MailService,
) *AuthService {
	return &AuthService{
		UserRepository: userRepository,
		CodeRepository: codeRepository,
		MailService:    mailService,
	}
}

// RequestRegistration starts the registration process
func (s *AuthService) RequestRegistration(email, username, password string) error {
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

// Register completes the registration process
func (s *AuthService) Register(email, code string) error {
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

// RequestResetPassword starts reset password process
func (s *AuthService) RequestResetPassword(email, oldPassword string) error {
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

// ResetPassword resets user's password
func (s *AuthService) ResetPassword(email, newPassword, code string) error {
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
func (s *AuthService) Login(emailOrUsername, password string) (string, error) {
	user, err := s.UserRepository.GetUserByEmail(emailOrUsername)
	if err != nil {
		user, err = s.UserRepository.GetUserByUsername(emailOrUsername)
	}
	if err != nil {
		return "", errors.New("user doesn't exist")
	}

	if !utils.CheckPasswordHash(password, user.Password) {
		return "", errors.New("invalid password")
	}

	token, err := utils.GenerateAccessToken(user.ID)
	if err != nil {
		return "", errors.New("could not generate token")
	}

	return token, nil
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
