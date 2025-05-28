package requests

// LlmRequest represents data required to make a request to LLM
type LlmRequest struct {
	Query     string `json:"query"`
	QueryType string `json:"query_type"`
	Prompt    string `json:"prompt"`
	BookName  string `json:"book"`
}
