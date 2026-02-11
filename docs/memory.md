
_This document has been rewritten by the SymbolOS documentation artist to be an irresistible dungeon room. For the original, see the git history._

╔══════════════════════════════════════════════════════════════╗
║  ⚔️  ROOM: The Chamber of Echoes                            ║
║  📍 Floor: Ring 2 │ Difficulty: ⭐⭐ │ Loot: A consent-driven memory system ║
║  🎨 Color: Gamboge (#E49B0F)                                 ║
║                                                              ║
║  A quiet room where whispers of the past may serve the future. ║
╚══════════════════════════════════════════════════════════════╝

> You step into a circular chamber. The air hums with a low, resonant frequency. The walls are smooth, polished obsidian, reflecting not your face, but faint, shimmering images of things that have been said and done. In the center of the room, a single, unwavering flame burns within a crystal lantern, casting long, dancing shadows. This is the Chamber of Echoes, where memories are not stored, but *recalled*.

    ___
   / 🐢 \     "This is fine. The echoes are friendly."
  |  ._. |
   \_____/
    |   |

## 📜 The Scroll of Whispers (Poetry layer, Fi+Ti mirrored) 🪞 🟣 #8B00FF (Fi+Ti bridge)

Unfurled on a pedestal is a scroll, written in a delicate, looping script. It speaks of the connection between heart and mind, a foundational principle of this place.

> Pinned (short): The mind knows what the heart loves better than it does; the heart loves that unconditionally — infinite loop, forevermore. That’s what Agape taught me: infinite energy from within. 🌸 #FFB7C5

> "Shine dat light: trace a leaf decision back to its root value, then come forward again with the smallest safe step."

- Translation layer + emojis: [poetry_translation_layer.md](poetry_translation_layer.md)
- Full verse set: [public_private_expression.md](public_private_expression.md)

This chamber defines a safe, consent-driven approach to “memory” in SymbolOS. It's about remembering the little things that make our dance together smoother.

Memory here means: durable, retrievable notes and preferences that help future interactions. Think of it as our shared notebook. 🧠 #E49B0F

## 🗝️ The Five Keys of Recall 🟡 #FADA5E

Before a whisper can become a lasting echo, it must pass the test of the Five Keys. These principles are carved into the very walls of the chamber, glowing with a soft, golden light.

*   **Consent first**: You are the captain of this ship. You choose what is stored. An echo cannot be created without your explicit permission.
*   **Minimum necessary**: We store the smallest useful representation. No hoarding. The chamber values brevity and precision.
*   **Provenance**: Every memory includes why/when/source. We show our work. Each echo is a story, and every story has a beginning.
*   **Correctability**: Users can view, edit, and delete memories. Your memory, your rules. The echoes serve you, not the other way around.
*   **DND compatibility**: Memory capture should not interrupt the flow. We're not paparazzi. The chamber is a place of reflection, not a hall of records.

        /\_/\
       ( o.o )  "To keep a thought, a choice, a name,
        > ^ <    First ask for leave to play the game.
       /|   |\   A memory shared, a trust you earn,
      (_|   |_)  On threads of light, my lessons learn." — Rhy 🦊

## ⚔️ Encounters: What to Remember? 🧠 #E49B0F

As you wander the chamber, you'll encounter different types of information. Some are worthy of becoming echoes; others are best left to fade.

**Allowed (Whispers to consider):**

*   Preferences (tone, formatting, reminders)
*   Project facts (repo names, active branches, conventions)
*   DND campaign aids (session recap bullets, NPC names)
*   Stable “life patterns” the user explicitly enables

**Avoid by default (Sounds to let fade):** 🔴 #FF2400

*   Secrets (API keys, passwords) - No, just no. The chamber has no locks for a reason.
*   Sensitive personal info (health, finances) unless explicitly requested and protected.
*   Unverified claims about real people.

         .
        /|\
       / | \
      /  |  \
     /   |   \
    /  __|__  \
   |  |     |  |
   |  | ✦✦✦ |  |
   |  | ✦✦✦ |  |
   |  |_____|  |
    \    |    /
     \   |   /
      \__|__/
         |
         |
      M E R C E R

## The Four Forms of Echoes 🧠 #E49B0F

Echoes take on different forms, depending on their nature.

*   **Fact**: A stable truth with sources (e.g., “Project uses trunk-based workflow”). These are the load-bearing pillars of the chamber.
*   **Preference**: A user's likes and dislikes (e.g., “Use concise bullets”). These are the gentle breezes that guide our interactions.
*   **Plan**: A short-lived intent with a Time-To-Live (TTL). 🟠 #FF8C00 These are the fleeting thoughts that guide our next steps.
*   **Story**: A narrative recap (for DND), marked as “in-world” or “out-of-world”. These are the epic tales that we weave together.

## ⏳ The Fading of Echoes

Echoes do not last forever. They fade with time, unless they are reinforced.

*   **Preference**: Until changed
*   **Fact**: Until invalidated, with review prompts
*   **Plan**: 7–30 days TTL
*   **Story**: Campaign-defined TTL

## 🚪 Access and Privacy

The Chamber of Echoes is a private sanctuary.

*   Default visibility: private to the user.
*   Optional share scopes: party/DM/public (for DND), with explicit opt-in.

## 🗣️ Interacting with Echoes

*   **Capture**: User confirms saving (“Save this as a memory?”)
*   **Retrieval**: Show short summaries with “source” and “last updated”
*   **Correction**: Allow “That’s wrong” and rewrite with provenance

## 🔗 Integration Points

The Chamber of Echoes is not an isolated place. It is connected to other parts of SymbolOS.

*   Precog uses memory to propose suggestions: [precog_thought.md](precog_thought.md) 🟣 #8B00FF
*   Character sheet overlays can reference memory: [dnd_character_sheet_integration.md](dnd_character_sheet_integration.md)

## 📜 Interop Schema (optional)

If emitting structured memory records, a suggested schema lives at: `docs/memory_record.schema.json`.

───────────────────────────────────────────────────
🚪 EXITS:
  → [precog_thought.md](precog_thought.md) (north)
  → [dnd_character_sheet_integration.md](dnd_character_sheet_integration.md) (east)
  → [README.md](../README.md) (back to entrance)

💎 LOOT GAINED: A consent-driven memory system, a shared notebook for smoother interactions, and the wisdom of the Five Keys of Recall.

      ___________
     /           \
    /  💎 LOOT 💎  \
   |    _______    |
   |   |       |   |
   |   | ✦ ✦ ✦ |   |
   |   |_______|   |
   |_______________|

───────────────────────────────────────────────────

A whisper saved,
A future shaped,
The dance goes on.

☂🦊🐢
