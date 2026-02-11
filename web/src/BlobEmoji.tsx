/**
 * BlobEmoji React Component for SymbolOS
 * ========================================
 * Renders blob-style emoji with SVG/PNG from CDN, native fallback.
 *
 * Usage:
 *   <BlobEmoji emoji="☂️" />
 *   <BlobEmoji emoji="🦊" size={32} />
 *   <BlobEmoji emoji="⭐" size={24} title="Manus-Max" />
 *   <BlobEmojiPicker onSelect={(emoji) => console.log(emoji)} />
 *
 * License: Apache 2.0 (blob assets from C1710/blobmoji)
 */
import React, { useState, useEffect, useCallback, useMemo } from 'react'
import {
  lookupBlob,
  searchBlobs,
  getBlobsByCategory,
  preloadBlob,
  BLOB_MANIFEST,
  type BlobEntry,
} from './blobmoji'

// --- BlobEmoji Component ---

interface BlobEmojiProps {
  /** The native Unicode emoji to render as a blob */
  emoji: string
  /** Size in pixels (default: 20) */
  size?: number
  /** Tooltip title */
  title?: string
  /** Additional CSS class */
  className?: string
  /** Click handler */
  onClick?: () => void
  /** Whether to use inline style (default: true) */
  inline?: boolean
}

export function BlobEmoji({
  emoji,
  size = 20,
  title,
  className = '',
  onClick,
  inline = true,
}: BlobEmojiProps) {
  const [imgUrl, setImgUrl] = useState<string | null>(null)
  const [failed, setFailed] = useState(false)

  useEffect(() => {
    let cancelled = false
    preloadBlob(emoji).then(url => {
      if (!cancelled) {
        if (url === emoji) {
          setFailed(true) // No blob available, use native
        } else {
          setImgUrl(url)
        }
      }
    })
    return () => { cancelled = true }
  }, [emoji])

  const entry = lookupBlob(emoji)
  const displayTitle = title || entry?.name || emoji

  // Native fallback
  if (failed || !imgUrl) {
    return (
      <span
        className={`blob-emoji blob-native ${className}`}
        title={displayTitle}
        onClick={onClick}
        role={onClick ? 'button' : undefined}
        style={inline ? {
          fontSize: `${size}px`,
          lineHeight: 1,
          cursor: onClick ? 'pointer' : 'default',
          display: 'inline-flex',
          alignItems: 'center',
          justifyContent: 'center',
          width: `${size}px`,
          height: `${size}px`,
          verticalAlign: 'middle',
        } : undefined}
      >
        {emoji}
      </span>
    )
  }

  // Blob image
  return (
    <img
      src={imgUrl}
      alt={emoji}
      title={displayTitle}
      className={`blob-emoji blob-img ${className}`}
      onClick={onClick}
      role={onClick ? 'button' : undefined}
      onError={() => setFailed(true)}
      style={{
        width: `${size}px`,
        height: `${size}px`,
        display: 'inline-block',
        verticalAlign: 'middle',
        cursor: onClick ? 'pointer' : 'default',
        objectFit: 'contain',
      }}
    />
  )
}

// --- BlobEmojiPicker Component ---

interface BlobEmojiPickerProps {
  /** Called when an emoji is selected */
  onSelect: (emoji: string) => void
  /** Filter by category (optional) */
  category?: BlobEntry['category']
  /** Size of each emoji in the picker (default: 28) */
  emojiSize?: number
  /** Whether the picker is visible */
  visible?: boolean
  /** Additional CSS class */
  className?: string
}

