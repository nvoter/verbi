package services

import (
	"VerbiDocuments/internal/repositories"
	"fmt"
	"github.com/pkg/sftp"
	"golang.org/x/crypto/ssh"
	"log"
)

// SftpService works with sftp server
type SftpService struct {
	SftpRepository *repositories.SftpRepository
}

// NewSftpService creates an instance of SftpService
func NewSftpService(sftpRepository *repositories.SftpRepository) *SftpService {
	return &SftpService{
		SftpRepository: sftpRepository,
	}
}

// createClient creates and returns a new sftp connection
func (s *SftpService) createClient(userId uint) (*sftp.Client, error) {
	credentials, err := s.SftpRepository.GetSftpCredentials(userId)
	if err != nil {
		return nil, fmt.Errorf("failed to retrieve sftp credentials: %w", err)
	}

	config := &ssh.ClientConfig{
		User: credentials.Username,
		Auth: []ssh.AuthMethod{
			ssh.Password(credentials.Password),
		},
		HostKeyCallback: ssh.InsecureIgnoreHostKey(),
	}

	connection, err := ssh.Dial("tcp", fmt.Sprintf("%s:%s", credentials.Host, credentials.Port), config)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to sftp server: %w", err)
	}

	client, err := sftp.NewClient(connection)
	if err != nil {
		connection.Close()
		return nil, fmt.Errorf("failed to create sftp client: %w", err)
	}

	return client, nil
}

// CreateUserDirectory creates a new directory on the SFTP server for the given user
func (s *SftpService) CreateUserDirectory(userId uint) (string, error) {
	directoryPath := fmt.Sprintf("/%d", userId)

	client, err := s.createClient(userId)
	if err != nil {
		return "", fmt.Errorf("failed to create sftp client: %w", err)
	}
	defer func(client *sftp.Client) {
		err := client.Close()
		if err != nil {
			log.Printf("failed to close sftp client: %v", err)
		}
	}(client)

	err = client.Mkdir(directoryPath)
	if err != nil {
		return "", fmt.Errorf("failed to create directory: %w", err)
	}

	return directoryPath, nil
}

// DeleteUserDirectory deletes all files uploaded by the user with the given userId
func (s *SftpService) DeleteUserDirectory(userId uint) error {
	directoryPath := fmt.Sprintf("/%d", userId)

	client, err := s.createClient(userId)
	if err != nil {
		return fmt.Errorf("failed to create sftp client: %w", err)
	}
	defer func(client *sftp.Client) {
		err := client.Close()
		if err != nil {
			log.Printf("failed to close sftp client: %v", err)
		}
	}(client)

	err = client.RemoveDirectory(directoryPath)
	if err != nil {
		return fmt.Errorf("failed to delete directory: %w", err)
	}

	return s.SftpRepository.DeleteSftpCredentials(userId)
}

// CreateDocumentDirectory creates a directory for a new file
func (s *SftpService) CreateDocumentDirectory(userId, documentId uint) error {
	directoryPath := fmt.Sprintf("/%d/%d", userId, documentId)

	client, err := s.createClient(userId)
	if err != nil {
		return fmt.Errorf("failed to create sftp client: %w", err)
	}

	err = client.Mkdir(directoryPath)
	if err != nil {
		return fmt.Errorf("failed to create directory: %w", err)
	}

	return nil
}

// DeleteDocumentDirectory deletes a directory created for a file
func (s *SftpService) DeleteDocumentDirectory(userId, documentId uint) error {
	directoryPath := fmt.Sprintf("/%d/%d", userId, documentId)

	client, err := s.createClient(userId)
	if err != nil {
		return fmt.Errorf("failed to create sftp client: %w", err)
	}

	err = client.RemoveDirectory(directoryPath)
	if err != nil {
		return fmt.Errorf("failed to delete directory: %w", err)
	}

	err = client.Close()
	if err != nil {
		return fmt.Errorf("failed to close sftp client: %w", err)
	}
	return nil
}
