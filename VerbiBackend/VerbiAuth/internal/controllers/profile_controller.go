package controllers

import (
	"VerbiAuth/internal/models/requests"
	"VerbiAuth/internal/services"
	"github.com/gin-gonic/gin"
	"net/http"
)

// ProfileController provides endpoints and handles HTTP requests related to profile management
// @Tags Profile
type ProfileController struct {
	profileService *services.ProfileService
}

// NewProfileController creates a new ProfileController
func NewProfileController(profileService *services.ProfileService) *ProfileController {
	return &ProfileController{
		profileService: profileService,
	}
}

// ChangeUsername endpoint handles change username request
// @Summary Handles username change
// @Description Checks the accessibility of new username and updates info
// @Tags Profile
// @ID changeUsername
// @Accept json
// @Produce json
// @Param request body requests.ChangeUsernameRequest true "Request body"
// @Success 200 {string} string "Username changed successfully"
// @Failure 400 {object} responses.ErrorResponse
// @Failure 401 {object} responses.ErrorResponse
// @Security BearerAuth
// @Router /profile [put]
func (c *ProfileController) ChangeUsername(ctx *gin.Context) {
	userId, exists := ctx.Get("user_id")
	if !exists {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	userIdFloat, ok := userId.(float64)
	if !ok {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid user Id type"})
		return
	}

	userIdUint := uint(userIdFloat)

	req := new(requests.ChangeUsernameRequest)
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err := c.profileService.ChangeUsername(userIdUint, req.NewUsername)
	if err != nil {
		if err.Error() == "User with this username already exists" || err.Error() == "User with this id not found" {
			ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"message": "Username changed successfully"})
}

// GetUserInfo endpoint to get user profile data
// @Summary Gives info about profile
// @Description Returns user's username and email
// @Tags Profile
// @ID getUserInfo
// @Accept json
// @Produce json
// @Success 200 {object} responses.GetUserInfoResponse "OK"
// @Failure 400 {object} responses.ErrorResponse
// @Failure 404 {object} responses.ErrorResponse
// @Security BearerAuth
// @Router /profile [get]
func (c *ProfileController) GetUserInfo(ctx *gin.Context) {
	userId, exists := ctx.Get("user_id")
	if !exists {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	userIdFloat, ok := userId.(float64)
	if !ok {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid user ID type"})
		return
	}

	userIdUint := uint(userIdFloat)

	getUserInfoResponse, err := c.profileService.GetUserInfo(userIdUint)
	if err != nil {
		if err.Error() == "User with this id not found" {
			ctx.JSON(http.StatusNotFound, gin.H{"error": "User with this id not found"})
			return
		}

		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	if getUserInfoResponse == nil || getUserInfoResponse.Username == "" || getUserInfoResponse.Email == "" {
		ctx.JSON(http.StatusNotFound, gin.H{"error": "User with this id not found"})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"username": getUserInfoResponse.Username,
		"email":    getUserInfoResponse.Email,
	})
}

// DeleteAccount endpoint deletes all user info from the database
// @Summary Handles account deletion
// @Description Deletes all user info from the database
// @Tags Profile
// @ID delete
// @Accept json
// @Produce json
// @Success 200 {string} string "Account successfully deleted"
// @Failure 400 {object} responses.ErrorResponse
// @Security BearerAuth
// @Router /profile [delete]
func (c *ProfileController) DeleteAccount(ctx *gin.Context) {
	userId, exists := ctx.Get("user_id")
	if !exists {
		ctx.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	userIdFloat, ok := userId.(float64)
	if !ok {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Invalid user ID type"})
		return
	}

	userIdUint := uint(userIdFloat)

	err := c.profileService.DeleteAccount(userIdUint)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"message": "Account deleted successfully"})
}
