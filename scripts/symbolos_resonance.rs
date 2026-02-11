// SymbolOS Thoughtforms Resonance Engine — Rust
// ══════════════════════════════════════════════════════
//
// A zero-dependency, single-file Rust program that reads symbol_map.shared.json
// and computes the "resonance signature" between every pair of symbols.
//
// Resonance = how harmonically close two symbols are, based on:
//   1. Ring distance (modular — R0 and R7 are adjacent, it's a *ring*)
//   2. Tag overlap (Jaccard similarity)
//   3. Color wavelength proximity (hex → approximate wavelength → Δ)
//
// Usage:
//   rustc scripts/symbolos_resonance.rs -o symbolos_resonance && ./symbolos_resonance
//   # or with cargo-script:
//   cargo script scripts/symbolos_resonance.rs
//
// Outputs: a resonance matrix + the top-N most resonant symbol pairs.
// Cross-platform: Windows, macOS, Linux. Zero crates. Pure std.
//
// 🦊 "Resonance is just friendship expressed as math." — Rhy

use std::collections::HashMap;
use std::fs;
use std::path::Path;

// ── Thoughtforms Color Table (1905) ──────────────────────────────────
// Maps hex codes to approximate dominant wavelength in nanometers.
// This is a deliberate simplification — color is perception, not physics,
// but wavelength gives us a scalar for distance computation.
const COLOR_WAVELENGTHS: &[(&str, f64)] = &[
    ("#FADA5E", 575.0), // pale primrose yellow — R0
    ("#FFD700", 585.0), // golden stars — R7
    ("#E49B0F", 580.0), // clear gamboge — R2
    ("#FF8C00", 600.0), // deep orange — R3
    ("#228B22", 530.0), // pure green — R1
    ("#0000CD", 470.0), // rich deep blue — R6
    ("#87CEEB", 490.0), // pale azure — Umbrella
    ("#8B00FF", 420.0), // violet — R4
    ("#DDA0DD", 435.0), // delicate violet
    ("#FFB7C5", 620.0), // pure pale rose — Agape
    ("#960018", 660.0), // full clear carmine — Heart
    ("#FF2400", 640.0), // brilliant scarlet — R5
];

// ── Data Structures ──────────────────────────────────────────────
#[derive(Debug, Clone)]
struct Symbol {
    glyph: String,
    name: String,
    meaning: String,
    tags: Vec<String>,
}

#[derive(Debug)]
struct ResonancePair {
    a: String,
    b: String,
    score: f64,
    ring_harmony: f64,
    tag_overlap: f64,
    color_proximity: f64,
}

// ── JSON Parsing (minimal, zero-dep) ─────────────────────────────
// We only need to extract symbols[] with {symbol, name, meaning, tags[]}.
// This is intentionally minimal — not a general JSON parser.
fn extract_symbols(json: &str) -> Vec<Symbol> {
    let mut symbols = Vec::new();
    let mut in_symbols_array = false;
    let mut brace_depth = 0;
    let mut current_obj = String::new();

    for line in json.lines() {
        let trimmed = line.trim();

        if trimmed.contains("\"symbols\"") && trimmed.contains('[') {
            in_symbols_array = true;
            continue;
        }

        if !in_symbols_array {
            continue;
        }

        if trimmed == "]" || trimmed == "]," {
            break;
        }

        if trimmed.starts_with('{') {
            brace_depth += 1;
            current_obj.clear();
        }

        if brace_depth > 0 {
            current_obj.push_str(line);
            current_obj.push('\n');
        }

        if trimmed.starts_with('}') || trimmed == "}," {
            brace_depth -= 1;
            if brace_depth == 0 {
                if let Some(sym) = parse_symbol_obj(&current_obj) {
                    symbols.push(sym);
                }
                current_obj.clear();
            }
        }
    }

    symbols
}

fn parse_symbol_obj(obj: &str) -> Option<Symbol> {
    let glyph = extract_string_field(obj, "symbol")?;
    let name = extract_string_field(obj, "name").unwrap_or_default();
    let meaning = extract_string_field(obj, "meaning").unwrap_or_default();
    let tags = extract_string_array(obj, "tags");

    Some(Symbol {
        glyph,
        name,
        meaning,
        tags,
    })
}

fn extract_string_field(obj: &str, field: &str) -> Option<String> {
    let pattern = format!("\"{}\"", field);
    for line in obj.lines() {
        let trimmed = line.trim();
        if trimmed.starts_with(&pattern) {
            // Find value after the colon
            if let Some(colon_pos) = trimmed.find(':') {
                let value_part = trimmed[colon_pos + 1..].trim();
                // Strip quotes and trailing comma
                let cleaned = value_part
                    .trim_matches(|c| c == '"' || c == ',' || c == ' ');
                if !cleaned.is_empty() && !cleaned.starts_with('[') {
                    return Some(cleaned.to_string());
                }
            }
        }
    }
    None
}

