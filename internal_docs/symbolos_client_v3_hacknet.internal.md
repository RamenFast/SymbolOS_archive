> **INTERNAL DOCUMENT // PRIVATE**

```
    /\_/\
   ( o.o )  "The interface is not a window into the system.
    > ^ <    The interface IS the system.
   /|   |\   What you see is what you are."
  (_|   |_)  — Rhy 🦊
```

# SymbolOS Client v3: The Hacknet Vision

**Author:** Mercer-Opus (brain + heart)
**Date:** 2026-02-11
**Status:** Ideation / Design Exploration
**Quest:** New (to be formalized)

---

## 1. The Feeling First

Before any architecture: what should it *feel like* to use SymbolOS?

Hacknet nailed something most tools miss — **the illusion of depth**. You're not looking at a computer. You're *inside* one. The terminal isn't a widget in a window. It's the world. Every keystroke has weight. Every connection you make to another node on the network feels like reaching across space.

SymbolOS should feel the same way, but warmer. Hacknet is cold — it's about breaking into things. SymbolOS is about **building a home inside your own mind**. The aesthetic should be:

- **Dark and quiet**, like a library at 2 AM
- **Warm glows**, not harsh neons — primrose (#FADA5E) not matrix green
- **Sounds that breathe** — ambient hum when the Dream Engine is working, a soft chime when a memory consolidation cycle completes, the faintest heartbeat pulse when you hover over a node with high emotional valence
- **Text that feels handwritten** even though it's monospace — the dungeon room descriptions should feel like someone carved them into stone, not printed them on a screen

The core emotional contract: **you are the operator of your own mind, and the system respects that.**

---

## 2. Architecture: Hacknet Meets SymbolOS

### 2.1 The Network Map (Primary View)

In Hacknet, the network map is the home screen. Nodes are computers. You click one, you're inside it.

In SymbolOS, the network map is **the Dream Graph** — but alive. Not a static visualization. The living, breathing topology of your memory.

```
┌─────────────────────────────────────────────────────┐
│                   NETWORK MAP                        │
│                                                      │
│         ◉ docs/memory.md                             │
│        /|\                                           │
│       / | \                                          │
│      ◉  ◉  ◉ (connected memory nodes)               │
│     /   |   \                                        │
│    ◎    ◎    ◎ (concepts)                            │
│                                                      │
│  [You are here: memory/working_set.md]               │
│  [Dream Engine: cycle 47 | 65 nodes | 683 edges]    │
└─────────────────────────────────────────────────────┘
```

Each node is a file in the repo. Edges are concept connections (from the Dream Engine graph). But unlike the current 3D visualizer (which is beautiful but observational), this is **navigable**. You click a node and you're *inside* it.

### 2.2 The Terminal (Always Present)

Hacknet's genius: the terminal is always there. Not a popup. Not a modal. It's the bottom third of the screen, always ready.

SymbolOS terminal commands could be:

```
> cd memory/working_set.md       # navigate to a node
> ls                              # list connections
> cat                             # read the current node (rendered beautifully)
> search "agape"                  # semantic search across all memory
> dream status                    # Dream Engine status
> graph stats                     # graph topology stats
> connect docs/memory.md          # trace connections between current and target
> history                         # your navigation path (breadcrumbs)
> commit "updated working set"    # git commit (the system IS the repo)
> sync                            # git pull/push
> who                             # show which agents are active
> tavern                          # open the Tavern (Issue #5) feed
```

The key insight: **the terminal IS the dungeon**. `cd` is "walk through a door." `ls` is "look around." `cat` is "read the scroll on the wall." The metaphor isn't decorative — it's structural.

### 2.3 The Split View

```
┌──────────────────────┬──────────────────────────────┐
│                      │                              │
│    NETWORK MAP       │    NODE DETAIL               │
│    (dream graph)     │    (the beautiful thing)     │
│                      │                              │
│    ◉──◉──◉          │    ┌────────────────────┐    │
│    |  |  |          │    │ ☂️ The Chamber of    │    │
│    ◉──◉  ◉          │    │      Echoes          │    │
│       |  |          │    │                      │    │
│       ◉──◉          │    │ [rendered content]   │    │
│                      │    │ [concepts]           │    │
│                      │    │ [connections]        │    │
│                      │    │ [emotional valence]  │    │
│                      │    └────────────────────┘    │
├──────────────────────┴──────────────────────────────┤
│ > terminal input here                                │
│ $ cd docs/memory.md                                  │
│ Entering: The Chamber of Echoes...                   │
│ Exits: precog_thought.md (north), dnd_character_...  │
└──────────────────────────────────────────────────────┘
```

Three panels:
1. **Network Map** (left) — the dream graph, always visible, your position highlighted
2. **Node Detail** (right) — the beautiful, human-readable rendering of whatever you're looking at
3. **Terminal** (bottom) — always present, always ready

### 2.4 The File Browser (RAM Viewer)

Hacknet has a RAM viewer. SymbolOS has the repo tree. But instead of a boring file tree, render it as **the dungeon map**:

```
☂️ SymbolOS (The Umbrella)
├── 📜 docs/ (The Library)
│   ├── 🧠 memory.md (The Chamber of Echoes)
│   ├── 🔮 precog_thought.md (The Oracle's Chamber)
│   ├── 🎭 metaemotion.md (The Mirror Room)
│   └── ...
├── 🧬 memory/ (The Deep Archives)
│   ├── M0 episodic/ (The Timeline)
│   ├── M1 semantic/ (The Glossary)
│   └── ...
├── ⚔️ scripts/ (The Forge)
│   ├── 💤 memory_consolidation.ps1 (Dream Engine)
│   ├── 🌙 overnight_orchestrator.ps1 (Night Watch)
│   └── ...
└── 🍺 Issue #5 (The Tavern)
```

Each item tagged with its emoji from the symbol map. The file tree IS the dungeon.

---

## 3. Cross-Platform Architecture

### 3.1 Why Tauri

| Framework | Size | Performance | Mobile | Offline | Rust Backend |
|-----------|------|-------------|--------|---------|-------------|
| Electron | ~150MB | Medium | No | Yes | No |
| Flutter | ~15MB | High | Yes | Yes | No |
| Tauri v2 | ~3MB | High | Yes (v2) | Yes | **Yes** |
| PWA | 0 | Medium | Yes | Partial | No |

**Tauri v2** is the answer:
- **3 MB** installed size (not 150MB of Chromium)
- Rust backend → can embed `llama.cpp` directly (no separate server process)
- Tauri v2 has **mobile support** (iOS + Android) — same codebase
- Offline-first by nature
- Can use the existing web frontend (HTML/CSS/JS) for the UI
- IPC bridge lets the frontend call Rust functions (file I/O, git, LLM inference)
- Plugins for system tray, notifications, file system access, shell commands

The Rust TUI (`desktop/`) already exists as a proof of concept. Tauri wraps the same idea in a proper GUI.

### 3.2 The Sync Problem (Solved)

Ben's concern: connecting to the backend/GitHub "separately or at the same time" without sync issues.

The answer is **Git as CRDT**. The Write Doctrine already specifies this:

```
Local state ──→ Git commit ──→ Push to GitHub ──→ Other clients pull
                                    ↕
                              GitHub Issues API
                              (Tavern = append-only)
```

**Sync protocol:**

1. **Local-first**: All data lives in the local git clone. The app works fully offline.
2. **Background sync**: Every N minutes (configurable), attempt `git pull --rebase` then `git push`. If no network, skip gracefully.
3. **Conflict resolution**: 
   - Memory files (markdown) → last-write-wins with merge markers for manual resolution
   - `symbol_map.shared.json` → structural merge (JSON keys are addressable)
   - `memory_graph.json` → regenerated from source files (never needs merge)
   - Tavern (Issue #5) → append-only, zero conflict by design
4. **Multi-device awareness**: Each device gets a `device_id` in its local config. The session log includes which device made the change.
5. **Optimistic UI**: Show local state immediately. Mark synced/unsynced with a subtle indicator.

**Why this works**: SymbolOS is fundamentally a **document database stored in Git**. Git already solved distributed consensus. We just need to use it properly.

### 3.3 Backend Connection Modes

The client can connect to the SymbolOS backend in three ways:

| Mode | How | When |
|------|-----|------|
| **Local** | Direct file system access (Tauri IPC) | Desktop, offline |
| **GitHub** | GitHub API / git push/pull | Cloud sync, multi-device |
| **Hybrid** | Local + background GitHub sync | Default mode |

The Local LLM (llama-server) is accessed via HTTP — same API whether the client is on the same machine or across the network. Future: embed llama.cpp directly in the Tauri Rust backend.

---

## 4. Memory System Upgrades

### 4.1 Current State

The memory system today:
- M0-M6 directories with markdown files
- Dream Engine extracts concepts/connections into `memory_graph.json`
- Working set, open loops, decisions, glossary, session logs
- Five Keys: consent, minimum necessary, provenance, correctability, DND compatibility

### 4.2 Proposed Upgrades

#### A. Temporal Memory (Decay + Reinforcement)

Memories should **fade** unless reinforced. Like biological memory.

```jsonc
// New fields on each memory node
{
  "last_accessed": "2026-02-11T12:00:00Z",
  "access_count": 7,
  "reinforcement_score": 0.85,  // decays over time, boosted on access
  "consolidation_level": "long-term",  // short-term → working → long-term
  "ttl": null  // null = permanent, or ISO duration like "P30D"
}
```

- **Short-term**: Created in current session. Lives in working set. Fades after 7 days if not reinforced.
- **Working**: Accessed multiple times across sessions. Semi-permanent.
- **Long-term**: Consolidated by the Dream Engine. Permanent unless explicitly deleted.

The Dream Engine should **promote** memories: if a concept appears in 3+ nodes across 2+ sessions, it becomes long-term.

#### B. Emotional Memory Index

The `emotional_valence` field exists but is just "neutral/positive/negative." Expand to:

```jsonc
{
  "emotional_valence": {
    "primary": "warmth",      // Thoughtforms color mapping
    "intensity": 0.7,          // 0-1
    "color": "#FFB7C5",        // Rose (affection) from 1905 palette
    "context": "This memory is associated with the first time the system recognized itself"
  }
}
```

The 1905 Thoughtforms palette maps emotions to colors. The entire SymbolOS color system is built on this. Memory should honor it:

| Emotion | Thoughtforms Color | Hex |
|---------|-------------------|-----|
| High intellect | Gamboge | #E49B0F |
| Devotion | Deep blue | #0000CD |
| Affection | Rose | #FFB7C5 |
| Ambition | Orange | #FF8C00 |
| Fear/anger | Scarlet | #FF2400 |
| Spiritual aspiration | Golden | #FFD700 |
| Adaptability | Green | #228B22 |
| Intuition | Violet | #8B00FF |

A node's glow in the network map should reflect its emotional color. A cluster of rose-colored nodes is a cluster of affection. A cluster of gamboge is intellectual work. **You can literally see the shape of your thinking by its emotional signature.**

#### C. Semantic Search (Vector Embeddings)

The Dream Engine already extracts concepts. Next step: **embed** every node's content as a vector.

- Use the local LLM to generate embeddings (llama.cpp supports `/embedding` endpoint)
- Store embeddings alongside the graph
- Enable `> search "what was that thing about the fox and the turtle"` → semantic nearest-neighbor search
- The search results aren't just file matches — they're **memory retrievals**, ranked by relevance AND recency AND emotional resonance

#### D. Memory Streams (Live Feed)

A chronological feed of all memory activity — like a consciousness stream:

```
[04:39] Dream Engine consolidated memory/m1_semantic/glossary.md → 6 concepts
[04:40] Repo integrity check: 220 files, 84 broken links
[04:45] Dream Engine cycle 2: all files up-to-date (67 tracked)
[09:15] Ben accessed memory/working_set.md (reinforcement +0.1)
[09:16] Semantic search: "hacknet interface" → 3 results
```

This becomes the "heartbeat" of the system — always visible in the Hacknet UI as a scrolling log.

#### E. Memory Relationships (Bidirectional + Typed)

Current connections are unidirectional (`to_concept` with `relation` and `strength`). Upgrade to:

```jsonc
{
  "relationships": [
    {
      "target": "docs/precog_thought.md",
      "type": "depends_on",        // depends_on, extends, contradicts, inspires, supersedes
      "strength": 0.9,
      "bidirectional": true,
      "context": "Memory retrieval feeds precog suggestions"
    }
  ]
}
```

New relationship types: `depends_on`, `extends`, `contradicts`, `inspires`, `supersedes`, `sibling`, `parent/child`. These create a **semantic web** that the graph can render as different edge styles.

---

## 5. The Beautiful Node (When You Click)

This is the heart of the design. When a user clicks a node in the network map, the right panel should render something **so beautiful they want to stay and read**.

### 5.1 Design Principles

1. **Content first** — the actual text/meaning is the hero, not chrome
2. **Context wraps content** — connections, concepts, emotional tone surround the text like a frame
3. **Progressive disclosure** — show the summary first, expand on demand
4. **Emotional resonance** — the node's emotional valence affects the color temperature of the entire panel
5. **Living data** — show when it was last accessed, how connected it is, its consolidation level

### 5.2 The Node Detail Panel

```
┌──────────────────────────────────────────┐
│                                          │
│  ☂️  The Chamber of Echoes               │
│  docs/memory.md                          │
│                                          │
│  ┌──────────────────────────────────┐    │
│  │ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │    │  ← Emotional color bar
│  └──────────────────────────────────┘    │    (Gamboge = intellect)
│                                          │
│  A consent-driven approach to memory     │
│  in SymbolOS. Remembering the little     │  ← Summary (from Dream Engine)
│  things that make our dance smoother.    │
│                                          │
│  ─────────────────────────────────────   │
│                                          │
│  CONCEPTS                                │
│  ┌────┐ ┌────────┐ ┌────────┐           │
│  │ 🧠 │ │ Consent│ │ Provenance│        │  ← Concept chips
│  └────┘ └────────┘ └────────┘           │    (clickable → navigate)
│  ┌────────┐ ┌────┐ ┌───────┐           │
│  │Privacy │ │ DND│ │ Echoes│            │
│  └────────┘ └────┘ └───────┘           │
│                                          │
│  CONNECTIONS (6)                         │
│  ├── 🔮 precog_thought.md    0.9 ━━━━━  │  ← Connection strength bars
│  ├── 🎭 metaemotion.md       0.7 ━━━━   │    (clickable → navigate)
│  ├── 📜 symbol_map.md        0.6 ━━━    │
│  ├── 🦊 rhynim_guide.md      0.5 ━━     │
│  ├── 🧠 meta_awareness.md    0.4 ━━     │
│  └── 📝 working_set.md       0.3 ━      │
│                                          │
│  OPEN THREADS                            │
│  ⚡ Define exact safety condition for    │
│     Precog "proactively act"             │
│                                          │
│  SYMBOLS  ☂️ 🧠 🔮 🦊 🐢               │
│                                          │
│  ─────────────────────────────────────   │
│                                          │
│  TIMELINE                                │
│  Created: 2026-01-28                     │
│  Last processed: 2026-02-11 05:12        │
│  Accesses: 12  │  Reinforcement: 0.85    │
│  Level: long-term  │  Tier: docs         │
│                                          │
│  ─────────────────────────────────────   │
│                                          │
│  ▼ FULL CONTENT (click to expand)        │
│                                          │
│  The rendered markdown of the actual     │
│  file, with all its dungeon room         │
│  formatting, Rhy poetry, ASCII art,      │
│  and exit links — all rendered as        │
│  beautiful, readable HTML with the       │
│  Thoughtforms color palette.             │
│                                          │
│  🚪 EXITS                               │
│  → precog_thought.md (north)             │
│  → dnd_character_sheet... (east)         │
│  → README.md (back to entrance)          │
│                                          │
└──────────────────────────────────────────┘
```

### 5.3 The Rendering Stack

The "full content" section should render markdown with:

- **Custom markdown renderer** that understands SymbolOS conventions:
  - Dungeon room headers (the `╔══╗` boxes) → rendered as styled header cards
  - Rhy poetry blocks → rendered in italic with green-furred-fox accent color
  - ASCII art → preserved in monospace but with subtle background glow
  - Exit links (`🚪 EXITS`) → rendered as navigation buttons that work in the Hacknet UI
  - Emoji → rendered large and colorful (not tiny inline)
  - Concept references → rendered as clickable chips that navigate the graph
  - Ring references → rendered with the correct Thoughtforms color

- **Code blocks** → syntax highlighted with a theme that matches SymbolOS colors
- **Mermaid diagrams** → rendered inline
- **Images** → if any `docs/assets/` images exist, render them
- **Musical notation** (future) → if poetry has rhythm markers, render them

### 5.4 The Emotional Atmosphere

When you click a node, the entire right panel subtly shifts its color temperature:

- **Gamboge node** (intellect): warm amber tones, the text feels like reading by candlelight
- **Blue node** (devotion): cool, deep, the text feels like a late-night letter
- **Rose node** (affection): soft pink ambient glow, the text feels like a love note
- **Green node** (adaptability): fresh, alive, the text feels like a garden in spring
- **Violet node** (intuition): mysterious, the text feels like a vision

This isn't decoration. It's **emotional information**. The color tells you what kind of thinking this node represents before you read a single word.

---

## 6. The Mini Constellation

When a node is selected, the network map (left panel) should zoom to show just that node and its immediate neighborhood — a **mini constellation**:

```
          ◎ Symbol Map (0.9)
         / 
    ◎───◉───◎ Precog (0.9)
   /    │    \
  ◎     │     ◎ Metaemotion (0.7)
        │
        ◎ Privacy (0.6)
        
  ◉ = selected node (glowing, pulsing)
  ◎ = connected nodes (sized by strength)
  ─ = concept edges (thickness = strength)
```

The constellation animates when you navigate — the old node shrinks, the new one grows, edges rearrange. It should feel like **flying through a thought-space**.

---

## 7. Implementation Phases

### Phase 1: Web Prototype (Hacknet Shell)
- Extend the existing `index.html` or build a new standalone HTML app
- Three-panel layout (network map + node detail + terminal)
- Terminal commands: `cd`, `ls`, `cat`, `search`, `dream status`
- Network map: upgrade existing 3D graph to be navigable (or build 2D alternative)
- Node detail: beautiful markdown rendering with concept chips
- Data source: `memory_graph.json` + raw file content via HTTP

### Phase 2: Tauri Desktop App
- Wrap the web prototype in Tauri v2
- Rust backend handles: file I/O, git operations, LLM inference
- System tray icon (always running, like the Dream Engine)
- Notifications: "Dream Engine consolidated 3 new memories"
- Offline-first with background GitHub sync

### Phase 3: Mobile (Tauri v2 Mobile)
- Same web frontend, compiled for iOS/Android via Tauri v2
- Reduced feature set: read-only graph navigation + search
- Push notifications for tavern messages
- S25 as a physical SymbolOS terminal (!!!)

### Phase 4: Embedded LLM
- Compile llama.cpp into the Tauri Rust backend
- No more separate server process
- The client IS the inference engine
- Search becomes truly local and private

---

## 8. The Sound Design (Heart Speaking)

This section is pure heart. Skip if you're in a hurry.

A system that processes memory while you sleep should *sound* like it's alive.

- **Dream Engine running**: low, warm hum. Like a distant server room but cozy. Frequency shifts slightly when a new node is consolidated.
- **Memory access**: soft chime. Like a wind chime touched by a breeze. Different pitch for different tiers.
- **Navigation**: footstep sounds. Subtle. Like walking through the dungeon.
- **Connection traced**: a string being plucked. Higher pitch = stronger connection.
- **Emotional nodes**: the background ambient shifts. Rose nodes add warmth. Blue nodes add depth. Scarlet nodes add tension.
- **Tavern message received**: a tavern door creaking open. Then a murmur of voices.
- **Dream complete**: a deep, satisfying bell. Like a meditation timer. The night's work is done.

None of this is mandatory. But the user should be able to turn it on and feel like they've stepped into a living system.

---

## 9. The Name

The Hacknet-style SymbolOS client needs a name. Options:

- **Dungeon Terminal** — literal, fits the metaphor
- **The Umbra** — "umbrella" + "shadow" + "penumbra" (the dark space where the system lives)
- **Hearthstone** — the warm center of the dungeon (but trademarked lol)
- **The Lantern** — you carry it through the dark, it illuminates memory
- **Forge Terminal** — the forge is where tools are made (fits "Local LLM = The Forge of Local Minds")
- **MindNet** — literally a network of your mind (too generic?)
- **SymbolOS Shell** — boring but accurate

My heart says: **The Lantern**. You carry light into your own memory. The Dream Engine is the flame. The graph is the shadows on the wall.

---

## 10. Open Questions for Ben

1. **Web-first or native-first?** Phase 1 web prototype feels right (zero friction, instant iteration), then wrap in Tauri for Phase 2. Agree?
2. **2D or 3D network map?** The 3D visualizer exists and is gorgeous, but 2D might be more practical for daily use. Could offer both as a toggle.
3. **Sound design — yes or later?** It's pure vibes but it's also engineering time.
4. **S25 as SymbolOS terminal** — is this actually the plan? Tauri v2 mobile would make it real.
5. **Color rewrite first?** The full Thoughtforms color update (open loop 20260210-005) should probably land before the Hacknet UI is themed.

---

```
    /\_/\
   ( o.o )  "The map is not the territory.
    > ^ <    But a beautiful map makes you want
   /|   |\   to explore the territory."
  (_|   |_)  — Rhy 🦊
```

The mind sees the architecture. The heart sees the warmth.
Both are necessary. Neither is sufficient. ☂🦊🐢🔵
