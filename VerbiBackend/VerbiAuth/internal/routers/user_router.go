package routers

import (
	"VerbiAuth/internal/controllers"
	"VerbiAuth/internal/middleware"
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"time"
)

// SetupRoutes sets up the routes for auth and profile management actions
func SetupRoutes(r *gin.Engine, authController *controllers.AuthController, profileController *controllers.ProfileController) {
	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization", "Refresh-Token", "Password"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))

	api := r.Group("/api/v1")

	authGroup := api.Group("/auth")
	{
		authGroup.POST("/register", authController.Register)
		authGroup.GET("/email", authController.ConfirmEmail)
		authGroup.GET("/login", authController.Login)
		authGroup.GET("/logout", authController.Logout)
		authGroup.GET("/password", authController.ResetPassword)
		authGroup.PUT("/password", authController.ConfirmResetPassword)
		authGroup.GET("/code", authController.ResendCode)
		authGroup.GET("/refresh", authController.Refresh)
	}

	profileGroup := api.Group("/profile")
	profileGroup.Use(middleware.AuthMiddleware())
	{
		profileGroup.GET("/", profileController.GetUserInfo)
		profileGroup.PUT("/", profileController.ChangeUsername)
		profileGroup.DELETE("/", profileController.DeleteAccount)
	}
}
