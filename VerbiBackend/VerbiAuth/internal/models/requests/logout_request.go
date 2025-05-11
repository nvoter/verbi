package requests

// LogoutRequest presents data required got logout
var LogoutRequest struct {
	RefreshToken string `json:"refresh_token" binding:"required"`
}
