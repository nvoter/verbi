package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"
	"strconv"
	"strings"
)

var services = map[string]string{
	"auth":      "http://192.168.0.32:8080/api/v1/auth",
	"profile":   "http://192.168.0.32:8080/api/v1/profile",
	"documents": "http://192.168.0.32:8081/api/v1/documents",
	"llm":       "http://192.168.0.32:8082/api/v1/llm",
}

func NewProxy(target string) *httputil.ReverseProxy {
	targetURL, _ := url.Parse(target)
	return httputil.NewSingleHostReverseProxy(targetURL)
}

func validateToken(r *http.Request) (uint, bool) {
	req, _ := http.NewRequest("GET", services["auth"]+"/", nil)
	req.Header = r.Header.Clone()

	resp, err := http.DefaultClient.Do(req)
	if err != nil || resp.StatusCode != http.StatusOK {
		return 0, false
	}
	defer resp.Body.Close()

	var result struct {
		UserID uint `json:"userId"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return 0, false
	}

	return result.UserID, true
}

func handleDocuments(w http.ResponseWriter, r *http.Request, userID uint) {
	proxy := NewProxy(services["documents"])

	if r.Method == "POST" {
		var body map[string]interface{}
		if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		body["user_id"] = userID
		modifiedBody, _ := json.Marshal(body)
		r.Body = io.NopCloser(bytes.NewReader(modifiedBody))
		r.ContentLength = int64(len(modifiedBody))
		r.URL.Path = ""
	}

	if r.Method == "GET" || r.Method == "DELETE" {
		log.Printf(r.URL.Path)
		pathParts := strings.Split(r.URL.Path, "/")
		if len(pathParts) == 4 {
			r.URL.Path = fmt.Sprintf("/%s", strconv.Itoa(int(userID)))
			log.Printf(r.URL.Path)
		} else if len(pathParts) == 5 {
			r.URL.Path = fmt.Sprintf("/%s?userId=1", pathParts[4])
			log.Printf(r.URL.Path)
		}
	}

	proxy.ServeHTTP(w, r)
}

func main() {
	proxies := make(map[string]*httputil.ReverseProxy)
	for name, addr := range services {
		proxies[name] = NewProxy(addr)
	}

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		pathParts := strings.SplitN(r.URL.Path, "/", 5)
		if len(pathParts) < 4 {
			http.Error(w, "Invalid path", http.StatusBadRequest)
			return
		}

		service := pathParts[3]
		proxy, exists := proxies[service]
		if !exists {
			log.Printf("No proxy for service %s", service)
			http.Error(w, "Service not found", http.StatusNotFound)
			return
		}

		if service == "documents" || service == "llm" {
			userID, valid := validateToken(r)
			if !valid {
				http.Error(w, "Unauthorized", http.StatusUnauthorized)
				return
			}

			if service == "documents" {
				handleDocuments(w, r, userID)
				return
			}
		}

		r.URL.Path = "/" + strings.Join(pathParts[4:], "/")
		proxy.ServeHTTP(w, r)
	})

	log.Fatal(http.ListenAndServe(":8083", nil))
}
