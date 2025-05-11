package controllers

import (
	"VerbiAuth/internal/models/requests"
	"VerbiAuth/internal/services"
	"github.com/gin-gonic/gin"
	"net/http"
	"strconv"
)

// ProfileController provides endpoints and handles HTTP requests related to profile management
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
func (c *ProfileController) ChangeUsername(ctx *gin.Context) {
	userId, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user id"})
		return
	}

	if err := ctx.ShouldBindJSON(&requests.ChangeUsernameRequest); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err = c.profileService.ChangeUsername(uint(userId), requests.ChangeUsernameRequest.NewUsername)
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
func (c *ProfileController) GetUserInfo(ctx *gin.Context) {
	userId, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user id"})
		return
	}

	getUserInfoResponse, err := c.profileService.GetUserInfo(uint(userId))
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
func (c *ProfileController) DeleteAccount(ctx *gin.Context) {
	userId, err := strconv.Atoi(ctx.Param("id"))
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user id"})
		return
	}

	err = c.profileService.DeleteAccount(uint(userId))
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"message": "Account deleted successfully"})
}
