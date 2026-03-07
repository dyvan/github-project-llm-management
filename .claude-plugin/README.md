# GitHub Project Management - Claude Code Plugin

A Claude Code plugin that provides slash commands and hooks for managing
GitHub Projects v2 boards directly from your editor.

## What it provides

- **8 slash commands**: task lifecycle (start, finish, status, plan, next-task),
  session management (save, load), and sprint reporting
- **4 hooks**: pre-commit validation, post-commit board updates,
  session start/end automation

## Installation

Copy the `.claude-plugin/` directory into your project root:

```bash
cp -r .claude-plugin/ /path/to/your/project/.claude-plugin/
```

## Configuration

Set the following environment variable (or add to `.env`):

- `GH_TOKEN` - GitHub Personal Access Token with `repo`, `project` scopes

The plugin uses `gh` CLI (>= 2.0.0) for all GitHub interactions.

## Commands

| Command | Description |
|---------|-------------|
| `/start-task` | Begin work on an issue (branch + board update) |
| `/finish-task` | Complete a task (PR creation + board update) |
| `/task-status` | Show current task and board status |
| `/plan-task` | Break down an issue into subtasks |
| `/next-task` | Pick the next prioritized task from the board |
| `/save-session` | Persist current session context |
| `/load-session` | Restore a saved session |
| `/sprint-report` | Generate a sprint progress report |

## Hooks

| Hook | Trigger | Action |
|------|---------|--------|
| `pre-commit-check.sh` | Before commit | Validates issue reference in message |
| `post-commit-update.sh` | After commit | Updates project board status |
| `session-start.sh` | Session open | Loads project context |
| `session-end.sh` | Session close | Saves session state |
