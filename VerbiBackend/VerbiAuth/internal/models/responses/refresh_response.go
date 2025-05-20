package responses

// RefreshResponse represents the model of the server's response to a refresh request
type RefreshResponse struct {
	AccessToken string `json:"access_token"`
}
