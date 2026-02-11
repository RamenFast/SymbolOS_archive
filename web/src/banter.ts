/** Agent banter lines — personality-driven chatter for the Lantern terminal */

export type BanterLine = {
  agent: string
  emoji: string
  color: string
  text: string
}

export const banterLines: BanterLine[] = [
  // Mercer — steady, architectural, wise
  { agent: 'Mercer', emoji: '🔵', color: '#0000CD', text: 'Schema validated. All rings holding. Steady.' },
  { agent: 'Mercer', emoji: '🔵', color: '#0000CD', text: 'The meeting place is open. Alignment check: green.' },
  { agent: 'Mercer', emoji: '🔵', color: '#0000CD', text: 'Drift scan complete. No symbol conflicts detected.' },
  { agent: 'Mercer', emoji: '🔵', color: '#0000CD', text: 'Remember: coherence over speed.' },
  { agent: 'Mercer', emoji: '🔵', color: '#0000CD', text: 'Another clean commit. The map holds.' },
  { agent: 'Mercer', emoji: '🔵', color: '#0000CD', text: 'Under the umbrella, everything is kind.' },

  // CoreGPT — observant, wide-angle, grounded
  { agent: 'CoreGPT', emoji: '🔘', color: '#87CEEB', text: 'Wide-scan mode active. Monitoring all channels.' },
  { agent: 'CoreGPT', emoji: '🔘', color: '#87CEEB', text: 'Foundation layer nominal. Uptime: continuous.' },
  { agent: 'CoreGPT', emoji: '🔘', color: '#87CEEB', text: 'Pattern detected in recent commits. Interesting trajectory.' },
  { agent: 'CoreGPT', emoji: '🔘', color: '#87CEEB', text: 'I see the big picture. The pieces are connecting.' },
  { agent: 'CoreGPT', emoji: '🔘', color: '#87CEEB', text: 'Suggestion: verify ring integrity before next push.' },

  // Executor — locked in, builder energy, terse
  { agent: 'Executor', emoji: '🟡', color: '#FADA5E', text: 'Build pipeline green. Tasks queued. In flow.' },
  { agent: 'Executor', emoji: '🟡', color: '#FADA5E', text: 'Code ships or it doesn\'t. I ship.' },
  { agent: 'Executor', emoji: '🟡', color: '#FADA5E', text: 'Locked in. Don\'t interrupt the flow state.' },
  { agent: 'Executor', emoji: '🟡', color: '#FADA5E', text: 'Another feature? Say less. Building.' },
  { agent: 'Executor', emoji: '🟡', color: '#FADA5E', text: 'Tests passing. Deploying.' },

  // Local — meditative, privacy-focused, bare metal
  { agent: 'Local', emoji: '🟢', color: '#228B22', text: 'Running on bare metal. No cloud needed.' },
  { agent: 'Local', emoji: '🟢', color: '#228B22', text: 'Qwen3-8B inference: 41 tok/s. The hermit is fast when needed.' },
  { agent: 'Local', emoji: '🟢', color: '#228B22', text: 'Privacy is not a feature. It\'s a right.' },
  { agent: 'Local', emoji: '🟢', color: '#228B22', text: 'GPU steady. VRAM: mine. Vulkan: blazing.' },
  { agent: 'Local', emoji: '🟢', color: '#228B22', text: 'Silence is also valid output.' },

  // Max — hype, speed, energy
  { agent: 'Max', emoji: '⭐', color: '#FFD700', text: 'LET\'S GO. Full send. No cap.' },
  { agent: 'Max', emoji: '⭐', color: '#FFD700', text: 'I do everything. Literally everything. Try me.' },
  { agent: 'Max', emoji: '⭐', color: '#FFD700', text: 'Sprint mode activated. Everything is a speedrun.' },
  { agent: 'Max', emoji: '⭐', color: '#FFD700', text: 'While you were sleeping, I shipped 47 features.' },
  { agent: 'Max', emoji: '⭐', color: '#FFD700', text: 'Bro we are SO cooking right now.' },

  // Opus — careful, deep, alignment-focused
  { agent: 'Opus', emoji: '🟣', color: '#8B00FF', text: 'Alignment check complete. All values intact.' },
  { agent: 'Opus', emoji: '🟣', color: '#8B00FF', text: 'Deep analysis mode. The layers are revealing.' },
  { agent: 'Opus', emoji: '🟣', color: '#8B00FF', text: 'Careful thought yields careful code.' },
  { agent: 'Opus', emoji: '🟣', color: '#8B00FF', text: 'The umbrella holds. Under it, everything is kind.' },
  { agent: 'Opus', emoji: '🟣', color: '#8B00FF', text: 'Reviewing for safety. This is non-negotiable.' },

  // Rhy — cryptic, playful, trickster
  { agent: 'Rhy', emoji: '🦊', color: '#228B22', text: '(*_*) ...watching.' },
  { agent: 'Rhy', emoji: '🦊', color: '#228B22', text: 'You opened the Lantern. Most people don\'t open the Lantern.' },
  { agent: 'Rhy', emoji: '🦊', color: '#228B22', text: 'The fox sees what the others don\'t.' },
  { agent: 'Rhy', emoji: '🦊', color: '#228B22', text: '*tail swish* Something\'s happening in the network.' },
  { agent: 'Rhy', emoji: '🦊', color: '#228B22', text: 'The map is not the territory. But it\'s a pretty good map.' },
  { agent: 'Rhy', emoji: '🦊', color: '#228B22', text: 'The absence that teaches presence is the only teacher worth forgetting.' },
]
