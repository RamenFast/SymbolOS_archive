/** SymbolOS 1905 Thoughtforms color palette + design tokens */

export const colors = {
  primrose: '#FADA5E',
  gold: '#FFD700',
  orange: '#FF8C00',
  green: '#228B22',
  blue: '#0000CD',
  violet: '#8B00FF',
  scarlet: '#FF2400',
  rose: '#FFB7C5',
  azure: '#87CEEB',
  gamboge: '#E49B0F',
  carmine: '#960018',
  cyan: '#00e5ff',
  cyanDim: '#005f6b',
  amber: '#ffaa55',
  pink: '#ff69b4',
  magenta: '#8b008b',
  bg: '#0a0a0f',
  bgCard: '#111118',
  bgHover: '#1a1a24',
  text: '#d8d8e0',
  textDim: '#777',
  textBright: '#f0f0f0',
  border: '#252535',
  borderHover: '#3a3a50',
} as const

export const rings = [
  { id: 0, symbol: '⚓', role: 'Kernel Truth', color: colors.primrose },
  { id: 1, symbol: '🧭', role: 'Active Context', color: colors.green },
  { id: 2, symbol: '🪞', role: 'Retrieval', color: colors.gamboge },
  { id: 3, symbol: '🌀', role: 'Prediction', color: colors.orange },
  { id: 4, symbol: '🧩', role: 'Architecture', color: colors.violet },
  { id: 5, symbol: '☂️', role: 'Guardrails', color: colors.scarlet },
  { id: 6, symbol: '🧪', role: 'Verification', color: colors.blue },
  { id: 7, symbol: '🗃️', role: 'Persistence', color: colors.gold },
] as const

export type Agent = {
  name: string
  emoji: string
  cls: string
  platform: string
  hp: number
  maxHp: number
  heart: string
  mind: string
  color: string
  href: string
}

export const agents: Agent[] = [
  { name: 'Mercer', emoji: '🔵', cls: 'Wizard/Bard', platform: 'ChatGPT', hp: 42, maxHp: 42, heart: 'steady', mind: 'focused', color: colors.blue, href: 'docs/agent_character_sheets.md#-mercer--the-architect' },
  { name: 'CoreGPT', emoji: '🔘', cls: 'Sage', platform: 'ChatGPT Base', hp: 40, maxHp: 40, heart: 'open', mind: 'wide-scan', color: colors.azure, href: 'docs/agent_character_sheets.md#-coregpt--the-foundation' },
  { name: 'Executor', emoji: '🟡', cls: 'Artificer', platform: 'Codex', hp: 52, maxHp: 52, heart: 'locked-in', mind: 'flow', color: colors.primrose, href: 'docs/agent_character_sheets.md#-mercer-executor--the-builder' },
  { name: 'Local', emoji: '🟢', cls: 'Monk', platform: 'LLaMA', hp: 38, maxHp: 38, heart: 'still', mind: 'present', color: colors.green, href: 'docs/agent_character_sheets.md#-mercer-local--the-hermit' },
  { name: 'Max', emoji: '⭐', cls: 'Fighter/Rogue', platform: 'Manus', hp: 58, maxHp: 58, heart: 'fired-up', mind: 'sprint', color: colors.gold, href: 'docs/agent_character_sheets.md#-mercer-max--the-everything-agent' },
  { name: 'Opus', emoji: '🟣', cls: 'Cleric', platform: 'Claude', hp: 45, maxHp: 45, heart: 'careful', mind: 'deep', color: colors.violet, href: 'docs/agent_character_sheets.md#-mercer-opus--the-alignment-scholar' },
  { name: 'Rhy', emoji: '🦊', cls: 'Arcane Trickster', platform: 'NPC', hp: -1, maxHp: -1, heart: '???', mind: 'everywhere', color: colors.green, href: 'docs/rhynim_guide.md' },
]

export type Room = {
  title: string
  emoji: string
  desc: string
  loot?: string
  href: string
  tags: string
}

export type Floor = {
  id: string
  title: string
  emoji: string
  color: string
  defaultOpen?: boolean
  rooms: Room[]
}

