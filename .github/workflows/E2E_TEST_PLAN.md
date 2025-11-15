# E2E Test Plan - Install Script Validation

## Overview

This document describes the E2E testing strategy for the `install.sh` script across different scenarios.

---

## Scenario 1: New Repository + install.sh (CURRENT)

**Workflow:** `.github/workflows/e2e-test-install.yml`

### Setup
1. Create empty repository under `dyvan-bot` account
2. Initialize git with README.md
3. Push to GitHub

### Execution
1. Download `install.sh` from main branch
2. Run `install.sh` with simulated user inputs (all defaults)
3. This simulates: `curl -fsSL https://raw.githubusercontent.com/dyvan/github-project-llm-management/main/install.sh | bash`

### Validations
- ✅ Repository owner is `dyvan-bot` (not `dyvan`)
- ✅ Project created with name "Project Board : {repo-name}"
- ✅ Project owner is `dyvan-bot`
- ✅ Custom fields configured (Status, Priority, Effort, Type)
- ✅ .env file created
- ✅ .gitignore created and contains .env

### Expected Output
```
Test Results: X/4 (XX%)
Failed Tests: (none, or specific failures listed)
```

### Cleanup
Auto-cleanup test repo after validation

---

## Scenario 2: Existing Project + install.sh (TODO)

**Status:** Not yet implemented

### Setup
1. Create repository with some existing code/content
2. Initialize with git commits

### Execution
1. Run `install.sh`
2. Answer "y" to "Add to existing repo?"
3. Script merges template files into existing repo

### Validations
- Existing files are NOT overwritten
- New template files are added
- Project created under existing repo owner
- Bootstrap runs successfully

### Expected Behavior
```
✅ .github/workflows merged
✅ scripts/ merged (new template scripts added, existing preserved)
✅ CLAUDE.md copied
✅ template-setup.sh available
```

---

## Scenario 3: Reinstallation + No-Overwrite (TODO)

**Status:** Not yet implemented

### Setup
1. Create repository that already uses the template
2. Has .env, project board, custom fields configured

### Execution
1. Run `install.sh` again (or `bash template-setup.sh` again)
2. Verify idempotency

### Validations
- ✅ No files are overwritten (safe to run multiple times)
- ✅ Project board is not duplicated
- ✅ Custom fields are not recreated (already exist)
- ✅ .env is preserved (not overwritten)

### Expected Behavior
```
⚠️  Project already exists, skipping
⚠️  .env already exists, keeping existing
✅ Setup idempotent
```

---

## Running Tests Locally

### Trigger Scenario 1
```bash
# Via gh CLI
gh workflow run e2e-test-install.yml

# Or via push to main
git push origin main
```

### Monitor Results
```bash
# List recent runs
gh run list --workflow e2e-test-install.yml

# View specific run
gh run view <run-id> --log
```

---

## Bot Account Setup

**Account:** `dyvan-bot`

**Token Secret:** `TEST_BOT_TOKEN` (stored in GitHub Actions Secrets)

**Permissions Required:**
- `repo` - Create/delete repositories
- `project` - Create/manage projects
- `workflow` - Update workflows

**Test Repos Location:** `github.com/dyvan-bot/test-install-e2e-*`

---

## Key Validation Points

### 1. Repository Context Isolation
- 🎯 **Critical:** Test repo owner must be `dyvan-bot`, NOT `dyvan`
- Prevents: Polluting main account, using wrong project, incorrect owner references

### 2. Project Naming
- Expected: `"Project Board : {repo-name}"`
- Owner: Must match repo owner (`dyvan-bot` for tests)

### 3. Custom Fields Configuration
- Status: Backlog, Ready, In progress, In review, Blocked, Done
- Priority: Low, Medium, High
- Effort: 1, 2, 3, 5, 8
- Type: Feature, User Story, Bug, Task, Docs, Infrastructure

### 4. Security
- .env is created but NOT committed
- .env is in .gitignore
- No secrets are exposed in logs

---

## Success Criteria

✅ **Scenario 1 passes** before merging to main
- All 4 tests pass (100%)
- No failed tests

✅ **Scenario 2 designed and queued** for implementation
- Plan documented
- Implementation ready

✅ **Scenario 3 planned** for final validation
- Idempotency verified
- Safe for production

---

## Failure Handling

If tests fail:

1. **Check logs:** `gh run view <run-id> --log`
2. **Identify failure:** Which validation failed?
3. **Debug test repo:** `gh repo view dyvan-bot/test-install-e2e-*`
4. **Fix root cause:**
   - Install script issue?
   - Bootstrap issue?
   - Project creation issue?
5. **Commit fix** and re-run

---

## Future Enhancements

- [ ] Parallel execution of all 3 scenarios
- [ ] Additional validation: Workflow file presence, Issue templates
- [ ] Integration tests: Create test issue, verify labels applied
- [ ] Performance metrics: Time taken for each step
- [ ] Report generation: Markdown summary in PR comments
