package repositories

import (
	"VerbiAuth/internal/models"
	"gorm.io/gorm"
)

// RefreshTokenRepository works with refresh token database
type RefreshTokenRepository struct {
	DB *gorm.DB
}

// NewRefreshTokenRepository creates a refresh token repository
func NewRefreshTokenRepository(db *gorm.DB) *RefreshTokenRepository {
	return &RefreshTokenRepository{DB: db}
}

// CreateToken inserts a new user into the database
func (r *RefreshTokenRepository) CreateToken(token *models.RefreshToken) error {
	return r.DB.Create(token).Error
}

// GetTokenByUserID searches for a token in the database by userID
func (r *RefreshTokenRepository) GetTokenByUserID(userID uint) (*models.RefreshToken, error) {
	var refreshToken models.RefreshToken
	err := r.DB.Where("user_id = ?", userID).First(&refreshToken).Error
	return &refreshToken, err
}

// DeleteToken deletes token from the database
func (r *RefreshTokenRepository) DeleteToken(token string) error {
	return r.DB.Where("token = ?", token).Delete(&models.RefreshToken{}).Error
}
