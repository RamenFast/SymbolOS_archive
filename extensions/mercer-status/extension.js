const vscode = require('vscode');
const fs = require('fs');
const path = require('path');

function readUtf8(filePath) {
  return fs.readFileSync(filePath, { encoding: 'utf8' });
}

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

function parseCoreSymbolsFromHumanMap(mdText) {
  const idx = mdText.toLowerCase().indexOf('## core symbols');
  if (idx < 0) return new Set();

  const after = mdText.slice(idx);
  // Find end of the Core section: next markdown heading that starts a new section.
  // We look for the next line that begins with "## " after the first line.
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

function computeDrift(repoRoot) {
  const sharedMapPath = path.join(repoRoot, 'symbol_map.shared.json');
  const humanMapPath = path.join(repoRoot, 'docs', 'symbol_map.md');

  if (!fs.existsSync(sharedMapPath)) {
    return { code: 1, summary: 'Missing symbol_map.shared.json' };
  }
  if (!fs.existsSync(humanMapPath)) {
    return { code: 1, summary: 'Missing docs/symbol_map.md' };
  }

  try {
    const shared = JSON.parse(readUtf8(sharedMapPath));
    const sharedSymbols = parseSharedSymbols(shared);

    const humanMd = readUtf8(humanMapPath);
    const coreSymbols = parseCoreSymbolsFromHumanMap(humanMd);

    const missingInDocs = [...sharedSymbols].filter(s => !coreSymbols.has(s)).sort();
    const extraInDocs = [...coreSymbols].filter(s => !sharedSymbols.has(s)).sort();

    if (missingInDocs.length === 0 && extraInDocs.length === 0) {
      return { code: 0, summary: 'Core symbols aligned' };
    }

    const parts = [];
    if (missingInDocs.length) parts.push(`docs missing: ${missingInDocs.join(' ')}`);
    if (extraInDocs.length) parts.push(`docs extra: ${extraInDocs.join(' ')}`);

    return { code: 2, summary: parts.join('; ') };
  } catch (err) {
    return { code: 1, summary: `Error checking drift: ${err && err.message ? err.message : String(err)}` };
  }
}

async function runTaskByLabel(label) {
  const tasks = await vscode.tasks.fetchTasks();
  const task = tasks.find(t => (t.name || t.label) === label);
  if (!task) {
    throw new Error(`Task not found: ${label}`);
  }

  await vscode.tasks.executeTask(task);
}

async function onStartup(repoRoot) {
  const cfg = vscode.workspace.getConfiguration('mercerStatus');
  const autoLaunch = cfg.get('autoLaunchOnDrift', true);
  const notifyOnOk = cfg.get('notifyOnOk', false);
  const taskLabel = cfg.get('taskLabel', 'Mercer: status UI (interactive)');

  const drift = computeDrift(repoRoot);

  if (drift.code === 0) {
    if (notifyOnOk) {
      vscode.window.showInformationMessage(`Mercer drift: OK - ${drift.summary}`);
    }
    return;
  }

  const level = drift.code === 2 ? 'WARN' : 'FAIL';

  if (!autoLaunch) {
    vscode.window.showWarningMessage(`Mercer drift: ${level} - ${drift.summary}`);
    return;
  }

  const choice = await vscode.window.showWarningMessage(
    `Mercer drift: ${level} - ${drift.summary}`,
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

/**
 * @param {vscode.ExtensionContext} context
 */
function activate(context) {
  const workspaceFolders = vscode.workspace.workspaceFolders || [];
  const repoRoot = workspaceFolders.length ? workspaceFolders[0].uri.fsPath : null;

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

  context.subscriptions.push(
    vscode.commands.registerCommand('mercerStatus.checkDrift', async () => {
      if (!repoRoot) {
        vscode.window.showErrorMessage('No workspace folder open.');
        return;
      }
      const drift = computeDrift(repoRoot);
      const level = drift.code === 0 ? 'OK' : (drift.code === 2 ? 'WARN' : 'FAIL');
      const msg = `Mercer drift: ${level} - ${drift.summary}`;
      if (drift.code === 0) vscode.window.showInformationMessage(msg);
      else vscode.window.showWarningMessage(msg);
    })
  );

  if (repoRoot) {
    // Delay slightly so tasks.json is loaded.
    setTimeout(() => {
      onStartup(repoRoot);
    }, 1200);
  }
}

function deactivate() {}

module.exports = {
  activate,
  deactivate
};
