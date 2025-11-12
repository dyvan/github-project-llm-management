#!/usr/bin/env python3
"""
Automatically configure GitHub Projects v2 custom fields via GraphQL API.
This script creates the required fields: Status, Priority, Effort, Type, Target Version.
"""

import os
import sys
import json
import argparse
import requests
from typing import Dict, List, Optional


class ProjectFieldsSetup:
    """Setup GitHub Projects v2 custom fields"""

    def __init__(self, token: str, project_id: str):
        self.token = token
        self.project_id = project_id
        self.api_url = "https://api.github.com/graphql"
        self.headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
        }

    def graphql_query(self, query: str, variables: Optional[Dict] = None) -> Dict:
        """Execute GraphQL query"""
        payload = {"query": query}
        if variables:
            payload["variables"] = variables

        response = requests.post(self.api_url, headers=self.headers, json=payload)
        response.raise_for_status()

        data = response.json()
        if "errors" in data:
            raise Exception(f"GraphQL errors: {data['errors']}")

        return data["data"]

    def get_existing_fields(self) -> Dict[str, str]:
        """Get existing project fields"""
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
        data = self.graphql_query(query, {"projectId": self.project_id})
        fields = {}
        for field in data["node"]["fields"]["nodes"]:
            fields[field["name"]] = field["id"]
        return fields

    def create_single_select_field(self, name: str, options: List[str]) -> bool:
        """Create a single select field"""
        mutation = """
        mutation($projectId: ID!, $name: String!, $options: [ProjectV2SingleSelectFieldOptionInput!]!) {
          createProjectV2Field(input: {
            projectId: $projectId
            dataType: SINGLE_SELECT
            name: $name
            singleSelectOptions: $options
          }) {
            projectV2Field {
              ... on ProjectV2SingleSelectField {
                id
                name
              }
            }
          }
        }
        """

        option_inputs = [{"name": opt, "color": "GRAY"} for opt in options]
        variables = {
            "projectId": self.project_id,
            "name": name,
            "options": option_inputs,
        }

        try:
            self.graphql_query(mutation, variables)
            print(f"  ✅ Created field: {name}")
            return True
        except Exception as e:
            print(f"  ❌ Failed to create field {name}: {e}")
            return False

    def create_text_field(self, name: str) -> bool:
        """Create a text field"""
        mutation = """
        mutation($projectId: ID!, $name: String!) {
          createProjectV2Field(input: {
            projectId: $projectId
            dataType: TEXT
            name: $name
          }) {
            projectV2Field {
              ... on ProjectV2Field {
                id
                name
              }
            }
          }
        }
        """

        variables = {"projectId": self.project_id, "name": name}

        try:
            self.graphql_query(mutation, variables)
            print(f"  ✅ Created field: {name}")
            return True
        except Exception as e:
            print(f"  ❌ Failed to create field {name}: {e}")
            return False

    def setup_all_fields(self):
        """Create all required project fields"""
        print("🔍 Checking existing fields...")
        existing_fields = self.get_existing_fields()

        # Define required fields
        fields_to_create = {
            "Status": ["Backlog", "Ready", "In Progress", "In Review", "Blocked", "Done"],
            "Priority": ["Low", "Medium", "High"],
            "Effort": ["1", "2", "3", "5", "8"],
            "Type": ["Feature", "Bug", "Task", "Docs", "Infrastructure"],
        }

        text_fields = ["Target Version"]

        print(f"\n📋 Creating custom fields...")

        # Create single select fields
        for field_name, options in fields_to_create.items():
            if field_name in existing_fields:
                print(f"  ⏭️  Field '{field_name}' already exists, skipping...")
            else:
                self.create_single_select_field(field_name, options)

        # Create text fields
        for field_name in text_fields:
            if field_name in existing_fields:
                print(f"  ⏭️  Field '{field_name}' already exists, skipping...")
            else:
                self.create_text_field(field_name)

        print("\n✅ All fields configured!")


def get_project_id_from_number(token: str, owner: str, number: int) -> Optional[str]:
    """Get project ID from project number"""
    api_url = "https://api.github.com/graphql"
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    }

    query = """
    query($owner: String!, $number: Int!) {
      user(login: $owner) {
        projectV2(number: $number) {
          id
        }
      }
      organization(login: $owner) {
        projectV2(number: $number) {
          id
        }
      }
    }
    """

    variables = {"owner": owner, "number": number}
    payload = {"query": query, "variables": variables}

    response = requests.post(api_url, headers=headers, json=payload)
    response.raise_for_status()

    data = response.json()["data"]

    if data.get("user") and data["user"].get("projectV2"):
        return data["user"]["projectV2"]["id"]
    elif data.get("organization") and data["organization"].get("projectV2"):
        return data["organization"]["projectV2"]["id"]

    return None


def main():
    parser = argparse.ArgumentParser(
        description="Setup GitHub Projects v2 custom fields automatically"
    )
    parser.add_argument(
        "--project-id",
        help="Project node ID (e.g., PVT_kwDOAB...)",
        required=False,
    )
    parser.add_argument(
        "--project-number",
        type=int,
        help="Project number (e.g., 1)",
        required=False,
    )
    parser.add_argument(
        "--owner",
        help="Repository owner (username or org)",
        required=False,
    )

    args = parser.parse_args()

    # Get token from environment
    token = os.getenv("GH_TOKEN") or os.getenv("GITHUB_TOKEN")
    if not token:
        print("❌ GH_TOKEN or GITHUB_TOKEN environment variable not set")
        sys.exit(1)

    # Determine project ID
    project_id = args.project_id

    if not project_id and args.project_number:
        owner = args.owner or os.getenv("GH_OWNER") or os.getenv("GITHUB_REPOSITORY_OWNER")
        if not owner:
            print("❌ Owner required when using --project-number")
            print("Use --owner or set GH_OWNER environment variable")
            sys.exit(1)

        print(f"🔍 Looking up project #{args.project_number} for {owner}...")
        project_id = get_project_id_from_number(token, owner, args.project_number)

        if not project_id:
            print(f"❌ Project #{args.project_number} not found for {owner}")
            sys.exit(1)

        print(f"✅ Found project ID: {project_id}")

    if not project_id:
        print("❌ Either --project-id or --project-number must be provided")
        sys.exit(1)

    # Setup fields
    print(f"\n🚀 Setting up GitHub Project fields...")
    print(f"Project ID: {project_id}\n")

    setup = ProjectFieldsSetup(token, project_id)
    setup.setup_all_fields()

    print("\n✨ Setup complete!")
    print("\nNext steps:")
    print("1. Go to your project board")
    print("2. Verify the custom fields are visible")
    print("3. Configure your workflows to use these fields")


if __name__ == "__main__":
    main()
