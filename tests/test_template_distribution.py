"""
Tests to ensure internal/E2E workflows are never distributed to template users.

The whitelist in template/.setup/steps/5-copy-files.sh controls which
workflows are copied during setup. This test reads that whitelist and
verifies correctness.
"""

import re
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).parent.parent
COPY_STEP = REPO_ROOT / "template" / ".setup" / "steps" / "5-copy-files.sh"

# Internal workflows that must NEVER be distributed
INTERNAL_WORKFLOWS = [
    "e2e-test-template.yml",
    "e2e-test-install.yml",
    "template-validation.yml",
    "auto-add-to-project.yml",
]

# Template workflows that SHOULD be distributed
EXPECTED_TEMPLATE_WORKFLOWS = [
    "create-branch.yml",
    "code-review-agent.yml",
    "auto-close-feature.yml",
    "generate-specification.yml",
    "plan-with-gemini.yml",
    "update-project.yml",
    "ci-tests.yml",
    "deploy-docs.yml",
]


def _parse_whitelist() -> list[str]:
    """Extract the workflows array from 5-copy-files.sh."""
    content = COPY_STEP.read_text()
    # Match the bash array block: local workflows=( ... )
    match = re.search(
        r'local workflows=\(\s*(.*?)\)', content, re.DOTALL
    )
    assert match, "Could not find 'local workflows=(...)' in 5-copy-files.sh"
    block = match.group(1)
    # Extract quoted strings
    return re.findall(r'"([^"]+)"', block)


class TestTemplateDistribution:
    """Verify the workflow distribution whitelist is correct."""

    @pytest.fixture(autouse=True)
    def whitelist(self):
        self._whitelist = _parse_whitelist()

    def test_copy_step_exists(self):
        assert COPY_STEP.exists(), f"{COPY_STEP} not found"

    def test_internal_workflows_excluded(self):
        """Internal/E2E workflows must NOT appear in the whitelist."""
        for wf in INTERNAL_WORKFLOWS:
            assert wf not in self._whitelist, (
                f"Internal workflow '{wf}' must not be in the distribution whitelist"
            )

    def test_expected_template_workflows_included(self):
        """All expected template workflows must appear in the whitelist."""
        for wf in EXPECTED_TEMPLATE_WORKFLOWS:
            assert wf in self._whitelist, (
                f"Template workflow '{wf}' is missing from the distribution whitelist"
            )

    def test_no_e2e_prefix_in_whitelist(self):
        """No workflow starting with 'e2e-' should be distributed."""
        for wf in self._whitelist:
            assert not wf.startswith("e2e-"), (
                f"Workflow '{wf}' starts with 'e2e-' and should not be distributed"
            )

    def test_no_template_prefix_in_whitelist(self):
        """No workflow starting with 'template-' should be distributed."""
        for wf in self._whitelist:
            assert not wf.startswith("template-"), (
                f"Workflow '{wf}' starts with 'template-' and should not be distributed"
            )
