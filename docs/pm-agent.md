# PM Agent

The PM agent is a Claude Code custom agent for project management tasks.

## Invoke

In Claude Code, use the agent via `/agent pm-agent` followed by a prompt.

## Capabilities

| Command | What it does |
|---------|-------------|
| Sprint planning | Checks velocity, proposes a sprint scope from Ready issues |
| Backlog grooming | Finds unlabeled, unestimated, stale, or duplicate issues |
| Retrospective | Summarizes completed work, velocity, merge times, blockers |
| Health check | Flags stale PRs, stuck issues, CI failures, unassigned work |

## Examples

```
/agent pm-agent Plan the next sprint
/agent pm-agent Groom the backlog
/agent pm-agent Run a retrospective for the last 2 weeks
/agent pm-agent Health check
```

## How it works

The agent reads the project board via `gh` CLI (GraphQL) and outputs
markdown reports. It asks for confirmation before making any changes
(assigning milestones, closing issues, etc.).

## Configuration

The agent uses project board IDs defined in its source file at
`.claude/agents/pm-agent.md`. Update those IDs if you use a different
GitHub Projects board.
