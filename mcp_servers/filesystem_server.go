// SymbolOS Filesystem MCP Server (Go)
// Scoped file operations with allowlist enforcement

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

const PORT = 8092

// Allowlist: directories where file operations are permitted
var allowedDirs = []string{
	"memory",
	"docs",
	"scripts",
	"mcp_servers",
	"prompts",
	"internal_docs",
	"extensions",
}

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

type FilesystemServer struct {
	repoRoot string
}

func NewFilesystemServer(repoRoot string) *FilesystemServer {
	return &FilesystemServer{
		repoRoot: repoRoot,
	}
}

func (s *FilesystemServer) sendJSON(w http.ResponseWriter, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "*")
	json.NewEncoder(w).Encode(data)
}

func (s *FilesystemServer) sendError(w http.ResponseWriter, message string, status int) {
	w.WriteHeader(status)
	s.sendJSON(w, MCPResponse{
		Success: false,
		Error:   message,
	})
}

// Security: validate path against allowlist
func (s *FilesystemServer) validatePath(requestedPath string) (string, error) {
	// Clean and resolve absolute path
	absPath := filepath.Join(s.repoRoot, requestedPath)
	cleanPath := filepath.Clean(absPath)

	// Check if path is within repo
	if !strings.HasPrefix(cleanPath, s.repoRoot) {
		return "", fmt.Errorf("path traversal detected (outside repo)")
	}

	// Check if path is in allowlist
	relPath, err := filepath.Rel(s.repoRoot, cleanPath)
	if err != nil {
		return "", err
	}

	// Check if first path component is in allowlist
	parts := strings.Split(filepath.ToSlash(relPath), "/")
	if len(parts) == 0 {
		return "", fmt.Errorf("invalid path")
	}

	allowed := false
	for _, dir := range allowedDirs {
		if parts[0] == dir {
			allowed = true
			break
		}
	}

	if !allowed {
		return "", fmt.Errorf("access denied: '%s' not in allowlist", parts[0])
	}

	return cleanPath, nil
}

func (s *FilesystemServer) handleHealth(w http.ResponseWriter, r *http.Request) {
	s.sendJSON(w, map[string]interface{}{
		"status":        "ok",
		"server":        "Filesystem MCP v1",
		"repo_root":     s.repoRoot,
		"allowed_dirs":  allowedDirs,
	})
}

