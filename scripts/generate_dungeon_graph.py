#!/usr/bin/env python3
"""
Dungeon Graph Parser for SymbolOS

Parses all markdown files to extract dungeon room metadata and exit links,
generating a structured dungeon_graph.json file.
"""
import json
import os
import re

REPO_ROOT = os.path.expanduser("~/SymbolOS")
DOCS_DIRS = [os.path.join(REPO_ROOT, "docs"), os.path.join(REPO_ROOT, "internal_docs")]
OUTPUT_FILE = os.path.join(REPO_ROOT, "docs/dungeon_graph.json")

def parse_room_banner(content):
    """Extracts metadata from the DND dungeon room banner."""
    banner_match = re.search(r"╔═════.*?ROOM: (.*?)║.*?Floor: (.*?)│.*?Difficulty: (.*?)│.*?Loot: (.*?)║.*?Color: (.*?)║.*?╚═════", content, re.DOTALL)
    if not banner_match:
        return None
    
    title, floor, difficulty, loot, color = [s.strip() for s in banner_match.groups()]
    
    ring_match = re.search(r"Ring (\d+)", floor)
    ring = int(ring_match.group(1)) if ring_match else None
    
    return {
        "title": title,
        "ring": ring,
        "difficulty": len(difficulty), # Count the stars
        "color": color,
        "loot": loot
    }

def parse_exits(content):
    """Extracts exit links from the 🚪 EXITS section."""
    exits_match = re.search(r"🚪 EXITS:(.*?)────────────────", content, re.DOTALL)
    if not exits_match:
        return []

    exits_text = exits_match.group(1)
    exit_links = re.findall(r"→ \[(.*?)\]\((.*?)\)", exits_text)
    
    exits = []
    for _, target in exit_links:
        # A simple way to determine direction, can be improved
        if "north" in _.lower(): direction = "north"
        elif "east" in _.lower(): direction = "east"
        elif "south" in _.lower(): direction = "south"
        elif "west" in _.lower(): direction = "west"
        else: direction = "unknown"
        exits.append({
            "direction": direction,
            "target": target
        })
    return exits

def main():
    """Find all markdown files, parse them, and generate the graph."""
    dungeon_graph = {"rooms": []}
    
    for docs_dir in DOCS_DIRS:
        for root, _, files in os.walk(docs_dir):
            for file in files:
                if file.endswith(".md"):
                    path = os.path.join(root, file)
                    rel_path = os.path.relpath(path, REPO_ROOT)
                    
                    with open(path, "r") as f:
                        content = f.read()
                    
                    metadata = parse_room_banner(content)
                    if not metadata:
                        continue
                        
                    exits = parse_exits(content)
                    
                    room_data = {
                        "path": rel_path,
                        **metadata,
                        "exits": exits
                    }
                    dungeon_graph["rooms"].append(room_data)

    with open(OUTPUT_FILE, "w") as f:
        json.dump(dungeon_graph, f, indent=4)
        
    print(f"Dungeon graph generated with {len(dungeon_graph['rooms'])} rooms.")
    print(f"Output file: {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
