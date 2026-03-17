# Development Workflow

Autonomous development workflow for GitHub projects managed with this template. This workflow supports both human and AI-driven development, with Gherkin acceptance criteria as the quality gate.

> **Note**: The pipeline steps (Gherkin writing, development, validation, merge) are executed by internal AI agents (Claude Code, Gemini CLI, or similar). The agent orchestration engine (bflow/beebotflow) is a separate private tool not included in this template. This document describes the **workflow conventions and labels** that any compatible agent system can follow.

## Overview

```
Issue Created → Gherkin Written → Dev Implements → PR Opens → CI Runs → Preview Validated → Merged
     |               |                  |              |           |            |              |
 auto:ready    auto:gherkin         auto:dev      auto:pr-open   |    auto:merge-ready    Done
                                                             auto:preview-ready
```

## Label Lifecycle

### Automation Labels (auto:*)

These labels track where an issue is in the autonomous pipeline. A human sets `auto:ready` to start; the rest are managed by the automation agent.

| Label | Set by | Meaning | Next step |
|-------|--------|---------|-----------|
| `auto:ready` | Human | Issue is well-defined, ready for autonomous processing | Write Gherkin |
| `auto:gherkin` | Agent | Acceptance criteria being written | Review Gherkin, then dev |
| `auto:dev` | Agent | Development in progress (worktree created) | Wait for PR |
| `auto:pr-open` | Agent | PR created, CI running | Wait for CI |
| `auto:preview-ready` | Agent/CI | CI green, preview deployed, waiting QA | Validate feature |
| `auto:merge-ready` | Agent | Validation passed, ready to merge | Human or auto merge |
| `auto:fix-needed` | Agent | CI or validation failed | Agent retries or human fixes |
| `auto:blocked` | Agent | Pipeline stuck, needs human intervention | Human investigates |
| `auto:needs-human` | Human | Not suitable for autonomous processing | Human handles manually |

### Priority Order

When an automation agent picks tasks, it follows this priority:

1. `auto:fix-needed` -- fix failing PRs first (already invested work)
2. `auto:preview-ready` -- validate features waiting for QA
3. `auto:dev` -- continue in-progress development
4. `auto:gherkin` -- write acceptance criteria for ready issues
5. `auto:ready` -- start new issues

### Spec Status Mapping

The board's "Spec Status" field maps to automation labels:

| Spec Status | Automation Label | Meaning |
|-------------|-----------------|---------|
| No spec | `auto:ready` | No Gherkin yet, needs criteria written |
| Spec in progress | `auto:gherkin` | Acceptance criteria being written |
| Spec complete | `auto:dev` | Gherkin done, ready for development |

## Workflow Steps

### 1. Issue Creation

Create an issue with proper labels:
- **Required**: `type:*` label (feature, bug, task, docs, infrastructure)
- **Recommended**: `priority:*` label, effort estimate, milestone
- **For autonomous processing**: add `auto:ready` when the issue is well-defined

A well-defined issue for autonomous processing should have:
- Clear title describing the feature or fix
- Description explaining the expected behavior
- Technical hints (affected files, routes, models) if applicable
- No ambiguity that would require human judgment

### 2. Gherkin-First Development

**Write acceptance criteria BEFORE code.** This is the core principle.

Use `/write-acceptance-tests <issue-number>` to generate Gherkin scenarios:

```gherkin
Feature: User can edit campaign name

  Background:
    Given an authenticated user

  Scenario: Successfully edit campaign name
    Given a campaign with name "Old Name"
    When the user clicks [data-testid="campaign-edit-btn"]
    And enters "New Name" in [data-testid="campaign-name-input"]
    And clicks [data-testid="campaign-save-btn"]
    Then [data-testid="campaign-alert-success"] contains "Campaign updated"
    And [data-testid="campaign-name-display"] contains "New Name"

  Scenario: Validation error on empty name
    When the user clears [data-testid="campaign-name-input"]
    And clicks [data-testid="campaign-save-btn"]
    Then [data-testid="campaign-alert-error"] contains "Name is required"
```

The command will:
- Analyze the codebase for context
- Generate scenarios covering happy paths, edge cases, and errors
- List all required `data-testid` attributes
- Save the `.feature` file to the repo
- Update the issue body with the acceptance criteria

### 3. Development

The developer (human or agent) implements against the Gherkin criteria:

