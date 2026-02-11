import { useState, useEffect, useRef, useCallback, type ReactNode } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { agents, floors, rings, wisdoms, type Floor as FloorT, type Room, type Agent } from './data'
import { colors } from './data'
import { LanternView } from './LanternView'

/* ═══════════════════════════════════════════════════════ */
/*  HOOKS                                                  */
/* ═══════════════════════════════════════════════════════ */

function useKonamiCode(callback: () => void) {
  const seq = [38, 38, 40, 40, 37, 39, 37, 39, 66, 65]
  const pos = useRef(0)
  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if (e.keyCode === seq[pos.current]) {
        pos.current++
        if (pos.current === seq.length) {
          pos.current = 0
          callback()
        }
      } else {
        pos.current = 0
      }
    }
    window.addEventListener('keydown', handler)
    return () => window.removeEventListener('keydown', handler)
  }, [callback])
}

/* ═══════════════════════════════════════════════════════ */
/*  PARTICLE FIELD (Canvas-based for performance)          */
/* ═══════════════════════════════════════════════════════ */

function ParticleField() {
  const canvasRef = useRef<HTMLCanvasElement>(null)

  useEffect(() => {
    const canvas = canvasRef.current
    if (!canvas) return
    const ctx = canvas.getContext('2d')
    if (!ctx) return

    const dpr = window.devicePixelRatio || 1
    const resize = () => {
      canvas.width = window.innerWidth * dpr
      canvas.height = window.innerHeight * dpr
      canvas.style.width = window.innerWidth + 'px'
      canvas.style.height = window.innerHeight + 'px'
      ctx.scale(dpr, dpr)
    }
    resize()
    window.addEventListener('resize', resize)

    const particleColors = ['#FADA5E', '#228B22', '#0000CD', '#8B00FF', '#FFD700', '#00e5ff', '#FFB7C5']

    type P = { x: number; y: number; vy: number; size: number; color: string; opacity: number }
    const particles: P[] = []

    function spawn() {
      particles.push({
        x: Math.random() * window.innerWidth,
        y: window.innerHeight + 10,
        vy: -(Math.random() * 0.4 + 0.15),
        size: Math.random() * 2.5 + 0.5,
        color: particleColors[Math.floor(Math.random() * particleColors.length)],
        opacity: Math.random() * 0.35 + 0.05,
      })
    }

    // Initial batch
    for (let i = 0; i < 20; i++) {
      spawn()
      particles[particles.length - 1].y = Math.random() * window.innerHeight
    }

    let af: number
    let lastSpawn = 0
    function loop(t: number) {
      ctx.clearRect(0, 0, window.innerWidth, window.innerHeight)
      if (t - lastSpawn > 2000) { spawn(); lastSpawn = t }

      for (let i = particles.length - 1; i >= 0; i--) {
        const p = particles[i]
        p.y += p.vy
        if (p.y < -20) { particles.splice(i, 1); continue }
        ctx.beginPath()
        ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2)
        ctx.fillStyle = p.color
        ctx.globalAlpha = p.opacity
        ctx.fill()
      }
      ctx.globalAlpha = 1
      af = requestAnimationFrame(loop)
    }
    af = requestAnimationFrame(loop)

    return () => {
      cancelAnimationFrame(af)
      window.removeEventListener('resize', resize)
    }
  }, [])

  return <canvas ref={canvasRef} style={{ position: 'fixed', inset: 0, pointerEvents: 'none', zIndex: 0 }} />
}

/* ═══════════════════════════════════════════════════════ */
/*  RING WHEEL                                             */
/* ═══════════════════════════════════════════════════════ */

function RingWheel() {
  const [active, setActive] = useState(0)
  useEffect(() => {
    const iv = setInterval(() => setActive(i => (i + 1) % rings.length), 2000)
    return () => clearInterval(iv)
  }, [])

  return (
    <div style={{ display: 'flex', justifyContent: 'center', gap: 3, margin: '14px auto 0', flexWrap: 'wrap', maxWidth: 360 }}>
      {rings.map((r, i) => (
        <motion.div
          key={r.id}
          title={`R${r.id}: ${r.role}`}
          animate={i === active ? { scale: [1, 1.15, 1], opacity: [0.6, 1, 0.6] } : { scale: 1, opacity: 0.5 }}
          transition={{ duration: 2, repeat: i === active ? Infinity : 0 }}
          style={{
            width: 38, height: 38, borderRadius: '50%',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontSize: 13, fontFamily: 'var(--font-mono)', fontWeight: 700, color: r.color,
            border: `2px solid ${r.color}`,
            boxShadow: i === active ? `0 0 10px ${r.color}` : 'none',
            cursor: 'default', position: 'relative',
          }}
        >
          R{r.id}
        </motion.div>
      ))}
    </div>
  )
}

