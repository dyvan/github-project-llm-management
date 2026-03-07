"""Tests for the .claude-plugin package structure."""

import json
import re
from pathlib import Path

import pytest

PLUGIN_DIR = Path(__file__).resolve().parent.parent / ".claude-plugin"


@pytest.fixture
def plugin_json():
    """Load and return parsed plugin.json."""
    manifest = PLUGIN_DIR / "plugin.json"
    assert manifest.exists(), "plugin.json must exist in .claude-plugin/"
    return json.loads(manifest.read_text())


class TestPluginManifest:
    """Validate plugin.json structure and content."""

    def test_plugin_json_exists(self):
        assert (PLUGIN_DIR / "plugin.json").exists()

    def test_plugin_json_is_valid_json(self):
        manifest = PLUGIN_DIR / "plugin.json"
        content = manifest.read_text()
        json.loads(content)  # raises on invalid JSON

    def test_has_required_fields(self, plugin_json):
        required = ["name", "version", "description", "commands", "hooks"]
        for field in required:
            assert field in plugin_json, f"Missing required field: {field}"

    def test_version_follows_semver(self, plugin_json):
        version = plugin_json["version"]
        pattern = r"^\d+\.\d+\.\d+$"
        assert re.match(pattern, version), (
            f"Version '{version}' does not follow semver (MAJOR.MINOR.PATCH)"
        )

    def test_commands_is_nonempty_list(self, plugin_json):
        assert isinstance(plugin_json["commands"], list)
        assert len(plugin_json["commands"]) > 0

    def test_hooks_is_nonempty_list(self, plugin_json):
        assert isinstance(plugin_json["hooks"], list)
        assert len(plugin_json["hooks"]) > 0


class TestCommandFiles:
    """All command files referenced in plugin.json must exist."""

    def test_all_command_files_exist(self, plugin_json):
        missing = []
        for cmd_path in plugin_json["commands"]:
            full_path = PLUGIN_DIR / cmd_path
            if not full_path.exists():
                missing.append(cmd_path)
        assert not missing, f"Missing command files: {missing}"

    def test_command_files_are_markdown(self, plugin_json):
        for cmd_path in plugin_json["commands"]:
            assert cmd_path.endswith(".md"), (
                f"Command file should be markdown: {cmd_path}"
            )


class TestHookFiles:
    """All hook files referenced in plugin.json must exist."""

    def test_all_hook_files_exist(self, plugin_json):
        missing = []
        for hook_path in plugin_json["hooks"]:
            full_path = PLUGIN_DIR / hook_path
            if not full_path.exists():
                missing.append(hook_path)
        assert not missing, f"Missing hook files: {missing}"

    def test_hook_files_are_shell_scripts(self, plugin_json):
        for hook_path in plugin_json["hooks"]:
            assert hook_path.endswith(".sh"), (
                f"Hook file should be a shell script: {hook_path}"
            )

    def test_hook_files_are_executable(self, plugin_json):
        import os
        not_exec = []
        for hook_path in plugin_json["hooks"]:
            full_path = PLUGIN_DIR / hook_path
            if full_path.exists() and not os.access(full_path, os.X_OK):
                not_exec.append(hook_path)
        assert not not_exec, f"Hook files not executable: {not_exec}"
