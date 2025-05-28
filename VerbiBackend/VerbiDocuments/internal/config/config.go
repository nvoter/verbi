package config

import (
	"VerbiDocuments/internal/repositories"
	"errors"
	"fmt"
	"github.com/gliderlabs/ssh"
	"github.com/joho/godotenv"
	"github.com/pkg/sftp"
	cryptossh "golang.org/x/crypto/ssh"
	"gorm.io/gorm"
	"io"
	"log"
	"os"
)

// LoadEnv function to get variables from .env file
func LoadEnv() error {
	err := godotenv.Load()
	if err != nil {
		log.Printf("Error loading .env file")
		return errors.New("error loading .env file")
	}

	return nil
}

func SetupSftpServer(db *gorm.DB) error {
	repository := repositories.NewSftpRepository(db)

	sshServer := &ssh.Server{
		Addr: fmt.Sprintf("0.0.0.0:%s", os.Getenv("SFTP_PORT")),
		PasswordHandler: func(ctx ssh.Context, password string) bool {
			username := ctx.User()
			creds, err := repository.GetSftpCredentialsByUsername(username)
			if err != nil {
				log.Printf("Auth error for user %s: %v", username, err)
				return false
			}
			return creds.Password == password
		},
		SubsystemHandlers: map[string]ssh.SubsystemHandler{
			"sftp": func(sess ssh.Session) {
				server, err := sftp.NewServer(sess, sftp.WithDebug(os.Stderr))
				if err != nil {
					log.Printf("sftp start error: %v", err)
					return
				}
				defer server.Close()
				if err := server.Serve(); err != nil && err != io.EOF {
					log.Printf("sftp serve error: %v", err)
					return
				}
				log.Printf("client %s disconnected", sess.RemoteAddr())
			},
		},
	}

	keyPath := os.Getenv("SFTP_HOST_KEY")
	keyBytes, err := os.ReadFile(keyPath)
	if err != nil {
		log.Printf("failed to load host key %s: %v", keyPath, err)
		return errors.New(err.Error())
	}
	signer, err := cryptossh.ParsePrivateKey(keyBytes)
	if err != nil {
		log.Printf("failed to parse private key: %v", err)
		return errors.New(err.Error())
	}
	sshServer.AddHostKey(signer)

	log.Printf("sftp server listening on %s", os.Getenv("SFTP_PORT"))
	log.Fatal(sshServer.ListenAndServe())
	return nil
}
