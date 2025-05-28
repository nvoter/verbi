package controllers

import (
	"VerbiDocuments/internal/models/requests"
	"VerbiDocuments/internal/models/responses"
	"VerbiDocuments/internal/services"
	"github.com/gin-gonic/gin"
	"log"
	"net/http"
	"strconv"
)

// DocumentController provides endpoints and handles HTTP requests related to actions with documents
// @Tags Documents
type DocumentController struct {
	DocumentService *services.DocumentService
}

// NewDocumentController creates a new DocumentController
func NewDocumentController(documentService *services.DocumentService) *DocumentController {
	return &DocumentController{
		DocumentService: documentService,
	}
}

// CreateDocument endpoint
// @Summary Create a new document in library
// @Description Saves document metadata and returns authorization credentials for sftp server
// @Tags Documents
// @ID createDocument
// @Accept json
// @Produce json
// @Param metadata body requests.CreateDocumentRequest true "Request body"
// @Success 201 {object} responses.CredentialsResponse
// @Failure 400 {object} responses.ErrorResponse
// @Router /documents [post]
func (c *DocumentController) CreateDocument(ctx *gin.Context) {
	req := new(requests.CreateDocumentRequest)
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	response, err := c.DocumentService.CreateDocument(req.UserId, req.Title)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusCreated, response)
}

// DeleteDocument endpoint
// @Summary Delete the document from the user's library
// @Description Deletes the document from the database and the sftp server
// @Tags Documents
// @ID deleteDocument
// @Accept json
// @Produce json
// @Param userId path uint true "User id"
// @Param documentId query string true "Document id"
// @Success 200 {string} string "Document deleted successfully"
// @Failure 400 {object} responses.ErrorResponse
// @Router /documents/{userId} [delete]
func (c *DocumentController) DeleteDocument(ctx *gin.Context) {
	userId := ctx.Param("userId")
	documentId := ctx.Query("documentId")

	userIdUint, err := strconv.ParseUint(userId, 10, 64)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "invalid user id"})
		return
	}

	documentIdUint, err := strconv.ParseUint(documentId, 10, 64)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "invalid document id"})
		return
	}

	err = c.DocumentService.DeleteDocument(uint(userIdUint), uint(documentIdUint))
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"message": "Document successfully deleted"})
}

// GetDocuments endpoint
// @Summary Gives all user's documents' metadata
// @Description Returns metadata of all documents in the user's library
// @Tags Documents
// @ID getDocuments
// @Accept json
// @Produce json
// @Param userId path uint true "User id"
// @Success 200 {object} responses.GetDocumentsResponse "List of user's documents"
// @Failure 400 {object} responses.ErrorResponse
// @Router /documents/{userId} [get]
func (c *DocumentController) GetDocuments(ctx *gin.Context) {
	userId := ctx.Param("userId")
	userIdUint, err := strconv.ParseUint(userId, 10, 64)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "invalid user id"})
		return
	}

	documents, err := c.DocumentService.GetDocuments(uint(userIdUint))
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, responses.GetDocumentsResponse{Documents: documents})
}

// GetCredentials endpoint
// @Summary Gives credentials for authentication at sftp server
// @Description Returns login and password for sftp server
// @Tags Documents
// @ID getCredentials
// @Accept json
// @Produce json
// @Param userId query uint true "User id"
// @Success 200 {object} responses.GetCredentialsResponse
// @Failure 400 {object} responses.ErrorResponse
// @Router /documents/credentials [get]
func (c *DocumentController) GetCredentials(ctx *gin.Context) {
	userId := ctx.Query("userId")
	log.Printf(userId)
	id, err := strconv.ParseUint(userId, 10, 64)
	if err != nil {
		log.Printf("invalid user id %s", userId)
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "invalid user id"})
		return
	}

	credentials, err := c.DocumentService.GetSftpCredentials(uint(id))
	if err != nil {
		ctx.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}

	response := responses.GetCredentialsResponse{
		Username: credentials.Username,
		Password: credentials.Password,
		Host:     credentials.Host,
		Port:     credentials.Port,
	}

	ctx.JSON(http.StatusOK, response)
}

// EraseLinkedByUserId endpoint
// @Summary Deletes all stored user info
// @Description Deletes all user's documents from the database and the sftp server
// @Tags Documents
// @ID eraseLinkedByUserId
// @Accept json
// @Produce json
// @Param userId query uint true "User id"
// @Success 200 {object} responses.CredentialsResponse
// @Failure 400 {object} responses.ErrorResponse
// @Router /documents [delete]
func (c *DocumentController) EraseLinkedByUserId(ctx *gin.Context) {
	userId := ctx.Query("userId")
	userIdUint, err := strconv.ParseUint(userId, 10, 64)
	if err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{"error": "invalid user id"})
		return
	}

	err = c.DocumentService.EraseLinkedByUserId(uint(userIdUint))
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{"message": "User successfully erased"})
}
