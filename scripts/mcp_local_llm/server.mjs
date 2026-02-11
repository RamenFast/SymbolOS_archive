#!/usr/bin/env node
// SymbolOS MCP Server — Local LLM Bridge
// Exposes the local llama.cpp server (http://127.0.0.1:8080) as MCP tools
// for VS Code Copilot agents.

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import { readFileSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const LLAMA_BASE = process.env.LLAMA_BASE_URL || "http://127.0.0.1:8080";

// ── Auto-context: load hub-generated snapshot for default system prompt ─────
const __dirname = dirname(fileURLToPath(import.meta.url));
const CONTEXT_PATH = resolve(__dirname, "../../local_ai/cache/mercer_local_context.md");

function loadDefaultContext() {
  try {
    return readFileSync(CONTEXT_PATH, "utf-8");
  } catch {
    return null;
  }
}

// ── Helper: call the llama.cpp API ──────────────────────────────────────────
async function llamaFetch(path, options = {}) {
  const url = `${LLAMA_BASE}${path}`;
  const res = await fetch(url, {
    ...options,
    headers: { "Content-Type": "application/json", ...options.headers },
    signal: AbortSignal.timeout(120_000),
  });
  if (!res.ok) {
    const text = await res.text().catch(() => "");
    throw new Error(`llama.cpp ${res.status}: ${text.slice(0, 500)}`);
  }
  return res.json();
}

// ── MCP Server ──────────────────────────────────────────────────────────────
const server = new McpServer({
  name: "symbolos-local-llm",
  version: "0.1.0",
});

// Tool: local_llm_chat ────────────────────────────────────────────────────────
server.tool(
  "local_llm_chat",
  "Send a chat completion request to the local Qwen3-8B model via llama.cpp. " +
    "Returns the assistant's response. Use for drafts, summaries, structured output, " +
    "or any task that benefits from a second opinion without cloud costs.",
  {
    system: z
      .string()
      .optional()
      .describe("System prompt (optional). Sets the model's role/behavior."),
    message: z.string().describe("The user message to send to the model."),
    temperature: z
      .number()
      .min(0)
      .max(2)
      .optional()
      .describe("Sampling temperature (default: 0.7). Lower = more deterministic."),
    max_tokens: z
      .number()
      .int()
      .min(1)
      .max(4096)
      .optional()
      .describe("Maximum tokens to generate (default: 1024)."),
    think: z
      .boolean()
      .optional()
      .describe(
        "Enable thinking/reasoning mode (default: false). " +
          "When true, the model reasons step-by-step before answering (uses more tokens). " +
          "When false, the model answers directly."
      ),
  },
  async ({ system, message, temperature, max_tokens, think }) => {
    const messages = [];
    // Use caller's system prompt, or auto-generated context snapshot, or nothing
    const effectiveSystem = system || loadDefaultContext();
    if (effectiveSystem) messages.push({ role: "system", content: effectiveSystem });
    messages.push({ role: "user", content: message });

    const body = {
      messages,
      temperature: temperature ?? 0.7,
      max_tokens: max_tokens ?? 1024,
      stream: false,
    };

    // Qwen3 defaults to thinking mode. Disable unless explicitly requested.
    if (!think) {
      body.chat_template_kwargs = { enable_thinking: false };
    }

    const data = await llamaFetch("/v1/chat/completions", {
      method: "POST",
      body: JSON.stringify(body),
    });

    const choice = data.choices?.[0];
    const usage = data.usage || {};
    const content = choice?.message?.content || "";
    const reasoning = choice?.message?.reasoning_content || "";

    // Build the response: content first, then reasoning if present
    const parts = [];
    if (content) parts.push(content);
    if (reasoning && think) parts.push(`\n<thinking>\n${reasoning}\n</thinking>`);
    // If content is empty but reasoning exists, show reasoning as fallback
    if (!content && reasoning) parts.push(reasoning);

    const text = parts.join("\n") || "(empty response)";

    return {
      content: [
        {
          type: "text",
          text: [
            text,
            "",
            `--- stats: ${usage.prompt_tokens ?? "?"}in / ${usage.completion_tokens ?? "?"}out tokens, model=${data.model || "unknown"} ---`,
          ].join("\n"),
        },
      ],
    };
  }
);

// Tool: local_llm_status ──────────────────────────────────────────────────────
server.tool(
  "local_llm_status",
  "Check the health and status of the local llama.cpp server. " +
    "Returns whether the server is reachable, the loaded model, and slot info.",
  {},
  async () => {
    try {
      const health = await llamaFetch("/health");
      let slotsInfo = "";
      try {
        const slots = await llamaFetch("/slots");
        if (Array.isArray(slots)) {
          slotsInfo = `\nSlots: ${slots.length} (${slots.filter((s) => s.is_processing).length} busy)`;
        }
      } catch {
        // /slots may be disabled
      }

      let modelInfo = "";
      try {
        const props = await llamaFetch("/props");
        if (props.default_generation_settings?.model) {
          modelInfo = `\nModel: ${props.default_generation_settings.model}`;
        }
      } catch {
        // /props may be disabled
      }

      return {
        content: [
          {
            type: "text",
            text: `Server: ${LLAMA_BASE}\nHealth: ${health.status || JSON.stringify(health)}${modelInfo}${slotsInfo}`,
          },
        ],
      };
    } catch (err) {
      return {
        content: [
          {
            type: "text",
            text: `Server OFFLINE (${LLAMA_BASE}): ${err.message}`,
          },
        ],
        isError: true,
      };
    }
  }
);

// Tool: local_llm_tokenize ────────────────────────────────────────────────────
server.tool(
  "local_llm_tokenize",
  "Count the number of tokens in a text string using the loaded model's tokenizer. " +
    "Useful for checking if content fits within context limits.",
  {
    text: z.string().describe("The text to tokenize."),
  },
  async ({ text }) => {
    const data = await llamaFetch("/tokenize", {
      method: "POST",
      body: JSON.stringify({ content: text }),
    });

    const count = Array.isArray(data.tokens) ? data.tokens.length : "unknown";
    return {
      content: [
        {
          type: "text",
          text: `Tokens: ${count}`,
        },
      ],
    };
  }
);

// ── Launch ───────────────────────────────────────────────────────────────────
const transport = new StdioServerTransport();
await server.connect(transport);
