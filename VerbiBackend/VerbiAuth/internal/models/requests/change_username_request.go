package requests

// ChangeUsernameRequest represents data required to change username
type ChangeUsernameRequest struct {
	NewUsername string `json:"new_username" binding:"required"`
}
