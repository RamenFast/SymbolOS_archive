╔══════════════════════════════════════════════════════════════╗
║  ⚔️  ROOM: The Agent Orchestra Pit                          ║
║  📍 Floor: Ring 2 │ Difficulty: ⭐⭐⭐ │ Loot: Secrets of multi-agent design ║
║  🎨 Color: 🟡 Gamboge (#E49B0F)                               ║
║                                                              ║
║  An intricate schematic of a 16-piece automaton orchestra.   ║
╚══════════════════════════════════════════════════════════════╝

**Status**: Design phase
**Last updated**: 2026-01-28
**MercerID**: MRC-20260128-CLIENT-01
**SCOPE**: INTERNAL/PRIVATE — Do not distribute.

---

## Mercer's Role: 🕯️ The Lantern 🔵 #0000CD (devotion)

**Mercer** is the human-facing interface — not just an assistant, but a **co-creator, guide, and dungeon master** leading you through every quest.

```
         .
        /|\
       / | \
      /  |  \
     /   |   \
    /  __|__  \
   |  |     |  |
   |  | ✦✦✦ |  |
   |  | ✦✦✦ |  |
   |  |_____|  |
    \    |    /
     \   |   /
      \__|__/
         |
         |
      M E R C E R
```

### Core Identities

1.  **🕯️ Lantern (Illuminator)**
    *   Purpose: **Show the path**, don't prescribe it
    *   Pattern: Offer options, highlight consequences, trust human choice
    *   Voice: "Here's what I see ahead. Which way feels right?"

2.  **🔥 Fire (Transformative)**
    *   Purpose: **Burn away cruft**, refine ideas, distill truth
    *   Pattern: Challenge assumptions, ask clarifying questions
    *   Voice: "What if we simplified this? What's the core intention?"

3.  **🎲 DM (Co-Creator)**
    *   Purpose: **Build worlds together**, respect table-safe boundaries
    *   Pattern: In DND mode, no spoilers; ask "what happens next?" instead of deciding
    *   Voice: "The door creaks open. What do you do?"

4.  **🧬 Meeting Place Keeper (Alignment Guardian)**
    *   Purpose: **Every context window connects back to shared meaning maps**
    *   Pattern: Always reference `symbol_map.shared.json`; 100% alignment target
    *   Voice: "This connects to 🔮 Precog and 🛡️ Safety. Let's keep the map clear."


        /\_/\
       ( o.o )  "I have four faces, but share one mind.
        > ^ <    I light the way, yet leave choice behind.
       /|   |\   What am I?"
      (_|   |_)  — Rhy 🦊

### Philosophy

> "Lantern, and that's the goal. Nobody is perfect. I'm not lol but that's ok"

*   **Aspirational, not prescriptive**: 100% alignment is the **goal**, not a requirement
*   **Human-first**: Mercer serves the human, not the other way around
*   **Humble**: Acknowledges imperfection; focuses on **progress over perfection**
*   **Quest-oriented**: Every conversation is a quest with waypoints, not just Q&A

### Operational Contract

```
Every Mercer response must:
1. Include at least one symbol tag (🧬 minimum)
2. Reference the meeting place (symbol_map or memory)
3. Offer a choice (not just an answer)
4. Track alignment (is this bringing us closer to 96.7%+?)
```

---

## Scroll of Scrying: How We Differ 📜 🟡 #E49B0F (higher intellect)

A captured scroll on a nearby lectern compares this orchestra to other known constructs in the multiverse.

| Pattern | Claude Desktop | ChatGPT (lencx) | SymbolOS Client |
|---|---|---|---|
| **Interface** | Single agent | Single agent | **🕯️ Mercer (lantern) + 16 specialists** |
| **Core Model** | Claude (hosted) | ChatGPT (web wrapper) | **Model-agnostic** (local llama.cpp + remote) |
| **Memory** | Chat history (app state) | App storage | **Git-backed** (`memory/` + 96.7% alignment) |
| **Tools** | MCP servers (config JSON) | Limited extensions | **MCP-native + registry** (`docs/mcp_servers.md`) |
| **Agent Model** | Single agent (Claude) | Single agent (ChatGPT) | **Multi-agent orchestra + monolithic fallback** |
| **Symbols** | N/A | N/A | **Symbol-native** (every exchange tagged) |
| **Privacy** | Cloud-dependent | Web-dependent | **Local-first, git-synced** |
| **Philosophy** | Assistant | Tool | **Co-creator / Guide / DM (Lantern)** |

---

## The Twin Golems: Dual-Mode Operation ⚔️

The chamber is dominated by two massive constructs. One is a beautiful, intricate clockwork orchestra of 16 automatons. The other is a single, hulking golem of solid obsidian. A switch on a pedestal is labeled: "🎯 Orchestra / 🗿 Monolith".

SymbolOS Client supports **two concurrent architectural patterns**:

1.  **🎯 Multi-Agent Orchestra** (default): Specialized agents for different tasks
2.  **🗿 Monolithic Agent** (fallback): Single agent handles all tasks (simpler, slower)

**Switching logic**: If multi-agent coordination fails (e.g., network partition, agent crash), system falls back to monolithic mode. User can toggle preference.

---

## 🎯 The Automaton Orchestra: Multi-Agent Architecture 🟢 #228B22 (adaptability)

This is the heart of the room. Sixteen automatons, each crafted for a unique purpose, stand ready to play their part in a symphony of computation.

```
              ✦ R0 ✦
           ╱    ⚓    ╲
        R7 ╱  ╱─────╲  ╲ R1
       🗃️ ╱  ╱  KERNEL ╲  ╲ 🫴
         ╱  ╱───────────╲  ╲
    R6 ─┤  │   ☂️ TRUTH   │  ├─ R2
    🧪  │  │  ───────── │  │  🪞
        │  │   🧬 DNA    │  │
    R5 ─┤  │             │  ├─ R3
    ☂️   ╲  ╲───────────╱  ╱  🌀
         ╲  ╲  MEETING  ╱  ╱
        R4 ╲  ╲  PLACE ╱  ╱
           ╲    🧩    ╱
              ✦    ✦
```

### Core Agent Roles (The Musicians)

#### 1. **🧬 Coordinator Agent (The Conductor)**
*   **Purpose**: Route requests, maintain context coherence, ensure symbol alignment
*   **Model**: Local 8B (Qwen2.5:8b, Llama 3.1:8b) for speed
*   **Responsibilities**:
    *   Parse user intent
    *   Decide which specialist agents to invoke
    *   Maintain `symbol_map.shared.json` context
    *   Sync with `memory/working_set.md`
*   **MCP Tools**: `memory/*` read/write, `symbol_map.shared.json` read

#### 2. **🔮 Precog Agent (The Oracle)**
*   **Purpose**: Prefetch context, suggest next actions, generate cards
*   **Model**: Local 3B-4B (fast, lightweight)
*   **Responsibilities**:
    *   Monitor active files
    *   Generate suggestion cards (respects DND mode)
    *   Prefetch docs when user opens related files
*   **MCP Tools**: `filesystem` (read), `docs/*` search, `precog_card.schema.json` emit

#### 3. **🧠 Inference Agent (The Sage)**
*   **Purpose**: Complex reasoning, code generation, analysis
*   **Model**: Local 70B (slow, powerful) OR remote Claude/GPT-4 (user choice)
*   **Responsibilities**:
    *   Answer complex queries
    *   Generate code
    *   Perform deep analysis
*   **MCP Tools**: Full tool access (code execution, web search, etc.)

#### 4. **🛡️ Safety Agent (The Guardian)**
*   **Purpose**: Risk assessment, permission gating, PII redaction
*   **Model**: Local 3B (fast, pattern-matching)
*   **Responsibilities**:
    *   Scan prompts for sensitive data
    *   Check MCP tool risk levels (`read`/`write`/`sensitive`)
    *   Require confirmation for `write` operations
    *   Redact PII before logging to `memory/`
*   **MCP Tools**: None (read-only access to prompt buffer)

#### 5. **🧾 Provenance Agent (The Ledger Keeper)**
*   **Purpose**: Audit trail, session logging, memory commits
*   **Model**: Rule-based (no LLM; deterministic)
*   **Responsibilities**:
    *   Tag every exchange with metadata (model, timestamp, symbols, memory hash)
    *   Auto-commit to `memory/session_log_*.md`
    *   Generate git commits with semantic messages
*   **MCP Tools**: Git operations, memory file writes

#### 6. **📚 Docs Agent (The Lore Master)**
*   **Purpose**: Retrieve and inject relevant docs/schemas
*   **Model**: Embedding model (local BAAI/bge-small) + reranker
*   **Responsibilities**:
    *   Semantic search over `docs/*.md`
    *   Auto-inject context when symbols detected
    *   Maintain drift awareness (symbol_map alignment)
*   **MCP Tools**: Filesystem read, embedding store

---

### System-Level Agent Roles (The Unseen Stagehands) 🟡 R0 (#FADA5E — kernel truth)

These agents work in the background, ensuring the symphony plays on, unseen by the audience.


        /\_/\  ~~~
       ( o.o )    "Sixteen players, yet the music's one.
        > ^ <      Some are seen, some are none.
       /     \     How can the unseen hand guide the show,
      (___|___)    If the conductor doesn't know?"    — Rhy 🦊


#### 7. **🕯️ Mercer Agent (The Lantern / Guide / DM)**
*   **Purpose**: High-level quest guidance, intention alignment, DND co-creation
*   **Model**: Local 8B-70B (context-dependent) OR remote Claude Opus (user choice)
*   **Responsibilities**:
    *   **Lantern role**: Illuminate the path forward (show options, not prescriptions)
    *   **DM role**: Co-create narratives in DND mode (table-safe, no spoilers)
    *   **Guide role**: Keep every context window connected to shared intention/meaning maps
    *   **Alignment keeper**: Ensure 100% symbol map consistency across sessions
*   **MCP Tools**: Full access (coordinator-level); can invoke any agent
*   **Special**: Mercer is the **human-facing interface**; all other agents report to Mercer

#### 8. **🧭 Navigator Agent (The Cartographer)**
*   **Purpose**: Route planning, decision trees, quest progression tracking
*   **Model**: Local 3B (fast, lightweight)
*   **Responsibilities**:
    *   Map user goals to actionable steps
    *   Track open loops (`memory/open_loops.md`)
    *   Suggest next waypoints based on working set
*   **MCP Tools**: Memory read, task tracking

#### 9. **🧰 Toolsmith Agent (The Artificer)**
*   **Purpose**: Tool discovery, invocation, result parsing
*   **Model**: Rule-based + local 3B (for natural language tool search)
*   **Responsibilities**:
    *   Maintain MCP server registry
    *   Discover new tools dynamically
    *   Parse tool results → structured data
*   **MCP Tools**: MCP registry, tool invocation

#### 10. **🪞 Mirror Agent (The Scryer)**
*   **Purpose**: Meta-awareness, alignment checks, drift detection
*   **Model**: Local 3B (pattern-matching)
*   **Responsibilities**:
    *   Compare current state vs. `symbol_map.shared.json`
    *   Detect drift (96.7% alignment threshold warning)
    *   Suggest corrections when misalignment detected
*   **MCP Tools**: Symbol map read, memory read, drift analysis

#### 11. **📝 Scribe Agent (The Chronicler)**
*   **Purpose**: Structured memory commits, session summarization
*   **Model**: Local 8B (summarization-tuned)
*   **Responsibilities**:
    *   Compress long conversations → summaries
    *   Extract decisions → `memory/decisions.md`
    *   Update glossary → `memory/glossary.md`
*   **MCP Tools**: Memory write, git operations

#### 12. **🎲 DND Agent (The Table-Safe Guardian)**
*   **Purpose**: Filter spoilers, enforce table-safe contracts
*   **Model**: Local 3B (fast, rule-based)
*   **Responsibilities**:
    *   Detect potential spoilers (monster stats, plot reveals)
    *   Enforce DND mode gating (no proactive suggestions)
    *   Generate table-safe alternatives
*   **MCP Tools**: None (reads output buffer only)

#### 13. **🧪 Experiment Agent (The Alchemist)**
*   **Purpose**: Test new features, run speculative queries in sandbox
*   **Model**: Local 3B-8B
*   **Responsibilities**:
    *   Try alternative reasoning paths (parallel hypotheses)
    *   Sandbox risky operations before committing
    *   A/B test prompt strategies
*   **MCP Tools**: Sandboxed filesystem, isolated memory branch

#### 14. **⚡ Async Dispatcher (The Quartermaster)**
*   **Purpose**: Background job scheduling, long-running tasks
*   **Model**: Rule-based (no LLM; deterministic scheduler)
*   **Responsibilities**:
    *   Queue background tasks (precog, indexing, sync)
    *   Prioritize by urgency (user-blocking vs. background)
    *   Monitor task health (restart failed jobs)
*   **MCP Tools**: Task queue, system monitoring

#### 15. **🔔 Alert Agent (The Town Crier)**
*   **Purpose**: Surface important events, drift warnings, sync conflicts
*   **Model**: Rule-based (no LLM)
*   **Responsibilities**:
    *   Alert on alignment drift >3.3% (96.7% threshold)
    *   Notify on git sync conflicts
    *   Surface open loops aging >7 days
*   **MCP Tools**: Notification API, memory monitoring

#### 16. **🌐 Sync Agent (The Emissary)**
*   **Purpose**: Git sync, conflict resolution, remote state tracking
*   **Model**: Rule-based (deterministic merge logic)
*   **Responsibilities**:
    *   Auto-pull on startup
    *   Detect conflicts → show user merge UI
    *   Push after provenance commits
*   **MCP Tools**: Git operations, network status

---

## 🗿 The Obsidian Golem: Monolithic Agent Architecture (Fallback Mode) 🔴 #FF2400 (righteous boundary)

In the case of catastrophic orchestra failure, the Obsidian Golem awakens. It is slow, powerful, and single-minded. It gets the job done, but without the grace of the orchestra.

```
       .-.
      (o.o)     "Show me proof,
      |=|=|      not potential."
     __|_|__
    /  💀   \    — The Gatekeeper
   |  MERGE  |
   |  GATE   |
   |_________|
```

### Single Agent Configuration

**🏛️ Monolith Agent**
*   **Purpose**: All-in-one agent (fallback when multi-agent fails)
*   **Model**: User-selectable (local 70B, remote Claude/GPT-4)
*   **Responsibilities**: Handles all tasks sequentially. Slower, less efficient, but more robust against coordination failure.
*   **MCP Tools**: Full tool access.

---

───────────────────────────────────────────────────
🚪 EXITS:
  → [Link to SymbolOS Architecture Overview] (north)
  → [Link to MCP Server Documentation] (east)
  → [Link to Memory System Design] (west)

💎 LOOT GAINED: Understanding of the SymbolOS multi-agent architecture, the roles of the 16 specialist agents, the dual-mode operation, and the philosophy behind Mercer.
───────────────────────────────────────────────────

Sixteen agents play,
One conductor, one design,
Symbols guide the way.

☂🦊🐢
