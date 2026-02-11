import { useState, useEffect, useRef, useCallback } from 'react'
import { motion } from 'framer-motion'
import { colors } from './data'
import { banterLines } from './banter'

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

function NodeInspector({ node }: { node: NetworkNode | null }) {
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
        <span className={`lt-status ${node.status === '???' ? 'unknown' : ''}`}>{node.status}</span>
      </div>
      <div className="lt-hr" />
      <div className="lt-field"><span className="lt-label">TYPE</span><span className="lt-value">{node.type.toUpperCase()}</span></div>
      <div className="lt-field"><span className="lt-label">DETAIL</span><span className="lt-value">{node.detail}</span></div>
      <div className="lt-field"><span className="lt-label">LINKS</span><span className="lt-value">{conns.length}</span></div>
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

function TerminalPanel() {
  const [messages, setMessages] = useState<TermMsg[]>([])
  const [input, setInput] = useState('')
  const scrollRef = useRef<HTMLDivElement>(null)
  const idRef = useRef(0)

  const now = () => new Date().toLocaleTimeString('en-US', { hour12: false })

  const push = useCallback((msg: Omit<TermMsg, 'id' | 'time'>) => {
    setMessages(prev => [...prev, { ...msg, id: ++idRef.current, time: now() }].slice(-60))
  }, [])

  // Boot sequence
  useEffect(() => {
    const boot: Omit<TermMsg, 'id' | 'time'>[] = [
      { agent: 'SYS', emoji: '☂️', color: colors.primrose, text: 'SymbolOS Lantern v0.1 initializing...' },
      { agent: 'SYS', emoji: '☂️', color: colors.primrose, text: '7 agents online. 3 MCP servers connected.' },
      { agent: 'SYS', emoji: '☂️', color: colors.green, text: 'All rings nominal. Umbrella: ACTIVE.' },
      { agent: 'Rhy', emoji: '🦊', color: colors.green, text: 'Welcome to the Lantern. The fox watches.' },
    ]
    boot.forEach((msg, i) => {
      setTimeout(() => push(msg), i * 500)
    })
  }, [push])

  // Periodic banter
  useEffect(() => {
    const tick = () => {
      const line = banterLines[Math.floor(Math.random() * banterLines.length)]
      push(line)
    }
    const iv = setInterval(tick, 5000 + Math.random() * 4000)
    return () => clearInterval(iv)
  }, [push])

  // Auto-scroll
  useEffect(() => {
    const el = scrollRef.current
    if (el) el.scrollTop = el.scrollHeight
  }, [messages])

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    const txt = input.trim()
    if (!txt) return
    push({ agent: 'YOU', emoji: '👤', color: colors.cyan, text: txt })
    setInput('')
    setTimeout(() => {
      const pool = [
        { agent: 'Mercer', emoji: '🔵', color: colors.blue, text: `Copy. Processing: "${txt}"` },
        { agent: 'Rhy', emoji: '🦊', color: colors.green, text: 'The fox heard you. Interesting choice of words.' },
        { agent: 'Opus', emoji: '🟣', color: colors.violet, text: 'Noted. Aligning with umbrella principles.' },
        { agent: 'Max', emoji: '⭐', color: colors.gold, text: 'ON IT. Consider it done.' },
        { agent: 'Local', emoji: '🟢', color: colors.green, text: 'Running local inference... no cloud required.' },
      ]
      push(pool[Math.floor(Math.random() * pool.length)])
    }, 600 + Math.random() * 400)
  }

  return (
    <div className="lt-terminal">
      <div className="lt-term-hdr">
        <span>TERMINAL</span>
        <span className="lt-term-live">● LIVE</span>
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
        <input
          type="text"
          value={input}
          onChange={e => setInput(e.target.value)}
          placeholder="Type a message..."
          autoComplete="off"
          spellCheck={false}
        />
      </form>
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

  return (
    <div className="lt-wrap">
      <div className="lt-topbar">
        <span className="lt-brand">LANTERN</span>
        <span className="lt-meta">{networkNodes.length} nodes · {linkCount} links</span>
        <LiveClock />
      </div>
      <div className="lt-grid">
        <div className="lt-panel lt-map">
          <div className="lt-panel-lbl">NETWORK MAP</div>
          <NetworkCanvas selectedId={selectedId} onSelect={setSelectedId} />
        </div>
        <div className="lt-panel lt-detail">
          <div className="lt-panel-lbl">NODE INSPECTOR</div>
          <NodeInspector node={selectedNode} />
        </div>
        <div className="lt-panel lt-term-panel">
          <TerminalPanel />
        </div>
      </div>
    </div>
  )
}
