package test

import (
	"testing"

	"VerbiAuth/internal/models"
	"VerbiAuth/internal/repositories"
	"github.com/stretchr/testify/assert"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

// setupTestDB creates and sets up a temporary database in memory
func setupTestDB() (*gorm.DB, error) {
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

// TestCreateUser tests user creation
func TestCreateUser(t *testing.T) {
	db, err := setupTestDB()
	assert.NoError(t, err)

	repo := repositories.NewUserRepository(db)

	user := &models.User{
		Username: "testuser",
		Email:    "test@example.com",
		Password: "password",
	}
	err = repo.CreateUser(user)
	assert.NoError(t, err)
	assert.NotZero(t, user.ID, "ID должен быть установлен после создания")

	var foundUser models.User
	err = db.First(&foundUser, user.ID).Error
	assert.NoError(t, err)
	assert.Equal(t, "testuser", foundUser.Username)
}

// TestUpdateUser tests user update
func TestUpdateUser(t *testing.T) {
	db, err := setupTestDB()
	assert.NoError(t, err)

	repo := repositories.NewUserRepository(db)

	user := &models.User{
		Username: "testuser",
		Email:    "test@example.com",
		Password: "password",
	}
	err = repo.CreateUser(user)
	assert.NoError(t, err)

	user.Email = "updated@example.com"
	err = repo.UpdateUser(user)
	assert.NoError(t, err)

	var updatedUser models.User
	err = db.First(&updatedUser, user.ID).Error
	assert.NoError(t, err)
	assert.Equal(t, "updated@example.com", updatedUser.Email)
}

// TestDeleteUser tests user deletion
func TestDeleteUser(t *testing.T) {
	db, err := setupTestDB()
	assert.NoError(t, err)

	repo := repositories.NewUserRepository(db)

	user := &models.User{
		Username: "testuser",
		Email:    "test@example.com",
		Password: "password",
	}
	err = repo.CreateUser(user)
	assert.NoError(t, err)

	err = repo.DeleteUser(user)
	assert.NoError(t, err)

	err = db.First(&user, user.ID).Error
	assert.Error(t, err)
}

// TestGetUserByEmail tests user search by email
func TestGetUserByEmail(t *testing.T) {
	db, err := setupTestDB()
	assert.NoError(t, err)

	repo := repositories.NewUserRepository(db)

	user := &models.User{
		Username: "testuser",
		Email:    "test@example.com",
		Password: "password",
	}
	err = repo.CreateUser(user)
	assert.NoError(t, err)

	foundUser, err := repo.GetUserByEmail(user.Email)
	assert.NoError(t, err)
	assert.NotNil(t, foundUser)
	assert.Equal(t, user.Username, foundUser.Username)

	_, err = repo.GetUserByEmail("nonexistent@example.com")
	assert.Error(t, err)
}

// TestGetUserByUsername tests user search by email username
func TestGetUserByUsername(t *testing.T) {
	db, err := setupTestDB()
	assert.NoError(t, err)

	repo := repositories.NewUserRepository(db)

	user := &models.User{
		Username: "testuser",
		Email:    "test@example.com",
		Password: "password",
	}
	err = repo.CreateUser(user)
	assert.NoError(t, err)

	foundUser, err := repo.GetUserByUsername(user.Username)
	assert.NoError(t, err)
	assert.NotNil(t, foundUser)
	assert.Equal(t, user.Email, foundUser.Email)

	_, err = repo.GetUserByUsername("nonexistent")
	assert.Error(t, err)
}