export function BlobEmojiPicker({
  onSelect,
  category,
  emojiSize = 28,
  visible = true,
  className = '',
}: BlobEmojiPickerProps) {
  const [search, setSearch] = useState('')
  const [activeCategory, setActiveCategory] = useState<BlobEntry['category'] | 'all'>(category || 'all')

  const categories: Array<{ key: BlobEntry['category'] | 'all'; label: string; icon: string }> = [
    { key: 'all', label: 'All', icon: '🔵' },
    { key: 'agent', label: 'Agents', icon: '🦊' },
    { key: 'ring', label: 'Rings', icon: '⚓' },
    { key: 'memory', label: 'Memory', icon: '🗃️' },
    { key: 'system', label: 'System', icon: '☂️' },
    { key: 'emotion', label: 'Emotion', icon: '🔥' },
    { key: 'action', label: 'Action', icon: '✅' },
    { key: 'decorative', label: 'Decor', icon: '✨' },
  ]

  const filteredEntries = useMemo(() => {
    let entries = BLOB_MANIFEST.entries

    if (activeCategory !== 'all') {
      entries = getBlobsByCategory(activeCategory)
    }

    if (search.trim()) {
      entries = searchBlobs(search.trim())
      if (activeCategory !== 'all') {
        entries = entries.filter(e => e.category === activeCategory)
      }
    }

    return entries
  }, [search, activeCategory])

  if (!visible) return null

  return (
    <div className={`blob-picker ${className}`} style={{
      background: '#0a0e14',
      border: '1px solid #1a3a2a',
      borderRadius: '8px',
      padding: '8px',
      maxWidth: '320px',
      fontFamily: '"Fira Code", "Cascadia Code", monospace',
    }}>
      {/* Search */}
      <input
        type="text"
        value={search}
        onChange={e => setSearch(e.target.value)}
        placeholder="Search emoji..."
        style={{
          width: '100%',
          background: '#0d1117',
          border: '1px solid #1a3a2a',
          borderRadius: '4px',
          color: '#c9d1d9',
          padding: '4px 8px',
          fontSize: '12px',
          marginBottom: '6px',
          outline: 'none',
          boxSizing: 'border-box',
        }}
      />

      {/* Category tabs */}
      <div style={{
        display: 'flex',
        gap: '2px',
        marginBottom: '6px',
        flexWrap: 'wrap',
      }}>
        {categories.map(cat => (
          <button
            key={cat.key}
            onClick={() => setActiveCategory(cat.key)}
            title={cat.label}
            style={{
              background: activeCategory === cat.key ? '#1a3a2a' : 'transparent',
              border: 'none',
              borderRadius: '4px',
              padding: '2px 6px',
              cursor: 'pointer',
              fontSize: '14px',
              opacity: activeCategory === cat.key ? 1 : 0.6,
            }}
          >
            {cat.icon}
          </button>
        ))}
      </div>

      {/* Emoji grid */}
      <div style={{
        display: 'grid',
        gridTemplateColumns: `repeat(auto-fill, minmax(${emojiSize + 8}px, 1fr))`,
        gap: '4px',
        maxHeight: '200px',
        overflowY: 'auto',
      }}>
        {filteredEntries.map(entry => (
          <button
            key={entry.codepoints}
            onClick={() => onSelect(entry.native)}
            title={`${entry.name}${entry.ring ? ` (${entry.ring})` : ''}`}
            style={{
              background: 'transparent',
              border: '1px solid transparent',
              borderRadius: '4px',
              padding: '4px',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              transition: 'all 0.15s',
            }}
            onMouseEnter={e => {
              (e.target as HTMLElement).style.background = '#1a3a2a';
              (e.target as HTMLElement).style.borderColor = entry.thoughtformColor || '#228B22'
            }}
            onMouseLeave={e => {
              (e.target as HTMLElement).style.background = 'transparent';
              (e.target as HTMLElement).style.borderColor = 'transparent'
            }}
          >
            <BlobEmoji emoji={entry.native} size={emojiSize} />
          </button>
        ))}
      </div>

      {/* Count */}
      <div style={{
        fontSize: '10px',
        color: '#484f58',
        textAlign: 'right',
        marginTop: '4px',
      }}>
        {filteredEntries.length} / {BLOB_MANIFEST.entries.length} blob emoji
      </div>
    </div>
  )
}

// --- Utility: Replace native emoji with blob in text ---

/**
 * Replace all known emoji in a text string with blob <img> tags.
 * Useful for rendering chat messages with blob emoji.
 */
export function blobifyText(text: string, size = 20): string {
  let result = text
  for (const entry of BLOB_MANIFEST.entries) {
    if (result.includes(entry.native)) {
      const imgTag = `<img src="${entry.svgUrl}" alt="${entry.native}" ` +
        `title="${entry.name}" class="blob-emoji blob-inline" ` +
        `style="width:${size}px;height:${size}px;vertical-align:middle;display:inline-block" ` +
        `onerror="this.replaceWith(document.createTextNode('${entry.native}'))" />`
      result = result.replaceAll(entry.native, imgTag)
    }
  }
  return result
}

export default BlobEmoji