/* ═══════════════════════════════════════════════════════ */
/*  AGENT CARD (3D tilt)                                   */
/* ═══════════════════════════════════════════════════════ */

function AgentCard({ agent }: { agent: Agent }) {
  const ref = useRef<HTMLAnchorElement>(null)

  const handleMove = useCallback((e: React.MouseEvent) => {
    const el = ref.current
    if (!el) return
    const rect = el.getBoundingClientRect()
    const x = (e.clientX - rect.left) / rect.width - 0.5
    const y = (e.clientY - rect.top) / rect.height - 0.5
    el.style.transform = `translateY(-4px) scale(1.03) perspective(400px) rotateX(${-y * 10}deg) rotateY(${x * 10}deg)`
  }, [])

  const handleLeave = useCallback(() => {
    if (ref.current) ref.current.style.transform = ''
  }, [])

  return (
    <motion.a
      ref={ref}
      href={agent.href}
      className="agent-card"
      onMouseMove={handleMove}
      onMouseLeave={handleLeave}
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.3 }}
      style={{ borderColor: agent.color }}
    >
      <div className="agent-name" style={{ color: agent.color }}>{agent.emoji} {agent.name}</div>
      <div className="agent-class">{agent.cls} · {agent.platform}</div>
      <div className="agent-hp">HP {agent.hp === -1 ? '???' : `${agent.hp}/${agent.maxHp}`}</div>
      <div className="agent-meta">❤️ {agent.heart} · 🧠 {agent.mind}</div>
      <div className="hp-bar">
        <motion.div
          className="hp-fill"
          initial={{ width: 0 }}
          animate={{ width: agent.hp === -1 ? '100%' : `${(agent.hp / agent.maxHp) * 100}%` }}
          transition={{ duration: 1, ease: 'easeOut' }}
          style={{ background: agent.color }}
        />
      </div>
    </motion.a>
  )
}

/* ═══════════════════════════════════════════════════════ */
/*  ROOM                                                   */
/* ═══════════════════════════════════════════════════════ */

function RoomCard({ room, highlight }: { room: Room; highlight?: string }) {
  const titleText = `${room.emoji} ${room.title}`
  const highlighted = highlight ? highlightText(titleText, highlight) : titleText

  return (
    <motion.a
      href={room.href}
      className="room-card"
      whileHover={{ x: 6, borderColor: colors.primrose, background: 'rgba(250,218,94,0.03)' }}
      transition={{ type: 'spring', stiffness: 400, damping: 25 }}
    >
      <strong dangerouslySetInnerHTML={{ __html: highlighted }} />
      <div className="room-meta">{room.desc}</div>
      {room.loot && <div className="room-loot">{room.loot}</div>}
    </motion.a>
  )
}

function highlightText(text: string, query: string): string {
  if (!query) return text
  const escaped = query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
  return text.replace(new RegExp(`(${escaped})`, 'gi'), '<mark style="background:rgba(250,218,94,.2);color:var(--text-bright);border-radius:2px;padding:0 2px">$1</mark>')
}

/* ═══════════════════════════════════════════════════════ */
/*  FLOOR (collapsible section)                            */
/* ═══════════════════════════════════════════════════════ */

