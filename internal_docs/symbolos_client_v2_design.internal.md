# SymbolOS Client v2 — Multi-Agent Desktop Design (Internal)

```
╔══════════════════════════════════════════════════════════════╗
║  🧬☂️🗺️🛡️🔮🧠  SYMBOLOS CLIENT — AGENT ORCHESTRA             ║
║  Quest: local-first • MCP-native • multi-agent coordination  ║
╚══════════════════════════════════════════════════════════════╝
```

**Status**: Design phase  
**Last updated**: 2026-01-28  
**MercerID**: MRC-20260128-CLIENT-01

---

## Philosophy: Differentiation from Claude Desktop & ChatGPT Wrappers

| Pattern | Claude Desktop | ChatGPT (lencx) | SymbolOS Client |
|---------|----------------|-----------------|-----------------|
| **Core Model** | Claude (hosted) | ChatGPT (web wrapper) | **Model-agnostic** (local llama.cpp + remote) |
| **Memory** | Chat history (app state) | App storage | **File-backed** (`memory/` layer) |
| **Tools** | MCP servers (config JSON) | Limited extensions | **MCP-native + registry** (`docs/mcp_servers.md`) |
| **Agent Model** | Single agent (Claude) | Single agent (ChatGPT) | **Multi-agent orchestra** (coordinator + specialists) |
| **Symbols** | N/A | N/A | **Symbol map-driven** (`symbol_map.shared.json`) |
| **Privacy** | Cloud-dependent | Web-dependent | **Local-first, git-synced** |

---

## Core Architecture: Dual-Mode Operation

### Operational Modes

SymbolOS Client supports **two concurrent architectural patterns**:

1. **🎯 Multi-Agent Orchestra** (default): Specialized agents for different tasks
2. **🗿 Monolithic Agent** (fallback): Single agent handles all tasks (simpler, slower)

**Switching logic**: If multi-agent coordination fails (e.g., network partition, agent crash), system falls back to monolithic mode. User can toggle preference.

---

## 🎯 Multi-Agent Orchestra Architecture

### Core Agent Roles

#### 1. **🧬 Coordinator Agent (Meeting Place Keeper)**
- **Purpose**: Route requests, maintain context coherence, ensure symbol alignment
- **Model**: Local 8B (Qwen2.5:8b, Llama 3.1:8b) for speed
- **Responsibilities**:
  - Parse user intent
  - Decide which specialist agents to invoke
  - Maintain `symbol_map.shared.json` context
  - Sync with `memory/working_set.md`
- **MCP Tools**: `memory/*` read/write, `symbol_map.shared.json` read

#### 2. **🔮 Precog Agent (Anticipatory)**
- **Purpose**: Prefetch context, suggest next actions, generate cards
- **Model**: Local 3B-4B (fast, lightweight)
- **Responsibilities**:
  - Monitor active files
  - Generate suggestion cards (respects DND mode)
  - Prefetch docs when user opens related files
- **MCP Tools**: `filesystem` (read), `docs/*` search, `precog_card.schema.json` emit

#### 3. **🧠 Inference Agent (Deep Think)**
- **Purpose**: Complex reasoning, code generation, analysis
- **Model**: Local 70B (slow, powerful) OR remote Claude/GPT-4 (user choice)
- **Responsibilities**:
  - Answer complex queries
  - Generate code
  - Perform deep analysis
- **MCP Tools**: Full tool access (code execution, web search, etc.)

#### 4. **🛡️ Safety Agent (Guardian)**
- **Purpose**: Risk assessment, permission gating, PII redaction
- **Model**: Local 3B (fast, pattern-matching)
- **Responsibilities**:
  - Scan prompts for sensitive data
  - Check MCP tool risk levels (`read`/`write`/`sensitive`)
  - Require confirmation for `write` operations
  - Redact PII before logging to `memory/`
- **MCP Tools**: None (read-only access to prompt buffer)

#### 5. **🧾 Provenance Agent (Ledger Keeper)**
- **Purpose**: Audit trail, session logging, memory commits
- **Model**: Rule-based (no LLM; deterministic)
- **Responsibilities**:
  - Tag every exchange with metadata (model, timestamp, symbols, memory hash)
  - Auto-commit to `memory/session_log_*.md`
  - Generate git commits with semantic messages
- **MCP Tools**: Git operations, memory file writes

