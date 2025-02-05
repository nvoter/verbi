package repositories

import (
	"VerbiAuth/internal/models"
	"gorm.io/gorm"
	"time"
)

// UserCodeRepository works with user code repository
type UserCodeRepository struct {
	DB *gorm.DB
}

// NewUserCodeRepository creates a user code repository
func NewUserCodeRepository(db *gorm.DB) *UserCodeRepository {
	return &UserCodeRepository{DB: db}
}

// CreateCode inserts a new code into the database
func (r *UserCodeRepository) CreateCode(userCode *models.UserCode) error {
	return r.DB.Create(userCode).Error
}

// UpdateCode updates an existing code in the database
func (r *UserCodeRepository) UpdateCode(userCode *models.UserCode) error {
	return r.DB.Updates(userCode).Error
}

// GetUserCode returns code by userId and type
func (r *UserCodeRepository) GetUserCode(userID uint, codeType string) (*models.UserCode, error) {
	var userCode models.UserCode
	err := r.DB.Where("user_id = ? AND type = ? AND expires_at > ?", userID, codeType, time.Now()).First(&userCode).Error
	return &userCode, err
}

// DeleteCode deletes code from the database
func (r *UserCodeRepository) DeleteCode(userId uint, codeType string) error {
	return r.DB.Where("user_id = ? AND type = ?", userId, codeType).Delete(&models.UserCode{}).Error
}