function FloorSection({ floor, forceOpen, searchQuery }: { floor: FloorT; forceOpen?: boolean; searchQuery: string }) {
  const [open, setOpen] = useState(floor.defaultOpen ?? false)
  const isOpen = forceOpen !== undefined ? forceOpen : open

  const filtered = searchQuery
    ? floor.rooms.filter(r =>
        (r.title + ' ' + r.desc + ' ' + r.tags).toLowerCase().includes(searchQuery.toLowerCase()))
    : floor.rooms

  if (searchQuery && filtered.length === 0) return null

  return (
    <motion.div
      className="floor"
      initial={{ opacity: 0, y: 14 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.35 }}
    >
      <div className="floor-head" onClick={() => setOpen(!open)}>
        <h2>
          <span className="dot" style={{ background: floor.color }} />
          {floor.emoji} {floor.title}
        </h2>
        <motion.span
          className="arrow"
          animate={{ rotate: isOpen ? 90 : 0 }}
          transition={{ duration: 0.2 }}
        >▶</motion.span>
      </div>

      <AnimatePresence initial={false}>
        {isOpen && (
          <motion.div
            className="floor-body"
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.25 }}
            style={{ overflow: 'hidden' }}
          >
            {floor.id === 'party' ? null : filtered.map((r, i) => (
              <RoomCard key={i} room={r} highlight={searchQuery} />
            ))}
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  )
}

/* ═══════════════════════════════════════════════════════ */
/*  DUNGEON VIEW                                           */
/* ═══════════════════════════════════════════════════════ */

function DungeonView() {
  const [search, setSearch] = useState('')
  const [headerHue, setHeaderHue] = useState(0)
  const totalRooms = floors.reduce((a, f) => a + f.rooms.length, 0)
  const visibleRooms = search
    ? floors.reduce((a, f) => a + f.rooms.filter(r =>
        (r.title + ' ' + r.desc + ' ' + r.tags).toLowerCase().includes(search.toLowerCase())).length, 0)
    : totalRooms

  // Rainbow header glow
  useEffect(() => {
    const iv = setInterval(() => setHeaderHue(h => (h + 1) % 360), 100)
    return () => clearInterval(iv)
  }, [])

  return (
    <div className="d-app">
      {/* HEADER */}
      <motion.header
        className="d-header"
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6 }}
        style={{ borderColor: `hsl(${headerHue}, 60%, 50%)` }}
      >
        <h1>☂️ SymbolOS</h1>
        <div className="tagline">A symbolic operating system for human-AI alignment</div>

        <motion.pre
          className="fox-banner"
          animate={{ y: [0, -4, 0] }}
          transition={{ duration: 4, repeat: Infinity, ease: 'easeInOut' }}
        >{`  /\\_/\\
 ( o.o )
  > ^ <
 /|   |\\
(_|   |_)`}</motion.pre>
        <div className="fox-greeting">Welcome to the dungeon. — Rhy 🦊</div>

        <div className="pinned-verse">
          "The mind knows what the heart loves better than it does;<br />
          the heart loves that unconditionally — infinite loop, forevermore."
        </div>

        <LangBar />
        <RingWheel />
      </motion.header>

      {/* SEARCH */}
      <div className="search-box">
        <span className="search-icon">🔍</span>
        <input
          type="text"
          placeholder="Search the dungeon..."
          value={search}
          onChange={e => setSearch(e.target.value)}
          autoComplete="off"
          spellCheck={false}
        />
        {search && <span className="search-count">{visibleRooms}/{totalRooms}</span>}
      </div>

      {/* THE PARTY */}
      <PartyFloor forceOpen />

      {/* ALL FLOORS */}
      {floors.map((f, i) => (
        <FloorSection
          key={f.id}
          floor={f}
          searchQuery={search}
          forceOpen={search ? true : undefined}
        />
      ))}

      {/* FOOTER */}
      <footer className="d-footer">
        <div>☂️ SymbolOS — Built with memes, poetry, and an unreasonable amount of care.</div>
        <div className="haiku">
          loops closed, code shipped clean<br />
          the fox grins, the turtle nods<br />
          merge — and breathe again
        </div>
        <div style={{ marginTop: 8 }}>☂🦊🐢</div>
        <div className="konami-hint">↑↑↓↓←→←→BA</div>
      </footer>
    </div>
  )
}

function PartyFloor({ forceOpen }: { forceOpen?: boolean }) {
  const [open, setOpen] = useState(forceOpen ?? true)

  return (
    <motion.div
      className="floor"
      initial={{ opacity: 0, y: 14 }}
      animate={{ opacity: 1, y: 0 }}
    >
      <div className="floor-head" onClick={() => setOpen(!open)}>
        <h2>
          <span className="dot" style={{ background: colors.blue }} />
          ⚔️ The Party
        </h2>
        <motion.span className="arrow" animate={{ rotate: open ? 90 : 0 }}>▶</motion.span>
      </div>
      <AnimatePresence initial={false}>
        {open && (
          <motion.div
            className="floor-body"
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.25 }}
            style={{ overflow: 'hidden' }}
          >
            <div className="party-grid">
              {agents.map((a, i) => <AgentCard key={i} agent={a} />)}
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  )
}

