"""
Tests for wiki templates, init script, and documentation.
"""

import subprocess
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).parent.parent
WIKI_DIR = REPO_ROOT / "template" / "wiki"
INIT_SCRIPT = REPO_ROOT / "scripts" / "init-wiki.sh"
WIKI_DOC = REPO_ROOT / "docs" / "wiki.md"
COPY_STEP = REPO_ROOT / "template" / ".setup" / "steps" / "5-copy-files.sh"

EXPECTED_WIKI_PAGES = [
    "Home.md",
    "Architecture.md",
    "Decisions.md",
    "Conventions.md",
    "Onboarding.md",
]


class TestWikiTemplates:
    """Verify wiki template files exist and meet quality standards."""

    @pytest.mark.parametrize("filename", EXPECTED_WIKI_PAGES)
    def test_wiki_template_exists(self, filename):
        """Each expected wiki template file must exist."""
        path = WIKI_DIR / filename
        assert path.exists(), f"Wiki template {filename} not found at {path}"

    @pytest.mark.parametrize("filename", EXPECTED_WIKI_PAGES)
    def test_wiki_template_under_80_lines(self, filename):
        """Each wiki template must be under 80 lines."""
        path = WIKI_DIR / filename
        lines = path.read_text().splitlines()
        assert len(lines) < 80, (
            f"{filename} has {len(lines)} lines, expected < 80"
        )

    @pytest.mark.parametrize("filename", EXPECTED_WIKI_PAGES)
    def test_wiki_template_has_heading(self, filename):
        """Each wiki template must start with a # heading."""
        path = WIKI_DIR / filename
        content = path.read_text()
        assert content.startswith("# "), (
            f"{filename} does not start with a # heading"
        )


class TestInitWikiScript:
    """Verify the init-wiki.sh script exists and has valid syntax."""

    def test_init_script_exists(self):
        assert INIT_SCRIPT.exists(), f"init-wiki.sh not found at {INIT_SCRIPT}"

    def test_init_script_is_executable(self):
        assert INIT_SCRIPT.stat().st_mode & 0o111, (
            "init-wiki.sh is not executable"
        )

    def test_init_script_valid_bash_syntax(self):
        """Check bash syntax with bash -n."""
        result = subprocess.run(
            ["bash", "-n", str(INIT_SCRIPT)],
            capture_output=True,
            text=True,
        )
        assert result.returncode == 0, (
            f"Bash syntax error in init-wiki.sh: {result.stderr}"
        )


class TestWikiDocumentation:
    """Verify docs/wiki.md exists and is concise."""

    def test_wiki_doc_exists(self):
        assert WIKI_DOC.exists(), f"docs/wiki.md not found at {WIKI_DOC}"

    def test_wiki_doc_under_40_lines(self):
        lines = WIKI_DOC.read_text().splitlines()
        assert len(lines) < 40, (
            f"docs/wiki.md has {len(lines)} lines, expected < 40"
        )


class TestStep5CopiesWikiTemplates:
    """Verify step 5 includes wiki template copying."""

    def test_copy_wiki_templates_function_exists(self):
        content = COPY_STEP.read_text()
        assert "copy_wiki_templates" in content, (
            "copy_wiki_templates function not found in 5-copy-files.sh"
        )

    def test_copy_wiki_templates_called_in_run_step(self):
        content = COPY_STEP.read_text()
        # Find the run_step function and check it calls copy_wiki_templates
        run_step_start = content.index("run_step()")
        run_step_body = content[run_step_start:]
        assert "copy_wiki_templates" in run_step_body, (
            "copy_wiki_templates is not called in run_step()"
        )
