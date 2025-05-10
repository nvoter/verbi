package services

import (
	"VerbiAuth/internal/models"
	"VerbiAuth/internal/repositories"
	"errors"
)

// ProfileService to handle actions related to account management
type ProfileService struct {
	UserRepository *repositories.UserRepository
}

// NewProfileService creates an instance of profile service
func NewProfileService(userRepository *repositories.UserRepository) *ProfileService {
	return &ProfileService{UserRepository: userRepository}
}

// ChangeUsername method to change username
func (s *ProfileService) ChangeUsername(userId uint, newUsername string) error {
	_, err := s.UserRepository.GetUserByUsername(newUsername)
	if err == nil {
		return errors.New("User with this username already exists")
	}

	user, err := s.UserRepository.GetUserById(userId)
	if err != nil {
		return errors.New("User with this id not found")
	}

	user.Username = newUsername
	err = s.UserRepository.UpdateUser(user)
	if err != nil {
		return errors.New("Error updating username")
	}

	return nil
}

// GetUserInfo method to get user data
func (s *ProfileService) GetUserInfo(userId uint) (*models.User, error) {
	user, err := s.UserRepository.GetUserById(userId)
	if err != nil {
		return nil, errors.New("User with this id not found")
	}
	return user, nil
}

// DeleteAccount function to delete profile from the app
func (s *ProfileService) DeleteAccount(userId uint) error {
	user, err := s.UserRepository.GetUserById(userId)
	if err != nil {
		return errors.New("User with this id not found")
	}

	err = s.UserRepository.DeleteUser(user)
	if err != nil {
		return errors.New("User with this id not found")
	}

	return nil
}
