#!/usr/bin/env python3
"""
GitHub Projects v2 Synchronization Script

This script synchronizes GitHub issues and PRs with GitHub Projects v2 board
using the GraphQL API to update custom fields (Status, Priority, Effort, etc.)
"""

import os
import sys
import json
import argparse
import requests
from typing import Optional, Dict, Any


class GitHubProjectSync:
    """Synchronize GitHub Issues/PRs with Projects v2"""

    def __init__(self, token: str, owner: str, repo: str):
        self.token = token
        self.owner = owner
        self.repo = repo
        self.api_url = "https://api.github.com/graphql"
        self.headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
        }
        self.project_id = None
        self.field_ids = {}

    def graphql_query(self, query: str, variables: Optional[Dict] = None) -> Dict[str, Any]:
        """Execute a GraphQL query"""
        payload = {"query": query}
        if variables:
            payload["variables"] = variables

        response = requests.post(self.api_url, headers=self.headers, json=payload)
        response.raise_for_status()

        data = response.json()
        if "errors" in data:
            raise Exception(f"GraphQL errors: {data['errors']}")

        return data["data"]

    def get_repository_id(self) -> str:
        """Get repository node ID"""
        query = """
        query($owner: String!, $repo: String!) {
          repository(owner: $owner, name: $repo) {
            id
          }
        }
        """
        variables = {"owner": self.owner, "repo": self.repo}
        data = self.graphql_query(query, variables)
        return data["repository"]["id"]

    def get_issue_or_pr_id(self, number: int, item_type: str = "issue") -> Optional[str]:
        """Get issue or PR node ID"""
        if item_type == "issue":
            query = """
            query($owner: String!, $repo: String!, $number: Int!) {
              repository(owner: $owner, name: $repo) {
                issue(number: $number) {
                  id
                }
              }
            }
            """
        else:  # PR
            query = """
            query($owner: String!, $repo: String!, $number: Int!) {
              repository(owner: $owner, name: $repo) {
                pullRequest(number: $number) {
                  id
                }
              }
            }
            """

        variables = {"owner": self.owner, "repo": self.repo, "number": number}
        data = self.graphql_query(query, variables)

        if item_type == "issue":
            return data["repository"]["issue"]["id"] if data["repository"]["issue"] else None
        else:
            return data["repository"]["pullRequest"]["id"] if data["repository"]["pullRequest"] else None

    def find_project(self, project_number: Optional[int] = None) -> Optional[str]:
        """Find project by number or get first project"""
        query = """
        query($owner: String!) {
          organization(login: $owner) {
            projectsV2(first: 20) {
              nodes {
                id
                number
                title
              }
            }
          }
        }
        """

        # Try organization first
        try:
            variables = {"owner": self.owner}
            data = self.graphql_query(query, variables)
            projects = data["organization"]["projectsV2"]["nodes"]
        except:
            # Try user projects if organization fails
            query = """
            query($owner: String!) {
              user(login: $owner) {
                projectsV2(first: 20) {
                  nodes {
                    id
                    number
                    title
                  }
                }
              }
            }
            """
            variables = {"owner": self.owner}
            data = self.graphql_query(query, variables)
            projects = data["user"]["projectsV2"]["nodes"]

        if not projects:
            print("⚠️  No projects found")
            return None

        if project_number:
            for project in projects:
                if project["number"] == project_number:
                    print(f"✅ Found project: {project['title']} (#{project['number']})")
                    return project["id"]
            print(f"⚠️  Project #{project_number} not found")
            return None
        else:
            # Return first project
            project = projects[0]
            print(f"✅ Using project: {project['title']} (#{project['number']})")
            return project["id"]

    def get_project_fields(self, project_id: str) -> Dict[str, Dict[str, Any]]:
        """Get project custom fields and their IDs"""
        query = """
        query($projectId: ID!) {
          node(id: $projectId) {
            ... on ProjectV2 {
              fields(first: 20) {
                nodes {
                  ... on ProjectV2Field {
                    id
                    name
                  }
                  ... on ProjectV2SingleSelectField {
                    id
                    name
                    options {
                      id
                      name
                    }
                  }
                }
              }
            }
          }
        }
        """
        variables = {"projectId": project_id}
        data = self.graphql_query(query, variables)

        fields = {}
        for field in data["node"]["fields"]["nodes"]:
            field_name = field["name"]
            field_data = {"id": field["id"], "type": "text"}

            # If it's a single select field, store options
            if "options" in field:
                field_data["type"] = "single_select"
                field_data["options"] = {opt["name"]: opt["id"] for opt in field["options"]}

            fields[field_name] = field_data

        return fields

    def add_item_to_project(self, project_id: str, item_id: str) -> Optional[str]:
        """Add an issue or PR to the project"""
        mutation = """
        mutation($projectId: ID!, $contentId: ID!) {
          addProjectV2ItemById(input: {projectId: $projectId, contentId: $contentId}) {
            item {
              id
            }
          }
        }
        """
        variables = {"projectId": project_id, "contentId": item_id}

        try:
            data = self.graphql_query(mutation, variables)
            project_item_id = data["addProjectV2ItemById"]["item"]["id"]
            print(f"✅ Added item to project (ID: {project_item_id})")
            return project_item_id
        except Exception as e:
            # Item might already be in project
            if "already exists" in str(e).lower():
                print("⚠️  Item already in project, finding existing item...")
                return self.find_project_item(project_id, item_id)
            else:
                print(f"❌ Failed to add item: {e}")
                return None

    def find_project_item(self, project_id: str, content_id: str) -> Optional[str]:
        """Find project item ID for a given issue/PR"""
        query = """
        query($projectId: ID!) {
          node(id: $projectId) {
            ... on ProjectV2 {
              items(first: 100) {
                nodes {
                  id
                  content {
                    ... on Issue {
                      id
                    }
                    ... on PullRequest {
                      id
                    }
                  }
                }
              }
            }
          }
        }
        """
        variables = {"projectId": project_id}
        data = self.graphql_query(query, variables)

        for item in data["node"]["items"]["nodes"]:
            if item["content"] and item["content"]["id"] == content_id:
                return item["id"]

        return None

    def update_project_field(
        self,
        project_id: str,
        item_id: str,
        field_name: str,
        value: str,
    ) -> bool:
        """Update a custom field on a project item"""
        # Get project fields
        if not self.field_ids:
            self.field_ids = self.get_project_fields(project_id)

        if field_name not in self.field_ids:
            print(f"⚠️  Field '{field_name}' not found in project")
            print(f"Available fields: {list(self.field_ids.keys())}")
            return False

        field_data = self.field_ids[field_name]
        field_id = field_data["id"]

        # For single select fields, get option ID
        if field_data["type"] == "single_select":
            if value not in field_data["options"]:
                print(f"⚠️  Option '{value}' not found for field '{field_name}'")
                print(f"Available options: {list(field_data['options'].keys())}")
                return False
            value_id = field_data["options"][value]

            mutation = """
            mutation($projectId: ID!, $itemId: ID!, $fieldId: ID!, $valueId: String!) {
              updateProjectV2ItemFieldValue(input: {
                projectId: $projectId
                itemId: $itemId
                fieldId: $fieldId
                value: {singleSelectOptionId: $valueId}
              }) {
                projectV2Item {
                  id
                }
              }
            }
            """
            variables = {
                "projectId": project_id,
                "itemId": item_id,
                "fieldId": field_id,
                "valueId": value_id,
            }
        else:
            # Text field
            mutation = """
            mutation($projectId: ID!, $itemId: ID!, $fieldId: ID!, $value: String!) {
              updateProjectV2ItemFieldValue(input: {
                projectId: $projectId
                itemId: $itemId
                fieldId: $fieldId
                value: {text: $value}
              }) {
                projectV2Item {
                  id
                }
              }
            }
            """
            variables = {
                "projectId": project_id,
                "itemId": item_id,
                "fieldId": field_id,
                "value": value,
            }

        try:
            self.graphql_query(mutation, variables)
            print(f"✅ Updated field '{field_name}' = '{value}'")
            return True
        except Exception as e:
            print(f"❌ Failed to update field: {e}")
            return False

    def sync_issue(
        self,
        issue_number: int,
        project_number: Optional[int] = None,
        fields: Optional[Dict[str, str]] = None,
    ) -> bool:
        """Sync an issue to the project and update fields"""
        print(f"\n🔄 Syncing issue #{issue_number}...")

        # Get issue ID
        issue_id = self.get_issue_or_pr_id(issue_number, "issue")
        if not issue_id:
            print(f"❌ Issue #{issue_number} not found")
            return False

        # Find or get project
        if not self.project_id:
            self.project_id = self.find_project(project_number)
            if not self.project_id:
                return False

        # Add to project
        project_item_id = self.add_item_to_project(self.project_id, issue_id)
        if not project_item_id:
            # Try to find existing item
            project_item_id = self.find_project_item(self.project_id, issue_id)
            if not project_item_id:
                print("❌ Failed to add or find item in project")
                return False

        # Update fields if provided
        if fields:
            for field_name, value in fields.items():
                self.update_project_field(self.project_id, project_item_id, field_name, value)

        print(f"✅ Issue #{issue_number} synced successfully")
        return True

    def sync_pr(
        self,
        pr_number: int,
        project_number: Optional[int] = None,
        fields: Optional[Dict[str, str]] = None,
    ) -> bool:
        """Sync a PR to the project and update fields"""
        print(f"\n🔄 Syncing PR #{pr_number}...")

        # Get PR ID
        pr_id = self.get_issue_or_pr_id(pr_number, "pr")
        if not pr_id:
            print(f"❌ PR #{pr_number} not found")
            return False

        # Find or get project
        if not self.project_id:
            self.project_id = self.find_project(project_number)
            if not self.project_id:
                return False

        # Add to project
        project_item_id = self.add_item_to_project(self.project_id, pr_id)
        if not project_item_id:
            # Try to find existing item
            project_item_id = self.find_project_item(self.project_id, pr_id)
            if not project_item_id:
                print("❌ Failed to add or find item in project")
                return False

        # Update fields if provided
        if fields:
            for field_name, value in fields.items():
                self.update_project_field(self.project_id, project_item_id, field_name, value)

        print(f"✅ PR #{pr_number} synced successfully")
        return True


