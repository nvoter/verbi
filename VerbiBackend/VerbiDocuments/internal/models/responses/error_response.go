package responses

// ErrorResponse represents the server's response to a request that finished with an error
type ErrorResponse struct {
	Error string `json:"error"`
}