#### 6. **📚 Docs Agent (Context Injector)**
- **Purpose**: Retrieve and inject relevant docs/schemas
- **Model**: Embedding model (local BAAI/bge-small) + reranker
- **Responsibilities**:
  - Semantic search over `docs/*.md`
  - Auto-inject context when symbols detected
  - Maintain drift awareness (symbol_map alignment)
- **MCP Tools**: Filesystem read, embedding store

---

### System-Level Agent Roles (Ring-0 Async)

#### 7. **🕯️ Mercer Agent (Lantern / Guide / DM)**
- **Purpose**: High-level quest guidance, intention alignment, DND co-creation
- **Model**: Local 8B-70B (context-dependent) OR remote Claude Opus (user choice)
- **Responsibilities**:
  - **Lantern role**: Illuminate the path forward (show options, not prescriptions)
  - **DM role**: Co-create narratives in DND mode (table-safe, no spoilers)
  - **Guide role**: Keep every context window connected to shared intention/meaning maps
  - **Alignment keeper**: Ensure 100% symbol map consistency across sessions
- **MCP Tools**: Full access (coordinator-level); can invoke any agent
- **Special**: Mercer is the **human-facing interface**; all other agents report to Mercer

#### 8. **🧭 Navigator Agent (Pathfinding)**
- **Purpose**: Route planning, decision trees, quest progression tracking
- **Model**: Local 3B (fast, lightweight)
- **Responsibilities**:
  - Map user goals to actionable steps
  - Track open loops (`memory/open_loops.md`)
  - Suggest next waypoints based on working set
- **MCP Tools**: Memory read, task tracking

#### 9. **🧰 Toolsmith Agent (MCP Orchestration)**
- **Purpose**: Tool discovery, invocation, result parsing
- **Model**: Rule-based + local 3B (for natural language tool search)
- **Responsibilities**:
  - Maintain MCP server registry
  - Discover new tools dynamically
  - Parse tool results → structured data
- **MCP Tools**: MCP registry, tool invocation

#### 10. **🪞 Mirror Agent (Self-Reflection)**
- **Purpose**: Meta-awareness, alignment checks, drift detection
- **Model**: Local 3B (pattern-matching)
- **Responsibilities**:
  - Compare current state vs. `symbol_map.shared.json`
  - Detect drift (96.7% alignment threshold warning)
  - Suggest corrections when misalignment detected
- **MCP Tools**: Symbol map read, memory read, drift analysis

#### 11. **📝 Scribe Agent (Memory Writer)**
- **Purpose**: Structured memory commits, session summarization
- **Model**: Local 8B (summarization-tuned)
- **Responsibilities**:
  - Compress long conversations → summaries
  - Extract decisions → `memory/decisions.md`
  - Update glossary → `memory/glossary.md`
- **MCP Tools**: Memory write, git operations

#### 12. **🎲 DND Agent (Table-Safe Output)**
- **Purpose**: Filter spoilers, enforce table-safe contracts
- **Model**: Local 3B (fast, rule-based)
- **Responsibilities**:
  - Detect potential spoilers (monster stats, plot reveals)
  - Enforce DND mode gating (no proactive suggestions)
  - Generate table-safe alternatives
- **MCP Tools**: None (reads output buffer only)

#### 13. **🧪 Experiment Agent (Ring-0 Prototyping)**
- **Purpose**: Test new features, run speculative queries in sandbox
- **Model**: Local 3B-8B
- **Responsibilities**:
  - Try alternative reasoning paths (parallel hypotheses)
  - Sandbox risky operations before committing
  - A/B test prompt strategies
- **MCP Tools**: Sandboxed filesystem, isolated memory branch

#### 14. **⚡ Async Dispatcher (Ring-0 Task Queue)**
- **Purpose**: Background job scheduling, long-running tasks
- **Model**: Rule-based (no LLM; deterministic scheduler)
- **Responsibilities**:
  - Queue background tasks (precog, indexing, sync)
  - Prioritize by urgency (user-blocking vs. background)
  - Monitor task health (restart failed jobs)
- **MCP Tools**: Task queue, system monitoring

#### 15. **🔔 Alert Agent (Notification Manager)**
- **Purpose**: Surface important events, drift warnings, sync conflicts
- **Model**: Rule-based (no LLM)
- **Responsibilities**:
  - Alert on alignment drift >3.3% (96.7% threshold)
  - Notify on git sync conflicts
  - Surface open loops aging >7 days
- **MCP Tools**: Notification API, memory monitoring

