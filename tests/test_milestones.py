"""Tests for milestone / sprint tracking feature (#110)."""

import os
import subprocess

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def test_create_sprint_script_exists():
    """The create-sprint.sh helper script must exist."""
    path = os.path.join(REPO_ROOT, "scripts", "create-sprint.sh")
    assert os.path.isfile(path), f"Missing {path}"


def test_create_sprint_script_is_executable():
    """The script must have the executable bit set."""
    path = os.path.join(REPO_ROOT, "scripts", "create-sprint.sh")
    assert os.access(path, os.X_OK), f"{path} is not executable"


def test_create_sprint_script_valid_bash_syntax():
    """The script must pass bash -n (syntax check)."""
    path = os.path.join(REPO_ROOT, "scripts", "create-sprint.sh")
    result = subprocess.run(
        ["bash", "-n", path], capture_output=True, text=True
    )
    assert result.returncode == 0, f"Syntax error: {result.stderr}"


def test_create_sprint_script_uses_github_token_pattern():
    """The script must use the GITHUB_TOKEN= pattern for gh commands."""
    path = os.path.join(REPO_ROOT, "scripts", "create-sprint.sh")
    with open(path) as f:
        content = f.read()
    assert "GITHUB_TOKEN=" in content, (
        "Script should use GITHUB_TOKEN= pattern for gh commands"
    )


def test_milestones_doc_exists():
    """docs/milestones.md must exist."""
    path = os.path.join(REPO_ROOT, "docs", "milestones.md")
    assert os.path.isfile(path), f"Missing {path}"


def test_milestones_doc_under_50_lines():
    """docs/milestones.md must be under 50 lines."""
    path = os.path.join(REPO_ROOT, "docs", "milestones.md")
    with open(path) as f:
        lines = f.readlines()
    assert len(lines) <= 50, f"milestones.md has {len(lines)} lines (max 50)"
