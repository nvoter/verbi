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
// @Tags Auth
type AuthController struct {
	AuthService *services.AuthService
}

// NewAuthController creates a new AuthController
func NewAuthController(authService *services.AuthService) *AuthController {
	return &AuthController{
		AuthService: authService,
	}
}

// Register endpoint
// @Summary Register a new user
// @Description Register a new user with email, username and password
// @Tags Auth
// @ID register
// @Accept json
// @Produce json
// @Param form body requests.RegisterRequest true "Registration form"
// @Success 201 {string} string "Registration successful"
// @Failure 400 {object} responses.ErrorResponse
// @Router /auth/register [post]
func (c *AuthController) Register(ctx *gin.Context) {
	req := new(requests.RegisterRequest)
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err := c.AuthService.Register(req.Email, req.Username, req.Password)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusCreated, gin.H{"message": "Registration successful"})
}

// ConfirmEmail endpoint
// @Summary Confirms user's email
// @Description Checks the confirmation code and confirms user's email
// @Tags Auth
// @ID confirmEmail
// @Accept json
// @Produce json
// @Param email query string true "Email"
// @Param code query string true "Code value"
// @Success 200 {string} string "Email confirmed successfully"
// @Failure 400 {object} responses.ErrorResponse
// @Router /auth/email [get]
func (c *AuthController) ConfirmEmail(ctx *gin.Context) {
	email := ctx.Query("email")
	code := ctx.Query("code")

	if email == "" || code == "" {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Email or code is empty"})
		return
	}

	err := c.AuthService.ConfirmEmail(email, code)
	if err != nil {
		if err.Error() == "code does not match" {
			ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"message": "Email confirmed successfully"})
}

// Login endpoint
// @Summary Handles user login
// @Description Checks the correctness of account data and performs login
// @Tags Auth
// @ID login
// @Accept json
// @Produce json
// @Param emailOrUsername query string true "Email or username"
// @Param password header string true "Password"
// @Success 200 {object} responses.LoginResponse "Successful login"
// @Failure 400 {object} responses.ErrorResponse
// @Router /auth/login [get]
func (c *AuthController) Login(ctx *gin.Context) {
	emailOrUsername := ctx.Query("emailOrUsername")
	password := ctx.GetHeader("Password")

	loginResponse, err := c.AuthService.Login(emailOrUsername, password)
	if err != nil {
		if err.Error() == "user doesn't exist" {
			ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid email or username"})
			return
		} else if err.Error() == "invalid password" {
			ctx.JSON(http.StatusBadRequest, gin.H{"error": "Wrong password"})
			return
		}
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
// @Summary Handles user logout
// @Description Performs logout
// @Tags Auth
// @ID logout
// @Accept json
// @Produce json
// @Param refreshToken header string true "Refresh Token"
// @Success 200 {string} string "Successful logout"
// @Failure 400 {object} responses.ErrorResponse
// @Router /auth/logout [get]
func (c *AuthController) Logout(ctx *gin.Context) {
	refreshToken := ctx.GetHeader("Refresh-token")

	if refreshToken == "" {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Refresh token is empty"})
		return
	}

	err := c.AuthService.Logout(refreshToken)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"message": "Logout successful"})
}

// Refresh endpoint to refresh access token
// @Summary Handles refresh of access token
// @Description Checks the validity of refresh token and generates new access token
// @Tags Auth
// @ID refresh
// @Accept json
// @Produce json
// @Param refreshToken header string true "Refresh Token"
// @Success 200 {object} responses.RefreshResponse "Successful refresh"
// @Failure 400 {object} responses.ErrorResponse
// @Router /auth/refresh [get]
func (c *AuthController) Refresh(ctx *gin.Context) {
	refreshToken := ctx.GetHeader("Refresh-token")

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
// @Summary Handles password reset
// @Description Sends confirmation code to user's email
// @Tags Auth
// @ID resetPassword
// @Accept json
// @Produce json
// @Param email query string true "Email"
// @Success 200 {string} string "Confirmation code sent"
// @Failure 400 {object} responses.ErrorResponse
// @Router /auth/password [get]
func (c *AuthController) ResetPassword(ctx *gin.Context) {
	email := ctx.Query("email")

	err := c.AuthService.ResetPassword(email)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"message": "Confirmation code sent"})
}

// ConfirmResetPassword endpoint to verify account and confirm password reset
// @Summary Finishes the password reset process
// @Description Checks the correctness of the confirmation code and updates info if it's correct
// @Tags Auth
// @ID confirmResetPassword
// @Accept json
// @Produce json
// @Param request body requests.ConfirmResetPasswordRequest true "Request body"
// @Success 200 {string} string "Password reset successfully"
// @Failure 400 {object} responses.ErrorResponse
// @Router /auth/password [put]
func (c *AuthController) ConfirmResetPassword(ctx *gin.Context) {
	req := new(requests.ConfirmResetPasswordRequest)
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err := c.AuthService.ConfirmResetPassword(req.Email, req.NewPassword, req.Code)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"message": "Password reset successfully"})
}

// ResendCode endpoint handles resending confirmation code to user's email
// @Summary Handles resend code request
// @Description Resends confirmation code to user's email
// @Tags Auth
// @ID resendCode
// @Accept json
// @Produce json
// @Param email query string true "Email"
// @Param codeType query string true "Code type"
// @Success 200 {string} string "Confirmation code sent"
// @Failure 400 {object} responses.ErrorResponse
// @Router /auth/code [get]
func (c *AuthController) ResendCode(ctx *gin.Context) {
	email := ctx.Query("email")
	codeType := ctx.Query("code_type")

	if codeType != models.EmailConfirmation.String() && codeType != models.PasswordReset.String() {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "code type is invalid"})
		return
	}

	err := c.AuthService.ResendCode(email, codeType)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusCreated, gin.H{"message": "Code sent successfully"})
}
