# MCP GitHub Server

## What it provides

The [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) GitHub server
gives Claude Code native access to GitHub APIs without shelling out to `gh`. This
includes:

- **Issues** -- list, create, update, comment
- **Pull Requests** -- list, create, review, merge
- **Repositories** -- search, read files, list branches
- **Projects v2** -- read and update project board items

## Configuration

The server is configured in `.mcp.json` at the project root. It reads the
`GH_TOKEN` environment variable from your `.env` file:

```bash
# .env (never commit this file)
GH_TOKEN=ghp_xxxxxxxxxxxxx
```

No additional setup is needed. Claude Code detects `.mcp.json` automatically
and starts the server on demand.

## How it complements gh CLI

| Capability           | gh CLI          | MCP GitHub        |
|----------------------|-----------------|-------------------|
| Shell scripting      | Native          | Not applicable    |
| Structured API data  | JSON via --json | Native objects    |
| Claude Code native   | Via Bash tool   | Direct tool calls |
| Offline fallback     | Yes             | No                |

Both approaches work. The MCP server provides a more integrated experience
inside Claude Code, while `gh` CLI remains the fallback for scripting and
when MCP is not available.

## Troubleshooting

- Ensure `GH_TOKEN` is set in `.env` with `repo`, `project`, and `read:org` scopes.
- Run `npx @modelcontextprotocol/server-github` manually to verify the server starts.
- If MCP is unavailable, all commands gracefully fall back to `gh` CLI.
