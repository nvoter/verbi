package services

import (
	"VerbiDocuments/internal/models"
	"VerbiDocuments/internal/repositories"
	"crypto/rand"
	"encoding/base64"
	"fmt"
	"os"
)

// DocumentService handles actions related to documents management
type DocumentService struct {
	DocumentRepository *repositories.DocumentRepository
	SftpRepository     *repositories.SftpRepository
	SftpService        *SftpService
}

// NewDocumentService creates a new document service
func NewDocumentService(
	documentRepository *repositories.DocumentRepository,
	sftpRepository *repositories.SftpRepository,
	sftpService *SftpService,
) *DocumentService {
	return &DocumentService{
		DocumentRepository: documentRepository,
		SftpRepository:     sftpRepository,
		SftpService:        sftpService,
	}
}

// generateRandomString generates a random string for temporary credentials
func generateRandomString(length int) (string, error) {
	b := make([]byte, length)
	_, err := rand.Read(b)
	if err != nil {
		return "", err
	}
	return base64.URLEncoding.EncodeToString(b)[:length], nil
}

// CreateDocument saves a new document metadata in the database and creates SFTP directory
func (s *DocumentService) CreateDocument(userId uint, title string) (map[string]interface{}, error) {
	tempUsername, err := generateRandomString(10)
	if err != nil {
		return nil, fmt.Errorf("failed to generate temporary username: %w", err)
	}

	tempPassword, err := generateRandomString(16)
	if err != nil {
		return nil, fmt.Errorf("failed to generate temporary password: %w", err)
	}

	document := &models.Document{
		UserId: userId,
		Title:  title,
	}

	id, err := s.DocumentRepository.CreateDocument(document)
	if err != nil {
		return nil, fmt.Errorf("failed to save document metadata: %w", err)
	}
	document.Path = fmt.Sprintf("/%d/%d", userId, id)
	err = s.DocumentRepository.UpdateDocumentPath(id, document.Path)
	if err != nil {
		return nil, fmt.Errorf("failed to update document path: %w", err)
	}

	err = s.SftpRepository.SaveSftpCredentials(userId, tempUsername, tempPassword)
	if err != nil {
		return nil, fmt.Errorf("failed to save sftp credentials: %w", err)
	}

	_, err = s.SftpService.CreateUserDirectory(userId)
	if err != nil {
		return nil, fmt.Errorf("failed to create sftp directory: %w", err)
	}

	err = s.SftpService.CreateDocumentDirectory(userId, id)
	if err != nil {
		return nil, fmt.Errorf("failed to create document directory: %w", err)
	}

	return map[string]interface{}{
		"documentId": id,
		"title":      document.Title,
		"path":       document.Path,
		"sftp": map[string]string{
			"username": tempUsername,
			"password": tempPassword,
			"host":     os.Getenv("SFTP_HOST"),
			"port":     os.Getenv("SFTP_PORT"),
		},
	}, nil
}

// GetDocuments returns all documents' uploaded by user with the given userId
func (s *DocumentService) GetDocuments(userId uint) ([]*models.Document, error) {
	documents, err := s.DocumentRepository.GetDocumentsByUserId(userId)
	if err != nil {
		return nil, fmt.Errorf("failed to retrieve documents: %w", err)
	}
	return documents, nil
}

// DeleteDocument deletes the document with the given documentId from the directory of the user with the given userId
func (s *DocumentService) DeleteDocument(userId, documentId uint) error {
	err := s.DocumentRepository.DeleteDocument(documentId)
	if err != nil {
		return fmt.Errorf("failed to delete document from the database: %w", err)
	}

	err = s.SftpService.DeleteDocumentDirectory(userId, documentId)
	if err != nil {
		return fmt.Errorf("failed to delete document from the sftp server: %w", err)
	}

	return nil
}

// EraseLinkedByUserId deletes all the documents uploaded by the user with the given userId
func (s *DocumentService) EraseLinkedByUserId(userId uint) error {
	err := s.DocumentRepository.EraseLinkedByUserId(userId)
	if err != nil {
		return fmt.Errorf("failed to erase linked documents from the database: %w", err)
	}

	err = s.SftpService.DeleteUserDirectory(userId)
	if err != nil {
		return fmt.Errorf("failed to erase linked documents from the sftp server: %w", err)
	}

	return nil
}

// GetSftpCredentials retrieves temporary SFTP credentials for a user
func (s *DocumentService) GetSftpCredentials(userId uint) (*models.SftpCredentials, error) {
	credentials, err := s.SftpRepository.GetSftpCredentials(userId)
	if err != nil {
		return nil, fmt.Errorf("failed to retrieve sftp credentials: %w", err)
	}
	return credentials, nil
}