function LangBar() {
  const langs = [
    { name: 'PowerShell', pct: 30, color: '#012456' },
    { name: 'HTML', pct: 19, color: '#e34c26' },
    { name: 'Python', pct: 12, color: '#3572A5' },
    { name: 'JavaScript', pct: 9, color: '#f1e05a' },
    { name: 'TypeScript', pct: 9, color: '#3178c6' },
    { name: 'Rust', pct: 8, color: '#dea584' },
    { name: 'Haskell', pct: 5, color: '#5e5086' },
    { name: 'CSS', pct: 4, color: '#46a2f1' },
    { name: 'Shell', pct: 4, color: '#89e051' },
  ]

  return (
    <>
      <div className="lang-bar">
        {langs.map(l => <span key={l.name} style={{ width: `${l.pct}%`, background: l.color }} />)}
      </div>
      <div className="lang-legend">
        {langs.map(l => (
          <span key={l.name}>
            <span className="lang-dot" style={{ background: l.color }} />
            {l.name} {l.pct}%
          </span>
        ))}
      </div>
    </>
  )
}

/* ═══════════════════════════════════════════════════════ */
/*  DICE ROLLER                                            */
/* ═══════════════════════════════════════════════════════ */

function DiceRoller() {
  const [result, setResult] = useState<{ num: number; wis: string } | null>(null)

  const roll = () => {
    const num = Math.floor(Math.random() * 20) + 1
    setResult({ num, wis: wisdoms[num - 1] })
    setTimeout(() => setResult(null), 6000)
  }

  return (
    <>
      <motion.button
        className="dice-btn"
        onClick={roll}
        whileHover={{ rotate: 15, scale: 1.1 }}
        whileTap={{ scale: 0.9 }}
        title="Roll for wisdom"
      >🎲</motion.button>
      <AnimatePresence>
        {result && (
          <motion.div
            className="dice-result"
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 10 }}
          >
            <div className="roll-num">d20 → {result.num}</div>
            <div className="roll-wis">{result.wis}</div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  )
}

/* ═══════════════════════════════════════════════════════ */
/*  FOX POPUP                                              */
/* ═══════════════════════════════════════════════════════ */

