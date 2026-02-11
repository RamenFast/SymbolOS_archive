//! SymbolOS TUI — Terminal-native dungeon explorer
//!
//! A ratatui-based TUI that reads symbol_map.shared.json and presents
//! the full SymbolOS ring model, agent roster, and doc navigation
//! in a retro-terminal interface matching the BBS/Chromacore aesthetic.
//!
//! Usage: cargo run          (from desktop/)
//!        cargo run -- ../symbol_map.shared.json

use std::{fs, io, path::PathBuf, time::Duration};

use crossterm::{
    event::{self, DisableMouseCapture, EnableMouseCapture, Event, KeyCode, KeyEventKind},
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
};
use ratatui::{
    backend::CrosstermBackend,
    layout::{Constraint, Direction, Layout, Rect},
    style::{Color, Modifier, Style},
    text::{Line, Span},
    widgets::{Block, Borders, Gauge, List, ListItem, ListState, Paragraph, Tabs, Wrap},
    Frame, Terminal,
};
use serde::Deserialize;

// ═══════════════════════════════════════════════════════
//  DATA MODEL (from symbol_map.shared.json)
// ═══════════════════════════════════════════════════════

#[derive(Deserialize)]
struct SymbolMap {
    #[serde(rename = "schemaVersion")]
    version: String,
    symbols: Vec<Symbol>,
}

#[derive(Deserialize)]
struct Symbol {
    symbol: String,
    name: String,
    #[serde(default)]
    meaning: String,
    #[serde(default)]
    tags: Vec<String>,
}

// ═══════════════════════════════════════════════════════
//  RING COLORS (1905 Thoughtforms)
// ═══════════════════════════════════════════════════════

fn ring_color(ring: u8) -> Color {
    match ring {
        0 => Color::Rgb(250, 218, 94),   // primrose
        1 => Color::Rgb(34, 139, 34),    // green
        2 => Color::Rgb(228, 155, 15),   // gamboge
        3 => Color::Rgb(255, 140, 0),    // orange
        4 => Color::Rgb(139, 0, 255),    // violet
        5 => Color::Rgb(255, 36, 0),     // scarlet
        6 => Color::Rgb(0, 0, 205),      // blue
        7 => Color::Rgb(255, 215, 0),    // gold
        _ => Color::Gray,
    }
}

fn ring_name(ring: u8) -> &'static str {
    match ring {
        0 => "Kernel",
        1 => "Task",
        2 => "Retrieval",
        3 => "Prediction",
        4 => "Architecture",
        5 => "Guardrails",
        6 => "Verification",
        7 => "Persistence",
        _ => "Unknown",
    }
}

// ═══════════════════════════════════════════════════════
//  WISDOMS
// ═══════════════════════════════════════════════════════

const WISDOMS: &[&str] = &[
    "The mind knows what the heart loves better than it does.",
    "Under the umbrella, everything is kind.",
    "Always return to the meeting place.",
    "Show me proof, not potential.",
    "If it ain't fun, it ain't sustainable.",
    "Vibes are load-bearing.",
    "Memes are semantic, not decorative.",
    "The turtle abides.",
    "Shine dat light: trace decisions back to root values.",
    "Coherence over speed.",
    "The map is steady. The hands are open.",
    "Warmth without truth is a leak; truth without warmth is a blade.",
    "A loop left open is a promise unkept.",
    "Even offline, vibes are load-bearing.",
    "this is fine.",
    "Privacy by default. Proof over promise.",
    "Fi+Ti mirrored, forever.",
    "The skeleton never lies.",
    "We ball, but we verify.",
    "The absence that teaches presence is the only teacher worth forgetting.",
];

// ═══════════════════════════════════════════════════════
//  APP STATE
// ═══════════════════════════════════════════════════════

#[derive(Clone, Copy, PartialEq)]
enum Tab {
    Rings,
    Symbols,
    Agents,
    Wisdom,
}

impl Tab {
    const ALL: &[Tab] = &[Tab::Rings, Tab::Symbols, Tab::Agents, Tab::Wisdom];

