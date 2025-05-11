package requests

// ChangeUsernameRequest represents data required to change username
var ChangeUsernameRequest struct {
	NewUsername string `json:"newUsername" binding:"required"`
}
