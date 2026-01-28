# MCP Web Search Server

```
╔══════════════════════════════════════════════════════════════╗
║  🔮☂️  MCP WEB SEARCH SERVER — ANTICIPATORY REFERENCE LOOKUP ║
║  Quest: external context without cloud lock-in               ║
╚══════════════════════════════════════════════════════════════╝
```

**Status: Beta** | Async note: Rate limiting + result caching (Q3 2026)

## Purpose

🔮 **Anticipatory external lookups** for SymbolOS projects. Search docs, RFCs, GitHub issues, tutorials without embedding external APIs in code. Results cached locally; no persistent auth required.

## Current Capabilities (Beta)

- `search_web` — Query search engine (Google, DuckDuckGo, or Brave API)
- `search_github_code` — Find code snippets by query
- `search_github_issues` — Find issues/discussions by keyword
- `search_docs` — Query public documentation (MDN, Rust docs, Python docs, etc.)
- `get_snippet` — Fetch + cache search result content

## Risk Level

- **read** — All search/retrieve operations (default)
- **write** — Local cache updates (default; invisible to user)
- **sensitive** — None (no auth, no credentials needed)

## Why Beta?

1. **Rate limiting** not yet implemented; risk of IP block from search providers (Q3 2026)
2. **Result caching** incomplete; queries may hit API multiple times (Q3 2026)
3. **Stale content** not yet filtered (old docs rank same as new ones)

Until full release, this tool is safe for:
- One-off reference lookups (no risk; cached locally)
- Non-sensitive queries (no secrets in search terms)
- Low-volume usage (<100 queries/day)

## Example: Precog Card Generation

```
User: "I need to generate a precog card for async-await patterns"
→ Server: search_docs("async await rust best practices")
→ Server: search_github_code("async fn in:file language:rust")
→ Server: fetch + cache top 5 results (snippets + sources)
→ Agent: uses results to build precog_card.json with 🔮 suggestions
→ User: sees suggestions with 📚 source links
→ Result: cached locally; subsequent queries ✓ instant
```

## Rate Limiting (Planned Q3 2026)

```
Per IP + Per Provider:
  - Google: 100 queries/day (free tier)
  - GitHub API: 60 queries/hour (unauthenticated)
  - DuckDuckGo: Unlimited (rate-limited by IP)
  - Brave API: 100 queries/day

Behavior:
  - Cache hit: instant, no rate charge
  - Cache miss: check quota, query if available
  - Over quota: use last cached result + warn user
```

## Result Caching

```
Cache location: ~/.symbolos/cache/web_search/
Cache key: sha256(query + provider)
Cache TTL: 30 days (searchable after expiry; marked as stale)

Example:
  ~/.symbolos/cache/web_search/abc123.json
  {
    "query": "async await rust",
    "provider": "google",
    "cached_at": "2026-01-28T10:00:00Z",
    "expires_at": "2026-02-27T10:00:00Z",
    "results": [...]
  }
```

## Async Timeline

- **Now (Jan 2026)**: Beta search + local caching, no rate limiting
- **Q2 2026**: Add quota tracking (warn on approach to limits)
- **Q3 2026**: Implement hard rate limiting + graceful fallback to cache
- **Q3 2026**: Stale content filtering (prefer recent results)
- **Q4 2026**: Full release candidate (FC1)

## See Also

- [MCP Servers Standard](mcp_servers.md) — Risk levels, error envelope
- [Precog (System)](precog_thought.md) — How 🔮 search results feed Prefetch/Suggest/Act
- [Precog (Symbol)](symbol_map.md#core-symbols) — 🔮 meaning