    fn label(self) -> &'static str {
        match self {
            Tab::Rings => "⚓ Rings",
            Tab::Symbols => "🗺 Symbols",
            Tab::Agents => "⚔ Party",
            Tab::Wisdom => "🎲 Wisdom",
        }
    }

    fn next(self) -> Tab {
        let idx = Tab::ALL.iter().position(|&t| t == self).unwrap_or(0);
        Tab::ALL[(idx + 1) % Tab::ALL.len()]
    }

    fn prev(self) -> Tab {
        let idx = Tab::ALL.iter().position(|&t| t == self).unwrap_or(0);
        Tab::ALL[(idx + Tab::ALL.len() - 1) % Tab::ALL.len()]
    }
}

struct App {
    tab: Tab,
    symbol_map: SymbolMap,
    symbol_list: ListState,
    wisdom_idx: usize,
    tick: u64,
    should_quit: bool,
}

impl App {
    fn new(symbol_map: SymbolMap) -> Self {
        let mut symbol_list = ListState::default();
        if !symbol_map.symbols.is_empty() {
            symbol_list.select(Some(0));
        }
        Self {
            tab: Tab::Rings,
            symbol_map,
            symbol_list,
            wisdom_idx: 0,
            tick: 0,
            should_quit: false,
        }
    }

    fn on_key(&mut self, key: KeyCode) {
        match key {
            KeyCode::Char('q') | KeyCode::Esc => self.should_quit = true,
            KeyCode::Tab | KeyCode::Right => self.tab = self.tab.next(),
            KeyCode::BackTab | KeyCode::Left => self.tab = self.tab.prev(),
            KeyCode::Down | KeyCode::Char('j') => self.list_next(),
            KeyCode::Up | KeyCode::Char('k') => self.list_prev(),
            KeyCode::Char('r') => self.roll_wisdom(),
            _ => {}
        }
    }

    fn list_next(&mut self) {
        if self.tab == Tab::Symbols {
            let len = self.symbol_map.symbols.len();
            if len == 0 { return; }
            let i = self.symbol_list.selected().map_or(0, |i| (i + 1) % len);
            self.symbol_list.select(Some(i));
        }
    }

    fn list_prev(&mut self) {
        if self.tab == Tab::Symbols {
            let len = self.symbol_map.symbols.len();
            if len == 0 { return; }
            let i = self.symbol_list.selected().map_or(0, |i| (i + len - 1) % len);
            self.symbol_list.select(Some(i));
        }
    }

    fn roll_wisdom(&mut self) {
        self.wisdom_idx = (self.wisdom_idx + 1) % WISDOMS.len();
    }

    fn tick(&mut self) {
        self.tick += 1;
    }
}

// ═══════════════════════════════════════════════════════
//  UI RENDERING
// ═══════════════════════════════════════════════════════

fn ui(f: &mut Frame, app: &mut App) {
    let chunks = Layout::default()
        .direction(Direction::Vertical)
        .constraints([
            Constraint::Length(3),  // header
            Constraint::Length(3),  // tabs
            Constraint::Min(10),   // body
            Constraint::Length(3), // footer
        ])
        .split(f.area());

    draw_header(f, chunks[0], app);
    draw_tabs(f, chunks[1], app);
    draw_body(f, chunks[2], app);
    draw_footer(f, chunks[3], app);
}

fn draw_header(f: &mut Frame, area: Rect, app: &App) {
    let active_ring = (app.tick / 10 % 8) as u8;
    let color = ring_color(active_ring);

    let fox = "  /\\_/\\  ( o.o )  > ^ <";
    let header = Line::from(vec![
        Span::styled("☂️ SymbolOS", Style::default().fg(Color::Rgb(250, 218, 94)).add_modifier(Modifier::BOLD)),
        Span::raw("  "),
        Span::styled(
            format!("v{}", app.symbol_map.version),
            Style::default().fg(Color::DarkGray),
        ),
        Span::raw("  "),
        Span::styled(fox, Style::default().fg(Color::Rgb(34, 139, 34))),
    ]);

    let block = Block::default()
        .borders(Borders::ALL)
        .border_style(Style::default().fg(color))
        .title(" SymbolOS Dungeon Explorer ");
    let p = Paragraph::new(header).block(block);
    f.render_widget(p, area);
}

