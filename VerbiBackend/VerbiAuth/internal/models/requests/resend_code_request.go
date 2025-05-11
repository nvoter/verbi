package requests

// ResendCodeRequest represents data required for confirmation code resending
var ResendCodeRequest struct {
	Email    string `json:"email"`
	CodeType string `json:"code_type"`
}
