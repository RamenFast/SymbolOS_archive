#!/usr/bin/env python3
"""
SymbolOS Memory MCP Server — Git-backed memory system with consent gates

Phase 1 Implementation:
- Read memory files (working_set, glossary, decisions, session_logs)
- Search memory by keyword (simple grep-style)
- Write memory with consent gate (act() mode required)
- Git integration (auto-commit on write)

MCP Standard compliance:
- Endpoints: /tools, /execute
- Transport: localhost HTTP (port 8091)
- Response envelope: {success, data, error}
"""

import json
import os
import re
import subprocess
from datetime import datetime
from http.server import HTTPServer, BaseHTTPRequestHandler
from pathlib import Path
from typing import Dict, List, Optional

# Configuration
REPO_ROOT = Path(__file__).parent.parent.resolve()
MEMORY_DIR = REPO_ROOT / "memory"
PORT = 8091

class MemoryMCPHandler(BaseHTTPRequestHandler):
    """HTTP request handler for Memory MCP server"""

    def log_message(self, format, *args):
        """Custom logging with [MEMORY] prefix"""
        print(f"[MEMORY] {format % args}")

    def _send_json(self, data: dict, status=200):
        """Helper to send JSON response"""
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())

    def _send_error(self, message: str, status=400):
        """Helper to send error response"""
        self._send_json({"success": False, "error": message}, status)

    def do_GET(self):
        """Handle GET requests"""
        if self.path == "/health":
            self._send_json({
                "status": "ok",
                "server": "Memory MCP v1",
                "memory_dir": str(MEMORY_DIR),
                "files_count": len(list(MEMORY_DIR.glob("*.md")))
            })

        elif self.path == "/tools":
            # MCP standard: list available tools
            tools = [
                {
                    "name": "memory_read",
                    "description": "Read a memory file (working_set, glossary, decisions, session_logs)",
                    "parameters": {
                        "file": "string (required) - filename in memory/ directory"
                    },
                    "risk": "read"
                },
                {
                    "name": "memory_search",
                    "description": "Search memory files by keyword",
                    "parameters": {
                        "query": "string (required) - search term",
                        "file_pattern": "string (optional) - glob pattern, default *.md"
                    },
                    "risk": "read"
                },
                {
                    "name": "memory_write",
                    "description": "Write to memory file (requires act() mode consent)",
                    "parameters": {
                        "file": "string (required) - filename",
                        "content": "string (required) - content to write",
                        "mode": "string (required) - 'append' or 'overwrite'",
                        "commit_message": "string (optional) - git commit message"
                    },
                    "risk": "write"
                },
                {
                    "name": "memory_list",
                    "description": "List all memory files",
                    "parameters": {},
                    "risk": "read"
                }
            ]
            self._send_json({"success": True, "tools": tools})

        else:
            self._send_error("Not found", 404)

    def do_POST(self):
        """Handle POST requests (tool execution)"""
        if self.path != "/execute":
            self._send_error("Not found", 404)
            return

        # Parse request body
        content_length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(content_length).decode()

        try:
            request = json.loads(body)
        except json.JSONDecodeError:
            self._send_error("Invalid JSON")
            return

        tool = request.get("tool")
        params = request.get("params", {})

        # Route to tool handler
        if tool == "memory_read":
            self._handle_memory_read(params)
        elif tool == "memory_search":
            self._handle_memory_search(params)
        elif tool == "memory_write":
            self._handle_memory_write(params)
        elif tool == "memory_list":
            self._handle_memory_list(params)
        else:
            self._send_error(f"Unknown tool: {tool}")

    def _handle_memory_read(self, params: dict):
        """Read a memory file"""
        filename = params.get("file")
        if not filename:
            self._send_error("Missing required parameter: file")
            return

        file_path = MEMORY_DIR / filename

        if not file_path.exists():
            self._send_error(f"File not found: {filename}", 404)
            return

        if not file_path.is_relative_to(MEMORY_DIR):
            self._send_error("Access denied: path traversal detected", 403)
            return

        try:
            content = file_path.read_text(encoding="utf-8")
            self._send_json({
                "success": True,
                "data": {
                    "file": filename,
                    "content": content,
                    "size": len(content),
                    "lines": content.count("\n") + 1
                }
            })
        except Exception as e:
            self._send_error(f"Read failed: {str(e)}", 500)

    def _handle_memory_search(self, params: dict):
        """Search memory files"""
        query = params.get("query")
        if not query:
            self._send_error("Missing required parameter: query")
            return

        pattern = params.get("file_pattern", "*.md")
        results = []

        for file_path in MEMORY_DIR.glob(pattern):
            if not file_path.is_file():
                continue

            try:
                content = file_path.read_text(encoding="utf-8")
                matches = []

                for i, line in enumerate(content.splitlines(), 1):
                    if query.lower() in line.lower():
                        matches.append({
                            "line": i,
                            "text": line.strip()
                        })

                if matches:
                    results.append({
                        "file": file_path.name,
                        "matches": matches[:10]  # Limit to 10 matches per file
                    })

            except Exception as e:
                print(f"[MEMORY] Error searching {file_path.name}: {e}")

        self._send_json({
            "success": True,
            "data": {
                "query": query,
                "results": results,
                "total_files": len(results)
            }
        })

    def _handle_memory_list(self, params: dict):
        """List all memory files"""
        files = []

        for file_path in sorted(MEMORY_DIR.glob("*.md")):
            if file_path.is_file():
                stat = file_path.stat()
                files.append({
                    "name": file_path.name,
                    "size": stat.st_size,
                    "modified": datetime.fromtimestamp(stat.st_mtime).isoformat()
                })

        self._send_json({
            "success": True,
            "data": {
                "files": files,
                "count": len(files)
            }
        })

    def _handle_memory_write(self, params: dict):
        """Write to memory file (Phase 1: stub with consent gate message)"""
        filename = params.get("file")
        content = params.get("content")
        mode = params.get("mode", "append")

        if not filename or not content:
            self._send_error("Missing required parameters: file, content")
            return

        # Phase 1: Always return consent gate message
        # (Gateway should block act() mode, but we reinforce here)
        self._send_json({
            "success": False,
            "blocked": True,
            "reason": "memory_write requires act() mode with explicit user confirmation (Phase 1: not implemented)"
        })

def run_server():
    """Start the Memory MCP server"""
    server_address = ("127.0.0.1", PORT)
    httpd = HTTPServer(server_address, MemoryMCPHandler)

    print("\n" + "="*60)
    print(f"[MEMORY] SymbolOS Memory MCP Server v1")
    print(f"[MEMORY] Port: {PORT}")
    print(f"[MEMORY] Memory directory: {MEMORY_DIR}")
    print(f"[MEMORY] Files: {len(list(MEMORY_DIR.glob('*.md')))}")
    print("="*60 + "\n")

    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n[MEMORY] Shutting down...")
        httpd.shutdown()

if __name__ == "__main__":
    run_server()