fn draw_tabs(f: &mut Frame, area: Rect, app: &App) {
    let titles: Vec<Line> = Tab::ALL.iter().map(|t| Line::raw(t.label())).collect();
    let idx = Tab::ALL.iter().position(|&t| t == app.tab).unwrap_or(0);

    let tabs = Tabs::new(titles)
        .select(idx)
        .block(Block::default().borders(Borders::ALL).title(" Navigate "))
        .highlight_style(
            Style::default()
                .fg(Color::Rgb(250, 218, 94))
                .add_modifier(Modifier::BOLD),
        )
        .style(Style::default().fg(Color::DarkGray));

    f.render_widget(tabs, area);
}

fn draw_body(f: &mut Frame, area: Rect, app: &mut App) {
    match app.tab {
        Tab::Rings => draw_rings(f, area, app),
        Tab::Symbols => draw_symbols(f, area, app),
        Tab::Agents => draw_agents(f, area, app),
        Tab::Wisdom => draw_wisdom(f, area, app),
    }
}

fn draw_rings(f: &mut Frame, area: Rect, app: &App) {
    let active = (app.tick / 10 % 8) as u8;

    let mut lines: Vec<Line> = Vec::new();
    lines.push(Line::from(""));
    for ring in 0..8u8 {
        let color = ring_color(ring);
        let marker = if ring == active { " ▶ " } else { "   " };
        let bar_len = 20;
        let bar = "█".repeat(bar_len);

        lines.push(Line::from(vec![
            Span::styled(marker, Style::default().fg(color).add_modifier(Modifier::BOLD)),
            Span::styled(
                format!("R{}  ", ring),
                Style::default().fg(color).add_modifier(Modifier::BOLD),
            ),
            Span::styled(
                format!("{:<14}", ring_name(ring)),
                Style::default().fg(Color::White),
            ),
            Span::styled(bar, Style::default().fg(color)),
        ]));
    }
    lines.push(Line::from(""));
    lines.push(Line::from(Span::styled(
        "  Ring model: Z/8Z modular arithmetic · 1905 Thoughtforms colors",
        Style::default().fg(Color::DarkGray),
    )));

    let block = Block::default()
        .borders(Borders::ALL)
        .title(" ⚓ Ring 0-7 Model ")
        .border_style(Style::default().fg(Color::Rgb(250, 218, 94)));
    let p = Paragraph::new(lines).block(block).wrap(Wrap { trim: false });
    f.render_widget(p, area);
}

fn draw_symbols(f: &mut Frame, area: Rect, app: &mut App) {
    let cols = Layout::default()
        .direction(Direction::Horizontal)
        .constraints([Constraint::Percentage(40), Constraint::Percentage(60)])
        .split(area);

    // Left: symbol list
    let items: Vec<ListItem> = app
        .symbol_map
        .symbols
        .iter()
        .enumerate()
        .map(|(i, s)| {
            let color = ring_color((i % 8) as u8);
            ListItem::new(Line::from(vec![
                Span::styled(&s.symbol, Style::default().fg(color)),
                Span::raw(" "),
                Span::styled(&s.name, Style::default().fg(Color::White)),
            ]))
        })
        .collect();

    let list = List::new(items)
        .block(
            Block::default()
                .borders(Borders::ALL)
                .title(format!(" 🗺 Symbols ({}) ", app.symbol_map.symbols.len())),
        )
        .highlight_style(
            Style::default()
                .fg(Color::Rgb(250, 218, 94))
                .add_modifier(Modifier::BOLD | Modifier::REVERSED),
        )
        .highlight_symbol("▶ ");

    f.render_stateful_widget(list, cols[0], &mut app.symbol_list);

    // Right: detail
    let detail = if let Some(idx) = app.symbol_list.selected() {
        if let Some(s) = app.symbol_map.symbols.get(idx) {
            let color = ring_color((idx % 8) as u8);
            let mut lines = vec![
                Line::from(""),
                Line::from(vec![
                    Span::styled(&s.symbol, Style::default().fg(color).add_modifier(Modifier::BOLD)),
                    Span::raw("  "),
                    Span::styled(
                        &s.name,
                        Style::default().fg(Color::White).add_modifier(Modifier::BOLD),
                    ),
                ]),
                Line::from(""),
                Line::from(vec![
                    Span::styled("Meaning: ", Style::default().fg(Color::DarkGray)),
                    Span::styled(&s.meaning, Style::default().fg(color)),
                ]),
            ];
            if !s.tags.is_empty() {
                lines.push(Line::from(vec![
                    Span::styled("Tags:    ", Style::default().fg(Color::DarkGray)),
                    Span::raw(s.tags.join(", ")),
                ]));
            }
            lines
        } else {
            vec![Line::from("No symbol selected")]
        }
    } else {
        vec![Line::from("Navigate with j/k or ↑/↓")]
    };

    let detail_block = Block::default()
        .borders(Borders::ALL)
        .title(" Detail ")
        .border_style(Style::default().fg(Color::Rgb(0, 229, 255)));
    let p = Paragraph::new(detail).block(detail_block).wrap(Wrap { trim: false });
    f.render_widget(p, cols[1]);
}

