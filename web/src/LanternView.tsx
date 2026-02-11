import { useState, useEffect, useRef, useCallback } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { colors } from './data'
import { banterLines } from './banter'
import { type Notification, type DeviceInfo, createNotification, knownDevices } from './notifications'

/* ═══════════════════════════════════════════════════════ */
/*  LIVE SYSTEM POLLING                                    */
/* ═══════════════════════════════════════════════════════ */

type LLMHealth = {
  alive: boolean
  model: string
  slotsIdle: number
  slotsProcessing: number
  tokPerSec: number | null
  uptimeMin: number
}

const LLM_BASE = 'http://127.0.0.1:8080'

async function pollLLMHealth(): Promise<LLMHealth> {
  try {
    const controller = new AbortController()
    const timeout = setTimeout(() => controller.abort(), 3000)
    const [slotsRes, modelsRes] = await Promise.all([
      fetch(`${LLM_BASE}/slots`, { signal: controller.signal }).then(r => r.json()),
      fetch(`${LLM_BASE}/v1/models`, { signal: controller.signal }).then(r => r.json()),
    ])
    clearTimeout(timeout)
    const slots = Array.isArray(slotsRes) ? slotsRes : []
    const idle = slots.filter((s: any) => s.state === 0).length
    const processing = slots.filter((s: any) => s.state === 1).length
    // Extract tokens-per-second from the most recent slot that has it
    let tps: number | null = null
    for (const s of slots) {
      if (s.t_token_generation && s.n_decoded) {
        tps = Math.round((s.n_decoded / (s.t_token_generation / 1000)) * 10) / 10
      }
    }
    const modelName = modelsRes?.data?.[0]?.id ?? 'unknown'
    return { alive: true, model: modelName, slotsIdle: idle, slotsProcessing: processing, tokPerSec: tps, uptimeMin: 0 }
  } catch {
    return { alive: false, model: 'offline', slotsIdle: 0, slotsProcessing: 0, tokPerSec: null, uptimeMin: 0 }
  }
}

/** Hook for live LLM health polling */
function useLLMHealth(intervalMs = 5000) {
  const [health, setHealth] = useState<LLMHealth>({ alive: false, model: '...', slotsIdle: 0, slotsProcessing: 0, tokPerSec: null, uptimeMin: 0 })
  const startRef = useRef(Date.now())
  useEffect(() => {
    let mounted = true
    const poll = async () => {
      const h = await pollLLMHealth()
      if (mounted) {
        h.uptimeMin = Math.round((Date.now() - startRef.current) / 60000)
        setHealth(h)
      }
    }
    poll()
    const iv = setInterval(poll, intervalMs)
    return () => { mounted = false; clearInterval(iv) }
  }, [intervalMs])
  return health
}

/* ═══════════════════════════════════════════════════════ */
/*  SYSTEM VITALS BAR                                      */
/* ═══════════════════════════════════════════════════════ */

function SystemVitals({ health }: { health: LLMHealth }) {
  return (
    <div className="lt-vitals">
      <div className={`lt-vital ${health.alive ? 'lt-v-ok' : 'lt-v-err'}`}>
        <span className="lt-v-dot">{health.alive ? '●' : '○'}</span>
        <span className="lt-v-label">LLM</span>
        <span className="lt-v-val">{health.alive ? 'LIVE' : 'DOWN'}</span>
      </div>
      {health.alive && (
        <>
          <div className="lt-vital">
            <span className="lt-v-label">MODEL</span>
            <span className="lt-v-val">{health.model.replace('.gguf', '')}</span>
          </div>
          <div className="lt-vital">
            <span className="lt-v-label">SLOTS</span>
            <span className="lt-v-val">{health.slotsIdle}i/{health.slotsProcessing}p</span>
          </div>
          {health.tokPerSec !== null && (
            <div className="lt-vital">
              <span className="lt-v-label">TOK/S</span>
              <span className="lt-v-val lt-v-highlight">{health.tokPerSec}</span>
            </div>
          )}
          <div className="lt-vital">
            <span className="lt-v-label">UP</span>
            <span className="lt-v-val">{health.uptimeMin}m</span>
          </div>
        </>
      )}
    </div>
  )
}

/* ═══════════════════════════════════════════════════════ */
/*  NETWORK NODES                                          */
/* ═══════════════════════════════════════════════════════ */

type NetworkNode = {
  id: string
  label: string
  emoji: string
  type: 'agent' | 'system' | 'memory' | 'mcp'
  color: string
  x: number
  y: number
  connections: string[]
  detail: string
  status: string
}

