package main

import (
	_ "VerbiDocuments/docs"
	"VerbiDocuments/internal/config"
	"VerbiDocuments/internal/factories"
	"VerbiDocuments/internal/models"
	"VerbiDocuments/internal/routers"
	"fmt"
	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"log"
	"os"
)

// @title VerbiDocuments API
// @version 1.0
// @description Documents management actions

// @host localhost:8081
// @BasePath /api/v1
func main() {
	err := config.LoadEnv()
	if err != nil {
		log.Fatal(err)
	}

	databaseHost := "postgres"
	databasePort := os.Getenv("DB_PORT")
	databaseName := os.Getenv("DB_NAME")
	databaseUser := os.Getenv("DB_USER")
	databasePassword := os.Getenv("DB_PASSWORD")

	psqlInfo := fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		databaseHost,
		databasePort,
		databaseUser,
		databasePassword,
		databaseName,
	)

	db, err := gorm.Open(postgres.Open(psqlInfo), &gorm.Config{})
	if err != nil {
		log.Fatalf("failed to connect to database: %v", err)
	}

	err = db.AutoMigrate(&models.Document{}, &models.SftpCredentials{})
	if err != nil {
		log.Fatalf("failed to migrate: %v", err)
	}

	go func() {
		err = config.SetupSftpServer(db)
		if err != nil {
			log.Fatalf("failed to setup sftp server: %v", err)
		}
	}()

	controllerFactory := factories.NewControllerFactory()
	documentsController, err := controllerFactory.GetController(db)
	if err != nil {
		log.Fatalf("failed to create documents controller: %v", err)
	}

	r := gin.Default()
	routers.SetupRoutes(r, documentsController)

	url := ginSwagger.URL("http://localhost:8081/swagger/doc.json")
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler, url))

	addr := fmt.Sprintf("0.0.0.0:%s", os.Getenv("SERVER_PORT"))
	log.Printf("HTTP server listening on %s", addr)
	if err := r.Run(addr); err != nil {
		log.Fatalf("HTTP server failed: %v", err)
	}
}
