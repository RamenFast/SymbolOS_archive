// SymbolOS Memory MCP Server (Go)
// Git-backed memory system with consent gates

package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"
)

const PORT = 8091

type MCPResponse struct {
	Success bool        `json:"success"`
	Data    interface{} `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
	Blocked bool        `json:"blocked,omitempty"`
	Reason  string      `json:"reason,omitempty"`
}

type Tool struct {
	Name        string            `json:"name"`
	Description string            `json:"description"`
	Parameters  map[string]string `json:"parameters"`
	Risk        string            `json:"risk"`
}

type ExecuteRequest struct {
	Tool   string                 `json:"tool"`
	Params map[string]interface{} `json:"params"`
}

type MemoryServer struct {
	memoryDir string
}

func NewMemoryServer(repoRoot string) *MemoryServer {
	return &MemoryServer{
		memoryDir: filepath.Join(repoRoot, "memory"),
	}
}

func (s *MemoryServer) sendJSON(w http.ResponseWriter, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "*")
	json.NewEncoder(w).Encode(data)
}

func (s *MemoryServer) sendError(w http.ResponseWriter, message string, status int) {
	w.WriteHeader(status)
	s.sendJSON(w, MCPResponse{
		Success: false,
		Error:   message,
	})
}

func (s *MemoryServer) handleHealth(w http.ResponseWriter, r *http.Request) {
	files, _ := filepath.Glob(filepath.Join(s.memoryDir, "*.md"))
	s.sendJSON(w, map[string]interface{}{
		"status":      "ok",
		"server":      "Memory MCP v1",
		"memory_dir":  s.memoryDir,
		"files_count": len(files),
	})
}

func (s *MemoryServer) handleTools(w http.ResponseWriter, r *http.Request) {
	tools := []Tool{
		{
			Name:        "memory_read",
			Description: "Read a memory file (working_set, glossary, decisions, session_logs)",
			Parameters: map[string]string{
				"file": "string (required) - filename in memory/ directory",
			},
			Risk: "read",
		},
		{
			Name:        "memory_search",
			Description: "Search memory files by keyword",
			Parameters: map[string]string{
				"query":        "string (required) - search term",
				"file_pattern": "string (optional) - glob pattern, default *.md",
			},
			Risk: "read",
		},
		{
			Name:        "memory_list",
			Description: "List all memory files",
			Parameters:  map[string]string{},
			Risk:        "read",
		},
		{
			Name:        "memory_write",
			Description: "Write to memory file (requires act() mode consent)",
			Parameters: map[string]string{
				"file":           "string (required) - filename",
				"content":        "string (required) - content to write",
				"mode":           "string (required) - 'append' or 'overwrite'",
				"commit_message": "string (optional) - git commit message",
			},
			Risk: "write",
		},
	}

	s.sendJSON(w, MCPResponse{
		Success: true,
		Data: map[string]interface{}{
			"tools": tools,
		},
	})
}

func (s *MemoryServer) handleExecute(w http.ResponseWriter, r *http.Request) {
	var req ExecuteRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		s.sendError(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	log.Printf("[MEMORY] Execute: %s", req.Tool)

	switch req.Tool {
	case "memory_read":
		s.handleMemoryRead(w, req.Params)
	case "memory_search":
		s.handleMemorySearch(w, req.Params)
	case "memory_list":
		s.handleMemoryList(w, req.Params)
	case "memory_write":
		s.handleMemoryWrite(w, req.Params)
	default:
		s.sendError(w, fmt.Sprintf("Unknown tool: %s", req.Tool), http.StatusBadRequest)
	}
}

func (s *MemoryServer) handleMemoryRead(w http.ResponseWriter, params map[string]interface{}) {
	filename, ok := params["file"].(string)
	if !ok || filename == "" {
		s.sendError(w, "Missing required parameter: file", http.StatusBadRequest)
		return
	}

	filePath := filepath.Join(s.memoryDir, filename)

	// Security: prevent path traversal
	if !strings.HasPrefix(filePath, s.memoryDir) {
		s.sendError(w, "Access denied: path traversal detected", http.StatusForbidden)
		return
	}

	content, err := os.ReadFile(filePath)
	if err != nil {
		if os.IsNotExist(err) {
			s.sendError(w, fmt.Sprintf("File not found: %s", filename), http.StatusNotFound)
		} else {
			s.sendError(w, fmt.Sprintf("Read failed: %v", err), http.StatusInternalServerError)
		}
		return
	}

	lines := strings.Count(string(content), "\n") + 1

	s.sendJSON(w, MCPResponse{
		Success: true,
		Data: map[string]interface{}{
			"file":    filename,
			"content": string(content),
			"size":    len(content),
			"lines":   lines,
		},
	})
}

func (s *MemoryServer) handleMemorySearch(w http.ResponseWriter, params map[string]interface{}) {
	query, ok := params["query"].(string)
	if !ok || query == "" {
		s.sendError(w, "Missing required parameter: query", http.StatusBadRequest)
		return
	}

	pattern := "*.md"
	if p, ok := params["file_pattern"].(string); ok {
		pattern = p
	}

	files, _ := filepath.Glob(filepath.Join(s.memoryDir, pattern))
	var results []map[string]interface{}

	for _, filePath := range files {
		content, err := os.ReadFile(filePath)
		if err != nil {
			continue
		}

		var matches []map[string]interface{}
		lines := strings.Split(string(content), "\n")

		for i, line := range lines {
			if strings.Contains(strings.ToLower(line), strings.ToLower(query)) {
				matches = append(matches, map[string]interface{}{
					"line": i + 1,
					"text": strings.TrimSpace(line),
				})
				if len(matches) >= 10 {
					break
				}
			}
		}

		if len(matches) > 0 {
			results = append(results, map[string]interface{}{
				"file":    filepath.Base(filePath),
				"matches": matches,
			})
		}
	}

	s.sendJSON(w, MCPResponse{
		Success: true,
		Data: map[string]interface{}{
			"query":       query,
			"results":     results,
			"total_files": len(results),
		},
	})
}

func (s *MemoryServer) handleMemoryList(w http.ResponseWriter, params map[string]interface{}) {
	files, _ := filepath.Glob(filepath.Join(s.memoryDir, "*.md"))
	var fileList []map[string]interface{}

	for _, filePath := range files {
		info, err := os.Stat(filePath)
		if err != nil {
			continue
		}

		fileList = append(fileList, map[string]interface{}{
			"name":     filepath.Base(filePath),
			"size":     info.Size(),
			"modified": info.ModTime().Format(time.RFC3339),
		})
	}

	s.sendJSON(w, MCPResponse{
		Success: true,
		Data: map[string]interface{}{
			"files": fileList,
			"count": len(fileList),
		},
	})
}

func (s *MemoryServer) handleMemoryWrite(w http.ResponseWriter, params map[string]interface{}) {
	// Phase 1: Always block with consent gate message
	s.sendJSON(w, MCPResponse{
		Success: false,
		Blocked: true,
		Reason:  "memory_write requires act() mode with explicit user confirmation (Phase 1: not implemented)",
	})
}

func main() {
	repoRoot := os.Getenv("SYMBOLOS_ROOT")
	if repoRoot == "" {
		exe, _ := os.Executable()
		repoRoot = filepath.Join(filepath.Dir(exe), "..")
	}

	server := NewMemoryServer(repoRoot)

	http.HandleFunc("/health", server.handleHealth)
	http.HandleFunc("/tools", server.handleTools)
	http.HandleFunc("/execute", server.handleExecute)

	addr := fmt.Sprintf("127.0.0.1:%d", PORT)
	log.Printf("\n==========================================================")
	log.Printf("[MEMORY] SymbolOS Memory MCP Server v1")
	log.Printf("[MEMORY] Port: %d", PORT)
	log.Printf("[MEMORY] Memory directory: %s", server.memoryDir)
	log.Printf("==========================================================\n")

	if err := http.ListenAndServe(addr, nil); err != nil {
		log.Fatalf("[MEMORY] Server error: %v", err)
	}
}
