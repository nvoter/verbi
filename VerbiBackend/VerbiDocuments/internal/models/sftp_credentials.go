package models

// SftpCredentials represents temporary credentials for sftp access
type SftpCredentials struct {
	UserId   uint   `gorm:"primary_key" json:"user_id"`
	Username string `gorm:"not null" json:"username"`
	Password string `gorm:"not null" json:"password"`
	Host     string `gorm:"not null" json:"host"`
	Port     string `gorm:"not null" json:"port"`
}
