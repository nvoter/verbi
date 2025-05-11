package requests

// LoginRequest presents data required for login
var LoginRequest struct {
	EmailOrUsername string `json:"emailOrUsername" binding:"required"`
	Password        string `json:"password" binding:"required,min=8"`
}
