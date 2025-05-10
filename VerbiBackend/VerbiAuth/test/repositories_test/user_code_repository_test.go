package repositories

import (
	"VerbiAuth/internal/models"
	"VerbiAuth/internal/repositories"
	"github.com/stretchr/testify/assert"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"testing"
)

// setupTestDB creates and sets up a temporary database in memory
func setupTestDB() (*gorm.DB, error) {
	db, err := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	if err != nil {
		return nil, err
	}

	err = db.AutoMigrate(&models.UserCode{})
	if err != nil {
		return nil, err
	}

	return db, nil
}

// TestCreateCode tests code creation
func TestCreateCode(t *testing.T) {
	db, err := setupTestDB()
	assert.NoError(t, err)

	repo := repositories.NewUserCodeRepository(db)

	code := &models.UserCode{
		UserEmail: "test@example.com",
		Code:      "123456",
		Type:      models.EmailConfirmation.String(),
	}
	err = repo.CreateCode(code)
	assert.NoError(t, err)

	var foundCode models.UserCode
	err = db.First(&foundCode, code.ID).Error
	assert.NoError(t, err)
	assert.Equal(t, code.Code, foundCode.Code)
	assert.NotNil(t, foundCode.ExpiresAt)
}

// TestUpdateCode tests code update
func TestUpdateCode(t *testing.T) {
	db, err := setupTestDB()
	assert.NoError(t, err)

	repo := repositories.NewUserCodeRepository(db)

	code := &models.UserCode{
		UserEmail: "test@example.com",
		Code:      "123456",
		Type:      models.EmailConfirmation.String(),
	}
	err = repo.CreateCode(code)
	assert.NoError(t, err)

	code.Code = "789012"
	err = repo.UpdateCode(code)
	assert.NoError(t, err)

	var updatedCode models.UserCode
	err = db.First(&updatedCode, code.ID).Error
	assert.NoError(t, err)
	assert.Equal(t, code.Code, updatedCode.Code)
}

// TestDeleteCode tests code deletion
func TestDeleteCode(t *testing.T) {
	db, err := setupTestDB()
	assert.NoError(t, err)

	repo := repositories.NewUserCodeRepository(db)

	code := &models.UserCode{
		UserEmail: "test@example.com",
		Code:      "123456",
		Type:      models.EmailConfirmation.String(),
	}
	err = repo.CreateCode(code)
	assert.NoError(t, err)

	err = repo.DeleteCode(code.UserEmail, code.Type)
	assert.NoError(t, err)

	err = db.First(&code, code.ID).Error
	assert.Error(t, err)
}

// TestGetUserCode tests code search by userId and codeType
func TestGetUserCode(t *testing.T) {
	db, err := setupTestDB()
	assert.NoError(t, err)

	repo := repositories.NewUserCodeRepository(db)

	code := &models.UserCode{
		UserEmail: "test@example.com",
		Code:      "123456",
		Type:      models.EmailConfirmation.String(),
	}
	err = repo.CreateCode(code)
	assert.NoError(t, err)

	foundCode, err := repo.GetUserCode(code.UserEmail, code.Type)
	assert.NoError(t, err)
	assert.NotNil(t, foundCode)
	assert.Equal(t, code.Code, foundCode.Code)
}