def main():
    parser = argparse.ArgumentParser(
        description="Synchronize GitHub issues/PRs with Projects v2"
    )
    parser.add_argument("--issue", type=int, help="Issue number to sync")
    parser.add_argument("--pr", type=int, help="PR number to sync")
    parser.add_argument("--project", type=int, help="Project number (optional)")
    parser.add_argument("--status", help="Set Status field (e.g., 'In Progress')")
    parser.add_argument("--priority", help="Set Priority field (e.g., 'High')")
    parser.add_argument("--effort", help="Set Effort field (e.g., '3')")
    parser.add_argument("--type", help="Set Type field (e.g., 'Feature')")
    parser.add_argument("--owner", help="Set Owner field")
    parser.add_argument("--version", help="Set Target Version field")

    args = parser.parse_args()

    # Get credentials from environment
    token = os.getenv("GH_TOKEN") or os.getenv("GITHUB_TOKEN")
    owner = os.getenv("GH_OWNER") or os.getenv("GITHUB_REPOSITORY_OWNER")
    repo = os.getenv("GH_REPO") or os.getenv("GITHUB_REPOSITORY", "").split("/")[-1]

    if not token:
        print("❌ GH_TOKEN or GITHUB_TOKEN environment variable not set")
        sys.exit(1)

    if not owner or not repo:
        print("❌ Could not determine repository owner/name")
        print("Set GH_OWNER and GH_REPO environment variables")
        sys.exit(1)

    # Build fields dict
    fields = {}
    if args.status:
        fields["Status"] = args.status
    if args.priority:
        fields["Priority"] = args.priority
    if args.effort:
        fields["Effort"] = args.effort
    if args.type:
        fields["Type"] = args.type
    if args.owner:
        fields["Owner"] = args.owner
    if args.version:
        fields["Target Version"] = args.version

    # Initialize sync
    sync = GitHubProjectSync(token, owner, repo)

    # Sync issue or PR
    if args.issue:
        success = sync.sync_issue(args.issue, args.project, fields)
    elif args.pr:
        success = sync.sync_pr(args.pr, args.project, fields)
    else:
        print("❌ Must specify --issue or --pr")
        parser.print_help()
        sys.exit(1)

    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