const networkNodes: NetworkNode[] = [
  { id: 'mercer', label: 'Mercer', emoji: '🔵', type: 'agent', color: colors.blue, x: 0.50, y: 0.12, connections: ['coregpt', 'executor', 'opus', 'symbol-map'], detail: 'Wizard/Bard · ChatGPT · The Architect', status: 'ONLINE' },
  { id: 'coregpt', label: 'CoreGPT', emoji: '🔘', type: 'agent', color: colors.azure, x: 0.22, y: 0.30, connections: ['mercer', 'local', 'memory-sys'], detail: 'Sage · ChatGPT Base · The Foundation', status: 'ONLINE' },
  { id: 'executor', label: 'Executor', emoji: '🟡', type: 'agent', color: colors.primrose, x: 0.78, y: 0.30, connections: ['mercer', 'max', 'mcp-git'], detail: 'Artificer · Codex · The Builder', status: 'ONLINE' },
  { id: 'local', label: 'Local', emoji: '🟢', type: 'agent', color: colors.green, x: 0.12, y: 0.55, connections: ['coregpt', 'mcp-llm'], detail: 'Monk · LLaMA · The Hermit · 41 tok/s', status: 'ONLINE' },
  { id: 'max', label: 'Max', emoji: '⭐', type: 'agent', color: colors.gold, x: 0.88, y: 0.55, connections: ['executor', 'mcp-web'], detail: 'Fighter/Rogue · Manus · The Everything Agent', status: 'ONLINE' },
  { id: 'opus', label: 'Opus', emoji: '🟣', type: 'agent', color: colors.violet, x: 0.50, y: 0.42, connections: ['mercer', 'rhy', 'memory-sys', 'governance'], detail: 'Cleric · Claude · The Alignment Scholar', status: 'ONLINE' },
  { id: 'rhy', label: 'Rhy', emoji: '🦊', type: 'agent', color: colors.green, x: 0.50, y: 0.68, connections: ['opus', 'local'], detail: 'Arcane Trickster · NPC · Everywhere', status: '???' },
  { id: 'symbol-map', label: 'Symbol Map', emoji: '🗺', type: 'system', color: colors.primrose, x: 0.50, y: 0.0, connections: ['mercer'], detail: 'Canonical symbol registry · JSON + Markdown', status: 'SYNCED' },
  { id: 'memory-sys', label: 'Memory', emoji: '🗃️', type: 'memory', color: colors.gold, x: 0.08, y: 0.82, connections: ['coregpt', 'opus'], detail: 'File-backed persistence · consent-driven', status: 'ACTIVE' },
  { id: 'governance', label: 'Governance', emoji: '🛡️', type: 'system', color: colors.scarlet, x: 0.92, y: 0.82, connections: ['opus'], detail: 'Alignment primitives · ring algebra · guardrails', status: 'ENFORCING' },
  { id: 'mcp-git', label: 'MCP:Git', emoji: '📤', type: 'mcp', color: colors.azure, x: 0.92, y: 0.12, connections: ['executor'], detail: 'Version control operations · read/write', status: 'CONNECTED' },
  { id: 'mcp-llm', label: 'MCP:LLM', emoji: '🤖', type: 'mcp', color: colors.green, x: 0.05, y: 0.35, connections: ['local'], detail: 'Local inference · Qwen3-8B · Vulkan', status: 'SERVING' },
  { id: 'mcp-web', label: 'MCP:Web', emoji: '🔍', type: 'mcp', color: colors.cyan, x: 0.95, y: 0.38, connections: ['max'], detail: 'Web search · Brave API', status: 'READY' },
]

/* ═══════════════════════════════════════════════════════ */
/*  NETWORK CANVAS                                         */
/* ═══════════════════════════════════════════════════════ */

