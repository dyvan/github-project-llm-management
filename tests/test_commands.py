"""
Tests for Claude Code slash commands (.claude/commands/*.md)
Validates structure, frontmatter, and conventions.
"""

import re
import pytest
from pathlib import Path


COMMANDS_DIR = Path(__file__).parent.parent / ".claude" / "commands"

# Expected commands with their required properties
EXPECTED_COMMANDS = {
    "start-task.md": {"has_argument": True, "description_contains": "start"},
    "finish-task.md": {"has_argument": True, "description_contains": "finish"},
    "task-status.md": {"has_argument": False, "description_contains": "status"},
    "save-session.md": {"has_argument": False, "description_contains": "save"},
    "load-session.md": {"has_argument": False, "description_contains": "load"},
    "sprint-report.md": {"has_argument": False, "description_contains": "report"},
    "plan-task.md": {"has_argument": True, "description_contains": "plan"},
}

FRONTMATTER_RE = re.compile(r"^---\n(.*?)\n---", re.DOTALL)
FIELD_RE = re.compile(r"^(\w[\w-]*):\s*(.+)$", re.MULTILINE)


def parse_frontmatter(content: str) -> dict:
    """Parse YAML-like frontmatter from a command file."""
    match = FRONTMATTER_RE.match(content)
    if not match:
        return {}
    return dict(FIELD_RE.findall(match.group(1)))


class TestCommandsDirectory:
    """Test that the commands directory exists and has expected files."""

    def test_commands_directory_exists(self):
        assert COMMANDS_DIR.exists(), ".claude/commands/ directory does not exist"
        assert COMMANDS_DIR.is_dir()

    def test_all_expected_commands_exist(self):
        for cmd_name in EXPECTED_COMMANDS:
            cmd_path = COMMANDS_DIR / cmd_name
            assert cmd_path.exists(), f"Missing command: {cmd_name}"

    def test_no_unexpected_files(self):
        """Only .md files should be in the commands directory."""
        for f in COMMANDS_DIR.iterdir():
            if f.name == ".DS_Store":
                continue
            assert f.suffix == ".md", f"Unexpected file in commands/: {f.name}"


class TestCommandFrontmatter:
    """Test that each command has valid frontmatter."""

    @pytest.fixture(params=list(EXPECTED_COMMANDS.keys()))
    def command(self, request):
        path = COMMANDS_DIR / request.param
        content = path.read_text()
        meta = parse_frontmatter(content)
        return {
            "name": request.param,
            "content": content,
            "meta": meta,
            "expected": EXPECTED_COMMANDS[request.param],
        }

    def test_has_frontmatter(self, command):
        assert FRONTMATTER_RE.match(command["content"]), (
            f"{command['name']} is missing YAML frontmatter (--- delimiters)"
        )

    def test_has_description(self, command):
        assert "description" in command["meta"], (
            f"{command['name']} missing 'description' in frontmatter"
        )

    def test_description_is_meaningful(self, command):
        desc = command["meta"].get("description", "").lower()
        keyword = command["expected"]["description_contains"]
        assert keyword in desc, (
            f"{command['name']} description should contain '{keyword}', got: {desc}"
        )

    def test_has_allowed_tools(self, command):
        assert "allowed-tools" in command["meta"], (
            f"{command['name']} missing 'allowed-tools' in frontmatter"
        )

    def test_allowed_tools_include_bash_gh(self, command):
        """All commands need gh access for GitHub operations."""
        tools = command["meta"].get("allowed-tools", "")
        assert "Bash(gh:*)" in tools or "Bash(GITHUB_TOKEN=:*)" in tools, (
            f"{command['name']} should allow gh commands"
        )

    def test_has_argument_hint_when_expected(self, command):
        if command["expected"]["has_argument"]:
            assert "argument-hint" in command["meta"], (
                f"{command['name']} should have 'argument-hint' (takes arguments)"
            )

    def test_no_argument_hint_when_not_expected(self, command):
        if not command["expected"]["has_argument"]:
            assert "argument-hint" not in command["meta"], (
                f"{command['name']} should NOT have 'argument-hint' (no arguments)"
            )


class TestCommandContent:
    """Test the body content of commands."""

    @pytest.fixture(params=list(EXPECTED_COMMANDS.keys()))
    def command_content(self, request):
        path = COMMANDS_DIR / request.param
        return {"name": request.param, "content": path.read_text()}

    def test_has_steps_section(self, command_content):
        assert "## Steps" in command_content["content"] or "## Step" in command_content["content"], (
            f"{command_content['name']} should have a Steps section"
        )

    def test_references_github_token_prefix(self, command_content):
        """Commands should use GITHUB_TOKEN= gh for dyvan account."""
        content = command_content["content"]
        if "gh issue" in content or "gh pr" in content or "gh api" in content:
            assert "GITHUB_TOKEN=" in content, (
                f"{command_content['name']} should use 'GITHUB_TOKEN= gh' for dyvan account"
            )

    def test_no_hardcoded_secrets(self, command_content):
        """Ensure no tokens or keys are hardcoded."""
        content = command_content["content"]
        assert "ghp_" not in content, f"{command_content['name']} contains hardcoded GitHub token"
        assert "sk-" not in content, f"{command_content['name']} contains hardcoded API key"

    def test_uses_arguments_variable(self, command_content):
        """Commands with arguments should reference $ARGUMENTS."""
        expected = EXPECTED_COMMANDS[command_content["name"]]
        if expected["has_argument"]:
            assert "$ARGUMENTS" in command_content["content"], (
                f"{command_content['name']} should reference $ARGUMENTS"
            )


class TestCommandIdempotency:
    """Test that commands are designed to be idempotent."""

    def test_start_task_checks_existing_branch(self):
        content = (COMMANDS_DIR / "start-task.md").read_text()
        assert "exists" in content.lower() or "already" in content.lower(), (
            "start-task should handle existing branches"
        )

    def test_save_session_creates_directory(self):
        content = (COMMANDS_DIR / "save-session.md").read_text()
        assert ".ai/" in content, "save-session should reference .ai/ directory"

    def test_load_session_handles_missing_file(self):
        content = (COMMANDS_DIR / "load-session.md").read_text()
        assert "not" in content.lower() or "doesn't exist" in content.lower() or "no saved" in content.lower(), (
            "load-session should handle missing session file"
        )


class TestTemplateCopyStep:
    """Test that step 5 copies commands to template users."""

    def test_copy_step_includes_commands(self):
        step5 = Path(__file__).parent.parent / "template" / ".setup" / "steps" / "5-copy-files.sh"
        content = step5.read_text()
        assert "copy_claude_commands" in content, (
            "Step 5 should call copy_claude_commands()"
        )
        assert ".claude/commands" in content, (
            "Step 5 should reference .claude/commands path"
        )