1. Create a feature branch: `feat/{issue-number}-{short-description}`
2. Read the Gherkin from the issue
3. Implement the feature, adding `data-testid` attributes as specified
4. Write unit/integration tests as needed
5. Open a PR with `Closes #{issue-number}` in the body

**For autonomous agents (bflow):**
- Each issue gets an isolated git worktree
- The agent reads the Gherkin from the issue (never writes its own)
- Uses conventional commits: `feat(scope): description (#issue-number)`
- Runs linters and tests before committing

### 4. CI and Preview

When the PR opens:
- CI runs (lint, tests, build)
- A preview environment is deployed (if configured)
- Label moves to `auto:pr-open`, then `auto:preview-ready` when CI passes

### 5. Validation

Use `/validate-feature <pr-number>` to test the preview against the Gherkin criteria:

- Fetches the PR and linked issue
- Extracts Gherkin scenarios
- Tests each scenario on the preview URL
- Posts a concise validation report on the PR
- Reports `data-testid` coverage

If validation fails, the issue gets `auto:fix-needed` and the agent retries.

### 6. Merge

When validation passes:
- Label moves to `auto:merge-ready`
- Human reviews and merges (or auto-merge if configured)
- Issue moves to Done on the board

## Acceptance Testing Rules

These are 3 separate steps -- never combine them in a single agent run:

1. **Write criteria** (`/write-acceptance-tests`) -- generates Gherkin + data-testid table. Must be done and reviewed BEFORE any code is written.

2. **Develop** -- reads the Gherkin, implements the feature, adds `data-testid` attributes. The developer must NOT write or modify the Gherkin.

3. **Validate** (`/validate-feature`) -- tests against the Gherkin on the preview, posts report. If Gherkin is missing, STOP and ask to run step 1 first.

**When launching parallel dev agents**: always run `/write-acceptance-tests` on all issues first, then launch the dev agents in a second batch.

## data-testid Convention

Every interactive or verifiable UI element should have a `data-testid` attribute:

| Pattern | Example | Element |
|---------|---------|---------|
| `{page}-{action}-btn` | `campaign-edit-btn` | Action button |
| `{page}-{action}-confirm` | `campaign-delete-confirm` | Confirmation button |
| `{page}-{field}-input` | `campaign-name-input` | Form input |
| `{page}-{field}-select` | `campaign-status-select` | Select dropdown |
| `{page}-{field}-display` | `campaign-name-display` | Read-only display |
| `{page}-{element}-badge` | `campaign-status-badge` | Status badge |
| `{page}-form` | `campaign-edit-form` | Form container |
| `{page}-alert-{type}` | `campaign-alert-success` | Alert message |
| `{page}-empty-state` | `campaign-empty-state` | Empty state |
| `{page}-card` | `campaign-card` | Clickable card (list) |

## Agent Orchestration

This workflow is designed to be driven by an autonomous agent orchestrator. The reference implementation is [bflow (beebotflow)](https://github.com/dyvan/beebotflow), a private orchestration engine. The agent code is not distributed with this template — only the workflow conventions, labels, and slash commands are provided here.

Any compatible agent system that follows the label lifecycle and priority order described above can drive this workflow.

### Reference Setup (bflow)

1. **Install your agent orchestrator** on a server or CI runner
2. **Configure it** for your project:
   ```json
   {
     "repo": "owner/repo",
     "labels": {
       "ready": "auto:ready",
       "gherkin": "auto:gherkin",
       "dev": "auto:dev",
       "pr_open": "auto:pr-open",
       "preview_ready": "auto:preview-ready",
       "merge_ready": "auto:merge-ready",
       "fix_needed": "auto:fix-needed",
       "blocked": "auto:blocked"
     }
   }
   ```
3. **Schedule runs** via k8s CronJob, crontab, or GitHub Actions
4. **Configure notifications** (Discord, Slack, etc.) for status changes
5. **Monitor** via your observability stack (Grafana, etc.)

### How bflow Works

Each run, bflow:
1. Queries issues by `auto:*` labels, following priority order
2. For `auto:ready`: runs `/write-acceptance-tests`, moves to `auto:gherkin`
3. For `auto:gherkin` (reviewed): creates worktree, starts dev, moves to `auto:dev`
4. For `auto:dev` (PR open): waits for CI, moves to `auto:pr-open`
5. For `auto:preview-ready`: runs `/validate-feature`, moves to `auto:merge-ready` or `auto:fix-needed`
6. For `auto:fix-needed`: retries the fix (up to N attempts), then `auto:blocked`
