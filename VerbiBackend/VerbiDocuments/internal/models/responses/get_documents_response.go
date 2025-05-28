package responses

import "VerbiDocuments/internal/models"

// GetDocumentsResponse represents server response on getDocuments request
type GetDocumentsResponse struct {
	Documents []*models.Document `json:"documents"`
}
