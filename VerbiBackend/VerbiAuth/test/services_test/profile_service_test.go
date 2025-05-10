package services_test

import (
	"VerbiAuth/internal/models"
	"VerbiAuth/internal/repositories"
	"VerbiAuth/internal/services"
	"github.com/stretchr/testify/assert"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"testing"
)

// setupTestProfileDB creates and sets up a temporary database in memory
func setupTestProfileDB() (*gorm.DB, error) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	if err != nil {
		return nil, err
	}
	err = db.AutoMigrate(&models.User{})
	if err != nil {
		return nil, err
	}
	return db, nil
}

// setupProfileService sets up the ProfileService with test dependencies
func setupProfileService(db *gorm.DB) (*services.ProfileService, error) {
	userRepo := repositories.NewUserRepository(db)
	profileService := services.NewProfileService(userRepo)
	return profileService, nil
}

// TestChangeUsername tests changing the username
func TestChangeUsername(t *testing.T) {
	db, err := setupTestDB()
	assert.NoError(t, err)
	profileService, err := setupProfileService(db)
	assert.NoError(t, err)

	user := &models.User{
		Username: "testuser",
		Email:    "test@example.com",
		Password: "password",
	}
	err = profileService.UserRepository.CreateUser(user)
	assert.NoError(t, err)

	err = profileService.ChangeUsername(user.ID, "testuser")
	assert.Error(t, err)

	newUsername := "newtestuser"
	err = profileService.ChangeUsername(user.ID, newUsername)
	assert.NoError(t, err)

	updatedUser, err := profileService.UserRepository.GetUserById(user.ID)
	assert.NoError(t, err)
	assert.Equal(t, newUsername, updatedUser.Username)
}

// TestGetUserInfo tests getting user info
func TestGetUserInfo(t *testing.T) {
	db, err := setupTestProfileDB()
	assert.NoError(t, err)
	profileService, err := setupProfileService(db)
	assert.NoError(t, err)

	user := &models.User{
		Username: "testuser",
		Email:    "test@example.com",
		Password: "password",
	}
	err = profileService.UserRepository.CreateUser(user)
	assert.NoError(t, err)

	userInfo, err := profileService.GetUserInfo(user.ID)
	assert.NoError(t, err)
	assert.NotNil(t, userInfo)
	assert.Equal(t, user.Username, userInfo.Username)
	assert.Equal(t, user.Email, userInfo.Email)

	nonExistentUser, err := profileService.GetUserInfo(999)
	assert.Error(t, err)
	assert.Nil(t, nonExistentUser)
}

// TestDeleteAccount tests deleting a user account
func TestDeleteAccount(t *testing.T) {
	db, err := setupTestDB()
	assert.NoError(t, err)
	profileService, err := setupProfileService(db)
	assert.NoError(t, err)

	user := &models.User{
		Username: "testuser",
		Email:    "test@example.com",
		Password: "password",
	}
	err = profileService.UserRepository.CreateUser(user)
	assert.NoError(t, err)

	err = profileService.DeleteAccount(user.ID)
	assert.NoError(t, err)

	deletedUser, err := profileService.UserRepository.GetUserById(user.ID)
	assert.Error(t, err)

	if deletedUser.ID == 0x0 {
		deletedUser = nil
	}
	assert.Nil(t, deletedUser)

	err = profileService.DeleteAccount(999)
	assert.Error(t, err)
}
