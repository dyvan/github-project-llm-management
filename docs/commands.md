# Slash Commands

8 commands for managing your project from the CLI. All commands live in
`.claude/commands/` and are invoked with `/` inside a Claude Code session.

## Task Lifecycle

### /start-task

Start working on an issue. Creates or checks out the feature branch, updates
the project board to "In Progress", and prints issue context.

```
/start-task 123
```

### /finish-task

Finish a task. Pushes the branch, creates a PR using the standard template,
and moves the issue to "In Review" on the board.

```
/finish-task 123
```

### /next-task

Auto-pick the next task from the board. Queries items in **Ready** status,
sorted by Priority > Milestone > Effort, and starts the top result.

```
/next-task
```

### /plan-task

Analyze an issue and propose an implementation plan with sub-tasks before
you start coding.

```
/plan-task 145
```

### /task-status

Show current task context: active branch, linked issue, PR status, and
CI check results.

```
/task-status
```

## Session Management

### /save-session

Save the current work context (branch, issue, plan, progress notes) so you
can resume later.

```
/save-session
```

### /load-session

Restore context from a previously saved session and continue where you
left off.

```
/load-session
```

## Reporting

### /sprint-report

Generate a sprint progress report including velocity, completed items,
open blockers, and remaining work.

```
/sprint-report
```