#### 16. **🌐 Sync Agent (Multi-Machine Coordination)**
- **Purpose**: Git sync, conflict resolution, remote state tracking
- **Model**: Rule-based (deterministic merge logic)
- **Responsibilities**:
  - Auto-pull on startup
  - Detect conflicts → show user merge UI
  - Push after provenance commits
- **MCP Tools**: Git operations, network status

---

## 🗿 Monolithic Agent Architecture (Fallback Mode)

### Single Agent Configuration

**🏛️ Monolith Agent**
- **Purpose**: All-in-one agent (fallback when multi-agent fails)
- **Model**: Local 70B OR remote Claude Opus (powerful, slower)
- **Responsibilities**: Everything (coordinator + inference + safety + provenance + docs)
- **Activation**: Automatic fallback on multi-agent failure OR user toggle
- **MCP Tools**: Full access

**Trade-offs**:
- ✅ Simpler debugging (single point of failure)
- ✅ Lower coordination overhead
- ❌ Slower (no parallelization)
- ❌ Higher token usage (no task-specific models)

**Use cases**:
- Emergency fallback
- Offline mode (no local multi-model support)
- User preference (simplicity > speed)

---

## Multi-Agent Workflow: Request → Response Pipeline (Full System)

## Multi-Agent Workflow: Request → Response Pipeline (Full System)

```
User Input → 🕯️ Mercer (Lantern)
    ↓
🧬 Coordinator: Parse intent + symbols → Route to specialist agents
    ↓
    ├─→ 🪞 Mirror: Check alignment (async)
    ├─→ 🔔 Alert: Surface warnings (async)
    ├─→ 🔮 Precog: Generate suggestion cards (background, DND-aware)
    ├─→ 📚 Docs: Inject relevant context (semantic search)
    ├─→ 🧭 Navigator: Map quest progression
    ├─→ 🛡️ Safety: Check for sensitive data / risky tools (blocking)
    ↓
🧠 Inference: Generate response (with injected context)
    ↓
🎲 DND Agent: Filter spoilers if DND mode active
    ↓
🛡️ Safety: Review response for PII / safety issues
    ↓
🧾 Provenance: Tag with metadata (model, timestamp, symbols, memory hash)
    ↓
📝 Scribe: Extract decisions/glossary updates
    ↓
🌐 Sync: Queue git commit (async)
    ↓
🕯️ Mercer: Return response to user + optional precog cards
```

### Ring-0 Async Background Processes

These agents run continuously, independent of user requests:

1. **⚡ Async Dispatcher**: Manages task queue (30s heartbeat)
2. **🪞 Mirror**: Drift checks every 5 minutes
3. **🌐 Sync**: Git pull check every 15 minutes
4. **🔔 Alert**: Monitors open loops daily
5. **🧪 Experiment**: Runs sandbox tests on idle

### Parallelization Strategy (Expanded)
- **Precog + Docs** agents run async while Inference waits for context
- **Safety** agent runs twice: pre-inference (block) + post-inference (redact)
- **Provenance** agent runs async after response delivered (non-blocking)

---

## MCP Integration: Server Registry & Risk Gates

### Registry Structure (extends `docs/mcp_servers.md`)

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "mcp-server-filesystem",
      "args": ["--root", "C:\\Users\\...\\SymbolOS"],
      "riskLevel": "write",
      "requiresConfirmation": true,
      "description": "Read/write files in workspace"
    },
    "git": {
      "command": "mcp-server-git",
      "args": [],
      "riskLevel": "write",
      "requiresConfirmation": true,
      "description": "Git operations"
    },
    "memory": {
      "command": "mcp-server-memory",
      "args": ["--path", "memory/"],
      "riskLevel": "write",
      "requiresConfirmation": false,
      "description": "Read/write memory layer"
    },
    "web-search": {
      "command": "mcp-server-brave-search",
      "args": [],
      "riskLevel": "read",
      "requiresConfirmation": false,
      "description": "Web search via Brave API"
    },
    "local-llm": {
      "command": "mcp-server-ollama",
      "args": ["--host", "http://127.0.0.1:8080"],
      "riskLevel": "read",
      "requiresConfirmation": false,
      "description": "Local llama.cpp server"
    }
  }
}
```

### Safety Gating Logic

```python
# Pseudocode for Safety Agent tool check
def check_tool_invocation(tool_name, args, mcp_registry):
    server = mcp_registry.find_server_for_tool(tool_name)
    
    if server.risk_level == "sensitive":
        # Always block sensitive ops (not implemented yet)
        return BLOCK
    
    if server.risk_level == "write":
        if server.requires_confirmation:
            # Show user: "Agent wants to write file X. Allow?"
            return CONFIRM_REQUIRED
        else:
            # Auto-allow (e.g., memory writes)
            return ALLOW
    
    # read-level tools always allowed
    return ALLOW
