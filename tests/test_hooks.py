"""
Tests for Claude Code hook scripts and configuration.
"""

import json
import os
import stat
import subprocess

import pytest

# Root of the repository
ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HOOKS_DIR = os.path.join(ROOT_DIR, ".claude", "hooks")
TEMPLATE_SETTINGS = os.path.join(ROOT_DIR, "template", "config", "claude-settings.json")
DOCS_HOOKS = os.path.join(ROOT_DIR, "docs", "hooks.md")

HOOK_SCRIPTS = [
    "pre-commit-check.sh",
    "post-commit-update.sh",
    "session-start.sh",
    "session-end.sh",
]


class TestHookScriptsExist:
    """All hook scripts must exist."""

    @pytest.mark.parametrize("script", HOOK_SCRIPTS)
    def test_hook_script_exists(self, script):
        path = os.path.join(HOOKS_DIR, script)
        assert os.path.isfile(path), f"Hook script missing: {path}"


class TestHookScriptsSyntax:
    """All hook scripts must have valid bash syntax."""

    @pytest.mark.parametrize("script", HOOK_SCRIPTS)
    def test_hook_script_valid_bash(self, script):
        path = os.path.join(HOOKS_DIR, script)
        result = subprocess.run(
            ["bash", "-n", path],
            capture_output=True,
            text=True,
        )
        assert result.returncode == 0, (
            f"Bash syntax error in {script}: {result.stderr}"
        )


class TestHookScriptsExecutable:
    """All hook scripts should be executable or can be made executable."""

    @pytest.mark.parametrize("script", HOOK_SCRIPTS)
    def test_hook_script_executable(self, script):
        path = os.path.join(HOOKS_DIR, script)
        st = os.stat(path)
        is_executable = bool(st.st_mode & (stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH))
        assert is_executable, (
            f"Hook script not executable: {script}. "
            f"Run: chmod +x {path}"
        )


class TestTemplateSettings:
    """Template settings file must exist and be valid JSON."""

    def test_template_settings_exists(self):
        assert os.path.isfile(TEMPLATE_SETTINGS), (
            f"Template settings missing: {TEMPLATE_SETTINGS}"
        )

    def test_template_settings_valid_json(self):
        with open(TEMPLATE_SETTINGS) as f:
            data = json.load(f)
        assert "hooks" in data, "Template settings must contain a 'hooks' key"

    def test_template_settings_has_hook_types(self):
        with open(TEMPLATE_SETTINGS) as f:
            data = json.load(f)
        hooks = data["hooks"]
        assert "PreToolUse" in hooks, "Missing PreToolUse in template settings"
        assert "PostToolUse" in hooks, "Missing PostToolUse in template settings"


class TestDocumentation:
    """Documentation file must exist."""

    def test_docs_hooks_exists(self):
        assert os.path.isfile(DOCS_HOOKS), f"Documentation missing: {DOCS_HOOKS}"
