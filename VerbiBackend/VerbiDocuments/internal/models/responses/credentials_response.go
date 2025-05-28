package responses

// CredentialsResponse represents the response with sftp credentials
type CredentialsResponse struct {
	DocumentId uint   `json:"document_id"`
	Title      string `json:"title"`
	Path       string `json:"path"`
	Sftp       struct {
		Username string `json:"username"`
		Password string `json:"password"`
		Host     string `json:"host"`
		Port     string `json:"port"`
	} `json:"sftp"`
}