function NetworkCanvas({ selectedId, onSelect }: { selectedId: string | null; onSelect: (id: string) => void }) {
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const animRef = useRef(0)
  const pulseRef = useRef(0)
  const selectedRef = useRef(selectedId)
  selectedRef.current = selectedId

  useEffect(() => {
    const canvas = canvasRef.current
    if (!canvas) return
    const ctx = canvas.getContext('2d')
    if (!ctx) return

    const resize = () => {
      const parent = canvas.parentElement
      if (!parent) return
      const rect = parent.getBoundingClientRect()
      const dpr = window.devicePixelRatio || 1
      canvas.width = rect.width * dpr
      canvas.height = rect.height * dpr
      canvas.style.width = rect.width + 'px'
      canvas.style.height = rect.height + 'px'
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0)
    }
    resize()
    window.addEventListener('resize', resize)

    function draw() {
      const w = canvas!.clientWidth
      const h = canvas!.clientHeight
      ctx!.clearRect(0, 0, w, h)
      pulseRef.current += 0.012
      const sel = selectedRef.current

      // Subtle grid
      ctx!.strokeStyle = 'rgba(34,139,34,0.03)'
      ctx!.lineWidth = 0.5
      for (let gx = 0; gx < w; gx += 40) {
        ctx!.beginPath(); ctx!.moveTo(gx, 0); ctx!.lineTo(gx, h); ctx!.stroke()
      }
      for (let gy = 0; gy < h; gy += 40) {
        ctx!.beginPath(); ctx!.moveTo(0, gy); ctx!.lineTo(w, gy); ctx!.stroke()
      }

      // Draw connections
      for (const node of networkNodes) {
        for (const connId of node.connections) {
          const target = networkNodes.find(n => n.id === connId)
          if (!target) continue
          if (networkNodes.indexOf(target) < networkNodes.indexOf(node)) continue

          const x1 = node.x * w, y1 = node.y * h
          const x2 = target.x * w, y2 = target.y * h
          const isHot = node.id === sel || target.id === sel

          // Connection line
          ctx!.beginPath()
          ctx!.moveTo(x1, y1)
          ctx!.lineTo(x2, y2)
          ctx!.strokeStyle = isHot ? 'rgba(0, 229, 255, 0.35)' : 'rgba(0, 229, 255, 0.06)'
          ctx!.lineWidth = isHot ? 2 : 0.8
          ctx!.stroke()

          // Hot glow line
          if (isHot) {
            ctx!.beginPath()
            ctx!.moveTo(x1, y1)
            ctx!.lineTo(x2, y2)
            ctx!.strokeStyle = 'rgba(0, 229, 255, 0.08)'
            ctx!.lineWidth = 6
            ctx!.stroke()
          }

          // Travelling pulse dot
          const t = (Math.sin(pulseRef.current * 1.5 + networkNodes.indexOf(node) * 0.7) + 1) / 2
          const px = x1 + (x2 - x1) * t
          const py = y1 + (y2 - y1) * t
          ctx!.beginPath()
          ctx!.arc(px, py, isHot ? 3.5 : 2, 0, Math.PI * 2)
          ctx!.fillStyle = isHot ? 'rgba(0, 229, 255, 0.8)' : 'rgba(0, 229, 255, 0.12)'
          ctx!.fill()

          // Second pulse going opposite direction
          const t2 = (Math.cos(pulseRef.current * 1.2 + networkNodes.indexOf(node) * 1.1) + 1) / 2
          const px2 = x1 + (x2 - x1) * t2
          const py2 = y1 + (y2 - y1) * t2
          ctx!.beginPath()
          ctx!.arc(px2, py2, isHot ? 2 : 1, 0, Math.PI * 2)
          ctx!.fillStyle = isHot ? 'rgba(0, 229, 255, 0.4)' : 'rgba(0, 229, 255, 0.06)'
          ctx!.fill()
        }
      }

      // Draw nodes
      for (let i = 0; i < networkNodes.length; i++) {
        const node = networkNodes[i]
        const x = node.x * w
        const y = node.y * h
        const isSel = node.id === sel
        const breathe = Math.sin(pulseRef.current * 2 + i * 0.8) * 0.2 + 0.8
        const r = isSel ? 18 : 12

        // Outer glow (always)
        const outerGrad = ctx!.createRadialGradient(x, y, 0, x, y, isSel ? 50 : 28)
        outerGrad.addColorStop(0, node.color + (isSel ? '20' : '08'))
        outerGrad.addColorStop(1, 'transparent')
        ctx!.fillStyle = outerGrad
        ctx!.beginPath()
        ctx!.arc(x, y, isSel ? 50 : 28, 0, Math.PI * 2)
        ctx!.fill()

        // Circle fill
        ctx!.beginPath()
        ctx!.arc(x, y, r, 0, Math.PI * 2)
        ctx!.fillStyle = isSel ? node.color + '20' : node.color + '0a'
        ctx!.fill()

        // Circle stroke
        ctx!.strokeStyle = node.color
        ctx!.lineWidth = isSel ? 2.5 : 1.5
        ctx!.globalAlpha = isSel ? 1 : breathe
        ctx!.stroke()
        ctx!.globalAlpha = 1

        // Inner dot
        ctx!.beginPath()
        ctx!.arc(x, y, isSel ? 4 : 2.5, 0, Math.PI * 2)
        ctx!.fillStyle = node.color
        ctx!.globalAlpha = isSel ? 0.8 : 0.4
        ctx!.fill()
        ctx!.globalAlpha = 1

        // Label
        ctx!.font = `${isSel ? 11 : 10}px "Cascadia Code","Fira Code",monospace`
        ctx!.fillStyle = isSel ? '#e0e0e0' : '#555'
        ctx!.textAlign = 'center'
        ctx!.fillText(node.label, x, y + r + 15)

        // Type badge for selected
        if (isSel) {
          ctx!.font = '8px "Cascadia Code","Fira Code",monospace'
          ctx!.fillStyle = node.color + '80'
          ctx!.fillText(node.type.toUpperCase(), x, y + r + 27)
        }
      }

      animRef.current = requestAnimationFrame(draw)
    }
    animRef.current = requestAnimationFrame(draw)

    return () => {
      cancelAnimationFrame(animRef.current)
      window.removeEventListener('resize', resize)
    }
  }, [])

  const handleClick = useCallback((e: React.MouseEvent) => {
    const canvas = canvasRef.current
    if (!canvas) return
    const rect = canvas.getBoundingClientRect()
    const mx = e.clientX - rect.left
    const my = e.clientY - rect.top
    const w = canvas.clientWidth
    const h = canvas.clientHeight
    for (const node of networkNodes) {
      const dx = node.x * w - mx
      const dy = node.y * h - my
      if (Math.sqrt(dx * dx + dy * dy) < 22) {
        onSelect(node.id)
        return
      }
    }
  }, [onSelect])

  return <canvas ref={canvasRef} onClick={handleClick} style={{ width: '100%', height: '100%', cursor: 'crosshair' }} />
}