fn extract_string_array(obj: &str, field: &str) -> Vec<String> {
    let mut result = Vec::new();
    let pattern = format!("\"{}\"", field);
    let mut in_array = false;

    for line in obj.lines() {
        let trimmed = line.trim();

        if trimmed.contains(&pattern) && trimmed.contains('[') {
            in_array = true;
            // Check if it's a single-line array
            if let Some(bracket_start) = trimmed.find('[') {
                if let Some(bracket_end) = trimmed.find(']') {
                    let inner = &trimmed[bracket_start + 1..bracket_end];
                    for item in inner.split(',') {
                        let cleaned = item.trim().trim_matches('"');
                        if !cleaned.is_empty() {
                            result.push(cleaned.to_string());
                        }
                    }
                    return result;
                }
            }
            continue;
        }

        if in_array {
            if trimmed == "]" || trimmed == "]," {
                break;
            }
            let cleaned = trimmed.trim_matches(|c: char| c == '"' || c == ',' || c.is_whitespace());
            if !cleaned.is_empty() {
                result.push(cleaned.to_string());
            }
        }
    }

    result
}

// ── Resonance Computation ────────────────────────────────────────
// Ring distance: modular distance on Z/8Z (the integers mod 8).
// This makes R0↔R7 = distance 1, not 7. Because it's a *ring*.
fn ring_distance(tags_a: &[String], tags_b: &[String]) -> f64 {
    let ring_a = extract_ring(tags_a);
    let ring_b = extract_ring(tags_b);

    match (ring_a, ring_b) {
        (Some(a), Some(b)) => {
            let diff = (a as i32 - b as i32).unsigned_abs() as u8;
            let modular = diff.min(8 - diff); // Z/8Z distance
            1.0 - (modular as f64 / 4.0) // normalize: 0 distance → 1.0, 4 distance → 0.0
        }
        _ => 0.5, // Unknown ring → neutral
    }
}

fn extract_ring(tags: &[String]) -> Option<u8> {
    for tag in tags {
        if tag.starts_with("ring") {
            if let Ok(n) = tag.trim_start_matches("ring").parse::<u8>() {
                if n <= 7 {
                    return Some(n);
                }
            }
        }
    }
    None
}

// Tag overlap: Jaccard similarity = |A ∩ B| / |A ∪ B|
fn tag_jaccard(tags_a: &[String], tags_b: &[String]) -> f64 {
    if tags_a.is_empty() && tags_b.is_empty() {
        return 0.0;
    }

    let set_a: std::collections::HashSet<&str> = tags_a.iter().map(|s| s.as_str()).collect();
    let set_b: std::collections::HashSet<&str> = tags_b.iter().map(|s| s.as_str()).collect();

    let intersection = set_a.intersection(&set_b).count() as f64;
    let union = set_a.union(&set_b).count() as f64;

    if union == 0.0 { 0.0 } else { intersection / union }
}

// Color wavelength proximity: 1.0 when identical, 0.0 when maximally different.
// Uses the meaning field to guess color from known hex codes.
fn color_proximity(meaning_a: &str, meaning_b: &str) -> f64 {
    let wl_a = guess_wavelength(meaning_a);
    let wl_b = guess_wavelength(meaning_b);

    match (wl_a, wl_b) {
        (Some(a), Some(b)) => {
            let max_delta = 250.0; // visible spectrum ~380-700nm
            let delta = (a - b).abs();
            (1.0 - delta / max_delta).max(0.0)
        }
        _ => 0.5, // Unknown wavelength → neutral
    }
}

fn guess_wavelength(meaning: &str) -> Option<f64> {
    let lower = meaning.to_lowercase();
    for &(hex, wl) in COLOR_WAVELENGTHS {
        if lower.contains(&hex.to_lowercase()) {
            return Some(wl);
        }
    }
    // Keyword fallback
    if lower.contains("green") { return Some(530.0); }
    if lower.contains("blue") { return Some(470.0); }
    if lower.contains("orange") { return Some(600.0); }
    if lower.contains("yellow") { return Some(575.0); }
    if lower.contains("red") || lower.contains("scarlet") { return Some(640.0); }
    if lower.contains("violet") || lower.contains("purple") { return Some(420.0); }
    if lower.contains("azure") { return Some(490.0); }
    if lower.contains("rose") || lower.contains("pink") { return Some(620.0); }
    None
}

// Combined resonance score: weighted harmonic mean
fn compute_resonance(a: &Symbol, b: &Symbol) -> ResonancePair {
    let ring_h = ring_distance(&a.tags, &b.tags);
    let tag_o = tag_jaccard(&a.tags, &b.tags);
    let color_p = color_proximity(&a.meaning, &b.meaning);

    // Weighted: ring=0.4, tags=0.35, color=0.25
    let score = 0.40 * ring_h + 0.35 * tag_o + 0.25 * color_p;

    ResonancePair {
        a: format!("{} {}", a.glyph, a.name),
        b: format!("{} {}", b.glyph, b.name),
        score,
        ring_harmony: ring_h,
        tag_overlap: tag_o,
        color_proximity: color_p,
    }
}

