package main

import (
	"VerbiAuth/config"
	_ "VerbiAuth/docs"
	"VerbiAuth/internal/factories"
	"VerbiAuth/internal/models"
	"VerbiAuth/internal/routers"
	"fmt"
	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"log"
	"os"
)

// @title VerbiAuth API
// @version 1.0
// @description Authentication and profile management actions

// @host localhost:8080
// @BasePath /api/v1/

// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
// @description `Bearer <your_access_token>`
func main() {
	err := config.LoadEnv()
	if err != nil {
		panic(err)
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
		log.Fatalf("Failed to connect to database: %v", err)
	}

	err = db.AutoMigrate(&models.User{}, &models.UserCode{}, &models.RefreshToken{})
	if err != nil {
		log.Fatalf("Failed to migrate: %v", err)
	}

	controllersFactory := factories.NewControllersFactory()

	authController, profileController, err := controllersFactory.GetControllers(db)

	if err != nil {
		log.Fatalf("Failed to create auth controller: %v", err)
	}

	r := gin.Default()
	routers.SetupRoutes(r, authController, profileController)

	url := ginSwagger.URL("http://localhost:8080/swagger/doc.json")
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler, url))

	if err = r.Run(":8080"); err != nil {
		log.Fatalf("Failed to run server: %v", err)
	}
}