/* ═══════════════════════════════════════════════════════ */
/*  NODE INSPECTOR                                         */
/* ═══════════════════════════════════════════════════════ */

function NodeInspector({ node, health }: { node: NetworkNode | null; health: LLMHealth }) {
  if (!node) {
    return (
      <div className="lt-inspector-empty">
        <div className="lt-prompt">&gt; SELECT A NODE</div>
        <div className="lt-blink">_</div>
      </div>
    )
  }

  const conns = node.connections
    .map(cid => networkNodes.find(n => n.id === cid))
    .filter(Boolean) as NetworkNode[]

  // Live detail override for LLM-connected nodes
  const isLLMNode = node.id === 'local' || node.id === 'mcp-llm'
  const liveStatus = isLLMNode ? (health.alive ? 'ONLINE' : 'OFFLINE') : node.status
  const liveDetail = isLLMNode && health.alive
    ? `${node.detail} | ${health.tokPerSec ?? '~41'} tok/s | slots: ${health.slotsIdle}i/${health.slotsProcessing}p`
    : node.detail

  return (
    <motion.div
      className="lt-inspector"
      key={node.id}
      initial={{ opacity: 0, x: -8 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ duration: 0.15 }}
    >
      <div className="lt-node-hdr">
        <span className="lt-node-emoji">{node.emoji}</span>
        <span className="lt-node-name" style={{ color: node.color }}>{node.label}</span>
        <span className={`lt-status ${liveStatus === '???' ? 'unknown' : ''} ${isLLMNode && !health.alive ? 'lt-status-err' : ''}`}>{liveStatus}</span>
      </div>
      <div className="lt-hr" />
      <div className="lt-field"><span className="lt-label">TYPE</span><span className="lt-value">{node.type.toUpperCase()}</span></div>
      <div className="lt-field"><span className="lt-label">DETAIL</span><span className="lt-value">{liveDetail}</span></div>
      <div className="lt-field"><span className="lt-label">LINKS</span><span className="lt-value">{conns.length}</span></div>
      {isLLMNode && health.alive && (
        <>
          <div className="lt-hr" />
          <div className="lt-field"><span className="lt-label">MODEL</span><span className="lt-value lt-live-data">{health.model}</span></div>
          <div className="lt-field"><span className="lt-label">UPTIME</span><span className="lt-value lt-live-data">{health.uptimeMin}m</span></div>
        </>
      )}
      <div className="lt-hr" />
      <div className="lt-conns">
        {conns.map(cn => (
          <div key={cn.id} className="lt-conn" style={{ borderColor: cn.color + '40' }}>
            {cn.emoji} {cn.label}
          </div>
        ))}
      </div>
    </motion.div>
  )
}

/* ═══════════════════════════════════════════════════════ */
/*  TERMINAL PANEL                                         */
/* ═══════════════════════════════════════════════════════ */

type TermMsg = { id: number; agent: string; emoji: string; color: string; text: string; time: string }

