package controllers

import (
	"VerbiLLM/internal/models/requests"
	"VerbiLLM/internal/services"
	"github.com/gin-gonic/gin"
	"log"
	"net/http"
)

// LlmController provides endpoints and handles HTTP requests to LLM
type LlmController struct {
	LlmService *services.LlmService
}

// NewLlmController creates a new LlmController
func NewLlmController(llmService *services.LlmService) *LlmController {
	return &LlmController{
		LlmService: llmService,
	}
}

// MakeRequest endpoint
// @Summary Handles a request to LLM
// @Description Sends a request to LLM and returns its response
// @Tags LLM
// @ID getResponse
// @Accept json
// @Produce json
// @Param request body requests.LlmRequest true "Request"
// @Success 200 {object} responses.LlmResponse "LLM response"
// @Failure 400 {object} responses.ErrorResponse
// @Router /llm/response [post]
func (c *LlmController) MakeRequest(ctx *gin.Context) {
	log.Println("LlmController MakeRequest")
	req := new(requests.LlmRequest)
	if err := ctx.ShouldBindJSON(req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	response, err := c.LlmService.HandleRequest(req.Query, req.QueryType, req.Prompt, req.BookName)
	if err != nil {
		log.Printf("LlmController MakeRequest Error: %v\n", err)
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err})
		return
	}

	log.Print(response)
	ctx.JSON(http.StatusOK, response)
}
