package requests

// CreateDocumentRequest represents data required to save a new document in the library
type CreateDocumentRequest struct {
	UserId uint   `json:"user_id"`
	Title  string `json:"title"`
}
