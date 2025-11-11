# Tests

Comprehensive test suite for GitHub Project LLM Management template.

---

## 🧪 Test Structure

```
tests/
├── test_project_sync.py      # Unit tests for project_sync.py
├── test_workflows.py          # Workflow YAML validation tests
├── test_setup_script.sh       # Bash tests for setup-project.sh
├── conftest.py               # Pytest configuration
└── README.md                 # This file
```

---

## 🚀 Running Tests

### Run All Tests

```bash
# From project root
pytest tests/

# With coverage
pytest tests/ --cov=scripts/ --cov-report=html

# With verbose output
pytest tests/ -v
```

### Run Specific Test Files

```bash
# Python unit tests only
pytest tests/test_project_sync.py

# Workflow validation only
pytest tests/test_workflows.py

# Setup script tests only
cd tests && bash test_setup_script.sh
```

### Run Specific Tests

```bash
# Run single test
pytest tests/test_project_sync.py::TestGitHubProjectSync::test_initialization

# Run test class
pytest tests/test_project_sync.py::TestGitHubProjectSync

# Run tests matching pattern
pytest tests/ -k "project_sync"
```

---

## 📊 Test Coverage

### Generate Coverage Report

```bash
# HTML report
pytest tests/ --cov=scripts/ --cov-report=html
# Open htmlcov/index.html in browser

# Terminal report
pytest tests/ --cov=scripts/ --cov-report=term

# XML report (for CI)
pytest tests/ --cov=scripts/ --cov-report=xml
```

### Current Coverage

The test suite aims for:
- **>80% code coverage** for Python scripts
- **100% workflow validation** for YAML files
- **Complete bash syntax testing** for shell scripts

---

## 🧩 Test Categories

### 1. Unit Tests (`test_project_sync.py`)

Tests for `scripts/project_sync.py`:
- ✅ GraphQL query execution
- ✅ Repository and issue ID retrieval
- ✅ Project finding and field management
- ✅ Item synchronization
- ✅ Field updates (Status, Priority, etc.)
- ✅ Error handling

**Example**:
```python
def test_sync_issue_success(self, sync):
    """Test syncing issue successfully"""
    # Mock all dependencies
    # Test full sync workflow
    # Assert success
```

### 2. Workflow Tests (`test_workflows.py`)

Tests for `.github/workflows/*.yml`:
- ✅ YAML syntax validation
- ✅ Required fields present
- ✅ Proper permissions configured
- ✅ Version-pinned actions
- ✅ Correct triggers configured

**Example**:
```python
def test_workflow_yaml_syntax(self, workflows_dir):
    """Validate all workflow files have valid YAML"""
    # Load and parse each workflow
    # Assert no YAML errors
```

### 3. Setup Script Tests (`test_setup_script.sh`)

Tests for `setup-project.sh`:
- ✅ Bash syntax validation
- ✅ Executable permissions
- ✅ Required command checks
- ✅ Label definitions present
- ✅ Error handling (`set -e`)
- ✅ Color definitions

**Example**:
```bash
test_syntax() {
    bash -n ../setup-project.sh
    # Assert exit code 0
}
```

---

## 🔧 Test Configuration

### pytest.ini

```ini
[pytest]
testpaths = tests
python_files = test_*.py
addopts = --verbose --tb=short --color=yes
```

### conftest.py

Configures pytest and adds `scripts/` to Python path.

---

## 🐛 Debugging Tests

### Run Tests with Debug Output

```bash
# Show print statements
pytest tests/ -s

# Show local variables on failure
pytest tests/ -l

# Drop into debugger on failure
pytest tests/ --pdb

# Show full traceback
pytest tests/ --tb=long
```

### Run Single Failing Test

```bash
# Run only failed tests from last run
pytest tests/ --lf

# Run failed tests first, then others
pytest tests/ --ff
```

---

## 🎯 Writing New Tests

### Adding Unit Tests

1. Create test file: `tests/test_new_feature.py`
2. Import the module to test
3. Create test class: `class TestNewFeature`
4. Write test methods: `def test_something(self)`
5. Use fixtures and mocks as needed

**Template**:
```python
import pytest
from unittest.mock import Mock, patch

class TestNewFeature:
    @pytest.fixture
    def feature(self):
        return NewFeature()

    def test_something(self, feature):
        result = feature.do_something()
        assert result == expected
```

### Adding Bash Tests

1. Add test function to `test_setup_script.sh`
2. Follow naming convention: `test_*`
3. Return 0 for success, 1 for failure
4. Add to main() function

**Template**:
```bash
test_new_feature() {
    echo "Testing new feature..."
    # Test logic here
    if [ condition ]; then
        echo "✅ Test passed"
        return 0
    else
        echo "❌ Test failed"
        return 1
    fi
}
```

---

## 📚 Test Dependencies

### Required Packages

Install from `requirements-dev.txt`:
```bash
pip install -r requirements-dev.txt
```

Includes:
- `pytest` - Testing framework
- `pytest-cov` - Coverage plugin
- `pytest-mock` - Mocking plugin
- `black` - Code formatter
- `pylint` - Linter
- `mypy` - Type checker

---

## 🤖 CI/CD Integration

Tests run automatically on:
- **Push** to main/develop/staging
- **Pull Requests** to main/develop

### GitHub Actions Workflow

See `.github/workflows/ci-tests.yml`:
1. Install dependencies
2. Validate workflow YAMLs
3. Check script syntax
4. Run format check (black)
5. Run lint (pylint)
6. Run type check (mypy)
7. Run unit tests with coverage
8. Run setup script tests
9. Upload coverage report
10. Comment results on PR

---

## 📈 Continuous Improvement

### Adding More Tests

Priority areas for additional tests:
1. **Integration tests** - Test full workflow end-to-end
2. **Edge cases** - Test error conditions and boundary values
3. **Performance tests** - Test with large projects
4. **Mock GitHub API** - Test API failure scenarios

### Test Quality Goals

- Maintain >80% code coverage
- All tests should be fast (<1s each)
- Tests should be independent (no order dependency)
- Mock external dependencies (GitHub API)
- Use descriptive test names

---

## 🆘 Troubleshooting

### Import Errors

```bash
# Ensure scripts/ is in Python path
export PYTHONPATH="${PYTHONPATH}:$(pwd)/scripts"
pytest tests/
```

### Module Not Found

```bash
# Install in development mode
pip install -e .

# Or add to conftest.py
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'scripts'))
```

### Permission Denied

```bash
# Make test script executable
chmod +x tests/test_setup_script.sh

# Make scripts executable
chmod +x setup-project.sh scripts/project_sync.py
```

---

## 📞 Questions?

- Check [CONTRIBUTING.md](../CONTRIBUTING.md) for contribution guidelines
- See [AUTOMATION.md](../AUTOMATION.md) for automation details
- Open an issue for test-related questions

---

**Last Updated**: 2025-11-10