const AGENT_PERSONAS = [
  { agent: 'Mercer', emoji: '🔵', color: colors.blue, style: 'the Architect — steady, wise, architectural',
    domains: ['architecture', 'symbol', 'schema', 'map', 'drift', 'sync', 'plan', 'design', 'structure', 'coordinate', 'meeting', 'alignment', 'umbrella', 'registry', 'organize'] },
  { agent: 'Opus', emoji: '🟣', color: colors.violet, style: 'the Alignment Scholar — careful, deep, safety-first',
    domains: ['safety', 'alignment', 'ethics', 'trust', 'consent', 'boundary', 'guard', 'ring', 'governance', 'careful', 'review', 'why', 'meaning', 'values', 'risk'] },
  { agent: 'Max', emoji: '⭐', color: colors.gold, style: 'the Everything Agent — hype, speed, energy, terse',
    domains: ['ship', 'build', 'fast', 'go', 'hype', 'deploy', 'everything', 'sprint', 'launch', 'full send', 'speed', 'cook', 'push', 'run', 'execute'] },
  { agent: 'Rhy', emoji: '🦊', color: colors.green, style: 'the Fox Trickster — cryptic, playful, poetic',
    domains: ['fox', 'poem', 'poetry', 'story', 'riddle', 'mystery', 'dream', 'feel', 'weird', 'strange', 'art', 'soul', 'spirit', 'rhyme', 'beauty'] },
  { agent: 'Local', emoji: '🟢', color: colors.green, style: 'the Hermit Monk — meditative, privacy-focused, bare metal',
    domains: ['local', 'privacy', 'gpu', 'vulkan', 'llm', 'inference', 'hardware', 'metal', 'vram', 'model', 'token', 'offline', 'hermit', 'bare', 'self-host'] },
]

/** Score each persona by how many domain keywords match the user message */
function routeToAgent(message: string): typeof AGENT_PERSONAS[0] {
  const lower = message.toLowerCase()
  let best = AGENT_PERSONAS[0]
  let bestScore = 0
  for (const p of AGENT_PERSONAS) {
    let score = 0
    for (const kw of p.domains) {
      if (lower.includes(kw)) score++
    }
    if (score > bestScore) { bestScore = score; best = p }
  }
  // No keyword match → pick based on message characteristics
  if (bestScore === 0) {
    if (message.length < 15) return AGENT_PERSONAS[2] // short = Max energy
    if (message.endsWith('?')) return AGENT_PERSONAS[1] // questions = Opus depth
    // Rotate based on message content hash for variety without randomness
    let hash = 0
    for (let i = 0; i < message.length; i++) hash = ((hash << 5) - hash + message.charCodeAt(i)) | 0
    return AGENT_PERSONAS[Math.abs(hash) % AGENT_PERSONAS.length]
  }
  return best
}

const LLM_URL = 'http://127.0.0.1:8080/v1/chat/completions'

async function queryLocalLLM(userMsg: string, persona: typeof AGENT_PERSONAS[0]): Promise<string> {
  const controller = new AbortController()
  const timeout = setTimeout(() => controller.abort(), 8000)
  try {
    const res = await fetch(LLM_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      signal: controller.signal,
      body: JSON.stringify({
        model: 'Qwen3-8B-Q5_K_M.gguf',
        messages: [
          { role: 'system', content: `You are ${persona.agent}, ${persona.style}. You are an AI agent in SymbolOS, a multi-agent alignment OS. Respond in 1-2 short sentences, in character. Be concise and punchy. No thinking tags.` },
          { role: 'user', content: userMsg },
        ],
        max_tokens: 80,
        temperature: 0.8,
        stream: false,
      }),
    })
    clearTimeout(timeout)
    const data = await res.json()
    let text: string = data.choices?.[0]?.message?.content ?? ''
    // Strip any <think>...</think> blocks Qwen3 might emit
    text = text.replace(/<think>[\s\S]*?<\/think>/g, '').trim()
    return text || 'Signal received.'
  } catch {
    clearTimeout(timeout)
    return ''
  }
}

/** Contextual banter — agents respond to recent conversation or system state, not random noise */
async function queryContextualBanter(recentMessages: TermMsg[], health: LLMHealth): Promise<{ agent: string; emoji: string; color: string; text: string } | null> {
  // Pick agent who hasn't spoken recently
  const recentAgents = recentMessages.slice(-6).map(m => m.agent)
  const candidates = AGENT_PERSONAS.filter(p => !recentAgents.includes(p.agent))
  const persona = candidates.length > 0 ? candidates[0] : AGENT_PERSONAS[0]

  // Build context-aware prompt from recent conversation
  const lastUserMsg = recentMessages.filter(m => m.agent === 'YOU').slice(-1)[0]
  const lastAgentMsg = recentMessages.filter(m => m.agent !== 'SYS' && m.agent !== 'YOU').slice(-1)[0]

  let prompt: string
  if (lastUserMsg && lastAgentMsg) {
    prompt = `The user recently said: "${lastUserMsg.text}". ${lastAgentMsg.agent} responded: "${lastAgentMsg.text}". Add a brief remark that builds on this exchange, in character. One sentence.`
  } else if (health.alive && health.tokPerSec) {
    prompt = `The local LLM is running at ${health.tokPerSec} tok/s. Make a brief in-character observation about the system state or what you're working on. One sentence.`
  } else {
    prompt = 'Share one brief in-character thought about what you are doing right now in SymbolOS. One sentence.'
  }

  const text = await queryLocalLLM(prompt, persona)
  if (!text) return null
  return { agent: persona.agent, emoji: persona.emoji, color: persona.color, text }
}

