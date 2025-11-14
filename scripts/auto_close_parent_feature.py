#!/usr/bin/env python3
"""
Auto-close parent feature when all user stories are Done.

This script checks if a completed user story has a parent feature issue,
and if so, verifies if all user stories of that feature are completed.
If all are done, closes the parent feature.
"""

import os
import sys
import json
import argparse
import requests
from typing import Optional, Dict, List, Any


class FeatureAutoCloser:
    """Auto-close parent features when all user stories are complete"""

    def __init__(self, token: str, owner: str, repo: str):
        self.token = token
        self.owner = owner
        self.repo = repo
        self.api_url = "https://api.github.com/graphql"
        self.headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
        }

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

    def get_issue_info(self, issue_number: int) -> Dict[str, Any]:
        """Get issue information including its parent issue (from body)"""
        query = """
        query($owner: String!, $repo: String!, $number: Int!) {
          repository(owner: $owner, name: $repo) {
            issue(number: $number) {
              id
              number
              title
              state
              body
              labels(first: 10) {
                nodes {
                  name
                }
              }
            }
          }
        }
        """
        variables = {"owner": self.owner, "repo": self.repo, "number": issue_number}
        data = self.graphql_query(query, variables)

        if not data["repository"]["issue"]:
            raise Exception(f"Issue #{issue_number} not found")

        return data["repository"]["issue"]

    def extract_parent_issue_from_body(self, body: str) -> Optional[int]:
        """Extract parent issue number from issue body
        Looks for patterns like:
        - Parent: #123
        - Parent issue: #123
        - Parent Feature: #123
        """
        if not body:
            return None

        import re
        # Look for parent issue patterns
        patterns = [
            r'[Pp]arent\s*(?:issue|feature)?\s*:?\s*#(\d+)',
            r'[Pp]arent\s*#(\d+)',
        ]

        for pattern in patterns:
            match = re.search(pattern, body)
            if match:
                return int(match.group(1))

        return None

    def get_sub_issues_from_project(self, parent_issue_number: int, project_id: str) -> List[Dict[str, Any]]:
        """Get all sub-issues (User Stories) of a parent feature from the project board"""
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
                      number
                      title
                      state
                      body
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

        sub_issues = []
        for item in data["node"]["items"]["nodes"]:
            if item.get("content") and "number" in item["content"]:
                # This is an Issue (indicated by presence of 'number' field)
                issue = item["content"]
                # Check if this issue has the parent in its body
                parent_id = self.extract_parent_issue_from_body(issue.get("body", ""))
                if parent_id == parent_issue_number:
                    sub_issues.append(issue)

        return sub_issues

    def get_project_id_from_number(self, project_number: int) -> str:
        """Get project node ID from project number"""
        # Try user first
        query = """
        query($owner: String!, $number: Int!) {
          user(login: $owner) {
            projectV2(number: $number) {
              id
            }
          }
        }
        """
        variables = {"owner": self.owner, "number": project_number}
        try:
            data = self.graphql_query(query, variables)
            if data.get("user") and data["user"].get("projectV2"):
                return data["user"]["projectV2"]["id"]
        except Exception:
            # User not found or project not under user, try organization
            pass

        # Try organization
        org_query = """
        query($owner: String!, $number: Int!) {
          organization(login: $owner) {
            projectV2(number: $number) {
              id
            }
          }
        }
        """
        try:
            data = self.graphql_query(org_query, variables)
            if data.get("organization") and data["organization"].get("projectV2"):
                return data["organization"]["projectV2"]["id"]
        except Exception:
            pass

        raise Exception(f"Project #{project_number} not found for owner {self.owner}")

    def close_issue(self, issue_number: int) -> bool:
        """Close an issue"""
        mutation = """
        mutation($repositoryId: ID!, $issueNumber: Int!) {
          closeIssue(input: {issueId: $repositoryId, clientMutationId: "1"}) {
            issue {
              id
              state
            }
          }
        }
        """
        # First get the issue ID
        query = """
        query($owner: String!, $repo: String!, $number: Int!) {
          repository(owner: $owner, name: $repo) {
            issue(number: $number) {
              id
            }
          }
        }
        """
        variables = {"owner": self.owner, "repo": self.repo, "number": issue_number}
        data = self.graphql_query(query, variables)
        issue_id = data["repository"]["issue"]["id"]

        # Close the issue
        mutation = """
        mutation($issueId: ID!) {
          closeIssue(input: {issueId: $issueId}) {
            issue {
              id
              state
            }
          }
        }
        """
        variables = {"issueId": issue_id}

        try:
            self.graphql_query(mutation, variables)
            return True
        except Exception as e:
            print(f"❌ Failed to close issue: {e}")
            return False

    def check_and_close_parent(self, issue_number: int, project_number: Optional[int] = None) -> bool:
        """
        Check if issue has a parent feature, and if so, close parent if all US are done
        """
        print(f"🔍 Checking issue #{issue_number}...")

        # Get issue info
        issue_info = self.get_issue_info(issue_number)
        print(f"   Title: {issue_info['title']}")
        print(f"   State: {issue_info['state']}")

        # Note: Issue may already be closed by GitHub (via "Closes #X" in PR)
        # Continue to check if it's a user story with a parent

        # Check if it's a user story (has "us" label)
        labels = [label["name"] for label in issue_info["labels"]["nodes"]]
        is_user_story = "us" in labels

        if not is_user_story:
            print(f"   ℹ️  Not a user story (no 'us' label), skipping")
            return False

        print(f"   ✅ Detected as User Story")

        # Extract parent issue from body
        parent_issue_num = self.extract_parent_issue_from_body(issue_info["body"])
        if not parent_issue_num:
            print(f"   ℹ️  No parent feature found in issue body")
            return False

        print(f"   📌 Parent Feature: #{parent_issue_num}")

        # Get parent feature info
        try:
            parent_info = self.get_issue_info(parent_issue_num)
            print(f"   Parent Title: {parent_info['title']}")
            print(f"   Parent State: {parent_info['state']}")

            if parent_info["state"] == "CLOSED":
                print(f"   ℹ️  Parent already closed")
                return False
        except Exception as e:
            print(f"   ❌ Could not fetch parent issue: {e}")
            return False

        # Get project ID
        if not project_number:
            # Try to auto-detect from environment
            project_number = int(os.getenv("GH_PROJECT_NUMBER", "0") or 0)
            if project_number == 0:
                print(f"   ❌ Project number not provided and not in GH_PROJECT_NUMBER")
                return False

        try:
            project_id = self.get_project_id_from_number(project_number)
            print(f"   📊 Project: #{project_number}")
        except Exception as e:
            print(f"   ❌ Could not get project: {e}")
            return False

        # Get all sub-issues of the parent
        sub_issues = self.get_sub_issues_from_project(parent_issue_num, project_id)
        print(f"   📋 Found {len(sub_issues)} user stories")

        if not sub_issues:
            print(f"   ⚠️  No sub-issues found - cannot verify completion")
            return False

        # Check if all sub-issues are closed
        all_closed = all(issue["state"] == "CLOSED" for issue in sub_issues)

        if all_closed:
            print(f"   ✅ All {len(sub_issues)} user stories are Done/Closed")
            print(f"   🔄 Closing parent feature #{parent_issue_num}...")

            if self.close_issue(parent_issue_num):
                print(f"   ✅ Feature #{parent_issue_num} closed successfully!")
                return True
            else:
                return False
        else:
            closed_count = sum(1 for issue in sub_issues if issue["state"] == "CLOSED")
            open_count = len(sub_issues) - closed_count
            print(f"   ⏳ {closed_count}/{len(sub_issues)} user stories done ({open_count} still open)")
            print(f"   ℹ️  Parent feature will auto-close when all are done")
            return False