func (s *FilesystemServer) handleTools(w http.ResponseWriter, r *http.Request) {
	tools := []Tool{
		{
			Name:        "file_read",
			Description: "Read file contents from allowed directories",
			Parameters: map[string]string{
				"path": "string (required) - relative path from repo root",
			},
			Risk: "read",
		},
		{
			Name:        "file_list",
			Description: "List directory contents",
			Parameters: map[string]string{
				"path":    "string (required) - relative directory path",
				"pattern": "string (optional) - glob pattern, default *",
			},
			Risk: "read",
		},
		{
			Name:        "file_write",
			Description: "Write to file (requires act() mode consent)",
			Parameters: map[string]string{
				"path":           "string (required) - relative path",
				"content":        "string (required) - file content",
				"mode":           "string (required) - 'append' or 'overwrite'",
				"commit_message": "string (optional) - git commit message",
			},
			Risk: "write",
		},
		{
			Name:        "file_delete",
			Description: "Delete file (requires act() mode consent)",
			Parameters: map[string]string{
				"path":           "string (required) - relative path",
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

func (s *FilesystemServer) handleExecute(w http.ResponseWriter, r *http.Request) {
	var req ExecuteRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		s.sendError(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	log.Printf("[FILESYSTEM] Execute: %s", req.Tool)

	switch req.Tool {
	case "file_read":
		s.handleFileRead(w, req.Params)
	case "file_list":
		s.handleFileList(w, req.Params)
	case "file_write":
		s.handleFileWrite(w, req.Params)
	case "file_delete":
		s.handleFileDelete(w, req.Params)
	default:
		s.sendError(w, fmt.Sprintf("Unknown tool: %s", req.Tool), http.StatusBadRequest)
	}
}

func (s *FilesystemServer) handleFileRead(w http.ResponseWriter, params map[string]interface{}) {
	path, ok := params["path"].(string)
	if !ok || path == "" {
		s.sendError(w, "Missing required parameter: path", http.StatusBadRequest)
		return
	}

	validPath, err := s.validatePath(path)
	if err != nil {
		s.sendError(w, fmt.Sprintf("Access denied: %v", err), http.StatusForbidden)
		return
	}

	content, err := os.ReadFile(validPath)
	if err != nil {
		if os.IsNotExist(err) {
			s.sendError(w, fmt.Sprintf("File not found: %s", path), http.StatusNotFound)
		} else {
			s.sendError(w, fmt.Sprintf("Read failed: %v", err), http.StatusInternalServerError)
		}
		return
	}

	lines := strings.Count(string(content), "\n") + 1

	s.sendJSON(w, MCPResponse{
		Success: true,
		Data: map[string]interface{}{
			"path":    path,
			"content": string(content),
			"size":    len(content),
			"lines":   lines,
		},
	})
}

func (s *FilesystemServer) handleFileList(w http.ResponseWriter, params map[string]interface{}) {
	path, ok := params["path"].(string)
	if !ok || path == "" {
		s.sendError(w, "Missing required parameter: path", http.StatusBadRequest)
		return
	}

	validPath, err := s.validatePath(path)
	if err != nil {
		s.sendError(w, fmt.Sprintf("Access denied: %v", err), http.StatusForbidden)
		return
	}

	// Check if directory exists
	info, err := os.Stat(validPath)
	if err != nil {
		if os.IsNotExist(err) {
			s.sendError(w, fmt.Sprintf("Directory not found: %s", path), http.StatusNotFound)
		} else {
			s.sendError(w, fmt.Sprintf("Stat failed: %v", err), http.StatusInternalServerError)
		}
		return
	}

	if !info.IsDir() {
		s.sendError(w, fmt.Sprintf("Not a directory: %s", path), http.StatusBadRequest)
		return
	}

	pattern := "*"
	if p, ok := params["pattern"].(string); ok {
		pattern = p
	}

	globPath := filepath.Join(validPath, pattern)
	files, err := filepath.Glob(globPath)
	if err != nil {
		s.sendError(w, fmt.Sprintf("Glob failed: %v", err), http.StatusInternalServerError)
		return
	}

	var fileList []map[string]interface{}
	for _, filePath := range files {
		info, err := os.Stat(filePath)
		if err != nil {
			continue
		}

		relPath, _ := filepath.Rel(s.repoRoot, filePath)
		fileType := "file"
		if info.IsDir() {
			fileType = "directory"
		}

		fileList = append(fileList, map[string]interface{}{
			"name":     filepath.Base(filePath),
			"path":     filepath.ToSlash(relPath),
			"type":     fileType,
			"size":     info.Size(),
			"modified": info.ModTime().Format(time.RFC3339),
		})
	}

	s.sendJSON(w, MCPResponse{
		Success: true,
		Data: map[string]interface{}{
			"path":  path,
			"files": fileList,
			"count": len(fileList),
		},
	})
}

func (s *FilesystemServer) handleFileWrite(w http.ResponseWriter, params map[string]interface{}) {
	// Phase 1: Always block with consent gate message
	s.sendJSON(w, MCPResponse{
		Success: false,
		Blocked: true,
		Reason:  "file_write requires act() mode with explicit user confirmation (Phase 1: not implemented)",
	})
}

func (s *FilesystemServer) handleFileDelete(w http.ResponseWriter, params map[string]interface{}) {
	// Phase 1: Always block with consent gate message
	s.sendJSON(w, MCPResponse{
		Success: false,
		Blocked: true,
		Reason:  "file_delete requires act() mode with explicit user confirmation (Phase 1: not implemented)",
	})
}

func main() {
	repoRoot := os.Getenv("SYMBOLOS_ROOT")
	if repoRoot == "" {
		exe, _ := os.Executable()
		repoRoot = filepath.Join(filepath.Dir(exe), "..")
	}

	server := NewFilesystemServer(repoRoot)

	http.HandleFunc("/health", server.handleHealth)
	http.HandleFunc("/tools", server.handleTools)
	http.HandleFunc("/execute", server.handleExecute)

	addr := fmt.Sprintf("127.0.0.1:%d", PORT)
	log.Printf("\n==========================================================")
	log.Printf("[FILESYSTEM] SymbolOS Filesystem MCP Server v1")
	log.Printf("[FILESYSTEM] Port: %d", PORT)
	log.Printf("[FILESYSTEM] Repo root: %s", server.repoRoot)
	log.Printf("[FILESYSTEM] Allowed directories: %v", allowedDirs)
	log.Printf("==========================================================\n")

	if err := http.ListenAndServe(addr, nil); err != nil {
		log.Fatalf("[FILESYSTEM] Server error: %v", err)
	}
}