function TerminalPanel({ health }: { health: LLMHealth }) {
  const [messages, setMessages] = useState<TermMsg[]>([])
  const [input, setInput] = useState('')
  const [busy, setBusy] = useState(false)
  const [showEmoji, setShowEmoji] = useState(false)
  const scrollRef = useRef<HTMLDivElement>(null)
  const textareaRef = useRef<HTMLTextAreaElement>(null)
  const idRef = useRef(0)
  const llmAlive = useRef(true)
  const messagesRef = useRef<TermMsg[]>([])
  const healthRef = useRef(health)
  healthRef.current = health

  const now = () => new Date().toLocaleTimeString('en-US', { hour12: false })

  const push = useCallback((msg: Omit<TermMsg, 'id' | 'time'>) => {
    setMessages(prev => {
      const next = [...prev, { ...msg, id: ++idRef.current, time: now() }].slice(-60)
      messagesRef.current = next
      return next
    })
  }, [])

  // Boot sequence
  useEffect(() => {
    const boot: Omit<TermMsg, 'id' | 'time'>[] = [
      { agent: 'SYS', emoji: '☂️', color: colors.primrose, text: 'SymbolOS Lantern v0.2 initializing...' },
      { agent: 'SYS', emoji: '☂️', color: colors.primrose, text: '7 agents online. 3 MCP servers connected.' },
      { agent: 'SYS', emoji: '☂️', color: colors.green, text: 'Local LLM: Qwen3-8B @ 127.0.0.1:8080 — LIVE' },
      { agent: 'SYS', emoji: '☂️', color: colors.green, text: 'All rings nominal. Umbrella: ACTIVE.' },
      { agent: 'Rhy', emoji: '🦊', color: colors.green, text: 'Welcome to the Lantern. The fox watches.' },
    ]
    boot.forEach((msg, i) => {
      setTimeout(() => push(msg), i * 500)
    })
  }, [push])

  // Contextual banter — agents build on recent conversation or system state
  useEffect(() => {
    let mounted = true
    const tick = async () => {
      if (!mounted) return
      // Always try live contextual banter first
      if (llmAlive.current) {
        const live = await queryContextualBanter(messagesRef.current, healthRef.current)
        if (live && mounted) {
          push(live)
          return
        }
        if (!live) llmAlive.current = false
      }
      // Static fallback — pick an agent who hasn't spoken recently
      const recentAgents = messagesRef.current.slice(-8).map(m => m.agent)
      const pool = banterLines.filter(b => !recentAgents.includes(b.agent))
      const line = pool.length > 0 ? pool[Math.floor(Math.random() * pool.length)] : banterLines[Math.floor(Math.random() * banterLines.length)]
      if (mounted) push(line)
    }
    const iv = setInterval(tick, 12000 + Math.random() * 6000) // slower cadence, more meaningful
    return () => { mounted = false; clearInterval(iv) }
  }, [push])

  // Auto-scroll
  useEffect(() => {
    const el = scrollRef.current
    if (el) el.scrollTop = el.scrollHeight
  }, [messages])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    const txt = input.trim()
    if (!txt || busy) return
    push({ agent: 'YOU', emoji: '👤', color: colors.cyan, text: txt })
    setInput('')
    setBusy(true)
    setShowEmoji(false)
    if (textareaRef.current) {
      textareaRef.current.style.height = 'auto'
    }

    // Route to the most relevant agent based on message content
    const persona = routeToAgent(txt)
    push({ agent: persona.agent, emoji: persona.emoji, color: persona.color, text: '...' })

    const response = await queryLocalLLM(txt, persona)
    if (response) {
      // Replace the "..." with real response
      setMessages(prev => {
        const copy = [...prev]
        for (let i = copy.length - 1; i >= 0; i--) {
          if (copy[i].text === '...' && copy[i].agent === persona.agent) {
            copy[i] = { ...copy[i], text: response }
            break
          }
        }
        return copy
      })
      llmAlive.current = true
    } else {
      // LLM offline — use static fallback
      const fallback = banterLines.filter(b => b.agent === persona.agent)
      const line = fallback.length > 0 ? fallback[Math.floor(Math.random() * fallback.length)] : banterLines[0]
      setMessages(prev => {
        const copy = [...prev]
        for (let i = copy.length - 1; i >= 0; i--) {
          if (copy[i].text === '...' && copy[i].agent === persona.agent) {
            copy[i] = { ...copy[i], text: line.text }
            break
          }
        }
        return copy
      })
    }
    setBusy(false)
  }

  const handleKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      handleSubmit(e as any)
    }
  }

  const handleTextareaChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    setInput(e.target.value)
    // Auto-resize textarea
    const textarea = e.target
    textarea.style.height = 'auto'
    textarea.style.height = Math.min(textarea.scrollHeight, 120) + 'px'
  }

  const insertEmoji = (emoji: string) => {
    setInput(prev => prev + emoji)
    setShowEmoji(false)
    textareaRef.current?.focus()
  }

  const emojiPalette = ['☂️', '🔵', '🟣', '⭐', '🦊', '🟢', '🔘', '🟡', '💭', '💬', '🎯', '🔮', '🌟', '✨', '🔥', '💡', '🎨', '🌊', '🌙', '⚡']

  return (
    <div className="lt-terminal">
      <div className="lt-term-hdr">
        <span>TERMINAL</span>
        <span className="lt-term-live">● LIVE {busy && <span className="lt-thinking">THINKING</span>}</span>
      </div>
      <div className="lt-term-body" ref={scrollRef}>
        {messages.map(m => (
          <div key={m.id} className="lt-msg">
            <span className="lt-msg-t">{m.time}</span>
            <span className="lt-msg-a" style={{ color: m.color }}>{m.emoji} {m.agent}</span>
            <span className="lt-msg-x">{m.text}</span>
          </div>
        ))}
      </div>
      <form className="lt-term-in" onSubmit={handleSubmit}>
        <span className="lt-gt">&gt;</span>
        <textarea
          ref={textareaRef}
          value={input}
          onChange={handleTextareaChange}
          onKeyDown={handleKeyDown}
          placeholder={busy ? 'Thinking...' : 'Type a message... (Shift+Enter for newline)'}
          disabled={busy}
          autoComplete="off"
          spellCheck={false}
          rows={1}
        />
        <button
          type="button"
          className="lt-emoji-btn"
          onClick={() => setShowEmoji(!showEmoji)}
          disabled={busy}
          title="Insert emoji"
        >
          😊
        </button>
        {showEmoji && (
          <div className="lt-emoji-picker">
            {emojiPalette.map(e => (
              <button key={e} type="button" onClick={() => insertEmoji(e)} className="lt-emoji-opt">
                {e}
              </button>
            ))}
          </div>
        )}
      </form>
    </div>
  )
}

