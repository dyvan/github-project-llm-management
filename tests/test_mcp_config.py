"""Tests for MCP GitHub server configuration."""

import json
import os
import subprocess

import pytest

# Resolve project root (repo root, not tests/)
PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


class TestMcpJson:
    """Validate .mcp.json exists and is correctly structured."""

    @pytest.fixture(autouse=True)
    def load_config(self):
        self.config_path = os.path.join(PROJECT_ROOT, ".mcp.json")

    def test_mcp_json_exists(self):
        assert os.path.isfile(self.config_path), ".mcp.json must exist at project root"

    def test_mcp_json_is_valid_json(self):
        with open(self.config_path) as f:
            data = json.load(f)
        assert isinstance(data, dict)

    def test_contains_github_server(self):
        with open(self.config_path) as f:
            data = json.load(f)
        assert "mcpServers" in data, "Top-level key 'mcpServers' is required"
        assert "github" in data["mcpServers"], "'github' server must be configured"

    def test_github_server_command(self):
        with open(self.config_path) as f:
            data = json.load(f)
        server = data["mcpServers"]["github"]
        assert server.get("command") == "npx"
        assert "@modelcontextprotocol/server-github" in server.get("args", [])

    def test_token_uses_env_var(self):
        """Token must reference an environment variable, not a hardcoded value."""
        with open(self.config_path) as f:
            data = json.load(f)
        env = data["mcpServers"]["github"].get("env", {})
        token_value = env.get("GITHUB_PERSONAL_ACCESS_TOKEN", "")
        assert token_value.startswith("${"), (
            "Token must use env var substitution (e.g. '${GH_TOKEN}'), "
            f"got: '{token_value}'"
        )


class TestMcpDocs:
    """Validate documentation for MCP GitHub server."""

    def test_docs_file_exists(self):
        docs_path = os.path.join(PROJECT_ROOT, "docs", "mcp-github.md")
        assert os.path.isfile(docs_path), "docs/mcp-github.md must exist"

    def test_docs_not_empty(self):
        docs_path = os.path.join(PROJECT_ROOT, "docs", "mcp-github.md")
        with open(docs_path) as f:
            content = f.read()
        assert len(content.strip()) > 100, "docs/mcp-github.md should have meaningful content"


class TestStep5CopiesMcpConfig:
    """Validate that step 5 includes .mcp.json in its copy logic."""

    def test_step5_references_mcp(self):
        step5_path = os.path.join(
            PROJECT_ROOT, "template", ".setup", "steps", "5-copy-files.sh"
        )
        assert os.path.isfile(step5_path), "5-copy-files.sh must exist"
        with open(step5_path) as f:
            content = f.read()
        assert "mcp" in content.lower(), (
            "5-copy-files.sh must contain MCP copy logic"
        )

    def test_step5_copies_mcp_json(self):
        step5_path = os.path.join(
            PROJECT_ROOT, "template", ".setup", "steps", "5-copy-files.sh"
        )
        with open(step5_path) as f:
            content = f.read()
        assert ".mcp.json" in content, (
            "5-copy-files.sh must reference .mcp.json"
        )
