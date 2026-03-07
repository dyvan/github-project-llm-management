"""Tests for project memory structure (.ai/memory/)."""

import os
import subprocess

import pytest

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MEMORY_DIR = os.path.join(REPO_ROOT, ".ai", "memory")
MEMORY_FILES = [
    "architecture.md",
    "decisions.md",
    "conventions.md",
    "current-sprint.md",
    "tech-debt.md",
]


class TestMemoryFilesExist:
    """All 5 memory files must exist."""

    @pytest.mark.parametrize("filename", MEMORY_FILES)
    def test_memory_file_exists(self, filename):
        path = os.path.join(MEMORY_DIR, filename)
        assert os.path.isfile(path), f"Missing memory file: {path}"


class TestMemoryFileSize:
    """Each memory file must be under 100 lines."""

    @pytest.mark.parametrize("filename", MEMORY_FILES)
    def test_memory_file_under_100_lines(self, filename):
        path = os.path.join(MEMORY_DIR, filename)
        with open(path) as f:
            line_count = sum(1 for _ in f)
        assert line_count <= 100, (
            f"{filename} has {line_count} lines (max 100)"
        )


class TestMemoryFileHeading:
    """Each memory file must have a title (# heading)."""

    @pytest.mark.parametrize("filename", MEMORY_FILES)
    def test_memory_file_has_heading(self, filename):
        path = os.path.join(MEMORY_DIR, filename)
        with open(path) as f:
            first_line = f.readline().strip()
        assert first_line.startswith("# "), (
            f"{filename} first line is not a heading: {first_line!r}"
        )


class TestUpdateMemoryScript:
    """update-memory.sh must exist and have valid bash syntax."""

    def test_script_exists(self):
        path = os.path.join(REPO_ROOT, "scripts", "update-memory.sh")
        assert os.path.isfile(path), "scripts/update-memory.sh not found"

    def test_script_is_executable(self):
        path = os.path.join(REPO_ROOT, "scripts", "update-memory.sh")
        assert os.access(path, os.X_OK), "scripts/update-memory.sh is not executable"

    def test_script_valid_bash_syntax(self):
        path = os.path.join(REPO_ROOT, "scripts", "update-memory.sh")
        result = subprocess.run(
            ["bash", "-n", path],
            capture_output=True,
            text=True,
        )
        assert result.returncode == 0, (
            f"Bash syntax error in update-memory.sh: {result.stderr}"
        )


class TestStep5Integration:
    """Step 5 must include copy_memory_templates."""

    def test_step5_has_copy_memory_templates_function(self):
        path = os.path.join(
            REPO_ROOT, "template", ".setup", "steps", "5-copy-files.sh"
        )
        with open(path) as f:
            content = f.read()
        assert "copy_memory_templates" in content, (
            "5-copy-files.sh missing copy_memory_templates function"
        )

    def test_step5_calls_copy_memory_templates_in_run_step(self):
        path = os.path.join(
            REPO_ROOT, "template", ".setup", "steps", "5-copy-files.sh"
        )
        with open(path) as f:
            content = f.read()
        # Must be called inside run_step(), not just defined
        run_step_section = content[content.index("run_step()"):]
        assert "copy_memory_templates" in run_step_section, (
            "copy_memory_templates not called in run_step()"
        )


class TestGitignore:
    """.gitignore must NOT ignore .ai/memory/."""

    def test_gitignore_does_not_ignore_ai_memory(self):
        path = os.path.join(REPO_ROOT, ".gitignore")
        with open(path) as f:
            lines = [line.strip() for line in f.readlines()]
        # .ai/ would ignore everything under .ai including memory
        assert ".ai/" not in lines, (
            ".gitignore has '.ai/' which would ignore .ai/memory/"
        )

    def test_gitignore_ignores_session_state(self):
        path = os.path.join(REPO_ROOT, ".gitignore")
        with open(path) as f:
            content = f.read()
        assert ".ai/session-state.md" in content, (
            ".gitignore should still ignore .ai/session-state.md"
        )
