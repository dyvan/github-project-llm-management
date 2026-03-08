# Plugin

The project ships as a Claude Code plugin in the `.claude-plugin/` directory.

## What the plugin contains

- **8 slash commands** -- task lifecycle (`start-task`, `finish-task`,
  `task-status`, `plan-task`, `next-task`), session management (`save-session`,
  `load-session`), and reporting (`sprint-report`).
- **4 hooks** -- `pre-commit-check` (validates issue ref in commit message),
  `post-commit-update` (updates board status), `session-start` (loads context),
  `session-end` (saves state).

## Plugin structure

```
.claude-plugin/
  plugin.json          # manifest (name, version, command/hook list)
  commands/            # slash command definitions (.md)
  hooks/               # shell hook scripts (.sh)
  README.md
```

## Installation

Copy the plugin directory into any project that uses GitHub Projects v2:

```bash
cp -r .claude-plugin/ /path/to/your/project/.claude-plugin/
```

## Requirements

- `gh` CLI >= 2.0.0
- A `GH_TOKEN` with `repo` and `project` scopes (set in `.env` or environment)
