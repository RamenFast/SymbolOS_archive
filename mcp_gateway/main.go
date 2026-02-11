// SymbolOS MCP Gateway — Phase 1 Local-First
// Single entrypoint for all MCP requests with mode barriers + routing

package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"sync"
	"time"
)

// Mode barriers: prefetch / suggest / act
type RequestMode string

const (
	ModePrefetch RequestMode = "prefetch" // Read-only, no confirmation
	ModeSuggest  RequestMode = "suggest"  // Propose action, no execution
	ModeAct      RequestMode = "act"      // Execute with confirmation
)

// MCP Request envelope
type MCPRequest struct {
	Mode   RequestMode            `json:"mode"`
	Tool   string                 `json:"tool"`
	Params map[string]interface{} `json:"params"`
	Agent  string                 `json:"agent"` // Agent identity
}

// MCP Response envelope
type MCPResponse struct {
	Success bool                   `json:"success"`
	Data    interface{}            `json:"data,omitempty"`
	Error   string                 `json:"error,omitempty"`
	Blocked bool                   `json:"blocked,omitempty"`
	Reason  string                 `json:"reason,omitempty"`
}

// ServerEntry represents a registered MCP server
type ServerEntry struct {
	ID           string   `json:"id"`
	Name         string   `json:"name"`
	Capabilities []string `json:"capabilities"`
	Endpoint     string   `json:"endpoint"`
	Status       string   `json:"status"`
	LastSeen     time.Time `json:"last_seen"`
}

// Gateway manages routing and security
type Gateway struct {
	servers map[string]*ServerEntry
	mu      sync.RWMutex
}

func NewGateway() *Gateway {
	return &Gateway{
		servers: make(map[string]*ServerEntry),
	}
}

// LoadRegistry reads mcp_registry.json from repo root
func (g *Gateway) LoadRegistry(repoRoot string) error {
	registryPath := filepath.Join(repoRoot, "mcp_registry.json")
	
	data, err := os.ReadFile(registryPath)
	if err != nil {
		if os.IsNotExist(err) {
			log.Println("[GATEWAY] No registry found, starting with empty fleet")
			return nil
		}
		return fmt.Errorf("failed to read registry: %w", err)
	}

	var registry struct {
		Servers []ServerEntry `json:"servers"`
	}

	if err := json.Unmarshal(data, &registry); err != nil {
		return fmt.Errorf("failed to parse registry: %w", err)
	}

	g.mu.Lock()
	defer g.mu.Unlock()

	for _, server := range registry.Servers {
		g.servers[server.ID] = &server
		log.Printf("[GATEWAY] Registered: %s (%s)", server.Name, server.ID)
	}

	return nil
}

// CheckModeBarrier enforces prefetch/suggest/act gates
func (g *Gateway) CheckModeBarrier(req *MCPRequest) (bool, string) {
	switch req.Mode {
	case ModePrefetch:
		// Read-only, always allowed
		return true, ""
	
	case ModeSuggest:
		// Propose action, no execution (always safe)
		return true, ""
	
	case ModeAct:
		// Execution requires confirmation
		// In Phase 1, block all act() calls to demonstrate barrier
		return false, "act() mode requires explicit user confirmation (not implemented in Phase 1)"
	
	default:
		return false, fmt.Sprintf("unknown mode: %s", req.Mode)
	}
}

// RouteRequest finds the appropriate server for a tool
func (g *Gateway) RouteRequest(toolName string) (*ServerEntry, error) {
	g.mu.RLock()
	defer g.mu.RUnlock()

	// Simple routing: find first server with matching capability
	for _, server := range g.servers {
		for _, cap := range server.Capabilities {
			if cap == toolName || cap == "*" {
				return server, nil
			}
		}
	}

	return nil, fmt.Errorf("no server found for tool: %s", toolName)
}

// HandleRequest processes incoming MCP requests
func (g *Gateway) HandleRequest(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req MCPRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		g.sendError(w, "Invalid request format", http.StatusBadRequest)
		return
	}

	log.Printf("[GATEWAY] Request: mode=%s tool=%s agent=%s", req.Mode, req.Tool, req.Agent)

	// Phase 1: Mode barrier check
	allowed, reason := g.CheckModeBarrier(&req)
	if !allowed {
		g.sendBlocked(w, reason)
		return
	}

	// Phase 1: Route to appropriate server
	server, err := g.RouteRequest(req.Tool)
	if err != nil {
		g.sendError(w, err.Error(), http.StatusNotFound)
		return
	}

	log.Printf("[GATEWAY] Routing %s → %s (%s)", req.Tool, server.Name, server.Endpoint)

	// Phase 1: Forward request (placeholder — actual forwarding in next iteration)
	response := MCPResponse{
		Success: true,
		Data: map[string]interface{}{
			"gateway_status": "Phase 1 stub — mode barrier active, routing functional",
			"routed_to":      server.Name,
			"tool":           req.Tool,
			"mode":           req.Mode,
		},
	}

	g.sendJSON(w, response)
}

// DiscoverServers returns all registered servers
func (g *Gateway) DiscoverServers(w http.ResponseWriter, r *http.Request) {
	g.mu.RLock()
	defer g.mu.RUnlock()

	servers := make([]ServerEntry, 0, len(g.servers))
	for _, server := range g.servers {
		servers = append(servers, *server)
	}

	response := MCPResponse{
		Success: true,
		Data: map[string]interface{}{
			"servers": servers,
			"count":   len(servers),
		},
	}

	g.sendJSON(w, response)
}

// Helper: send JSON response
func (g *Gateway) sendJSON(w http.ResponseWriter, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(data)
}

// Helper: send error response
func (g *Gateway) sendError(w http.ResponseWriter, message string, status int) {
	w.WriteHeader(status)
	g.sendJSON(w, MCPResponse{
		Success: false,
		Error:   message,
	})
}

// Helper: send blocked response
func (g *Gateway) sendBlocked(w http.ResponseWriter, reason string) {
	g.sendJSON(w, MCPResponse{
		Success: false,
		Blocked: true,
		Reason:  reason,
	})
}

func main() {
	repoRoot := os.Getenv("SYMBOLOS_ROOT")
	if repoRoot == "" {
		// Default to parent directory of mcp_gateway/
		exe, _ := os.Executable()
		repoRoot = filepath.Join(filepath.Dir(exe), "..")
	}

	gateway := NewGateway()

	if err := gateway.LoadRegistry(repoRoot); err != nil {
		log.Fatalf("[GATEWAY] Failed to load registry: %v", err)
	}

	// Routes
	http.HandleFunc("/mcp/request", gateway.HandleRequest)
	http.HandleFunc("/mcp/discover", gateway.DiscoverServers)
	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, `{"status":"ok","gateway":"Phase 1 MCP Gateway","version":"0.1.0"}`)
	})

	port := os.Getenv("PORT")
	if port == "" {
		port = "8090"
	}

	addr := fmt.Sprintf("127.0.0.1:%s", port)
	log.Printf("[GATEWAY] Starting MCP Gateway on %s", addr)
	log.Printf("[GATEWAY] Mode barrier: ACTIVE (act() blocked)")
	log.Printf("[GATEWAY] Registry: %d servers loaded", len(gateway.servers))
	
	if err := http.ListenAndServe(addr, nil); err != nil {
		log.Fatalf("[GATEWAY] Server error: %v", err)
	}
}
