package routers

import (
	"VerbiDocuments/internal/controllers"
	"github.com/gin-gonic/gin"
)

// SetupRoutes sets up the routes for document management actions
func SetupRoutes(r *gin.Engine, documentController *controllers.DocumentController) {
	api := r.Group("/api/v1")

	documentGroup := api.Group("/documents")
	{
		documentGroup.POST("/", documentController.CreateDocument)
		documentGroup.GET("/:userId", documentController.GetDocuments)
		documentGroup.DELETE("/:userId", documentController.DeleteDocument)
		documentGroup.GET("/credentials", documentController.GetCredentials)
		documentGroup.DELETE("/", documentController.EraseLinkedByUserId)
	}
}