def main():
    parser = argparse.ArgumentParser(
        description="Auto-close parent feature when all user stories are complete"
    )
    parser.add_argument("--issue", type=int, required=True, help="Issue number to check")
    parser.add_argument("--project", type=int, help="Project number")
    parser.add_argument("--owner", help="Repository owner")
    parser.add_argument("--repo", help="Repository name")

    args = parser.parse_args()

    # Get credentials from environment
    token = os.getenv("GH_TOKEN") or os.getenv("GITHUB_TOKEN")
    owner = args.owner or os.getenv("GH_OWNER") or os.getenv("GITHUB_REPOSITORY_OWNER")
    repo = args.repo or os.getenv("GH_REPO") or os.getenv("GITHUB_REPOSITORY", "").split("/")[-1]
    project_number = args.project or (int(os.getenv("GH_PROJECT_NUMBER", "0") or 0) or None)

    if not token:
        print("❌ GH_TOKEN or GITHUB_TOKEN environment variable not set")
        sys.exit(1)

    if not owner or not repo:
        print("❌ Could not determine repository owner/name")
        sys.exit(1)

    print(f"\n🚀 Auto-close Feature Check")
    print(f"   Owner: {owner}")
    print(f"   Repo: {repo}")
    print(f"   Issue: #{args.issue}\n")

    closer = FeatureAutoCloser(token, owner, repo)

    try:
        success = closer.check_and_close_parent(args.issue, project_number)
        sys.exit(0 if success else 1)
    except Exception as e:
        print(f"\n❌ Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
