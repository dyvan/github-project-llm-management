"""
Tests for the /next-task Claude Code slash command.
Validates structure, frontmatter, content, and conventions.
"""

import re
import pytest
from pathlib import Path


COMMANDS_DIR = Path(__file__).parent.parent / ".claude" / "commands"
COMMAND_FILE = COMMANDS_DIR / "next-task.md"

FRONTMATTER_RE = re.compile(r"^---\n(.*?)\n---", re.DOTALL)
FIELD_RE = re.compile(r"^(\w[\w-]*):\s*(.+)$", re.MULTILINE)


def parse_frontmatter(content: str) -> dict:
    """Parse YAML-like frontmatter from a command file."""
    match = FRONTMATTER_RE.match(content)
    if not match:
        return {}
    return dict(FIELD_RE.findall(match.group(1)))


@pytest.fixture
def command_content():
    """Read the next-task command file."""
    assert COMMAND_FILE.exists(), "next-task.md does not exist"
    return COMMAND_FILE.read_text()


@pytest.fixture
def command_meta(command_content):
    """Parse frontmatter from the command."""
    return parse_frontmatter(command_content)


class TestNextTaskFileExists:
    """Test that the next-task command file exists."""

    def test_file_exists(self):
        assert COMMAND_FILE.exists(), (
            ".claude/commands/next-task.md does not exist"
        )

    def test_file_is_not_empty(self):
        assert COMMAND_FILE.stat().st_size > 0, (
            "next-task.md is empty"
        )


class TestNextTaskFrontmatter:
    """Test that next-task.md has valid frontmatter."""

    def test_has_frontmatter(self, command_content):
        assert FRONTMATTER_RE.match(command_content), (
            "next-task.md is missing YAML frontmatter (--- delimiters)"
        )

    def test_has_description(self, command_meta):
        assert "description" in command_meta, (
            "next-task.md missing 'description' in frontmatter"
        )

    def test_description_is_meaningful(self, command_meta):
        desc = command_meta.get("description", "").lower()
        assert "next" in desc or "pick" in desc or "task" in desc, (
            f"next-task.md description should mention next/pick/task, got: {desc}"
        )

    def test_has_allowed_tools(self, command_meta):
        assert "allowed-tools" in command_meta, (
            "next-task.md missing 'allowed-tools' in frontmatter"
        )

    def test_allowed_tools_include_gh(self, command_meta):
        tools = command_meta.get("allowed-tools", "")
        assert "Bash(gh:*)" in tools or "Bash(GITHUB_TOKEN=:*)" in tools, (
            "next-task.md should allow gh commands"
        )

    def test_no_argument_hint(self, command_meta):
        """next-task takes no arguments."""
        assert "argument-hint" not in command_meta, (
            "next-task.md should NOT have 'argument-hint' (takes no arguments)"
        )


class TestNextTaskContent:
    """Test the body content of next-task.md."""

    def test_has_steps_section(self, command_content):
        assert "## Steps" in command_content, (
            "next-task.md should have a '## Steps' section"
        )

    def test_references_project_id(self, command_content):
        assert "PVT_kwHOAX_dWc4BGnys" in command_content, (
            "next-task.md should reference the project board ID"
        )

    def test_references_github_token_prefix(self, command_content):
        assert "GITHUB_TOKEN=" in command_content, (
            "next-task.md should use 'GITHUB_TOKEN= gh' for dyvan account"
        )

    def test_references_ready_status(self, command_content):
        """Should filter for Ready items."""
        assert "61e4505c" in command_content or "Ready" in command_content, (
            "next-task.md should reference Ready status"
        )

    def test_references_priority_field_ids(self, command_content):
        """Should reference priority option IDs for sorting."""
        assert "79628723" in command_content, (
            "next-task.md should reference P0 priority option ID"
        )
        assert "0a877460" in command_content, (
            "next-task.md should reference P1 priority option ID"
        )
        assert "da944a9c" in command_content, (
            "next-task.md should reference P2 priority option ID"
        )

    def test_references_effort_field_ids(self, command_content):
        """Should reference effort option IDs for sorting."""
        assert "08e40e54" in command_content, (
            "next-task.md should reference effort 1 option ID"
        )

    def test_mentions_milestone_sorting(self, command_content):
        content_lower = command_content.lower()
        assert "milestone" in content_lower, (
            "next-task.md should mention milestone for sorting"
        )

    def test_no_hardcoded_secrets(self, command_content):
        assert "ghp_" not in command_content, (
            "next-task.md contains hardcoded GitHub token"
        )
        assert "sk-" not in command_content, (
            "next-task.md contains hardcoded API key"
        )
        assert "AIza" not in command_content, (
            "next-task.md contains hardcoded Gemini API key"
        )

    def test_is_read_only(self, command_content):
        """Command should be read-only and not modify anything."""
        content_lower = command_content.lower()
        assert "read-only" in content_lower or "do not modify" in content_lower, (
            "next-task.md should state it is read-only"
        )

    def test_asks_user_before_starting(self, command_content):
        """Should ask confirmation before invoking start-task."""
        content_lower = command_content.lower()
        assert "ask" in content_lower or "confirm" in content_lower, (
            "next-task.md should ask user for confirmation before starting a task"
        )

    def test_displays_candidates(self, command_content):
        """Should display top candidates."""
        assert "top" in command_content.lower() or "#1" in command_content or "candidates" in command_content.lower(), (
            "next-task.md should display top candidates"
        )
