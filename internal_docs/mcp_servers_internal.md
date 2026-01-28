# MCP Servers: Internal Guidelines 🔒

This document is intended for internal contributors working on the SymbolOS implementation of **MCP servers**.  It complements the public overview by providing deeper technical notes, development standards and future plans.  **Do not share this document outside the team**.

## Project structure

Our MCP server code resides in the `services/mcp_servers` directory of the repository.  Each sub‑directory corresponds to a specific integration (e.g., `calendar_server`, `git_server`).  Shared utilities live in `services/mcp_servers/common`.

### Naming conventions

* Server directories use `snake_case` to match the service name (e.g., `git_server`).
* Tool schemas live in `schemas/` within each server directory and follow the naming pattern `<tool_name>.schema.json`.
* Resource definitions are stored in `resources.yaml` for each server.
* Tests are located in `tests/` mirroring the server structure.

### Development workflow

1. Create a new branch from `main` when adding or modifying a server.
2. Define tool and resource schemas using JSON Schema drafts.  Use `$ref` to import common definitions from `schemas/common.json` where possible.
3. Implement server endpoints in **TypeScript** or **Python** using the existing frameworks.  Consistency in code style is enforced via Prettier and Flake8; run `make lint` before submitting a pull request.
4. Write unit tests covering schema validation, successful tool calls and error cases.  Use fixtures to mock external services.
5. Update documentation (public and internal) when adding new servers or changing interfaces.
6. Submit a pull request with clear description and link to the relevant issue.  All code must be reviewed by at least one maintainer.

## Authentication and security

MCP servers may expose sensitive operations (e.g., file writes, API calls).  Always:

* Use API tokens or OAuth for authenticating client calls.  Never allow anonymous execution of tools.
* Implement scope‑based permissions.  Tools should check whether the requesting agent has the right to perform the action.
* Log all tool executions and resource accesses.  Logs are stored in the central audit service and retained for 90 days.
* Sanitise all inputs and enforce strict schema validation to prevent injection attacks.
* When exposing prompts that combine user data with templates, escape special characters to avoid prompt‑injection vulnerabilities.

## Future roadmap

* **Server registry** – we plan to implement a dynamic registry so that agents can discover available servers without hardcoding endpoints.
* **Streaming responses** – add support for streaming tool outputs (e.g., real‑time log tails) via server‑sent events.
* **Versioning** – adopt semantic versioning for servers and tools; the registry will support version negotiation between agents and servers.
* **Fallback mechanisms** – allow clients to specify fallback behaviour if a tool call fails (e.g., try again later or notify the user).
* **Monitoring** – integrate each server with our Prometheus-based monitoring stack; expose metrics such as request counts, latencies and error rates.

Please coordinate with the architecture team before implementing major changes.  For any questions, reach out via the `#symbolos-dev` Slack channel or file an issue in the internal repo.
