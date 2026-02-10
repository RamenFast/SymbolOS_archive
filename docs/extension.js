const vscode = require('vscode');
const fs = require('fs');
const path = require('path');

function getConfig() {
  return vscode.workspace.getConfiguration('mercerStatus');
}

function makeLogger(outputChannel) {
  return {
    debug: (msg) => {
      const cfg = getConfig();
      const devMode = cfg.get('devMode', false);
      if (!devMode) return;
      outputChannel.appendLine(`[mercer-status] ${msg}`);
    }
  };
}

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

function computeDrift(repoRoot, logger) {
  const sharedMapPath = path.join(repoRoot, 'symbol_map.shared.json');
  const humanMapPath = path.join(repoRoot, 'docs', 'symbol_map.md');

  logger && logger.debug(`repoRoot: ${repoRoot}`);
  logger && logger.debug(`sharedMapPath: ${sharedMapPath}`);
  logger && logger.debug(`humanMapPath: ${humanMapPath}`);

  if (!fs.existsSync(sharedMapPath)) {
    return { code: 1, summary: 'Missing symbol_map.shared.json' };
  }
  if (!fs.existsSync(humanMapPath)) {
    return { code: 1, summary: 'Missing docs/symbol_map.md' };
  }

  try {
    const shared = JSON.parse(readUtf8(sharedMapPath));
    const sharedSymbols = parseSharedSymbols(shared);

    logger && logger.debug(`sharedSymbols: ${[...sharedSymbols].join(' ')}`);

    const humanMd = readUtf8(humanMapPath);
    const coreSymbols = parseCoreSymbolsFromHumanMap(humanMd);

    logger && logger.debug(`coreSymbols: ${[...coreSymbols].join(' ')}`);

    const missingInDocs = [...sharedSymbols].filter(s => !coreSymbols.has(s)).sort();
    const extraInDocs = [...coreSymbols].filter(s => !sharedSymbols.has(s)).sort();

    if (missingInDocs.length) logger && logger.debug(`missingInDocs: ${missingInDocs.join(' ')}`);
    if (extraInDocs.length) logger && logger.debug(`extraInDocs: ${extraInDocs.join(' ')}`);

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

async function onStartup(repoRoot, outputChannel) {
  const cfg = getConfig();
  const devMode = cfg.get('devMode', false);
  const autoLaunch = cfg.get('autoLaunchOnDrift', true);
  const notifyOnOk = cfg.get('notifyOnOk', false);
  const taskLabel = cfg.get('taskLabel', 'Mercer: status UI (interactive)');

  const logger = makeLogger(outputChannel);
  logger.debug(`startup devMode=${devMode} autoLaunchOnDrift=${autoLaunch} notifyOnOk=${notifyOnOk} taskLabel='${taskLabel}'`);

  const drift = computeDrift(repoRoot, logger);

  if (drift.code === 0) {
    if (devMode) {
      outputChannel.show(true);
      logger.debug(`startup drift=OK summary='${drift.summary}'`);
      vscode.window.showInformationMessage(`Mercer drift: OK - ${drift.summary}`);
      return;
    }
    if (notifyOnOk) {
      vscode.window.showInformationMessage(`Mercer drift: OK - ${drift.summary}`);
    }
    return;
  }

  const level = drift.code === 2 ? 'WARN' : 'FAIL';

  if (!autoLaunch) {
    if (devMode) outputChannel.show(true);
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

  const outputChannel = vscode.window.createOutputChannel('Mercer Status');
  context.subscriptions.push(outputChannel);
  const logger = makeLogger(outputChannel);

  context.subscriptions.push(
    vscode.commands.registerCommand('mercerStatus.showStatus', async () => {
      const cfg = getConfig();
      const devMode = cfg.get('devMode', false);
      const taskLabel = cfg.get('taskLabel', 'Mercer: status UI (interactive)');
      if (devMode) {
        outputChannel.show(true);
        logger.debug(`showStatus taskLabel='${taskLabel}'`);
      }
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
      const cfg = getConfig();
      const devMode = cfg.get('devMode', false);
      if (devMode) {
        outputChannel.show(true);
        logger.debug('checkDrift invoked');
      }
      const drift = computeDrift(repoRoot, logger);
      const level = drift.code === 0 ? 'OK' : (drift.code === 2 ? 'WARN' : 'FAIL');
      const msg = `Mercer drift: ${level} - ${drift.summary}`;
      if (drift.code === 0) vscode.window.showInformationMessage(msg);
      else vscode.window.showWarningMessage(msg);
    })
  );

  if (repoRoot) {
    // Delay slightly so tasks.json is loaded.
    setTimeout(() => {
      onStartup(repoRoot, outputChannel);
    }, 1200);
  }
}

function deactivate() {}

module.exports = {
  activate,
  deactivate
};
