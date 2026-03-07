"""Tests for the PM agent definition file."""

import os
import re

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
AGENT_PATH = os.path.join(REPO_ROOT, ".claude", "agents", "pm-agent.md")


def _read_agent():
    with open(AGENT_PATH) as f:
        return f.read()


class TestPmAgentExists:
    def test_file_exists(self):
        assert os.path.isfile(AGENT_PATH), f"Agent file not found at {AGENT_PATH}"


class TestPmAgentFrontmatter:
    def test_has_yaml_frontmatter(self):
        content = _read_agent()
        assert content.startswith("---"), "File must start with YAML frontmatter"
        parts = content.split("---", 2)
        assert len(parts) >= 3, "File must have closing --- for frontmatter"

    def test_frontmatter_has_name(self):
        content = _read_agent()
        frontmatter = content.split("---", 2)[1]
        assert "name:" in frontmatter

    def test_frontmatter_has_description(self):
        content = _read_agent()
        frontmatter = content.split("---", 2)[1]
        assert "description:" in frontmatter

    def test_frontmatter_has_allowed_tools(self):
        content = _read_agent()
        frontmatter = content.split("---", 2)[1]
        assert "allowed-tools:" in frontmatter


class TestPmAgentSections:
    def test_has_sprint_planning(self):
        content = _read_agent()
        assert "### Sprint Planning" in content

    def test_has_backlog_grooming(self):
        content = _read_agent()
        assert "### Backlog Grooming" in content

    def test_has_retrospective(self):
        content = _read_agent()
        assert "### Retrospective" in content

    def test_has_health_check(self):
        content = _read_agent()
        assert "### Health Check" in content


class TestPmAgentReferences:
    def test_references_project_board_id(self):
        content = _read_agent()
        assert "PVT_kwHOAX_dWc4BGnys" in content

    def test_references_status_field(self):
        content = _read_agent()
        assert "PVTSSF_lAHOAX_dWc4BGnyszg3nS_U" in content

    def test_references_priority_field(self):
        content = _read_agent()
        assert "PVTSSF_lAHOAX_dWc4BGnyszg3nTXs" in content

    def test_references_effort_field(self):
        content = _read_agent()
        assert "PVTSSF_lAHOAX_dWc4BGnyszg4oAuc" in content

    def test_references_github_token_pattern(self):
        content = _read_agent()
        assert "GITHUB_TOKEN=" in content

    def test_no_hardcoded_secrets(self):
        content = _read_agent()
        # Should not contain actual API keys or tokens
        assert "ghp_" not in content
        assert "gho_" not in content
        assert "AIza" not in content
        # Should not contain .env values
        assert not re.search(r"GEMINI_API_KEY\s*=\s*\S+", content)
        assert not re.search(r"GH_TOKEN\s*=\s*ghp_", content)
