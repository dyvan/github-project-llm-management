"""
Tests that Gemini AI workflows are opt-in and skip cleanly without API keys.
"""

import os
import yaml
import pytest

WORKFLOW_DIR = os.path.join(os.path.dirname(__file__), "..", ".github", "workflows")

GEMINI_WORKFLOWS = {
    "code-review-agent.yml": "GEMINI_REVIEW_API_KEY",
    "plan-with-gemini.yml": "GEMINI_PLAN_API_KEY",
    "generate-specification.yml": "GEMINI_SPEC_API_KEY",
}


def load_workflow(filename):
    path = os.path.join(WORKFLOW_DIR, filename)
    with open(path) as f:
        return yaml.safe_load(f)


def read_workflow_raw(filename):
    path = os.path.join(WORKFLOW_DIR, filename)
    with open(path) as f:
        return f.read()


class TestGeminiWorkflowsExist:
    """All three Gemini workflows must be present."""

    @pytest.mark.parametrize("filename", GEMINI_WORKFLOWS.keys())
    def test_workflow_file_exists(self, filename):
        path = os.path.join(WORKFLOW_DIR, filename)
        assert os.path.isfile(path), f"Workflow {filename} not found"


class TestGeminiOptInMechanism:
    """Each workflow must check for secrets.GEMINI_API_KEY to skip when absent."""

    @pytest.mark.parametrize("filename", GEMINI_WORKFLOWS.keys())
    def test_has_secrets_check(self, filename):
        raw = read_workflow_raw(filename)
        assert "secrets.GEMINI_API_KEY" in raw, (
            f"{filename} must reference secrets.GEMINI_API_KEY for opt-in gating"
        )

    @pytest.mark.parametrize("filename,specific_key", GEMINI_WORKFLOWS.items())
    def test_has_specific_key_check(self, filename, specific_key):
        raw = read_workflow_raw(filename)
        assert f"secrets.{specific_key}" in raw, (
            f"{filename} must reference secrets.{specific_key}"
        )


class TestGeminiFallbackPattern:
    """Each workflow must use the fallback pattern: SPECIFIC_KEY || GEMINI_API_KEY."""

    @pytest.mark.parametrize("filename,specific_key", GEMINI_WORKFLOWS.items())
    def test_uses_fallback_pattern(self, filename, specific_key):
        raw = read_workflow_raw(filename)
        pattern = f"secrets.{specific_key} || secrets.GEMINI_API_KEY"
        assert pattern in raw, (
            f"{filename} must use fallback pattern: {pattern}"
        )


class TestGeminiSkipNotice:
    """Each workflow should have a skip-notice job for when no key is set."""

    @pytest.mark.parametrize("filename", GEMINI_WORKFLOWS.keys())
    def test_has_skip_notice_job(self, filename):
        data = load_workflow(filename)
        assert "skip-notice" in data.get("jobs", {}), (
            f"{filename} must have a 'skip-notice' job for graceful skipping"
        )
