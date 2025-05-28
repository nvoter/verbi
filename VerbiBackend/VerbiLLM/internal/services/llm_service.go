package services

import (
	"VerbiLLM/internal/models/responses"
	"context"
	"errors"
	"fmt"
	hf "github.com/hupe1980/go-huggingface"
	"os"
	"strings"
)

// LlmService handles LLM requests
type LlmService struct{}

// NewLlmService creates an instance of a new LLM service
func NewLlmService() *LlmService {
	return &LlmService{}
}

// HandleRequest sends a request to LLM API and returns its response
func (s *LlmService) HandleRequest(query, queryType, prompt, bookName string) (*responses.LlmResponse, error) {
	if query == "" || queryType == "" {
		return nil, errors.New("query and query type are required")
	}
	if queryType == "question" && prompt == "" {
		return nil, errors.New("prompt is required if queryType is question")
	}
	if queryType != "question" && queryType != "summarize" && queryType != "rephrase" {
		return nil, errors.New("invalid query type")
	}

	request := createPrompt(query, queryType, prompt, bookName)
	if request == "" {
		return nil, errors.New("failed to generate prompt")
	}

	apiKey := os.Getenv("API_KEY")
	if apiKey == "" {
		return nil, errors.New("failed to get API key")
	}

		model := os.Getenv("MODEL_NAME")
	if model == "" {
		model = "Qwen/Qwen3-235B-A22BB"
	}

	client := hf.NewInferenceClient(apiKey)

	req := hf.TextGenerationRequest{
		Inputs: request,
		Model:  model,
	}

	resp, err := client.TextGeneration(context.Background(), &req)
	if err != nil {
		return nil, fmt.Errorf("failed to generate text: %s", err)
	}

	responseSplit := strings.Split(resp[0].GeneratedText, "</think>")
	response := strings.TrimSpace(responseSplit[len(responseSplit)-1])
	if response == "" {
		return nil, errors.New("failed to generate response")
	}

	return &responses.LlmResponse{Response: response}, nil
}

// createPrompt makes a prompt to LLM from the provided data
func createPrompt(query, queryType, prompt, bookName string) string {
	switch queryType {
	case "question":
		return fmt.Sprintf("Ответь на вопрос %s по текстовому фрагменту \"%s\" из книги \"%s\"", prompt, query, bookName)
	case "summarize":
		return fmt.Sprintf("Кратко перескажи текстовый фрагмент \"%s\" не добавляя ничего своего", query)
	case "rephrase":
		return fmt.Sprintf("Переформулируй этот текст не добавляя ничего своего: %s", query)
	}
	return ""
}
