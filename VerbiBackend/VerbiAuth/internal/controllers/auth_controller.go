package controllers

import (
	"VerbiAuth/internal/models"
	"VerbiAuth/internal/models/requests"
	"VerbiAuth/internal/services"
	"github.com/gin-gonic/gin"
	"net/http"
	"time"
)

// AuthController provides endpoints and handles HTTP requests related to authentication actions
type AuthController struct {
	AuthService *services.AuthService
}

// NewAuthController creates a new AuthController
func NewAuthController(authService *services.AuthService) *AuthController {
	return &AuthController{
		AuthService: authService,
	}
}

// Register endpoint handles user registration
func (c *AuthController) Register(ctx *gin.Context) {
	if err := ctx.ShouldBindJSON(&requests.RegisterRequest); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err := c.AuthService.Register(requests.RegisterRequest.Email, requests.RegisterRequest.Username, requests.RegisterRequest.Password)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusCreated, gin.H{"message": "Registration successful"})
}

// ConfirmEmail endpoint checks the confirmation code and confirms user's email
func (c *AuthController) ConfirmEmail(ctx *gin.Context) {
	email := ctx.Query("email")
	code := ctx.Query("code")

	if email == "" || code == "" {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "email or code is empty"})
		return
	}

	err := c.AuthService.ConfirmEmail(email, code)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusCreated, gin.H{"message": "Email confirmed successfully"})
}

// Login endpoint handles user login
func (c *AuthController) Login(ctx *gin.Context) {
	if err := ctx.ShouldBindJSON(&requests.LoginRequest); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	loginResponse, err := c.AuthService.Login(requests.LoginRequest.EmailOrUsername, requests.LoginRequest.Password)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"access_token":  loginResponse.AccessToken,
		"refresh_token": loginResponse.RefreshToken,
		"expires_in":    time.Hour * 7 * 24,
	})
}

// Logout endpoint handles user logout
func (c *AuthController) Logout(ctx *gin.Context) {
	if err := ctx.ShouldBindJSON(&requests.LogoutRequest); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err := c.AuthService.Logout(requests.LogoutRequest.RefreshToken)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"message": "Logout successful"})
}

// Refresh endpoint to refresh access token
func (c *AuthController) Refresh(ctx *gin.Context) {
	refreshToken := ctx.Query("refresh_token")
	if refreshToken == "" {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "refresh_token is empty"})
		return
	}

	accessToken, err := c.AuthService.Refresh(refreshToken)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"access_token": accessToken,
	})
}

// ResetPassword endpoint handles reset password request
func (c *AuthController) ResetPassword(ctx *gin.Context) {
	if err := ctx.ShouldBindJSON(&requests.ResetPasswordRequest); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err := c.AuthService.ResetPassword(requests.ResetPasswordRequest.Email, requests.ResetPasswordRequest.OldPassword)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusCreated, gin.H{"message": "Confirmation code sent"})
}

// ConfirmResetPassword endpoint to verify account and confirm password reset
func (c *AuthController) ConfirmResetPassword(ctx *gin.Context) {
	if err := ctx.ShouldBindJSON(&requests.ConfirmResetPasswordRequest); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err := c.AuthService.ConfirmResetPassword(requests.ConfirmResetPasswordRequest.Email, requests.ConfirmResetPasswordRequest.NewPassword, requests.ConfirmResetPasswordRequest.Code)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"message": "Password reset successfully"})
}

// ResendCode endpoint handles resending confirmation code to user's email
func (c *AuthController) ResendCode(ctx *gin.Context) {
	if err := ctx.ShouldBindJSON(&requests.ResendCodeRequest); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if requests.ResendCodeRequest.CodeType != models.EmailConfirmation.String() && requests.ResendCodeRequest.CodeType != models.PasswordReset.String() {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "code type is invalid"})
		return
	}

	err := c.AuthService.ResendCode(requests.ResendCodeRequest.Email, requests.ResendCodeRequest.CodeType)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusCreated, gin.H{"message": "Code sent successfully"})
}
