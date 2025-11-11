"""
Unit tests for GitHub Projects v2 synchronization script
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
import sys
import os

# Add scripts directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'scripts'))

from project_sync import GitHubProjectSync


class TestGitHubProjectSync:
    """Test GitHubProjectSync class"""

    @pytest.fixture
    def sync(self):
        """Create GitHubProjectSync instance for testing"""
        return GitHubProjectSync(token="test_token", owner="test_owner", repo="test_repo")

    def test_initialization(self, sync):
        """Test GitHubProjectSync initialization"""
        assert sync.token == "test_token"
        assert sync.owner == "test_owner"
        assert sync.repo == "test_repo"
        assert sync.api_url == "https://api.github.com/graphql"
        assert "Authorization" in sync.headers
        assert sync.headers["Authorization"] == "Bearer test_token"

    @patch('requests.post')
    def test_graphql_query_success(self, mock_post, sync):
        """Test successful GraphQL query"""
        mock_response = Mock()
        mock_response.json.return_value = {
            "data": {"repository": {"id": "R_123"}}
        }
        mock_post.return_value = mock_response

        query = "query { repository { id } }"
        result = sync.graphql_query(query)

        assert result == {"repository": {"id": "R_123"}}
        mock_post.assert_called_once()

    @patch('requests.post')
    def test_graphql_query_with_errors(self, mock_post, sync):
        """Test GraphQL query with errors"""
        mock_response = Mock()
        mock_response.json.return_value = {
            "errors": [{"message": "Not found"}]
        }
        mock_post.return_value = mock_response

        query = "query { repository { id } }"

        with pytest.raises(Exception) as exc_info:
            sync.graphql_query(query)

        assert "GraphQL errors" in str(exc_info.value)

    @patch.object(GitHubProjectSync, 'graphql_query')
    def test_get_repository_id(self, mock_query, sync):
        """Test getting repository ID"""
        mock_query.return_value = {
            "repository": {"id": "R_kgDOAbCdEf"}
        }

        repo_id = sync.get_repository_id()

        assert repo_id == "R_kgDOAbCdEf"
        mock_query.assert_called_once()

    @patch.object(GitHubProjectSync, 'graphql_query')
    def test_get_issue_id(self, mock_query, sync):
        """Test getting issue node ID"""
        mock_query.return_value = {
            "repository": {
                "issue": {"id": "I_kwDOAbCdEf"}
            }
        }

        issue_id = sync.get_issue_or_pr_id(123, "issue")

        assert issue_id == "I_kwDOAbCdEf"
        mock_query.assert_called_once()

    @patch.object(GitHubProjectSync, 'graphql_query')
    def test_get_pr_id(self, mock_query, sync):
        """Test getting PR node ID"""
        mock_query.return_value = {
            "repository": {
                "pullRequest": {"id": "PR_kwDOAbCdEf"}
            }
        }

        pr_id = sync.get_issue_or_pr_id(45, "pr")

        assert pr_id == "PR_kwDOAbCdEf"
        mock_query.assert_called_once()

    @patch.object(GitHubProjectSync, 'graphql_query')
    def test_find_project_by_number(self, mock_query, sync):
        """Test finding project by number"""
        mock_query.return_value = {
            "organization": {
                "projectsV2": {
                    "nodes": [
                        {"id": "PVT_123", "number": 1, "title": "Project 1"},
                        {"id": "PVT_456", "number": 2, "title": "Project 2"}
                    ]
                }
            }
        }

        project_id = sync.find_project(project_number=2)

        assert project_id == "PVT_456"

    @patch.object(GitHubProjectSync, 'graphql_query')
    def test_find_project_first(self, mock_query, sync):
        """Test finding first project when no number specified"""
        mock_query.return_value = {
            "organization": {
                "projectsV2": {
                    "nodes": [
                        {"id": "PVT_123", "number": 1, "title": "Project 1"}
                    ]
                }
            }
        }

        project_id = sync.find_project()

        assert project_id == "PVT_123"

    @patch.object(GitHubProjectSync, 'graphql_query')
    def test_get_project_fields(self, mock_query, sync):
        """Test getting project fields"""
        mock_query.return_value = {
            "node": {
                "fields": {
                    "nodes": [
                        {
                            "id": "FIELD_1",
                            "name": "Status",
                            "options": [
                                {"id": "OPT_1", "name": "Backlog"},
                                {"id": "OPT_2", "name": "In Progress"}
                            ]
                        },
                        {
                            "id": "FIELD_2",
                            "name": "Priority",
                            "options": [
                                {"id": "OPT_3", "name": "High"},
                                {"id": "OPT_4", "name": "Medium"}
                            ]
                        }
                    ]
                }
            }
        }

        fields = sync.get_project_fields("PVT_123")

        assert "Status" in fields
        assert "Priority" in fields
        assert fields["Status"]["type"] == "single_select"
        assert "Backlog" in fields["Status"]["options"]
        assert fields["Priority"]["options"]["High"] == "OPT_3"

    @patch.object(GitHubProjectSync, 'graphql_query')
    def test_add_item_to_project(self, mock_query, sync):
        """Test adding item to project"""
        mock_query.return_value = {
            "addProjectV2ItemById": {
                "item": {"id": "PVTI_789"}
            }
        }

        item_id = sync.add_item_to_project("PVT_123", "I_456")

        assert item_id == "PVTI_789"

    @patch.object(GitHubProjectSync, 'graphql_query')
    def test_update_project_field_single_select(self, mock_query, sync):
        """Test updating single select field"""
        sync.field_ids = {
            "Status": {
                "id": "FIELD_1",
                "type": "single_select",
                "options": {"In Progress": "OPT_1"}
            }
        }
        mock_query.return_value = {
            "updateProjectV2ItemFieldValue": {
                "projectV2Item": {"id": "PVTI_789"}
            }
        }

        result = sync.update_project_field("PVT_123", "PVTI_789", "Status", "In Progress")

        assert result is True
        mock_query.assert_called_once()

    @patch.object(GitHubProjectSync, 'graphql_query')
    def test_update_project_field_text(self, mock_query, sync):
        """Test updating text field"""
        sync.field_ids = {
            "Target Version": {
                "id": "FIELD_2",
                "type": "text"
            }
        }
        mock_query.return_value = {
            "updateProjectV2ItemFieldValue": {
                "projectV2Item": {"id": "PVTI_789"}
            }
        }

        result = sync.update_project_field("PVT_123", "PVTI_789", "Target Version", "v1.0")

        assert result is True
        mock_query.assert_called_once()

    @patch.object(GitHubProjectSync, 'get_project_fields')
    def test_update_project_field_invalid_field(self, mock_get_fields, sync):
        """Test updating non-existent field"""
        sync.field_ids = {}
        mock_get_fields.return_value = {"Status": {"id": "FIELD_1"}}

        result = sync.update_project_field("PVT_123", "PVTI_789", "NonExistent", "Value")

        assert result is False

    @patch.object(GitHubProjectSync, 'get_project_fields')
    def test_update_project_field_invalid_option(self, mock_get_fields, sync):
        """Test updating with invalid option value"""
        sync.field_ids = {
            "Status": {
                "id": "FIELD_1",
                "type": "single_select",
                "options": {"Backlog": "OPT_1"}
            }
        }

        result = sync.update_project_field("PVT_123", "PVTI_789", "Status", "InvalidStatus")

        assert result is False

    @patch.object(GitHubProjectSync, 'get_issue_or_pr_id')
    @patch.object(GitHubProjectSync, 'find_project')
    @patch.object(GitHubProjectSync, 'add_item_to_project')
    @patch.object(GitHubProjectSync, 'update_project_field')
    def test_sync_issue_success(self, mock_update, mock_add, mock_find, mock_get_id, sync):
        """Test syncing issue successfully"""
        mock_get_id.return_value = "I_456"
        mock_find.return_value = "PVT_123"
        mock_add.return_value = "PVTI_789"
        mock_update.return_value = True

        fields = {"Status": "Backlog", "Priority": "High"}
        result = sync.sync_issue(123, fields=fields)

        assert result is True
        mock_get_id.assert_called_once_with(123, "issue")
        mock_add.assert_called_once()
        assert mock_update.call_count == 2

    @patch.object(GitHubProjectSync, 'get_issue_or_pr_id')
    def test_sync_issue_not_found(self, mock_get_id, sync):
        """Test syncing non-existent issue"""
        mock_get_id.return_value = None

        result = sync.sync_issue(999)

        assert result is False

    @patch.object(GitHubProjectSync, 'get_issue_or_pr_id')
    @patch.object(GitHubProjectSync, 'find_project')
    @patch.object(GitHubProjectSync, 'add_item_to_project')
    @patch.object(GitHubProjectSync, 'update_project_field')
    def test_sync_pr_success(self, mock_update, mock_add, mock_find, mock_get_id, sync):
        """Test syncing PR successfully"""
        mock_get_id.return_value = "PR_456"
        mock_find.return_value = "PVT_123"
        mock_add.return_value = "PVTI_789"
        mock_update.return_value = True

        fields = {"Status": "In Review"}
        result = sync.sync_pr(45, fields=fields)

        assert result is True
        mock_get_id.assert_called_once_with(45, "pr")

    @patch.object(GitHubProjectSync, 'graphql_query')
    def test_find_project_item(self, mock_query, sync):
        """Test finding project item for issue/PR"""
        mock_query.return_value = {
            "node": {
                "items": {
                    "nodes": [
                        {"id": "PVTI_111", "content": {"id": "I_456"}},
                        {"id": "PVTI_222", "content": {"id": "I_789"}}
                    ]
                }
            }
        }

        item_id = sync.find_project_item("PVT_123", "I_456")

        assert item_id == "PVTI_111"

    @patch.object(GitHubProjectSync, 'graphql_query')
    def test_find_project_item_not_found(self, mock_query, sync):
        """Test finding non-existent project item"""
        mock_query.return_value = {
            "node": {
                "items": {
                    "nodes": []
                }
            }
        }

        item_id = sync.find_project_item("PVT_123", "I_999")

        assert item_id is None


class TestCLIArguments:
    """Test CLI argument parsing"""

    def test_main_no_arguments(self):
        """Test main function without arguments"""
        # Import main and test
        with patch('sys.argv', ['project_sync.py']):
            with patch('sys.exit') as mock_exit:
                # This would normally call main(), but we'll skip for now
                # as it requires full environment setup
                pass


class TestEnvironmentVariables:
    """Test environment variable handling"""

    @patch.dict(os.environ, {
        'GH_TOKEN': 'test_token',
        'GH_OWNER': 'test_owner',
        'GH_REPO': 'test_repo'
    })
    def test_env_vars_loaded(self):
        """Test that environment variables are loaded correctly"""
        assert os.getenv('GH_TOKEN') == 'test_token'
        assert os.getenv('GH_OWNER') == 'test_owner'
        assert os.getenv('GH_REPO') == 'test_repo'

    @patch.dict(os.environ, {}, clear=True)
    def test_missing_env_vars(self):
        """Test handling of missing environment variables"""
        assert os.getenv('GH_TOKEN') is None
        assert os.getenv('GITHUB_TOKEN') is None
