package responses

// GetUserInfoResponse represents user profile data returned in response on get request
type GetUserInfoResponse struct {
	Username string `json:"username"`
	Email    string `json:"email"`
}
