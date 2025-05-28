package repositories

import (
	"VerbiDocuments/internal/models"
	"gorm.io/gorm"
)

// DocumentRepository works with documents database
type DocumentRepository struct {
	DB *gorm.DB
}

// NewDocumentRepository creates a document repository
func NewDocumentRepository(db *gorm.DB) *DocumentRepository {
	return &DocumentRepository{DB: db}
}

// CreateDocument inserts a new document into the database
func (r *DocumentRepository) CreateDocument(document *models.Document) (uint, error) {
	err := r.DB.Create(document).Error
	if err != nil {
		return 0, err
	}
	return document.ID, nil
}

// GetDocumentsByUserId returns a list of all documents uploaded by the user
func (r *DocumentRepository) GetDocumentsByUserId(userId uint) ([]*models.Document, error) {
	var documents []*models.Document
	err := r.DB.Where("user_id = ?", userId).Find(&documents).Error
	return documents, err
}

// DeleteDocument deletes a document from the database by id
func (r *DocumentRepository) DeleteDocument(id uint) error {
	return r.DB.Where("id = ?", id).Delete(&models.Document{}).Error
}

// EraseLinkedByUserId deletes all user's documents from the database
func (r *DocumentRepository) EraseLinkedByUserId(id uint) error {
	return r.DB.Where("user_id = ?", id).Delete(&models.Document{}).Error
}

// UpdateDocumentPath updates a path of the document with the given id in the database
func (r *DocumentRepository) UpdateDocumentPath(id uint, path string) error {
	return r.DB.Model(&models.Document{}).Where("id = ?", id).Update("path", path).Error
}
