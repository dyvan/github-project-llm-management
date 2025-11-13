"""
Tests for workflow YAML files validation
"""

import pytest
import yaml
import os
from pathlib import Path


class TestWorkflowFiles:
    """Test GitHub Actions workflow files"""

    @pytest.fixture
    def workflows_dir(self):
        """Get workflows directory path"""
        return Path(__file__).parent.parent / ".github" / "workflows"

    def test_workflows_directory_exists(self, workflows_dir):
        """Test that workflows directory exists"""
        assert workflows_dir.exists(), "Workflows directory does not exist"
        assert workflows_dir.is_dir(), "Workflows path is not a directory"

    def test_workflow_files_exist(self, workflows_dir):
        """Test that required workflow files exist"""
        required_workflows = [
            "create-branch.yml",
            "code-review-agent.yml",
            "ci-tests.yml",
            "update-project.yml",
            "deploy-docs.yml"
        ]

        for workflow in required_workflows:
            workflow_path = workflows_dir / workflow
            assert workflow_path.exists(), f"Workflow {workflow} does not exist"

    def test_workflow_yaml_syntax(self, workflows_dir):
        """Test that all workflow files have valid YAML syntax"""
        workflow_files = list(workflows_dir.glob("*.yml")) + list(workflows_dir.glob("*.yaml"))

        assert len(workflow_files) > 0, "No workflow files found"

        for workflow_file in workflow_files:
            try:
                with open(workflow_file, 'r') as f:
                    yaml.safe_load(f)
            except yaml.YAMLError as e:
                pytest.fail(f"Invalid YAML in {workflow_file.name}: {e}")

    def test_workflow_required_fields(self, workflows_dir):
        """Test that workflows have required fields"""
        workflow_files = list(workflows_dir.glob("*.yml"))

        for workflow_file in workflow_files:
            with open(workflow_file, 'r') as f:
                content = yaml.safe_load(f)

            assert 'name' in content, f"{workflow_file.name} missing 'name' field"
            assert 'on' in content, f"{workflow_file.name} missing 'on' field"
            assert 'jobs' in content, f"{workflow_file.name} missing 'jobs' field"

    def test_update_project_workflow_structure(self, workflows_dir):
        """Test update-project.yml has correct structure"""
        workflow_path = workflows_dir / "update-project.yml"

        with open(workflow_path, 'r') as f:
            content = yaml.safe_load(f)

        # Check triggers
        assert 'push' in content['on'] or 'pull_request' in content['on'] or 'issues' in content['on']

        # Check jobs
        assert 'update-project' in content['jobs']

        # Check steps include project_sync.py calls
        job = content['jobs']['update-project']
        steps = job['steps']

        # Check that at least one step calls project_sync.py
        has_sync_call = any(
            'project_sync.py' in str(step.get('run', ''))
            for step in steps
        )
        assert has_sync_call, "update-project workflow doesn't call project_sync.py"

    def test_create_branch_workflow_structure(self, workflows_dir):
        """Test create-branch.yml has correct structure"""
        workflow_path = workflows_dir / "create-branch.yml"

        with open(workflow_path, 'r') as f:
            content = yaml.safe_load(f)

        # Check triggers
        assert 'issues' in content['on']
        assert 'labeled' in content['on']['issues']

    def test_code_review_workflow_structure(self, workflows_dir):
        """Test code-review-agent.yml has correct structure"""
        workflow_path = workflows_dir / "code-review-agent.yml"

        with open(workflow_path, 'r') as f:
            content = yaml.safe_load(f)

        # Check triggers
        assert 'pull_request' in content['on']

        # Check permissions
        assert 'permissions' in content
        assert content['permissions']['pull-requests'] == 'write'

    def test_ci_tests_workflow_structure(self, workflows_dir):
        """Test ci-tests.yml has correct structure"""
        workflow_path = workflows_dir / "ci-tests.yml"

        with open(workflow_path, 'r') as f:
            content = yaml.safe_load(f)

        # Check triggers
        assert 'push' in content['on'] or 'pull_request' in content['on']

        # Check that it has test job
        jobs = content['jobs']
        assert len(jobs) > 0, "ci-tests.yml has no jobs"

    def test_workflow_permissions(self, workflows_dir):
        """Test that workflows have appropriate permissions"""
        sensitive_workflows = ['update-project.yml', 'create-branch.yml']

        for workflow_name in sensitive_workflows:
            workflow_path = workflows_dir / workflow_name

            with open(workflow_path, 'r') as f:
                content = yaml.safe_load(f)

            # These workflows should have permissions defined
            assert 'permissions' in content or any(
                'permissions' in job
                for job in content.get('jobs', {}).values()
            ), f"{workflow_name} should have permissions defined"

    def test_workflow_uses_correct_actions(self, workflows_dir):
        """Test that workflows use official GitHub actions"""
        workflow_files = list(workflows_dir.glob("*.yml"))

        official_actions = [
            'actions/checkout',
            'actions/setup-python',
            'actions/setup-node',
            'github/codeql-action'
        ]

        for workflow_file in workflow_files:
            with open(workflow_file, 'r') as f:
                content = yaml.safe_load(f)

            for job_name, job in content.get('jobs', {}).items():
                for step in job.get('steps', []):
                    if 'uses' in step:
                        action = step['uses']
                        # Check version is pinned
                        if any(official in action for official in official_actions):
                            assert '@v' in action or '@' in action, \
                                f"Action {action} in {workflow_file.name} should be version-pinned"
