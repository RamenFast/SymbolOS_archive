#!/usr/bin/env -S npx tsx
/**
 * SymbolOS Ring Validator — Cross-platform TypeScript CLI
 * Validates ring model integrity across documentation and symbol map.
 *
 * Usage:
 *   npx tsx scripts/symbolos_ring_validator.ts          # Full validation
 *   npx tsx scripts/symbolos_ring_validator.ts --quiet   # Exit code only
 *   deno run --allow-read scripts/symbolos_ring_validator.ts
 *   bun run scripts/symbolos_ring_validator.ts
 *
 * Runs on: Windows, macOS, Linux (Node 18+, Deno, or Bun — zero npm deps)
 */

import { readFileSync, readdirSync, existsSync, statSync } from "fs";
import { join, resolve, dirname } from "path";
import { fileURLToPath } from "url";

// ── Types ────────────────────────────────────────────────────

interface RingDef {
  id: number;
  glyph: string;
  label: string;
  description: string;
}

interface Symbol {
  glyph: string;
  label: string;
  ring?: number;
  [key: string]: unknown;
}

interface ValidationResult {
  check: string;
  status: "PASS" | "WARN" | "FAIL";
  details: string[];
}

// ── Constants ────────────────────────────────────────────────

const RING_MODEL: RingDef[] = [
  { id: 0, glyph: "⚓", label: "Kernel", description: "Identity / grounding" },
  { id: 1, glyph: "🧭", label: "Task", description: "Orchestration" },
  { id: 2, glyph: "🪞", label: "Retrieval", description: "Memory access" },
  { id: 3, glyph: "🌀", label: "Prediction", description: "Precog / PreEmotion" },
  { id: 4, glyph: "🧩", label: "Architecture", description: "Design / structure" },
  { id: 5, glyph: "☂️", label: "Guardrails", description: "Safety / privacy" },
  { id: 6, glyph: "🧪", label: "Verification", description: "Testing / proof" },
  { id: 7, glyph: "🗃️", label: "Persistence", description: "Logging / storage" },
];

const SCRIPT_DIR = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(SCRIPT_DIR, "..");

// ── Helpers ──────────────────────────────────────────────────

function readJSON(path: string): unknown {
  const text = readFileSync(path, "utf-8");
  return JSON.parse(text);
}

function readText(path: string): string {
  return readFileSync(path, "utf-8");
}

function findFiles(dir: string, ext: string): string[] {
  const results: string[] = [];
  if (!existsSync(dir)) return results;
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    const full = join(dir, entry.name);
    if (entry.isDirectory()) {
      results.push(...findFiles(full, ext));
    } else if (entry.name.endsWith(ext)) {
      results.push(full);
    }
  }
  return results;
}

// ── Validators ───────────────────────────────────────────────

function validateRingCompleteness(symbols: Symbol[]): ValidationResult {
  const result: ValidationResult = {
    check: "Ring Model Completeness (R0–R7)",
    status: "PASS",
    details: [],
  };

  const ringsPresent = new Set(
    symbols.filter((s) => s.ring !== undefined).map((s) => s.ring!)
  );

  for (const ring of RING_MODEL) {
    if (ringsPresent.has(ring.id)) {
      result.details.push(`  ✅ R${ring.id} ${ring.glyph} ${ring.label}`);
    } else {
      result.details.push(`  ❌ R${ring.id} ${ring.glyph} ${ring.label} — no symbol assigned`);
      result.status = "WARN";
    }
  }

  return result;
}

function validateRingBounds(symbols: Symbol[]): ValidationResult {
  const result: ValidationResult = {
    check: "Ring Value Bounds",
    status: "PASS",
    details: [],
  };

  for (const sym of symbols) {
    if (sym.ring !== undefined) {
      if (typeof sym.ring !== "number" || sym.ring < 0 || sym.ring > 7) {
        result.details.push(
          `  ❌ ${sym.glyph} "${sym.label}" has invalid ring: ${sym.ring} (must be 0–7)`
        );
        result.status = "FAIL";
      }
    }
  }

  if (result.details.length === 0) {
    result.details.push("  ✅ All ring values in valid range [0, 7]");
  }

  return result;
}

function validateSymbolUniqueness(symbols: Symbol[]): ValidationResult {
  const result: ValidationResult = {
    check: "Symbol Uniqueness",
    status: "PASS",
    details: [],
  };

  const seen = new Map<string, number>();
  for (const sym of symbols) {
    const count = (seen.get(sym.glyph) ?? 0) + 1;
    seen.set(sym.glyph, count);
  }

  for (const [glyph, count] of seen) {
    if (count > 1) {
      result.details.push(`  ❌ Duplicate glyph: ${glyph} (appears ${count}×)`);
      result.status = "WARN";
    }
  }

  if (result.details.length === 0) {
    result.details.push(`  ✅ All ${symbols.length} symbols are unique`);
  }

  return result;
}