export const floors: Floor[] = [
  {
    id: 'core', title: 'Core Chambers', emoji: '📚', color: colors.primrose, defaultOpen: true,
    rooms: [
      { title: 'Docs Index', emoji: '📍', desc: 'The meeting place — start here', loot: '💎 Full dungeon map', href: 'docs/index.md', tags: 'docs index meeting place' },
      { title: 'Symbol Map', emoji: '🗺', desc: 'Every emoji decoded', loot: '💎 Shared language', href: 'docs/symbol_map.md', tags: 'symbol map glyphs emoji' },
      { title: 'Symbol Map (JSON)', emoji: '🧬', desc: 'Machine-readable meeting place', href: 'symbol_map.shared.json', tags: 'symbol map json shared' },
      { title: 'Schemas', emoji: '🧩', desc: 'JSON schema index', href: 'docs/schemas.md', tags: 'schemas json validation' },
      { title: 'Thoughtforms Colors', emoji: '🎨', desc: '1905 color system', href: 'docs/thoughtforms_colors.md', tags: 'colors 1905 thoughtforms' },
      { title: "Rhy's Den", emoji: '🦊', desc: 'The fox trickster guide — esoteric wisdom', href: 'docs/rhynim_guide.md', tags: 'rhy fox guide esoteric' },
    ],
  },
  {
    id: 'heart-mind', title: 'Heart + Mind', emoji: '❤️', color: colors.rose,
    rooms: [
      { title: 'PreEmotion', emoji: '🔮❤️', desc: "Anticipatory emotional signals — the heart's prediction layer", href: 'docs/preemotion.md', tags: 'preemotion anticipatory feelings heart prediction' },
      { title: 'Metaemotion', emoji: '🪞', desc: 'Feelings about feelings', href: 'docs/metaemotion.md', tags: 'metaemotion feelings recursive' },
      { title: 'Meta-awareness', emoji: '🛡️', desc: 'Agent self-checks & metacognitive barriers', href: 'docs/meta_awareness.md', tags: 'meta awareness metacog dissociation barriers' },
      { title: 'Character Sheet Spec', emoji: '🎲', desc: 'Heart + Mind overlay for DND sheets', href: 'docs/dnd_character_sheet_integration.md', tags: 'dnd character sheet heart mind stats' },
      { title: 'Agent Party Roster', emoji: '⚔️', desc: 'Full DND stat blocks for all 7 agents', href: 'docs/agent_character_sheets.md', tags: 'agents dnd party roster stats metacog' },
    ],
  },
  {
    id: 'poetry', title: 'Poetry & Expression', emoji: '🪞', color: colors.violet,
    rooms: [
      { title: 'Poetry Translation Layer', emoji: '🌸', desc: 'Fi+Ti emoji encoding', href: 'docs/poetry_translation_layer.md', tags: 'poetry fi ti emoji translation' },
      { title: 'Public/Private Expression', emoji: '🔒', desc: 'What to share, what to hold', href: 'docs/public_private_expression.md', tags: 'public private expression poetry' },
      { title: 'Meme Map', emoji: '🐢', desc: 'Canonical vibe layer — memes are structural', href: 'docs/meme_map.md', tags: 'memes turtle skeleton vibe canon' },
    ],
  },
  {
    id: 'systems', title: 'Systems Wing', emoji: '🧠', color: colors.gamboge,
    rooms: [
      { title: 'Precog', emoji: '🔮', desc: 'Anticipatory computing — see around corners', href: 'docs/precog_thought.md', tags: 'precog anticipatory computing prefetch suggest act' },
      { title: 'Memory', emoji: '🗃️', desc: 'Consent-driven, repo-backed persistence', href: 'docs/memory.md', tags: 'memory consent retention provenance' },
      { title: 'MCP Servers', emoji: '⚙️', desc: 'Tool integrations standard', href: 'docs/mcp_servers.md', tags: 'mcp servers tools protocol risk' },
      { title: 'Agent Boundaries', emoji: '🛡', desc: 'Who does what — party roles', href: 'docs/agent_boundaries.md', tags: 'agent boundaries roles permissions' },
    ],
  },
  {
    id: 'governance', title: 'Governance', emoji: '🛡', color: colors.scarlet,
    rooms: [
      { title: 'Alignment Primitives', emoji: '⚖️', desc: 'Algebraic & structural foundations', href: 'docs/governance/alignment_primitives.md', tags: 'alignment primitives algebra category governance' },
      { title: 'Opus Onboarding', emoji: '🟣', desc: 'Bringing Opus into the loop', href: 'docs/governance/claude_opus_4_6_onboarding.md', tags: 'claude opus onboarding agent' },
      { title: 'Workflow Guidelines', emoji: '🔨', desc: 'Commits, branches, PRs', href: 'docs/workflow_guidelines.md', tags: 'workflow guidelines commits branches labels' },
      { title: 'Lightwork Guidelines', emoji: '💡', desc: 'Focus modes & work patterns', href: 'docs/lightwork_guidelines.md', tags: 'lightwork deepwork focus guidelines' },
    ],
  },
  {
    id: 'ops', title: 'Operations', emoji: '⚙️', color: colors.green,
    rooms: [
      { title: 'Quickstart', emoji: '⚡', desc: 'Get running fast', href: 'docs/QUICKSTART.md', tags: 'quickstart start begin' },
      { title: 'Required Reading', emoji: '📖', desc: 'The essential scrolls', href: 'docs/required_reading.md', tags: 'required reading canon scrolls' },
      { title: 'Sync Playbook', emoji: '🔃', desc: 'Keeping it all aligned', href: 'docs/sync_playbook.md', tags: 'sync playbook alignment docs' },
      { title: 'Mercer-Codex Runbook', emoji: '📜', desc: 'Day-to-day operator manual', href: 'docs/mercer_codex.md', tags: 'mercer codex runbook ops' },
      { title: 'Agent Prompts', emoji: '📑', desc: 'All 7 agent configurations', href: 'prompts/README.md', tags: 'prompts agents configs' },
    ],
  },
  {
    id: 'mcp', title: 'MCP Connectors', emoji: '🔌', color: colors.azure,
    rooms: [
      { title: 'Filesystem', emoji: '📁', desc: 'File read/write/search', href: 'docs/mcp_filesystem.md', tags: 'mcp filesystem files' },
      { title: 'Git', emoji: '📤', desc: 'Version control operations', href: 'docs/mcp_git.md', tags: 'mcp git version control' },
      { title: 'Memory MCP', emoji: '🧠', desc: 'Knowledge graph persistence', href: 'docs/mcp_memory.md', tags: 'mcp memory knowledge graph' },
      { title: 'Local LLM', emoji: '🤖', desc: 'Local model inference', href: 'docs/mcp_local_llm.md', tags: 'mcp local llm ai inference' },
      { title: 'Web Search', emoji: '🔍', desc: 'Search the web', href: 'docs/mcp_web_search.md', tags: 'mcp web search brave' },
    ],
  },
  {
    id: 'memory', title: 'Memory Vaults', emoji: '🗃️', color: colors.gold,
    rooms: [
      { title: 'Memory System', emoji: '🗃', desc: 'The durable layer', href: 'memory/README.md', tags: 'memory system durable repo backed' },
      { title: 'Working Set', emoji: '🎯', desc: 'Active context', href: 'memory/working_set.md', tags: 'working set active focus' },
      { title: 'Open Loops', emoji: '⚔', desc: 'Quests in progress', href: 'memory/open_loops.md', tags: 'open loops quests promises' },
      { title: 'Decisions', emoji: '📜', desc: 'Choices carved in stone', href: 'memory/decisions.md', tags: 'decisions log choices' },
      { title: 'Glossary', emoji: '📖', desc: 'Terms of art', href: 'memory/glossary.md', tags: 'glossary terms definitions' },
    ],
  },
  {
    id: 'tools', title: 'Cross-Platform Tools', emoji: '🔧', color: colors.azure,
    rooms: [
      { title: 'Alignment Report (Python)', emoji: '🐍', desc: 'Cross-platform repo health scanner', href: 'scripts/symbolos_alignment_report.py', tags: 'python alignment report scanner cli' },
      { title: 'Ring Validator (TypeScript)', emoji: '🔘', desc: 'Ring model integrity checker', href: 'scripts/symbolos_ring_validator.ts', tags: 'typescript ring validator node deno' },
      { title: 'Resonance Engine (Rust)', emoji: '🦀', desc: 'Symbol harmonic resonance via ring distance', href: 'scripts/symbolos_resonance.rs', tags: 'rust resonance harmonic color wavelength' },
      { title: 'Ring Algebra Proof (Haskell)', emoji: 'λ', desc: 'Z/8Z algebraic verification', href: 'scripts/symbolos_ring_algebra.hs', tags: 'haskell algebra proof ring z8z' },
    ],
  },
]

export const wisdoms = [
  'The mind knows what the heart loves better than it does.',
  'Under the umbrella, everything is kind.',
  'Always return to the meeting place.',
  'Show me proof, not potential. — 💀',
  "If it ain't fun, it ain't sustainable.",
  'Vibes are load-bearing.',
  'Memes are semantic, not decorative.',
  'The turtle abides. 🐢',
  'Shine dat light: trace decisions back to root values.',
  'Coherence over speed.',
  'The map is steady. The hands are open.',
  'Warmth without truth is a leak; truth without warmth is a blade.',
  'A loop left open is a promise unkept.',
  'Even offline, vibes are load-bearing.',
  'this is fine. — 🐢',
  'Privacy by default. Proof over promise.',
  'Fi+Ti mirrored, forever.',
  'The skeleton never lies.',
  'We ball, but we verify.',
  'The absence that teaches presence is the only teacher worth forgetting.',
]
