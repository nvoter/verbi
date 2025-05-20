package requests

// ConfirmResetPasswordRequest represents data required for verifying account and password resetting
type ConfirmResetPasswordRequest struct {
	Email       string `json:"email" binding:"required,email"`
	NewPassword string `json:"new_password" binding:"required,min=8"`
	Code        string `json:"code" binding:"required,min=6,max=6"`
}
