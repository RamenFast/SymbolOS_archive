// ╔══════════════════════════════════════════════════════════════╗
// ║  ⚔️  SYMBOLOS EXTENSION — extension.js
// ║  🎨 Color: 🟡 #E49B0F (higher intellect)
// ╚══════════════════════════════════════════════════════════════╝
//
// ─── MCP Sync/Commit Output Formatting (Chroma 97, ASCII) ────────────────
// All output/logs must use ASCII banners and Chroma 97/Thoughtforms style.
function formatMCPBanner({ room, floor, difficulty, loot, color, maturity }) {
  // Returns a string banner for logs/commits
  const lines = [
    '╔══════════════════════════════════════════════════════════════╗',
    `║  ⚔️  ROOM: ${room.padEnd(48)}║`,
    `║  📍 Floor: ${floor} │ Difficulty: ${difficulty} │ Loot: ${loot.padEnd(18)}║`,
    `║  🎨 Color: ${color}${maturity ? ` │ Maturity: ${maturity}` : ''}${' '.repeat(Math.max(0, 54 - color.length - (maturity ? maturity.length + 13 : 0)))}║`,
    '╚══════════════════════════════════════════════════════════════╝'
  ];
  return lines.join('\n');
}

function formatMCPFooter() {
  return '\n☂🦊🐢';
}

function formatMCPCommitMessage({ banner, summary, details }) {
  // Compose a full commit message with banner, summary, details, and footer
  return [
    banner,
    '',
    summary,
    details ? `- ${details}` : '',
    formatMCPFooter()
  ].filter(Boolean).join('\n');
}

// ─── MCP Sync/Commit Command Implementations ─────────────────────
const MCP_MEMORY_URL = 'http://127.0.0.1:8091';
const MCP_FS_URL = 'http://127.0.0.1:8092';
const MCP_GIT_URL = 'http://127.0.0.1:8093'; // Planned

const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));

async function mcpSyncCommand() {
  // List memory files and show in output
  try {
    const res = await fetch(`${MCP_MEMORY_URL}/tools`);
    const data = await res.json();
    const files = (data.data && data.data.tools) ? data.data.tools.map(t => t.name).join(', ') : 'N/A';
    const banner = formatMCPBanner({
      room: "MCP Sync Chamber",
      floor: "R9 (Persistence)",
      difficulty: "⭐⭐",
      loot: "Memory, docs, audit",
      color: "Gold (#FFD700)",
      maturity: undefined
    });
    const summary = '- MCP Sync: Available tools: ' + files;
    vscode.window.showInformationMessage([banner, '', summary, formatMCPFooter()].join('\n'));
  } catch (err) {
    vscode.window.showErrorMessage('MCP Sync error: ' + err.message);
  }
}

async function mcpCommitCommand() {
  // Phase 1: Consent-gated commit (stub for MCP Git server)
  const banner = formatMCPBanner({
    room: "The Git Sync Chamber (MCP-First)",
    floor: "R9 (Persistence)",
    difficulty: "⭐⭐⭐",
    loot: "Provenance, audit",
    color: "Gold (#FFD700)",
    maturity: undefined
  });
  const summary = '- MCP Commit: All changes auditable and style-compliant';
  const details = 'Consent required. (Planned: POST to MCP Git server for commit/push)';
  const msg = formatMCPCommitMessage({ banner, summary, details });
  vscode.window.showInformationMessage(msg);
}

// ─── MCP Sync/Commit UI Panel ──────────────────────────────
function showMcpPanel(context) {
  const panel = vscode.window.createWebviewPanel(
    'mcpSyncPanel',
    'MCP Sync/Commit State',
    vscode.ViewColumn.One,
    { enableScripts: true }
  );
  panel.webview.html = getMcpPanelHtml();
}

function getMcpPanelHtml() {
  // Simple HTML panel with Chroma 97/ASCII style
  return `
    <html><body style="font-family:monospace;background:#181818;color:#FFD700;">
    <pre>
╔══════════════════════════════════════════════════════════════╗
║  🗃️  MCP Sync/Commit State Panel                            ║
║  📍 Floor: R9 │ Difficulty: ⭐⭐⭐ │ Loot: Provenance, audit   ║
║  🎨 Color: Gold (#FFD700)                                   ║
╚══════════════════════════════════════════════════════════════╝

<b>Sync/Commit Status:</b>
- Last sync: (not implemented)
- Pending changes: (not implemented)
- Audit log: (not implemented)

<button onclick="vscode.postMessage({ command: 'mcpSync' })">Sync via MCP</button>
<button onclick="vscode.postMessage({ command: 'mcpCommit' })">Commit via MCP</button>

☂🦊🐢
    </pre>
    <script>
      const vscode = acquireVsCodeApi();
      window.addEventListener('message', event => {
        // handle messages from extension
      });
    </script>
    </body></html>
  `;
}
//        /\_/\
//       ( o.o )  "Extensions extend, but foxes transcend."
//        > ^ <
//       /|   |\
//      (_|   |_)  — Rhy 🦊
//
// ╔══════════════════════════════════════════════════════════════╗
// ║  🧬🔍☂️  MERCER STATUS — VS Code Extension                   ║
// ║  "Show me proof, not potential." — 💀 Skeleton Gatekeeper    ║
// ╚══════════════════════════════════════════════════════════════╝
//
//   (•_•)
//   <)  )╯  "we ball, but we verify"
//    /  \    — and this extension does the verifying
//