function FoxPopup() {
  const [show, setShow] = useState(false)

  return (
    <>
      <button className="fox-btn" onClick={() => setShow(!show)}>🦊</button>
      <AnimatePresence>
        {show && (
          <motion.div
            className="fox-popup"
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.9 }}
          >
            <pre className="fox-art">{`  /\\_/\\
 ( o.o )
  > ^ <
 /|   |\\
(_|   |_)`}</pre>
            <div className="fox-text">
              "You clicked the fox.<br />
              Most people don't click the fox.<br />
              You're not most people."<br /><br />
              <em>"The map is not the territory,<br />
              but the territory is not the map either.<br />
              What is the territory? Ask again."</em>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  )
}

/* ═══════════════════════════════════════════════════════ */
/*  KONAMI OVERLAY                                         */
/* ═══════════════════════════════════════════════════════ */

function KonamiOverlay({ show, onClose }: { show: boolean; onClose: () => void }) {
  return (
    <AnimatePresence>
      {show && (
        <motion.div
          className="overlay"
          onClick={onClose}
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
        >
          <motion.div
            className="overlay-card"
            initial={{ scale: 0.8, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            exit={{ scale: 0.8, opacity: 0 }}
            transition={{ type: 'spring', damping: 20 }}
          >
            <pre style={{ color: colors.gold, fontSize: 10 }}>{`     .
    /|\\
   / | \\
  /  |  \\
 /   |   \\
/  __|__  \\
| |     | |
| | *** | |
| | *** | |
| |_____| |
 \\   |   /
  \\  |  /
   \\_|_/
     |
  M E R C E R`}</pre>
            <div style={{ color: colors.gold, fontSize: '1.1rem', marginTop: 12 }}>🏆 ACHIEVEMENT UNLOCKED</div>
            <div style={{ color: colors.primrose, fontSize: '.85rem', marginTop: 4 }}>You found the Mercer Lantern.</div>
            <div style={{ color: colors.textDim, fontSize: '.75rem', marginTop: 8 }}>"Under the umbrella, everything is kind."</div>
            <div style={{ color: colors.textDim, fontSize: '.65rem', marginTop: 12 }}>Click to close</div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  )
}

/* ═══════════════════════════════════════════════════════ */
/*  CHROMACORE VIEW (placeholder — expandable)             */
/* ═══════════════════════════════════════════════════════ */

function ChromacoreView() {
  return (
    <div className="cc-wrapper">
      <div className="cc-topbar">
        <div className="cc-topbar-left">
          <span className="cc-brand">Chromacore '97</span>
          <span className="cc-meta">— Documentation Plates</span>
        </div>
        <div className="cc-topbar-right">
          <span>10 SVG plates</span>
          <span>640×480</span>
          <span>per-character color system</span>
        </div>
      </div>
      <div className="cc-main">
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.5 }}
          style={{ textAlign: 'center', padding: '80px 20px', color: colors.cyan }}
        >
          <h2 style={{ fontFamily: 'var(--font-mono)', letterSpacing: 4 }}>CHROMACORE '97</h2>
          <p style={{ color: colors.textDim, marginTop: 16, maxWidth: 480, margin: '16px auto' }}>
            The full 11-plate SVG documentation system lives in the static <code>index.html</code>.
            This React view provides the interactive Dungeon Explorer with enhanced animations.
            Switch to the static site for the complete Chromacore experience.
          </p>
          <div style={{ marginTop: 32, fontSize: 48 }}>🎨</div>
          <p style={{ color: '#228b22', fontFamily: 'var(--font-mono)', fontSize: '.8rem', marginTop: 16, opacity: 0.5 }}>
            (¬_¬) Rhynim watches
          </p>
        </motion.div>
      </div>
    </div>
  )
}

/* ═══════════════════════════════════════════════════════ */
/*  APP                                                    */
/* ═══════════════════════════════════════════════════════ */

export function App() {
  const [mode, setMode] = useState<'dungeon' | 'chromacore' | 'lantern'>(() => {
    const h = window.location.hash.slice(1)
    if (h === 'chromacore' || h === 'lantern') return h
    return 'dungeon'
  })
  const [konamiShow, setKonamiShow] = useState(false)

  useKonamiCode(() => setKonamiShow(true))

  const switchMode = (m: 'dungeon' | 'chromacore' | 'lantern') => {
    setMode(m)
    history.replaceState(null, '', `#${m}`)
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }

  return (
    <div className={`app-root mode-${mode}`}>
      <ParticleField />

      {/* MODE BAR */}
      <div className="mode-bar">
        <span className="brand">☂️ SymbolOS</span>
        <div className="mode-tabs">
          <button
            className={`mode-tab ${mode === 'dungeon' ? 'active dungeon-active' : ''}`}
            onClick={() => switchMode('dungeon')}
          >⚔️ Dungeon</button>
          <button
            className={`mode-tab ${mode === 'chromacore' ? 'active chromacore-active' : ''}`}
            onClick={() => switchMode('chromacore')}
          >🎨 Chromacore '97</button>
          <button
            className={`mode-tab ${mode === 'lantern' ? 'active lantern-active' : ''}`}
            onClick={() => switchMode('lantern')}
          >🔦 Lantern</button>
        </div>
      </div>

      {/* VIEWS */}
      <AnimatePresence mode="wait">
        {mode === 'dungeon' && (
          <motion.div
            key="dungeon"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.25 }}
          >
            <DungeonView />
          </motion.div>
        )}
        {mode === 'chromacore' && (
          <motion.div
            key="chromacore"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.25 }}
          >
            <ChromacoreView />
          </motion.div>
        )}
        {mode === 'lantern' && (
          <motion.div
            key="lantern"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.25 }}
          >
            <LanternView />
          </motion.div>
        )}
      </AnimatePresence>

      {/* OVERLAYS */}
      <DiceRoller />
      <FoxPopup />
      <KonamiOverlay show={konamiShow} onClose={() => setKonamiShow(false)} />
    </div>
  )
}