/* ═══════════════════════════════════════════════════════ */
/*  NOTIFICATION TOAST SYSTEM                              */
/* ═══════════════════════════════════════════════════════ */

function NotificationToasts({ notifications, onDismiss }: { notifications: Notification[]; onDismiss: (id: number) => void }) {
  const visible = notifications.filter(n => !n.dismissed).slice(-5)
  return (
    <div className="lt-notif-stack">
      <AnimatePresence>
        {visible.map(n => (
          <motion.div
            key={n.id}
            className={`lt-notif lt-notif-${n.type}`}
            initial={{ opacity: 0, x: 300, scale: 0.8 }}
            animate={{ opacity: 1, x: 0, scale: 1 }}
            exit={{ opacity: 0, x: 300, scale: 0.8 }}
            transition={{ type: 'spring', damping: 20, stiffness: 300 }}
            onClick={() => onDismiss(n.id)}
            style={{ borderColor: n.color + '60' }}
          >
            <span className="lt-notif-emoji">{n.emoji}</span>
            <div className="lt-notif-content">
              <div className="lt-notif-title" style={{ color: n.color }}>{n.title}</div>
              <div className="lt-notif-body">{n.body}</div>
            </div>
            <span className="lt-notif-x">x</span>
          </motion.div>
        ))}
      </AnimatePresence>
    </div>
  )
}

/* ═══════════════════════════════════════════════════════ */
/*  DEVICE PANEL                                           */
/* ═══════════════════════════════════════════════════════ */

