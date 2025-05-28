package responses

// ValidateResponse represents the server's response to a request of access token validation
type ValidateResponse struct {
	UserId uint `json:"user_id"`
}