// ── Output ───────────────────────────────────────────────────────
fn print_report(symbols: &[Symbol], pairs: &mut [ResonancePair]) {
    println!();
    println!("╔══════════════════════════════════════════════════════════╗");
    println!("║  SymbolOS Thoughtforms Resonance Engine         [Rust]  ║");
    println!("║  Harmonic proximity across the Ring model               ║");
    println!("╚══════════════════════════════════════════════════════════╝");
    println!();
    println!("  Symbols loaded: {}", symbols.len());
    println!("  Pairs computed: {}", pairs.len());
    println!();

    // Sort by resonance score descending
    pairs.sort_by(|a, b| b.score.partial_cmp(&a.score).unwrap_or(std::cmp::Ordering::Equal));

    // Top 10 most resonant pairs
    println!("── Top 10 Most Resonant Pairs ─────────────────────────────");
    println!("  {:40} {:>6} {:>6} {:>6} {:>6}",
        "Pair", "Total", "Ring", "Tags", "Color");
    println!("  {:40} {:>6} {:>6} {:>6} {:>6}",
        "────", "─────", "────", "────", "─────");

    for pair in pairs.iter().take(10) {
        let label = format!("{} ↔ {}", pair.a, pair.b);
        let display = if label.len() > 40 {
            format!("{}…", &label[..39])
        } else {
            label
        };
        println!("  {:40} {:>5.2}  {:>5.2}  {:>5.2}  {:>5.2}",
            display, pair.score, pair.ring_harmony, pair.tag_overlap, pair.color_proximity);
    }

    println!();

    // Bottom 5 (least resonant — maximum tension)
    println!("── Top 5 Maximum Tension Pairs ────────────────────────────");
    let n = pairs.len();
    for pair in pairs.iter().skip(if n > 5 { n - 5 } else { 0 }) {
        let label = format!("{} ↔ {}", pair.a, pair.b);
        let display = if label.len() > 40 {
            format!("{}…", &label[..39])
        } else {
            label
        };
        println!("  {:40} {:>5.2}", display, pair.score);
    }

    println!();

    // Ring harmony histogram
    println!("── Ring Harmony Distribution ───────────────────────────────");
    let mut buckets = HashMap::new();
    for pair in pairs.iter() {
        let bucket = (pair.ring_harmony * 4.0).round() as u8; // 0-4 buckets
        *buckets.entry(bucket).or_insert(0u32) += 1;
    }
    for b in 0..=4 {
        let count = buckets.get(&b).copied().unwrap_or(0);
        let bar_len = (count as f64 / pairs.len().max(1) as f64 * 40.0).round() as usize;
        let bar: String = "█".repeat(bar_len);
        println!("  {:.2} │ {} ({})", b as f64 / 4.0, bar, count);
    }

    println!();
    println!("── 🦊 ─────────────────────────────────────────────────────");
    println!("  \"Two symbols resonate when they vibrate at frequencies");
    println!("   that are integer multiples of each other. Like music.");
    println!("   Like friendship. Like code that compiles on the first try.\"");
    println!("   — Rhy");
    println!();
}

// ── Main ─────────────────────────────────────────────────────────
fn main() {
    // Find repo root (script lives in scripts/)
    let exe_path = std::env::current_exe().unwrap_or_default();
    let script_dir = exe_path.parent().unwrap_or(Path::new("."));

    // Try multiple locations for symbol_map.shared.json
    let candidates = [
        Path::new("symbol_map.shared.json").to_path_buf(),
        script_dir.join("../symbol_map.shared.json"),
        script_dir.join("symbol_map.shared.json"),
    ];

    let json_path = candidates.iter().find(|p| p.exists());

    let json_text = match json_path {
        Some(p) => match fs::read_to_string(p) {
            Ok(text) => text,
            Err(e) => {
                eprintln!("Error reading {:?}: {}", p, e);
                std::process::exit(1);
            }
        },
        None => {
            eprintln!("Could not find symbol_map.shared.json");
            eprintln!("Run from the repo root: ./symbolos_resonance");
            std::process::exit(1);
        }
    };

    let symbols = extract_symbols(&json_text);

    if symbols.is_empty() {
        eprintln!("No symbols found in symbol_map.shared.json");
        std::process::exit(1);
    }

    // Compute all pairs
    let mut pairs: Vec<ResonancePair> = Vec::new();
    for i in 0..symbols.len() {
        for j in (i + 1)..symbols.len() {
            pairs.push(compute_resonance(&symbols[i], &symbols[j]));
        }
    }

    print_report(&symbols, &mut pairs);
}