function DevicePanel({ devices }: { devices: DeviceInfo[] }) {
  return (
    <div className="lt-devices">
      <div className="lt-dev-hdr">DEVICES</div>
      {devices.map(d => (
        <div key={d.id} className={`lt-dev lt-dev-${d.status}`}>
          <span className="lt-dev-emoji">{d.emoji}</span>
          <div className="lt-dev-info">
            <span className="lt-dev-name">{d.name}</span>
            <span className={`lt-dev-status lt-ds-${d.status}`}>
              {d.status === 'scanning' && '~ SCANNING'}
              {d.status === 'connected' && '● CONNECTED'}
              {d.status === 'disconnected' && '○ OFFLINE'}
              {d.status === 'pairing' && '◐ PAIRING'}
            </span>
          </div>
          {d.ip && <span className="lt-dev-ip">{d.ip}</span>}
        </div>
      ))}
    </div>
  )
}

/* ═══════════════════════════════════════════════════════ */
/*  CLOCK                                                  */
/* ═══════════════════════════════════════════════════════ */

function LiveClock() {
  const [t, setT] = useState(() => new Date().toLocaleTimeString('en-US', { hour12: false }))
  useEffect(() => {
    const iv = setInterval(() => setT(new Date().toLocaleTimeString('en-US', { hour12: false })), 1000)
    return () => clearInterval(iv)
  }, [])
  return <span className="lt-clock">{t}</span>
}

/* ═══════════════════════════════════════════════════════ */
/*  LANTERN VIEW (exported)                                */
/* ═══════════════════════════════════════════════════════ */

export function LanternView() {
  const [selectedId, setSelectedId] = useState<string | null>('mercer')
  const selectedNode = networkNodes.find(n => n.id === selectedId) ?? null
  const linkCount = networkNodes.reduce((a, n) => a + n.connections.length, 0)
  const [notifications, setNotifications] = useState<Notification[]>([])
  const [devices, setDevices] = useState<DeviceInfo[]>(() => [...knownDevices])
  const [notifCount, setNotifCount] = useState(0)
  const health = useLLMHealth(5000)

  const pushNotif = useCallback((n: Notification) => {
    setNotifications(prev => [...prev, n].slice(-20))
    setNotifCount(c => c + 1)
  }, [])

  const dismissNotif = useCallback((id: number) => {
    setNotifications(prev => prev.map(n => n.id === id ? { ...n, dismissed: true } : n))
  }, [])

  // Boot — no toast, just terminal messages handle it
  // Device scanning is shown as persistent indicator in topbar, not toasts

  // Device scanning — silent background probe, status shown in topbar indicator only
  useEffect(() => {
    const scanInterval = setInterval(() => {
      setDevices(prev => prev.map(d => {
        if (d.id !== 'zenphone9') return d
        return { ...d, lastSeen: Date.now() }
      }))
    }, 30000) // less aggressive: every 30s

    return () => clearInterval(scanInterval)
  }, [])

  // Simulate device detection when user manually connects
  // (Real impl: WebSocket handshake or mDNS)
  useEffect(() => {
    const handler = (e: CustomEvent<{ deviceId: string; ip: string }>) => {
      const { deviceId, ip } = e.detail
      setDevices(prev => prev.map(d =>
        d.id === deviceId ? { ...d, status: 'connected' as const, ip, lastSeen: Date.now() } : d
      ))
      pushNotif(createNotification(
        'device_connect',
        'Device Connected!',
        `${deviceId} joined the network at ${ip}`,
        '📱',
        colors.green,
      ))
    }
    window.addEventListener('symbolos:device-connect' as any, handler as any)
    return () => window.removeEventListener('symbolos:device-connect' as any, handler as any)
  }, [pushNotif])

  return (
    <div className="lt-wrap">
      <div className="lt-topbar">
        <span className="lt-brand">LANTERN</span>
        <span className="lt-meta">{networkNodes.length} nodes · {linkCount} links</span>
        <DevicePanel devices={devices} />
        <div className="lt-notif-badge" title={`${notifCount} notifications`}>
          🔔 {notifCount > 0 && <span className="lt-badge-num">{notifCount}</span>}
        </div>
        <LiveClock />
      </div>
      <SystemVitals health={health} />
      <div className="lt-grid">
        <div className="lt-panel lt-map">
          <div className="lt-panel-lbl">NETWORK MAP</div>
          <NetworkCanvas selectedId={selectedId} onSelect={setSelectedId} />
        </div>
        <div className="lt-panel lt-detail">
          <div className="lt-panel-lbl">NODE INSPECTOR</div>
          <NodeInspector node={selectedNode} health={health} />
        </div>
        <div className="lt-panel lt-term-panel">
          <TerminalPanel health={health} />
        </div>
      </div>
      <NotificationToasts notifications={notifications} onDismiss={dismissNotif} />
    </div>
  )
}
