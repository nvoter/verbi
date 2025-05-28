package factories

import (
	"VerbiDocuments/internal/controllers"
	"VerbiDocuments/internal/repositories"
	"VerbiDocuments/internal/services"
	"gorm.io/gorm"
)

// ControllerFactory creates an instance of DocumentsController with all necessary dependencies
type ControllerFactory struct{}

// NewControllerFactory creates ControllerFactory
func NewControllerFactory() *ControllerFactory { return &ControllerFactory{} }

// GetController function to create a new instance of DocumentsController with all necessary dependencies
func (f *ControllerFactory) GetController(db *gorm.DB) (*controllers.DocumentController, error) {
	documentRepository := repositories.NewDocumentRepository(db)
	sftpRepository := repositories.NewSftpRepository(db)
	sftpService := services.NewSftpService(sftpRepository)
	documentService := services.NewDocumentService(documentRepository, sftpRepository, sftpService)
	return controllers.NewDocumentController(documentService), nil
}