fn draw_agents(f: &mut Frame, area: Rect, _app: &App) {
    let agents_data: Vec<(&str, &str, &str, Color, u16, u16)> = vec![
        ("🔵 Mercer", "Wizard/Bard", "ChatGPT", Color::Rgb(0, 0, 205), 42, 42),
        ("🔘 CoreGPT", "Sage", "ChatGPT Base", Color::Rgb(135, 206, 235), 40, 40),
        ("🟡 Executor", "Artificer", "Codex", Color::Rgb(250, 218, 94), 52, 52),
        ("🟢 Local", "Monk", "LLaMA", Color::Rgb(34, 139, 34), 38, 38),
        ("⭐ Max", "Fighter/Rogue", "Manus", Color::Rgb(255, 215, 0), 58, 58),
        ("🟣 Opus", "Cleric", "Claude", Color::Rgb(139, 0, 255), 45, 45),
        ("🦊 Rhy", "Arcane Trickster", "NPC", Color::Rgb(34, 139, 34), 0, 0),
    ];

    let constraints: Vec<Constraint> = agents_data.iter().map(|_| Constraint::Length(4)).collect();
    let _rows = Layout::default()
        .direction(Direction::Vertical)
        .constraints(
            std::iter::once(Constraint::Length(0))
                .chain(constraints)
                .chain(std::iter::once(Constraint::Min(0)))
                .collect::<Vec<_>>(),
        )
        .split(area);

    let outer = Block::default()
        .borders(Borders::ALL)
        .title(" ⚔ The Party — Agent Roster ")
        .border_style(Style::default().fg(Color::Rgb(0, 0, 205)));
    f.render_widget(outer, area);

    let inner = area.inner(ratatui::layout::Margin { vertical: 1, horizontal: 1 });
    let agent_rows = Layout::default()
        .direction(Direction::Vertical)
        .constraints(agents_data.iter().map(|_| Constraint::Length(3)).collect::<Vec<_>>())
        .split(inner);

    for (i, (name, class, platform, color, hp, max_hp)) in agents_data.iter().enumerate() {
        if i >= agent_rows.len() { break; }
        let cols = Layout::default()
            .direction(Direction::Horizontal)
            .constraints([Constraint::Length(22), Constraint::Length(22), Constraint::Min(20)])
            .split(agent_rows[i]);

        let name_w = Paragraph::new(Line::from(Span::styled(
            *name,
            Style::default().fg(*color).add_modifier(Modifier::BOLD),
        )));
        f.render_widget(name_w, cols[0]);

        let class_w = Paragraph::new(Line::from(vec![
            Span::styled(*class, Style::default().fg(Color::Gray)),
            Span::raw(" · "),
            Span::styled(*platform, Style::default().fg(Color::DarkGray)),
        ]));
        f.render_widget(class_w, cols[1]);

        if *max_hp > 0 {
            let gauge = Gauge::default()
                .gauge_style(Style::default().fg(*color))
                .ratio(*hp as f64 / *max_hp as f64)
                .label(format!("HP {}/{}", hp, max_hp));
            f.render_widget(gauge, cols[2]);
        } else {
            let mystery = Paragraph::new(Span::styled(
                "HP ???",
                Style::default().fg(Color::Rgb(34, 139, 34)),
            ));
            f.render_widget(mystery, cols[2]);
        }
    }
}

