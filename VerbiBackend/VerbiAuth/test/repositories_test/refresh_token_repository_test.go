package repositories_test

import (
	"VerbiAuth/internal/models"
	"VerbiAuth/internal/repositories"
	"github.com/stretchr/testify/assert"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"testing"
	"time"
)

// setupTestRefreshTokenDB creates and sets up a temporary database in memory
func setupTestRefreshTokenDB() (*gorm.DB, error) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	if err != nil {
		return nil, err
	}
	err = db.AutoMigrate(&models.RefreshToken{})
	if err != nil {
		return nil, err
	}
	return db, nil
}

// TestCreateToken tests token creation
func TestCreateToken(t *testing.T) {
	db, err := setupTestRefreshTokenDB()
	assert.NoError(t, err)
	repo := repositories.NewRefreshTokenRepository(db)
	token := &models.RefreshToken{
		UserID:    1,
		Token:     "test_token",
		ExpiresAt: time.Now().Add(time.Hour),
	}
	err = repo.CreateToken(token)
	assert.NoError(t, err)
	assert.NotZero(t, token.ID, "ID must be set after creation")

	var foundToken models.RefreshToken
	err = db.First(&foundToken, token.ID).Error
	assert.NoError(t, err)
	assert.Equal(t, token.Token, foundToken.Token)
}

// TestGetTokenByUserID tests getting token by user ID
func TestGetTokenByUserID(t *testing.T) {
	db, err := setupTestRefreshTokenDB()
	assert.NoError(t, err)
	repo := repositories.NewRefreshTokenRepository(db)
	token := &models.RefreshToken{
		UserID:    1,
		Token:     "test_token",
		ExpiresAt: time.Now().Add(time.Hour),
	}
	err = repo.CreateToken(token)
	assert.NoError(t, err)

	foundToken, err := repo.GetTokenByUserID(token.UserID)
	assert.NoError(t, err)
	assert.NotNil(t, foundToken)
	assert.Equal(t, token.Token, foundToken.Token)
}

// TestDeleteToken tests deleting token
func TestDeleteToken(t *testing.T) {
	db, err := setupTestRefreshTokenDB()
	assert.NoError(t, err)
	repo := repositories.NewRefreshTokenRepository(db)
	token := &models.RefreshToken{
		UserID:    1,
		Token:     "test_token",
		ExpiresAt: time.Now().Add(time.Hour),
	}
	err = repo.CreateToken(token)
	assert.NoError(t, err)

	err = repo.DeleteToken(token.Token)
	assert.NoError(t, err)

	_, err = repo.GetTokenByUserID(token.UserID)
	assert.Error(t, err)
}
