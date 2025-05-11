package requests

// ResetPasswordRequest represents data required to change user's password
var ResetPasswordRequest struct {
	Email       string `json:"email" binding:"required,email"`
	OldPassword string `json:"old_password" binding:"required,min=8"`
}
