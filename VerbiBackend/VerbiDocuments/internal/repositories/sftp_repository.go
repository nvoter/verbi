package repositories

import (
	"VerbiDocuments/internal/models"
	"gorm.io/gorm"
	"os"
)

// SftpRepository handles storage and retrieval of SFTP credentials
type SftpRepository struct {
	DB *gorm.DB
}

// NewSftpRepository creates a new SftpRepository
func NewSftpRepository(db *gorm.DB) *SftpRepository {
	return &SftpRepository{DB: db}
}

// SaveSftpCredentials saves temporary SFTP credentials for a user
func (r *SftpRepository) SaveSftpCredentials(userId uint, username, password string) error {
	credentials := models.SftpCredentials{
		UserId:   userId,
		Username: username,
		Password: password,
		Host:     os.Getenv("SFTP_HOST"),
		Port:     os.Getenv("SFTP_PORT"),
	}

	return r.DB.Create(&credentials).Error
}

// GetSftpCredentials retrieves temporary sftp credentials for a user
func (r *SftpRepository) GetSftpCredentials(userId uint) (*models.SftpCredentials, error) {
	var credentials models.SftpCredentials
	err := r.DB.Where("user_id = ?", userId).First(&credentials).Error
	return &credentials, err
}

// DeleteSftpCredentials deletes credentials of user with userId from the database
func (r *SftpRepository) DeleteSftpCredentials(userId uint) error {
	return r.DB.Where("user_id = ?", userId).Delete(&models.SftpCredentials{}).Error
}

// GetSftpCredentialsByUsername retrieves temporary SFTP credentials for a user with the given username
func (r *SftpRepository) GetSftpCredentialsByUsername(username string) (*models.SftpCredentials, error) {
	var credentials models.SftpCredentials
	err := r.DB.Where("username = ?", username).First(&credentials).Error
	return &credentials, err
}
