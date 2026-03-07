---
description: Analyze an issue and propose an implementation plan
allowed-tools: Bash(gh:*), Bash(GITHUB_TOKEN=:*), Read, Grep, Glob
argument-hint: <issue-number>
---

# Plan Task

Analyze issue #$ARGUMENTS and propose a concrete implementation plan.

## Steps

1. **Fetch issue details**:
   - `GITHUB_TOKEN= gh issue view $ARGUMENTS --json number,title,body,labels,milestone,comments`
   - Extract: description, acceptance criteria, technical notes

2. **Check for related issues**:
   - Look for issue references in the body (e.g., #123, "depends on", "blocks", "related to")
   - `GITHUB_TOKEN= gh issue view {related-number}` for each related issue
   - Note any dependencies or ordering constraints

3. **Scan the codebase**:
   - Extract keywords from the issue title and body
   - Use Grep to search for relevant code patterns, function names, file references
   - Use Glob to find related files by name
   - List the files that would likely need modification

4. **Analyze complexity**:
   - Count files to modify
   - Assess scope: is it a single-file change or cross-cutting?
   - Check if tests exist for affected code
   - Note any risks (breaking changes, migration needed, etc.)

5. **Propose implementation plan**:
   ```markdown
   ## Implementation Plan for #{number}: {title}

   ### Approach
   {1-2 sentence summary of the approach}

   ### Files to Modify
   1. `path/to/file.ext` - {what to change}
   2. `path/to/other.ext` - {what to change}

   ### New Files
   - `path/to/new.ext` - {purpose}

   ### Steps
   1. {First step}
   2. {Second step}
   3. ...

   ### Tests
   - {what to test}

   ### Dependencies
   - {blocking issues or prerequisites}

   ### Estimated Complexity
   {Low/Medium/High} - {brief justification}

   ### Risks
   - {potential issues to watch for}
   ```

6. **Ask the user** if they want to proceed with `/start-task $ARGUMENTS` or adjust the plan.

## Important
- Use `GITHUB_TOKEN= gh ...` for all gh commands (uses dyvan account)
- This is a read-only analysis command — do not modify any files
- Be specific about file paths and line numbers when possible