const vscode = require('vscode');
const fs = require('fs');
const path = require('path');

// ─── R6: File I/O ───────────────────────────────────────────
// 🐢 "just read the file, turtle. nice and steady."

function readUtf8(filePath) {
  return fs.readFileSync(filePath, { encoding: 'utf8' });
}

// ─── R6: Symbol Parsing ────────────────────────────────────
// Parse the shared JSON map — the machine-readable meeting place.
// Every symbol here is a promise. We check if the docs keep it.

function parseSharedSymbols(sharedMapJson) {
  const symbols = new Set();
  const list = Array.isArray(sharedMapJson.symbols) ? sharedMapJson.symbols : [];
  for (const entry of list) {
    if (entry && typeof entry.symbol === 'string' && entry.symbol.trim()) {
      symbols.add(entry.symbol.trim());
    }
  }
  return symbols;
}

// Parse the human-readable symbol map (docs/symbol_map.md).
// This is what humans actually read. If it drifts from the JSON,
// someone's going to have a bad time.
//
//     ___
//    / 🐢 \    "parsing markdown for emoji"
//   |  ._. |   "what a time to be alive"
//    \_____/
//     |   |

function parseCoreSymbolsFromHumanMap(mdText) {
  const idx = mdText.toLowerCase().indexOf('## core symbols');
  if (idx < 0) return new Set();

  const after = mdText.slice(idx);
  // Find end of the Core section: next markdown heading.
  let end = after.length;
  const next = after.slice(1).search(/\n##\s+/);
  if (next >= 0) end = next + 1;

  const block = after.slice(0, end);
  const symbols = new Set();

  // Lines like: - `☂️` Umbrella...
  const re = /^\s*-\s+`([^`]+)`\s+/gm;
  let m;
  while ((m = re.exec(block)) !== null) {
    const sym = (m[1] || '').trim();
    if (sym) symbols.add(sym);
  }

  return symbols;
}

// ─── R6: Drift Computation ─────────────────────────────────
// This is the heart of the extension. Compare shared vs human.
// If they match: 🐢 "this is fine"
// If they don't: 💀 "prove your worth!"

function computeDrift(repoRoot) {
  const sharedMapPath = path.join(repoRoot, 'symbol_map.shared.json');
  const humanMapPath = path.join(repoRoot, 'docs', 'symbol_map.md');

  if (!fs.existsSync(sharedMapPath)) {
    return { code: 1, summary: 'Missing symbol_map.shared.json — the meeting place is gone!' };
  }
  if (!fs.existsSync(humanMapPath)) {
    return { code: 1, summary: 'Missing docs/symbol_map.md — the human map is missing!' };
  }

  try {
    const shared = JSON.parse(readUtf8(sharedMapPath));
    const sharedSymbols = parseSharedSymbols(shared);

    const humanMd = readUtf8(humanMapPath);
    const coreSymbols = parseCoreSymbolsFromHumanMap(humanMd);

    const missingInDocs = [...sharedSymbols].filter(s => !coreSymbols.has(s)).sort();
    const extraInDocs = [...coreSymbols].filter(s => !sharedSymbols.has(s)).sort();

    if (missingInDocs.length === 0 && extraInDocs.length === 0) {
      // 🐢 "this is fine" — symbols aligned, umbrella held
      return { code: 0, summary: 'Core symbols aligned ☂️✅' };
    }

    // 💀 Skeleton says: drift detected
    const parts = [];
    if (missingInDocs.length) parts.push(`docs missing: ${missingInDocs.join(' ')}`);
    if (extraInDocs.length) parts.push(`docs extra: ${extraInDocs.join(' ')}`);

    return { code: 2, summary: parts.join('; ') };
  } catch (err) {
    return { code: 1, summary: `Error checking drift: ${err && err.message ? err.message : String(err)}` };
  }
}

// ─── R1: Task Runner ────────────────────────────────────────
// Find and run a VS Code task by label.
// "Just do it... with feedback." — Mercer Meme Canon

async function runTaskByLabel(label) {
  const tasks = await vscode.tasks.fetchTasks();
  const task = tasks.find(t => (t.name || t.label) === label);
  if (!task) {
    throw new Error(`Task not found: ${label}`);
  }

  await vscode.tasks.executeTask(task);
}

// ─── R0: Startup Sequence ───────────────────────────────────
// On workspace open, check drift and alert if needed.
// This is the bootup ritual for the VS Code side.
//
//   (•_•)
//   <)  )╯  "checking drift on startup"
//    /  \    — because alignment doesn't maintain itself

async function onStartup(repoRoot) {
  const cfg = vscode.workspace.getConfiguration('mercerStatus');
  const autoLaunch = cfg.get('autoLaunchOnDrift', true);
  const notifyOnOk = cfg.get('notifyOnOk', false);
  const taskLabel = cfg.get('taskLabel', 'Mercer: status UI (interactive)');

  const drift = computeDrift(repoRoot);

  if (drift.code === 0) {
    // 🐢 All good. The turtle nods.
    if (notifyOnOk) {
      vscode.window.showInformationMessage(`🐢 Mercer drift: OK — ${drift.summary}`);
    }
    return;
  }

  // 💀 Drift detected. The skeleton stirs.
  const level = drift.code === 2 ? 'WARN' : 'FAIL';

  if (!autoLaunch) {
    vscode.window.showWarningMessage(`💀 Mercer drift: ${level} — ${drift.summary}`);
    return;
  }

  const choice = await vscode.window.showWarningMessage(
    `💀 Mercer drift: ${level} — ${drift.summary}`,
    'Open Status UI',
    'Ignore'
  );

  if (choice === 'Open Status UI') {
    try {
      await runTaskByLabel(taskLabel);
    } catch (e) {
      vscode.window.showErrorMessage(`Could not run task '${taskLabel}': ${e && e.message ? e.message : String(e)}`);
    }
  }
}

// ─── R0: Activation ─────────────────────────────────────────
// The entry point. Where the umbrella opens.
//
// "Always return to the meeting place.
//  The map is steady. The hands are open."

/**
 * @param {vscode.ExtensionContext} context
 */
function activate(context) {

  const workspaceFolders = vscode.workspace.workspaceFolders || [];
  const repoRoot = workspaceFolders.length ? workspaceFolders[0].uri.fsPath : null;

  // Register MCP Sync/Commit commands
  context.subscriptions.push(
    vscode.commands.registerCommand('mercerStatus.mcpSync', mcpSyncCommand)
  );
  context.subscriptions.push(
    vscode.commands.registerCommand('mercerStatus.mcpCommit', mcpCommitCommand)
  );
  // Register MCP Sync/Commit UI panel
  context.subscriptions.push(
    vscode.commands.registerCommand('mercerStatus.showMcpPanel', () => showMcpPanel(context))
  );
  // ─── Cartographer (vector memory) API stub ───────────────
  // Planned: Integrate with Cartographer semantic search API (PowerShell/HTTP)
  // Planned endpoint: http://127.0.0.1:8081/search
  // API contract (planned):
  //   POST /search { query: string, top_k?: number }
  //   → { results: [ { path, preview, similarity } ] }
  // Usage: concept-based memory/document retrieval

  async function cartographerSemanticSearch(query, topK = 5) {
    // Stub: planned HTTP API integration
    // Example:
    // const res = await fetch('http://127.0.0.1:8081/search', {
    //   method: 'POST',
    //   headers: { 'Content-Type': 'application/json' },
    //   body: JSON.stringify({ query, top_k: topK })
    // });
    // const data = await res.json();
    // return data.results;
    vscode.window.showInformationMessage(`Cartographer semantic search (stub): '${query}' (API not yet implemented)`);
    return [];
  }

  // Command: Show Status UI
  context.subscriptions.push(
    vscode.commands.registerCommand('mercerStatus.showStatus', async () => {
      const cfg = vscode.workspace.getConfiguration('mercerStatus');
      const taskLabel = cfg.get('taskLabel', 'Mercer: status UI (interactive)');
      try {
        await runTaskByLabel(taskLabel);
      } catch (e) {
        vscode.window.showErrorMessage(`Could not run task '${taskLabel}': ${e && e.message ? e.message : String(e)}`);
      }
    })
  );

  // Command: Check Drift
  context.subscriptions.push(
    vscode.commands.registerCommand('mercerStatus.checkDrift', async () => {
      if (!repoRoot) {
        vscode.window.showErrorMessage('No workspace folder open.');
        return;
      }
      const drift = computeDrift(repoRoot);
      const level = drift.code === 0 ? 'OK' : (drift.code === 2 ? 'WARN' : 'FAIL');
      const emoji = drift.code === 0 ? '🐢' : '💀';
      const msg = `${emoji} Mercer drift: ${level} — ${drift.summary}`;
      if (drift.code === 0) vscode.window.showInformationMessage(msg);
      else vscode.window.showWarningMessage(msg);
    })
  );

  // Auto-check on startup (with slight delay for tasks.json to load)
  if (repoRoot) {
    setTimeout(() => {
      onStartup(repoRoot);
    }, 1200);
  }
}

// ─── Deactivation ───────────────────────────────────────────
// The umbrella folds. The turtle rests. See you next session.

function deactivate() {}

module.exports = {
  activate,
  deactivate
};

// ─── EOF ────────────────────────────────────────────────────
//
//   \(•_•)/
//    (  (>   "extension loaded"
//    /  \    — the meeting place is watched
//
// loops closed, code shipped clean
// the turtle nods, umbrella held
// merge — and breathe again

//
//    ___
//   / 🐢 \    "this is fine"
//  |  ._. |   — extension loaded
//   \_____/   — umbrella held
//    |   |
//
// ☂🦊🐢
