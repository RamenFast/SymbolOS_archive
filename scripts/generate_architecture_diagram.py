#!/usr/bin/env python3
"""
Living Architecture Diagram Generator for SymbolOS

Generates a Mermaid diagram of the 12 rings of cognition.
"""

MERMAID_TEMPLATE = """
graph TD
    subgraph R0 - Kernel ⚓
        R0_Content[symbol_map.shared.json]
    end
    subgraph R1 - Will 🎯
        R1_Content(working_set.md)
    end
    subgraph R2 - Sensation 👁️
        R2_Content(API Inputs / User Prompts)
    end
    subgraph R3 - Task 🫴
        R3_Content(Current Goal)
    end
    subgraph R4 - Retrieval 📚
        R4_Content(Memory M0-M6)
    end
    subgraph R5 - Prediction 🌀
        R5_Content(Precog / Shadow Queue)
    end
    subgraph R6 - Architecture 🧩
        R6_Content(Dungeon Graph / Schemas)
    end
    subgraph R7 - Guardrails 🛡️
        R7_Content(Rhy Test / Safety Policies)
    end
    subgraph R8 - Verification 🧪
        R8_Content(Scripts / Tests)
    end
    subgraph R9 - Persistence 🗃️
        R9_Content(Git Commit / File Write)
    end
    subgraph R10 - Reflection 🪞
        R10_Content(Ring Heartbeat / Self-Correction)
    end
    subgraph R11 - Integration 🌌
        R11_Content(Agent Personality / Emergent Behavior)
    end

    R0 --> R1 --> R2 --> R3 --> R4 --> R5 --> R6 --> R7 --> R8 --> R9 --> R10 --> R11 --> R0
"""

OUTPUT_FILE = "/home/ubuntu/SymbolOS/docs/architecture_diagram.md"

def main():
    """Generate the Mermaid diagram and save it to a markdown file."""
    content = f"# Living Architecture Diagram\n\n```mermaid\n{MERMAID_TEMPLATE}\n```"
    with open(OUTPUT_FILE, "w") as f:
        f.write(content)
    print(f"Architecture diagram saved to {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
