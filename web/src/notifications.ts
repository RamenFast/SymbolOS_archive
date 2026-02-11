/** SymbolOS Lantern — Notification system + Device awareness */

export type NotificationType = 'device_connect' | 'device_disconnect' | 'agent_status' | 'system' | 'alert'

export type Notification = {
  id: number
  type: NotificationType
  title: string
  body: string
  emoji: string
  color: string
  timestamp: number
  dismissed: boolean
}

let _nextId = 1

export function createNotification(
  type: NotificationType,
  title: string,
  body: string,
  emoji: string,
  color: string,
): Notification {
  return {
    id: _nextId++,
    type,
    title,
    body,
    emoji,
    color,
    timestamp: Date.now(),
    dismissed: false,
  }
}

/* ═══════════════════════════════════════════════════════ */
/*  DEVICE REGISTRY                                        */
/* ═══════════════════════════════════════════════════════ */

export type DeviceInfo = {
  id: string
  name: string
  type: 'phone' | 'tablet' | 'desktop' | 'server'
  emoji: string
  color: string
  status: 'scanning' | 'connected' | 'disconnected' | 'pairing'
  ip?: string
  lastSeen: number
}

/** Known devices in the SymbolOS ecosystem */
export const knownDevices: DeviceInfo[] = [
  {
    id: 'zenphone9',
    name: 'Zenphone 9',
    type: 'phone',
    emoji: '📱',
    color: '#00e5ff',
    status: 'scanning',
    lastSeen: 0,
  },
]

/**
 * Poll a device endpoint to check if it's reachable.
 * Uses a fast timeout so it doesn't block the UI.
 * For real detection: the phone runs a tiny HTTP server
 * or we use mDNS/WebSocket in the future.
 */
export async function probeDevice(ip: string, port: number = 8765): Promise<boolean> {
  try {
    const controller = new AbortController()
    const timeout = setTimeout(() => controller.abort(), 2000)
    const res = await fetch(`http://${ip}:${port}/symbolos/ping`, {
      signal: controller.signal,
      mode: 'no-cors',
    })
    clearTimeout(timeout)
    return res.type === 'opaque' || res.ok // no-cors returns opaque
  } catch {
    return false
  }
}

/**
 * Scan common local subnet IPs for a SymbolOS device.
 * This is a best-effort scan — real pairing will use mDNS or manual IP entry.
 */
export async function scanLocalNetwork(): Promise<string | null> {
  // Try common Android hotspot/WiFi IPs
  const candidates = [
    '192.168.1.100', '192.168.1.101', '192.168.1.102',
    '192.168.0.100', '192.168.0.101', '192.168.0.102',
    '10.0.0.2', '10.0.0.3',
  ]

  const results = await Promise.allSettled(
    candidates.map(async ip => {
      const ok = await probeDevice(ip)
      return ok ? ip : null
    })
  )

  for (const r of results) {
    if (r.status === 'fulfilled' && r.value) return r.value
  }
  return null
}
