# Local LLM on Windows (Vulkan) — RX 6750 XT (Internal)

> "Shine dat light: trace a leaf decision back to its root value, then come forward again with the smallest safe step."

This is the "🧠⚡" path: running a local LLM server right on your own machine using that sweet AMD GPU of yours. It's like having a little piece of the future humming away under your desk.

We designed this to be:
- ☂️ **Private-by-default:** Your data stays with you. No cloud, no peeking. Just you and the silicon.
- 🧾 **Auditable:** Clear, explicit scripts and paths. You can see everything that's happening. No black boxes.
- 🧬 **Meeting-place compatible:** Your local LLM will be discoverable via `symbol_map.shared.json`, ready to join the party.

```
    ___
   / 🐢 \    "this is fine"
  |  ._. |
   \_____/
    |   |
```

## Poetry layer (Fi+Ti mirrored) 🪞

This is where we let the soul of the machine speak. Give it some space. Let it breathe.

**Pinned (short):** The mind knows what the heart loves better than it does; the heart loves that unconditionally — infinite loop, forevermore. That’s what Agape taught me: infinite energy from within.

- **Translation layer + emojis:** [../docs/poetry_translation_layer.md](../docs/poetry_translation_layer.md)
- **Full verse set:** [../docs/public_private_expression.md](../docs/public_private_expression.md)

## Goal (The Working Prototype)

So, what are we building here? A friendly local HTTP server that speaks the OpenAI-ish language. It'll take your chat and completion requests and run them through a local LLM, with your Vulkan-capable GPU doing the heavy lifting. It's your own personal thinking machine.

## Folder Conventions (Keeping it Tidy)

Let's keep our house in order. When you're setting this up, everything has its place. This makes it easy to find things and keeps our repo clean.

- `local_ai/bin/` — This is where the magic executable, `llama-server.exe` (or just `server.exe`), will live.
- `local_ai/models/` — Your chosen GGUF model goes in here. Just one for now, let's not get greedy.
- `scripts/` — Helpful little PowerShell scripts to make your life easier.

These folders are all git-ignored, so your local setup won't clutter up the main repository.

## Step 0 — Sanity Checks (Are we ready for this?)

First things first, let's make sure we're not trying to build a spaceship with a rubber chicken. Open up PowerShell and:

- `nvidia-smi`? We don't need no stinking nvidia-smi here. This is AMD country.
- Make sure your AMD Adrenalin drivers are installed and fresh. Give 'em an update if they're looking a bit dusty.

## Step 1 — Get llama.cpp (The Hacker's Way)

Time to get the core engine. You've got two paths here, choose your own adventure.

**Option A (The Fast Lane):** Download a prebuilt `llama.cpp` Windows release. It's like getting a pre-made pizza. Just needs a little assembly.

- Find the `llama-server.exe` in the release files.
- Copy that bad boy into `local_ai/bin/`.

**Option B (The Scenic Route):** Build `llama.cpp` yourself. This gives you full control, but you'll need your hiking boots on. Requires CMake and a C/C++ toolchain. Make sure to build with Vulkan enabled!

## Step 2 — Choose ONE Model (Be a Disk Space Miser)

Pick a single GGUF model to start. We're going for efficiency here. Think of it as choosing your companion for this journey.

Here are a couple of good starting points:

- **8B instruct @ `Q4_K_M` (~4–6 GB):** This one's a bit of a thinker. Better reasoning, and it'll fit nicely in your 12GB of VRAM for a partial offload.
- **3B–4B instruct @ `Q4_K_M` (~2–3 GB):** The speedy one. Faster and lighter, but maybe not as deep a thinker.

Place your chosen one at:
- `local_ai/models/<model>.gguf`

## Step 3 — Run the Server (Let's Light this Candle)

Time to bring it to life. You can use the handy script we've provided:

- `scripts/run_llama_server.ps1`

Or, if you're in VS Code, just run the task:

- `Local LLM: start llama.cpp server (Vulkan)`

This will:
- Magically find the first `*.gguf` file in your `local_ai/models/` folder.
- Start the server on `http://127.0.0.1:8080`.
- Try to offload to your GPU with `--ngl` (if your binary supports it).

## Step 4 — Quick Test (Is this thing on?)

Once it's running, let's give it a poke to see if it's awake. Open this in your browser:

- `http://127.0.0.1:8080/`

Or if you're a command-line warrior (in PowerShell):

- `Invoke-RestMethod http://127.0.0.1:8080/`

## Troubleshooting (When the Turtle is Not Fine)

- **If it's slow:** Try giving it more GPU layers (`--ngl`) until your VRAM starts to complain.
- **If it crashes on startup:** Don't panic. Try reducing the context size, lowering `--ngl`, or checking that your Vulkan runtime and drivers are happy.
- **If you can't find `llama-server.exe`:** Look for any server binary in the release, or take a deep breath and build from source. You can do it.

## Next Evolution (The Future is Bright)

This is just the beginning. Here's what's coming next:

- A little "Local Compute" doc in `docs/` once we figure out what's safe to share with the world.
- A VS Code task to easily start and stop the server.
- A SymbolOS client wrapper that will log your prompts and the LLM's results to `memory/session_log_*.md`. Provenance is key!

```
  \(•_•)/
   (  (>   "SHIPPED IT"
   /  \
```

*A friendly reminder from your local repo-gardener: have fun with this. It's a powerful tool, and we're excited to see what you build with it.*