fn draw_wisdom(f: &mut Frame, area: Rect, app: &App) {
    let wisdom = WISDOMS[app.wisdom_idx];

    let lines = vec![
        Line::from(""),
        Line::from(""),
        Line::from(Span::styled(
            "  🎲  Press 'r' to roll for wisdom",
            Style::default().fg(Color::DarkGray),
        )),
        Line::from(""),
        Line::from(""),
        Line::from(Span::styled(
            format!("  d20 → {}", app.wisdom_idx + 1),
            Style::default()
                .fg(Color::Rgb(255, 215, 0))
                .add_modifier(Modifier::BOLD),
        )),
        Line::from(""),
        Line::from(Span::styled(
            format!("  \"{}\"", wisdom),
            Style::default()
                .fg(Color::Rgb(135, 206, 235))
                .add_modifier(Modifier::ITALIC),
        )),
        Line::from(""),
        Line::from(""),
        Line::from(Span::styled(
            "  /\\_/\\",
            Style::default().fg(Color::Rgb(34, 139, 34)),
        )),
        Line::from(Span::styled(
            " ( o.o )  — Rhy",
            Style::default().fg(Color::Rgb(34, 139, 34)),
        )),
        Line::from(Span::styled(
            "  > ^ <",
            Style::default().fg(Color::Rgb(34, 139, 34)),
        )),
    ];

    let block = Block::default()
        .borders(Borders::ALL)
        .title(" 🎲 Wisdom of the Dungeon ")
        .border_style(Style::default().fg(Color::Rgb(255, 215, 0)));
    let p = Paragraph::new(lines).block(block).wrap(Wrap { trim: false });
    f.render_widget(p, area);
}

fn draw_footer(f: &mut Frame, area: Rect, _app: &App) {
    let footer = Line::from(vec![
        Span::styled(" ←/→ ", Style::default().fg(Color::Rgb(250, 218, 94)).add_modifier(Modifier::BOLD)),
        Span::styled("tabs  ", Style::default().fg(Color::DarkGray)),
        Span::styled(" ↑/↓ ", Style::default().fg(Color::Rgb(250, 218, 94)).add_modifier(Modifier::BOLD)),
        Span::styled("navigate  ", Style::default().fg(Color::DarkGray)),
        Span::styled(" r ", Style::default().fg(Color::Rgb(250, 218, 94)).add_modifier(Modifier::BOLD)),
        Span::styled("roll  ", Style::default().fg(Color::DarkGray)),
        Span::styled(" q ", Style::default().fg(Color::Rgb(255, 36, 0)).add_modifier(Modifier::BOLD)),
        Span::styled("quit  ", Style::default().fg(Color::DarkGray)),
        Span::raw("  "),
        Span::styled("☂️ SymbolOS TUI", Style::default().fg(Color::Rgb(250, 218, 94))),
    ]);

    let block = Block::default()
        .borders(Borders::ALL)
        .border_style(Style::default().fg(Color::Rgb(37, 37, 53)));
    let p = Paragraph::new(footer).block(block);
    f.render_widget(p, area);
}

// ═══════════════════════════════════════════════════════
//  MAIN
// ═══════════════════════════════════════════════════════

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Find symbol_map.shared.json
    let path = std::env::args()
        .nth(1)
        .map(PathBuf::from)
        .unwrap_or_else(|| {
            // Try relative paths from likely CWDs
            let candidates = [
                PathBuf::from("../symbol_map.shared.json"),
                PathBuf::from("symbol_map.shared.json"),
                PathBuf::from("../../symbol_map.shared.json"),
            ];
            let default = candidates[0].clone();
            candidates
                .into_iter()
                .find(|p| p.exists())
                .unwrap_or(default)
        });

    let symbol_map: SymbolMap = if path.exists() {
        let data = fs::read_to_string(&path)?;
        serde_json::from_str(&data)?
    } else {
        eprintln!("⚠ symbol_map.shared.json not found at {:?}, using defaults", path);
        SymbolMap {
            version: "?.?".into(),
            symbols: vec![],
        }
    };

    // Terminal setup
    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen, EnableMouseCapture)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    let mut app = App::new(symbol_map);

    // Main loop
    loop {
        terminal.draw(|f| ui(f, &mut app))?;

        if event::poll(Duration::from_millis(100))? {
            if let Event::Key(key) = event::read()? {
                if key.kind == KeyEventKind::Press {
                    app.on_key(key.code);
                }
            }
        }

        app.tick();

        if app.should_quit {
            break;
        }
    }

    // Cleanup
    disable_raw_mode()?;
    execute!(
        terminal.backend_mut(),
        LeaveAlternateScreen,
        DisableMouseCapture
    )?;
    terminal.show_cursor()?;

    Ok(())
}
