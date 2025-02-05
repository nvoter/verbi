package repositories

import (
	"VerbiAuth/internal/models"
	"gorm.io/gorm"
)

// UserRepository works with user database
type UserRepository struct {
	DB *gorm.DB
}

// NewUserRepository creates a user repository
func NewUserRepository(db *gorm.DB) *UserRepository {
	return &UserRepository{DB: db}
}

// CreateUser inserts a new user into the database
func (r *UserRepository) CreateUser(user *models.User) error {
	return r.DB.Create(user).Error
}

// UpdateUser updates an existing user in the database
func (r *UserRepository) UpdateUser(user *models.User) error {
	return r.DB.Updates(user).Error
}

// GetUserByEmail searches for a user in the database by email
func (r *UserRepository) GetUserByEmail(email string) (*models.User, error) {
	var user models.User
	err := r.DB.Where("email = ?", email).First(&user).Error
	return &user, err
}

// GetUserByUsername searches for a user in the database by username
func (r *UserRepository) GetUserByUsername(username string) (*models.User, error) {
	var user models.User
	err := r.DB.Where("username = ?", username).First(&user).Error
	return &user, err
}

// DeleteUser deletes user from the database
func (r *UserRepository) DeleteUser(user *models.User) error {
	return r.DB.Delete(user).Error
}
