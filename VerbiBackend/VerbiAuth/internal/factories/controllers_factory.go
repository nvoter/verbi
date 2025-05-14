package factories

import (
	"VerbiAuth/internal/controllers"
	"VerbiAuth/internal/repositories"
	"VerbiAuth/internal/services"
	"errors"
	"gorm.io/gorm"
)

// ControllersFactory creates instances of AuthController and ProfileController
type ControllersFactory struct{}

// NewControllersFactory creates ControllersFactory
func NewControllersFactory() *ControllersFactory {
	return &ControllersFactory{}
}

// GetControllers creates new instances of AuthController and ProfileController with all necessary dependencies
func (f *ControllersFactory) GetControllers(db *gorm.DB) (*controllers.AuthController, *controllers.ProfileController, error) {
	userRepository := repositories.NewUserRepository(db)
	userCodeRepository := repositories.NewUserCodeRepository(db)
	refreshTokenRepository := repositories.NewRefreshTokenRepository(db)

	mailService, err := services.NewMailService()
	if err != nil {
		return nil, nil, errors.New("could not create mail service")
	}

	authService := services.NewAuthService(userRepository, refreshTokenRepository, userCodeRepository, mailService)
	authController := controllers.NewAuthController(authService)

	profileService := services.NewProfileService(userRepository)
	profileController := controllers.NewProfileController(profileService)

	return authController, profileController, nil
}
