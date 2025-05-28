package main

import (
	_ "VerbiLLM/docs"
	"VerbiLLM/internal/config"
	"VerbiLLM/internal/controllers"
	"VerbiLLM/internal/routers"
	"VerbiLLM/internal/services"
	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
	"log"
)

// @title VerbiLLM API
// @version 1.0
// @description LLM actions

// @host localhost:8082
// @BasePath /api/v1
func main() {
	err := config.LoadEnv()
	if err != nil {
		log.Fatal(err)
	}

	llmController := controllers.NewLlmController(services.NewLlmService())

	r := gin.Default()
	routers.SetupRoutes(r, llmController)

	url := ginSwagger.URL("http://localhost:8082/swagger/doc.json")
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler, url))

	if err := r.Run(":8082"); err != nil {
		log.Fatalf("failed to run server: %v", err)
	}
	log.Printf("server running on port 8082")
}
