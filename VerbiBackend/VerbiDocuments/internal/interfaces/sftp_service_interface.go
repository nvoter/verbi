package interfaces

// SftpServiceInterface defines the methods to work with sftp server
type SftpServiceInterface interface {
	CreateUserDirectory(userId uint) (string, error)
	DeleteUserDirectory(userId uint) error
}