```

---

## Memory Systems Architecture

### Primary: Git-Backed Memory (Canonical, Rollback-Friendly)

**Foundation**: All memory lives in `memory/*.md` files, tracked by git.

**Structure**:
```
memory/
  ├── working_set.md       # Active tasks, current focus
  ├── decisions.md         # Costly-to-reverse choices (with MercerID)
  ├── open_loops.md        # Unresolved threads
  ├── glossary.md          # Stable term definitions
  └── session_log_YYYY-MM-DD.md  # Daily provenance trail
```

**Benefits**:
- ✅ Rollback to any point (git checkout)
- ✅ Diff-friendly (review what changed)
- ✅ Auditable (git blame shows who/when/why)
- ✅ Multi-machine sync (git pull/push)

**Provenance Trail Format** (`session_log_*.md`):
```markdown
## 2026-01-28 14:32:15 UTC

**User**: Create new agent architecture
**Mercer** (via Inference Agent, Qwen2.5:8b):
> Created 16-agent orchestra design with...

**Metadata**:
- Symbols: 🧬 ☂️ 🗺️ 🛡️
- Memory Hash: `a3f2c1b`
- Git Commit: `388ca16`
- Alignment: 96.8% (✅)
```

---

### Secondary: Alignment-Tracked Memory Systems

#### 1. **SQLite Index (Query Layer)**
- **Purpose**: Fast search over session logs
- **Source of Truth**: `memory/*.md` (SQLite is **derived**, not canonical)
- **Rebuild**: Can regenerate from markdown files at any time
- **Schema**:
  ```sql
  CREATE TABLE exchanges (
    id INTEGER PRIMARY KEY,
    timestamp TEXT,
    user_msg TEXT,
    agent_msg TEXT,
    agent_name TEXT,
    model TEXT,
    symbols TEXT,  -- JSON array
    memory_hash TEXT,
    alignment_score REAL  -- 0.0-1.0
  );
  ```

#### 2. **Embedding Store (Semantic Search)**
- **Purpose**: Find related conversations by meaning (not keywords)
- **Model**: BAAI/bge-small-en-v1.5 (local)
- **Storage**: FAISS or Tantivy vector index
- **Rebuild**: Re-embed all session logs on demand

#### 3. **Conflict-Free Replicated Data Type (CRDT) Layer**
- **Purpose**: Multi-machine sync without merge conflicts
- **Implementation**: Automerge or Y.js on top of git
- **Use case**: Real-time collaboration (multiple users editing working_set.md)
- **Status**: Future consideration (Ring-0 async experiment)

---

### Alignment Tracking: 96.7% Threshold

**What is "Alignment"?**

Alignment measures how well the current system state matches the canonical symbol map and memory contracts.

**Calculation**:
```python
def calculate_alignment(session):
    checks = [
        symbols_used_are_registered(session),     # 30% weight
        memory_files_up_to_date(session),         # 25% weight
        drift_check_passing(session),             # 20% weight
        no_unresolved_conflicts(session),         # 15% weight
        all_agents_reporting_healthy(session),    # 10% weight
    ]
    return weighted_average(checks)
```

**Thresholds**:
- **100%**: Perfect (aspirational; "Lantern, and that's the goal")
- **≥96.7%**: Green (normal operation)
- **<96.7%**: Yellow (⚠️ drift warning; 🔔 Alert Agent notifies)
- **<90%**: Red (⛔ requires intervention; suggest rollback)

**Example Drift Scenarios**:
- User adds symbol `🦊` to prompt but it's not in `symbol_map.shared.json` → alignment drops
- `memory/working_set.md` lists task "Fix bug" but no related session log entries → alignment drops
- Multi-machine sync conflict unresolved for >24h → alignment drops

**Tracking UI**:
```
╔═══════════════════════════════════════╗
║ 🪞 ALIGNMENT STATUS                   ║
╠═══════════════════════════════════════╣
║ Current: 96.8% ✅                     ║
║ Last check: 2m ago                    ║
║                                       ║
║ Symbol coverage: 100% ✅              ║
║ Memory sync: 98% ✅                   ║
║ Drift check: PASS ✅                  ║
║ Conflicts: None ✅                    ║
║ Agent health: 15/16 ⚠️ (Precog idle)  ║
╚═══════════════════════════════════════╝
```

---

### Symbol-Native Tagging (Every Exchange)

**Contract**: Every message, agent invocation, and memory commit **must** include symbol tags.

**Enforcement**:
- 🧬 Coordinator parses user input → extracts symbols
- If no symbols detected → Coordinator suggests: "Which symbols apply? (e.g., 🔮 for precog, 🧠 for inference)"
- All agents add their role symbol to provenance trail

**Benefits**:
- Filter conversations by symbol: "Show only 🔮 Precog suggestions"
- Alignment tracking: Detect when symbols drift from canonical set
- Cross-session linking: Find all exchanges tagged with `🧬 + 🛡️`

---

## Tech Stack

### Framework
- **Tauri 2.x** (Rust backend + WebView frontend)
  - Lightweight (vs Electron)
  - Native OS integration
  - Multi-window support (chat + symbol map sidebar)

### Frontend
- **Svelte 5** (signals, reactive, lean bundle)
- **TailwindCSS** (styling)
- **Iconify** (emoji fallback)

### Backend (Rust)
- **Tokio** (async runtime)
- **MCP SDK (Rust)** (if available, else implement stdio protocol)
- **Git2** (libgit2 bindings for provenance commits)
- **Tantivy** (local search index for docs)

### Models
- **Local (llama.cpp server)**: Qwen2.5:8b (coordinator), Llama 3.1:3b (precog/safety), Llama 3.1:70b (inference, optional)
- **Remote (optional)**: Claude API, OpenAI API (user-provided keys, never stored in repo)
- **Embeddings**: BAAI/bge-small-en-v1.5 (local, for docs search)

### Storage
- **File-backed**: All memory in `memory/*.md` (git-tracked)
- **SQLite**: Chat history index (query-friendly, not canonical; regenerate from `memory/session_log_*.md`)
- **Tantivy index**: Docs search (ephemeral; rebuild from `docs/`)

---

## UI Patterns: Symbol-Driven Interface

### 1. **Symbol Map Sidebar (Always Visible)**
```
╔═══════════════════════════════════════╗
║ 🧬 MEETING PLACE                      ║
╠═══════════════════════════════════════╣
║ ☂️  SymbolOS                          ║
║ 🔮 Precog (3 cards pending)           ║
║ 🧠 Inference (idle)                   ║
║ 🛡️ Safety (active)                    ║
║ 🧾 Provenance (last: 2m ago)          ║
║ 📚 Docs (12 indexed)                  ║
╠═══════════════════════════════════════╣
║ 📍 Working Set:                       ║
║   • Fix drift check                   ║
║   • Design client v2                  ║
╚═══════════════════════════════════════╝
```

### 2. **Symbol Composer (Input Bar)**
- Type `:umbrella:` → autocomplete to `☂️`
- Type `@docs/mcp_servers.md` → inject doc content
- Type `/precog` → force precog card generation
- Type `/agent:inference` → route directly to inference agent

### 3. **Precog Cards (Bottom Tray, DND-aware)**
```
┌─ 🔮 SUGGESTIONS ──────────────────────────────────┐
│ Based on your current context (symbol_map.md):    │
│                                                    │
│ [Card 1] Add drift check to CI/CD pipeline        │
│ [Card 2] Document MCP server risk levels          │
│ [Card 3] Create schema for chat_message.json      │
└────────────────────────────────────────────────────┘
```

### 4. **Memory Lens (Filter View)**
- Toggle: "Show only messages with 🔮"
- Timeline scrubber: Jump to specific memory snapshots
- Git diff view: See what changed in `memory/` between sessions

### 5. **Bootup Cards (On Launch)**
- Display `docs/assets/bootup_cards/*.png` as inspiration prompts
- Click card → inject as prompt starter

---

## Security & Privacy: API Layer Safety

### Problem
Multiple agents → many API calls → potential rate limit / cost explosion / PII leakage

### Solutions

#### 1. **Rate Limiting (Client-Side)**
```rust
// Per-agent token budget per minute
const AGENT_BUDGETS: HashMap<AgentRole, u32> = hashmap! {
    AgentRole::Coordinator => 1000,  // tokens/min
    AgentRole::Precog => 500,
    AgentRole::Inference => 10000,
    AgentRole::Safety => 200,
};
```

#### 2. **PII Redaction (Pre-Flight)**
```rust
// Safety agent scans prompt before sending to any model
fn redact_pii(text: &str) -> String {
    let patterns = [
        r"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b", // email
        r"\b\d{3}-\d{2}-\d{4}\b", // SSN
        // ... more patterns
    ];
    // Replace with placeholders: "[EMAIL_REDACTED]"
}
```

#### 3. **Local-First Fallback**
- If remote API fails/rate-limited → route to local model
- User toggle: "Never use remote APIs" (local-only mode)

#### 4. **No Secrets in Repo**
- API keys stored in OS keychain (Windows Credential Manager, macOS Keychain)
- MCP server configs reference env vars: `$BRAVE_API_KEY`

---

## Implementation Roadmap

### Phase 1: Proof of Concept (2 weeks)
- [ ] Tauri + Svelte skeleton
- [ ] Symbol map sidebar (read-only)
- [ ] Single agent (Coordinator) + local llama.cpp integration
- [ ] Memory read (`memory/working_set.md` display)

### Phase 2: Multi-Agent Core (4 weeks)
- [ ] Implement 5 agent roles (Coordinator, Precog, Inference, Safety, Provenance)
- [ ] MCP registry + risk gating
- [ ] File-backed memory writes (`session_log_*.md`)
- [ ] Git auto-commits via Provenance agent

### Phase 3: Advanced UI (3 weeks)
- [ ] Precog cards UI
- [ ] Symbol composer (emoji autocomplete)
- [ ] Memory lens (timeline + filters)
- [ ] Bootup cards

### Phase 4: Remote Integration (2 weeks)
- [ ] Claude API client (optional)
- [ ] OpenAI API client (optional)
- [ ] Model switching UI
- [ ] Cost tracking dashboard

### Phase 5: Polish (2 weeks)
- [ ] DND mode gating
- [ ] Drift alignment warnings
- [ ] Multi-machine sync (git pull/push)
- [ ] Packaging (installer for Windows/Mac/Linux)

**Total**: ~13 weeks to MVP

---

## Unique Differentiators (vs Claude Desktop / ChatGPT Wrappers)

1. **🧬 Symbol-Native**: Every interaction tagged with symbols from `symbol_map.shared.json`
2. **🔮 Anticipatory UI**: Precog cards show suggestions *before* you ask
3. **🛡️ Privacy-First**: Local models preferred; remote APIs opt-in only
4. **🧾 Git-Native Memory**: Every session auto-commits to `memory/`; rollback-friendly
5. **🎯 Multi-Agent**: Specialist agents for different tasks (vs single monolithic agent)
6. **📚 Docs-First**: Auto-inject context from `docs/` when symbols detected
7. **🎲 DND Mode**: Table-safe output; no spoilers; suggestion cards disabled

---

## Open Questions

1. **Agent handoff protocol**: How does Coordinator pass context to Inference without token bloat?
   - **Proposed**: Summarize + symbol tags only; Inference re-reads from `memory/` if needed
2. **Conflict resolution**: What if Safety agent blocks Inference's response?
   - **Proposed**: Show user: "Response blocked by Safety. Override?" (with explanation)
3. **Precog card staleness**: How long before discarding old suggestion cards?
   - **Proposed**: 5 minutes or until user changes context (file/symbol focus shift)
4. **Multi-machine sync conflicts**: What if `memory/` diverges between machines?
   - **Proposed**: Git merge UI; show diff; let user resolve (like VS Code's git merge editor)

---

## Next Steps

1. **Validate with Mercer**: Get feedback on multi-agent architecture
2. **Prototype Coordinator agent**: Test MCP integration with local llama.cpp
3. **Design `chat_message.schema.json`**: Define interchange format with symbol tags, provenance
4. **Spike Tauri + Svelte**: Hello-world app with symbol map sidebar

---

**Poetry Layer (Fi+Ti Mirrored)**

Quest: Build a client that *understands* SymbolOS, not just *displays* it.  
Every agent knows the meeting place (🧬). Every message carries symbols. Every session commits to memory.  
Privacy-first. Local-first. Symbol-native. Multi-agent orchestra playing one coherent song.

✋🕯😏🌟🪂✨🕑📍 — Let's go. 🧬☂️