function validateRingReferencesInDocs(): ValidationResult {
  const result: ValidationResult = {
    check: "Ring References in Documentation",
    status: "PASS",
    details: [],
  };

  const docsDir = join(REPO_ROOT, "docs");
  const mdFiles = findFiles(docsDir, ".md");
  const ringPattern = /\bR[0-7]\b|Ring\s*[0-7]/gi;

  let totalRefs = 0;
  const ringRefCounts = new Map<number, number>();

  for (const file of mdFiles) {
    const text = readText(file);
    const matches = text.matchAll(ringPattern);
    for (const match of matches) {
      totalRefs++;
      const num = parseInt(match[0].replace(/\D/g, ""), 10);
      if (num >= 0 && num <= 7) {
        ringRefCounts.set(num, (ringRefCounts.get(num) ?? 0) + 1);
      }
    }
  }

  result.details.push(`  Total ring references across ${mdFiles.length} docs: ${totalRefs}`);
  for (const ring of RING_MODEL) {
    const count = ringRefCounts.get(ring.id) ?? 0;
    const icon = count > 0 ? "✅" : "⚠️";
    result.details.push(`  ${icon} R${ring.id} ${ring.glyph} — ${count} references`);
    if (count === 0) result.status = "WARN";
  }

  return result;
}

function validateSchemaRingFields(): ValidationResult {
  const result: ValidationResult = {
    check: "Schema Ring Field Consistency",
    status: "PASS",
    details: [],
  };

  const docsDir = join(REPO_ROOT, "docs");
  const schemaFiles = findFiles(docsDir, ".schema.json");

  for (const file of schemaFiles) {
    const relPath = file.replace(REPO_ROOT + (process.platform === "win32" ? "\\" : "/"), "");
    try {
      const schema = readJSON(file) as Record<string, unknown>;
      const props = (schema.properties ?? {}) as Record<string, unknown>;

      // Check if schema has a ring/dnd/privacy field pattern
      const hasRing = "ring" in props || "dnd" in props;
      const hasPrivacy = "privacy" in props;

      if (hasRing || hasPrivacy) {
        result.details.push(`  ✅ ${relPath} — ring/privacy fields present`);
      } else {
        result.details.push(`  ℹ️  ${relPath} — no ring/privacy fields (may be intentional)`);
      }
    } catch {
      result.details.push(`  ❌ ${relPath} — failed to parse`);
      result.status = "WARN";
    }
  }

  return result;
}

// ── Report ───────────────────────────────────────────────────

function runAllValidations(): ValidationResult[] {
  const results: ValidationResult[] = [];

  // Load symbol map
  const smPath = join(REPO_ROOT, "symbol_map.shared.json");
  if (!existsSync(smPath)) {
    results.push({
      check: "Symbol Map",
      status: "FAIL",
      details: ["  ❌ symbol_map.shared.json not found"],
    });
    return results;
  }

  const data = readJSON(smPath) as { symbols?: Symbol[]; schemaVersion?: string };
  const symbols = data.symbols ?? [];

  results.push(validateRingCompleteness(symbols));
  results.push(validateRingBounds(symbols));
  results.push(validateSymbolUniqueness(symbols));
  results.push(validateRingReferencesInDocs());
  results.push(validateSchemaRingFields());

  return results;
}

function printReport(results: ValidationResult[], quiet: boolean): number {
  if (!quiet) {
    console.log("");
    console.log("╔══════════════════════════════════════════════════════════╗");
    console.log("║  SymbolOS Ring Validator                                ║");
    console.log("║  Ring Model Integrity Check (R0–R7)                    ║");
    console.log("╚══════════════════════════════════════════════════════════╝");
    console.log("");
  }

  let hasWarn = false;
  let hasFail = false;

  for (const r of results) {
    if (r.status === "WARN") hasWarn = true;
    if (r.status === "FAIL") hasFail = true;

    if (!quiet) {
      const icon = { PASS: "✅", WARN: "⚠️", FAIL: "❌" }[r.status];
      console.log(`── ${r.check} ${icon} ──`);
      for (const d of r.details) {
        console.log(d);
      }
      console.log("");
    }
  }

  const overall = hasFail ? "FAIL" : hasWarn ? "WARN" : "PASS";
  const exitCode = hasFail ? 1 : hasWarn ? 2 : 0;

  if (!quiet) {
    const icon = { PASS: "✅", WARN: "⚠️", FAIL: "❌" }[overall];
    console.log(`── Overall: ${icon} ${overall} ──`);
    console.log("");
    console.log('  🦊 "Validation measures the structure. But structure is just');
    console.log('       rhythm made visible." — Rhy');
    console.log("");
  }

  return exitCode;
}

// ── Main ─────────────────────────────────────────────────────

const quiet = process.argv.includes("--quiet");
const results = runAllValidations();
const exitCode = printReport(results, quiet);
process.exit(exitCode);
