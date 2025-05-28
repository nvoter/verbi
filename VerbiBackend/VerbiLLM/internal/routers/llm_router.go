package routers

import (
	"VerbiLLM/internal/controllers"
	"github.com/gin-gonic/gin"
)

func SetupRoutes(router *gin.Engine, llmController *controllers.LlmController) {
	api := router.Group("/api/v1")

	llmGroup := api.Group("/llm")
	{
		llmGroup.POST("/response", llmController.MakeRequest)
	}
}
