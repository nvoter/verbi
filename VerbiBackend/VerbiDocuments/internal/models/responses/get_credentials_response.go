package responses

// GetCredentialsResponse represents the response with SFTP credentials
type GetCredentialsResponse struct {
	Username string `json:"username"`
	Password string `json:"password"`
	Host     string `json:"host"`
	Port     string `json:"port"`
}
