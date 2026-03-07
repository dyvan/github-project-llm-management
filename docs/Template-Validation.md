# ✅ Template Validation

How the template is automatically validated.

## Validation workflow

The `.github/workflows/template-validation.yml` workflow automatically validates that all template features are working correctly.

### When does it run?

- ✅ On every **Pull Request**
- ✅ On every **push** to main/develop
- ✅ **Manually** via the Actions tab
- ✅ **Weekly** (Monday 9am UTC)

### What is tested

#### 1. Scripts (Syntax & Execution)

**Python scripts**:
- `scripts/project_sync.py`
- `scripts/setup_project_fields.py`

**Bash scripts**:
- `template-setup.sh`
- `scripts/validate_setup.sh`

**Checks**:
- ✅ Valid syntax
- ✅ Scripts are executable
- ✅ CLI works (--help)

#### 2. GitHub Actions Workflows

**Workflows tested**:
- `ci-tests.yml`
- `update-project.yml`
- `create-branch.yml`
- `code-review-agent.yml`
- `template-validation.yml`

**Checks**:
- ✅ Valid YAML
- ✅ All required workflows present
- ✅ Correct syntax

#### 3. Unit tests

**Tests run**:
- 32 unit tests (pytest)
- Workflow tests
- project_sync.py tests

**Coverage**:
- GraphQL queries
- Field updates
- Error handling

#### 4. Configuration

**Files validated**:
- `.github/project.yml`
- `.env.example`
- `requirements.txt`
- `requirements-dev.txt`

**Checks**:
- ✅ Valid YAML
- ✅ Required variables present
- ✅ Dependencies installable

#### 5. Documentation

**Files checked**:
- `README.md`
- `CONTRIBUTING.md`
- `CODE_OF_CONDUCT.md`
- `docs/Home.md`
- `docs/Getting-Started.md`
- `docs/Scripts-Reference.md`
- All other docs/

**Checks**:
- ✅ All files present
- ✅ Complete structure
- ✅ Valid internal links

#### 6. Templates

**Templates validated**:
- `.github/ISSUE_TEMPLATE/bug_report.yml`
- `.github/ISSUE_TEMPLATE/feature_request.yml`
- `.github/ISSUE_TEMPLATE/task.yml`
- `.github/PULL_REQUEST_TEMPLATE.md`

**Checks**:
- ✅ Valid YAML (issue templates)
- ✅ Valid Markdown (PR template)
- ✅ All templates present

#### 7. Dependencies

**Packages tested**:
- requests
- pyyaml
- google-generativeai
- pytest
- pytest-cov
- pytest-mock

**Checks**:
- ✅ Successful installation
- ✅ Imports working
- ✅ Compatible versions

#### 8. Security

**Checks**:
- ✅ No exposed secrets (API keys)
- ✅ No tokens in the code
- ✅ Secrets used correctly (via secrets.*)

#### 9. Feature simulation

**Features simulated**:
- CLI project_sync.py
- CLI setup_project_fields.py
- Setup validation

#### 10. Integration test (on main)

**Simulated user workflow**:
- Clone the repo
- Install dependencies
- Run setup
- Validate

---

## Running validation manually

### Via GitHub Actions

1. Go to the **Actions** tab
2. Select **Template Validation - E2E Tests**
3. Click **Run workflow**
4. Choose the branch
5. Click **Run workflow**

### Locally

```bash
# Install dependencies
pip install -r requirements.txt
pip install -r requirements-dev.txt

# Run tests
pytest tests/ -v

# Validate workflows
python -c "import yaml; [yaml.safe_load(open(f)) for f in ['.github/workflows/ci-tests.yml', '.github/workflows/update-project.yml']]"

# Validate setup
./scripts/validate_setup.sh
```

---

## Validation report

After execution, the workflow generates a **detailed report**:

```
📊 TEMPLATE VALIDATION REPORT
================================

✅ Scripts syntax: PASSED
✅ Workflows YAML: PASSED
✅ Unit tests: PASSED
✅ Configuration files: PASSED
✅ Documentation: PASSED
✅ Issue templates: PASSED
✅ Dependencies: PASSED
✅ Security checks: PASSED

================================
🎉 TEMPLATE VALIDATION: SUCCESS

The template is ready for use!
```

The report is also available in the **Summary** tab of each run.

---

## On failure

If a test fails:

### 1. Check the logs

- Go to Actions → Template Validation
- Click on the failed run
- View the detailed logs

### 2. Reproduce locally

```bash
# Reproduce the failing part
pytest tests/test_workflows.py -v

# Or run a specific script
python scripts/project_sync.py --help
```

### 3. Fix

- Fix the identified issue
- Commit
- Push → The workflow reruns automatically

### 4. Ask for help

If you don't understand the error:
- [Open an issue](https://github.com/dyvan/github-project-llm-management/issues)
- [Ask a question](https://github.com/dyvan/github-project-llm-management/discussions)

---

## Validation badge

Add the badge to your README:

```markdown
[![Template Validation](https://github.com/OWNER/REPO/actions/workflows/template-validation.yml/badge.svg)](https://github.com/OWNER/REPO/actions/workflows/template-validation.yml)
```

---

## Validation frequency

| Trigger | Frequency |
|---------|-----------|
| Pull Request | On every PR |
| Push main/develop | On every push |
| Manual | On demand |
| Automatic | Monday 9am UTC |

---

## Benefits

✅ **Confidence**: The template is tested automatically
✅ **Quality**: Early detection of regressions
✅ **Documentation**: Detailed report on each run
✅ **Transparency**: Validation is publicly visible

---

[⬅️ Understanding Workflows](Understanding-Workflows) | [🏠 Home](Home)
