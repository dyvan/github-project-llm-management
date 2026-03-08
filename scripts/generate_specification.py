#!/usr/bin/env python3
"""
Generate detailed specification from QCM responses using Gemini

This script:
1. Fetches issue details from GitHub
2. Reads the QCM comment with user responses
3. Sends the QCM responses to Gemini AI
4. Gemini understands the responses and generates detailed specification
5. Saves responses snapshot + specification to specifications/{issue-number}/
6. Creates a sub-issue with the specification
7. Updates labels to trigger next workflow step
"""

import os
import sys
import json
import argparse
import requests
from datetime import datetime
from typing import Dict, Any, Optional


class SpecificationGenerator:
    """Generate detailed specification from QCM responses using Gemini AI"""

    def __init__(self, api_key: str):
        self.api_key = api_key
        self.api_url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"

    def get_issue_details(self, owner: str, repo: str, issue_number: int, token: str) -> Dict[str, Any]:
        """Fetch issue and QCM comment from GitHub"""
        headers = {
            "Authorization": f"Bearer {token}",
            "Accept": "application/vnd.github.v3+json",
        }

        # Get issue
        issue_url = f"https://api.github.com/repos/{owner}/{repo}/issues/{issue_number}"
        response = requests.get(issue_url, headers=headers)
        response.raise_for_status()
        issue = response.json()

        # Get comments (to find QCM comment)
        comments_url = f"{issue_url}/comments"
        response = requests.get(comments_url, headers=headers)
        response.raise_for_status()
        comments = response.json()

        # Find QCM comment (has "Specification Questionnaire")
        qcm_comment = None
        for comment in comments:
            if "Specification Questionnaire" in comment.get("body", "") or "Questionnaire de Spécification" in comment.get("body", ""):
                qcm_comment = comment["body"]
                break

        if not qcm_comment:
            raise Exception("No QCM comment found in this issue. Please complete the questionnaire first.")

        return {
            "issue": issue,
            "qcm_comment": qcm_comment,
            "issue_type": self._get_issue_type(issue.get("labels", [])),
        }

    def _get_issue_type(self, labels: list) -> str:
        """Determine issue type from labels"""
        for label in labels:
            name = label.get("name", "").lower()
            if "type:feature" in name:
                return "feature"
            elif "type:bug" in name:
                return "bug"
            elif "type:task" in name:
                return "task"
        return "general"

    def generate_specification(self, issue_data: Dict[str, Any]) -> str:
        """Generate detailed specification from QCM responses using Gemini"""
        issue = issue_data["issue"]
        qcm_comment = issue_data["qcm_comment"]
        issue_type = issue_data["issue_type"]

        prompt = self._build_specification_prompt(
            issue_number=issue["number"],
            title=issue["title"],
            description=issue["body"],
            issue_type=issue_type,
            qcm_responses=qcm_comment,
        )

        try:
            specification = self._call_gemini_api(prompt)
            return specification
        except Exception as e:
            print(f"⚠️  Error calling Gemini API: {e}")
            print(f"⚠️  Using structured template fallback...")
            # Fallback to template-based specification
            return self._generate_template_specification(issue_type, issue["title"], issue["number"])

    def _build_specification_prompt(
        self,
        issue_number: int,
        title: str,
        description: str,
        issue_type: str,
        qcm_responses: str,
    ) -> str:
        """Build optimized prompt for Gemini to generate specification"""

        base_prompt = f"""You are a senior technical architect creating detailed specifications.

**Issue:** #{issue_number}: {title}
**Type:** {issue_type.upper()}
**Original Description:**
{description}

---

**User Responses to Questionnaire (QCM):**
{qcm_responses}

---

Based on the issue description and the user's QCM responses above, generate a comprehensive specification document.

Your specification should:
1. Be specific and actionable for developers
2. Reference the user's answers directly
3. Identify potential risks and dependencies
4. Provide clear acceptance criteria
5. Include implementation notes and edge cases
6. Use Markdown format

**Generate different sections based on issue type:**"""

        if issue_type == "feature":
            base_prompt += """

## For FEATURE issues, include these sections:

1. **Executive Summary** (2-3 sentences)
   - What are we building?
   - Why is it important?

2. **User Requirements** (based on QCM answers)
   - User stories or use cases
   - Expected behavior

3. **Functional Specifications**
   - Detailed feature behavior
   - Scope and limits
   - Integration points

4. **Technical Architecture**
   - Recommended technical approach
   - Technology choices
   - System design

5. **Acceptance Criteria** (5-8 specific, testable criteria)
   - Feature must...
   - Feature should...
   - Feature must NOT...

6. **Non-Functional Requirements**
   - Performance targets
   - Security considerations
   - Scalability requirements

7. **Dependencies & Risks**
   - External dependencies
   - Blockers
   - Risk mitigation

8. **Implementation Notes**
   - Edge cases to handle
   - Error scenarios
   - Known gotchas"""

        elif issue_type == "bug":
            base_prompt += """

## For BUG issues, include these sections:

1. **Problem Statement**
   - What's broken?
   - When did it start?

2. **Impact Assessment** (based on QCM answers)
   - Severity level
   - Who is affected
   - Business impact

3. **Reproduction Steps**
   - Exact conditions to reproduce
   - Expected vs actual behavior

4. **Root Cause Analysis**
   - Why is this happening?
   - Contributing factors

5. **Proposed Solution**
   - Recommended fix approach
   - Short-term workaround (if applicable)

6. **Acceptance Criteria** (5-8 specific criteria)
   - Bug must be fixed when...
   - No regression on...
   - Performance must not degrade...

7. **Regression Testing**
   - What could break?
   - Related functionality to test
   - Test cases to add

8. **Implementation Notes**
   - Code areas to modify
   - Edge cases in the fix
   - Rollback plan (if needed)"""

        elif issue_type == "task":
            base_prompt += """

## For TASK issues, include these sections:

1. **Objective** (based on QCM answers)
   - What are we accomplishing?
   - Why now?

2. **Scope**
   - What's included
   - What's out of scope

3. **Technical Approach**
   - Recommended method
   - Architecture considerations
   - Technology choices

4. **Deliverables**
   - Code changes
   - Documentation
   - Configuration changes

5. **Success Criteria** (5-8 specific, measurable criteria)
   - Deliverable X must...
   - Performance must improve by...
   - Documentation must cover...

6. **Dependencies & Prerequisites**
   - What needs to be done first
   - External dependencies
   - Access/permissions needed

7. **Timeline & Milestones** (based on QCM answers)
   - Estimated breakdown
   - Key milestones
   - Effort estimate

8. **Implementation Notes**
   - Gotchas and edge cases
   - Testing considerations
   - Documentation requirements"""

        base_prompt += """

---

## Important Guidelines:

- Write in English language
- Be specific and concrete
- Reference the user's QCM answers directly
- Provide clear, actionable guidance
- Include code examples if relevant
- Specify any configuration needed
- Use proper Markdown formatting

Generate ONLY the specification content above. Do not add any preamble, explanation, or footer.
Start directly with the Executive Summary or Problem Statement."""

        return base_prompt

    def _call_gemini_api(self, prompt: str) -> str:
        """Call Gemini API to generate specification"""
        url = self.api_url
        api_headers = {"x-goog-api-key": self.api_key, "Content-Type": "application/json"}

        payload = {
            "contents": [
                {
                    "parts": [
                        {"text": prompt}
                    ]
                }
            ],
            "generationConfig": {
                "temperature": 0.5,  # Lower temp for more consistent spec
                "topK": 40,
                "topP": 0.95,
                "maxOutputTokens": 4096,
            }
        }

        response = requests.post(url, json=payload, headers=api_headers)
        response.raise_for_status()

        result = response.json()

        # Extract generated text
        if "candidates" in result and len(result["candidates"]) > 0:
            candidate = result["candidates"][0]
            if "content" in candidate and "parts" in candidate["content"]:
                parts = candidate["content"]["parts"]
                if len(parts) > 0 and "text" in parts[0]:
                    return parts[0]["text"]

        raise Exception(f"Unexpected API response structure: {result}")

    def _generate_template_specification(self, issue_type: str, title: str, issue_number: int) -> str:
        """Generate template-based specification as fallback"""

        base_spec = f"""# Specification - Issue #{issue_number}: {title}

> This specification was automatically generated from the QCM questionnaire responses.

## Executive Summary

Based on the QCM questionnaire responses for this issue.

"""

        if issue_type == "feature":
            base_spec += """## Functional Specifications - Feature

### 1. Scope and Objective
- Clearly define what needs to be delivered
- Identify scope: MVP vs full feature vs extensions

### 2. User Experience
- Expected interface and interactions
- Main user flow
- Priority use cases

### 3. Integration
- Integration points with existing systems
- APIs to consume or expose
- Data to synchronize

### 4. Acceptance Criteria
- [ ] Feature works as specified
- [ ] Interface is intuitive and responsive
- [ ] Performance is acceptable
- [ ] Unit tests are in place
- [ ] Documentation is up to date
- [ ] No regression on existing features

### 5. Non-Functional Requirements
- **Performance**: Response time < 1s for main operations
- **Scalability**: Support X concurrent users/operations
- **Security**: Input validation, authentication if needed
- **Accessibility**: WCAG 2.1 level AA

### 6. Dependencies and Blockers
- Identified from QCM responses
- To clarify with the product owner

### 7. Implementation Notes
- Recommended architecture: to define in team discussion
- Suggested technologies: to validate
- Edge cases to handle: test in detail

---

**Next steps:** Refer to the QCM comment for user response details."""

        elif issue_type == "bug":
            base_spec += """## Fix Specifications - Bug

### 1. Problem Statement
- Detailed bug description
- When and how it occurs
- Impact on the user

### 2. Impact Assessment
- Severity: Critical/High/Medium/Low
- Affected users
- Business impact

### 3. Reproduction Steps
- Context and preconditions
- Exact steps to reproduce
- Expected vs observed result

### 4. Proposed Solution
- Recommended fix approach
- Temporary workaround (if applicable)
- Long-term approach

### 5. Acceptance Criteria
- [ ] Bug is fixed in the code
- [ ] Tests reproduce and validate the fix
- [ ] No regression detected
- [ ] Documentation is up to date
- [ ] Behavior is consistent

### 6. Regression Testing
- Affected features to test
- Edge cases to verify
- Environments to test

### 7. Implementation Notes
- Code areas to modify
- Special considerations
- Rollback plan if needed

---

**Next steps:** Refer to the QCM comment for bug-specific details."""

        else:  # task or general
            base_spec += """## Technical Specifications - Task

### 1. Objective
- Clarify the purpose of this task
- Expected outcomes

### 2. Technical Approach
- Recommended method
- Architecture and design
- Technologies involved

### 3. Deliverables
- Code to modify/create
- Documentation to produce
- Configuration to deploy

### 4. Success Criteria
- [ ] Deliverable X is completed and tested
- [ ] Documentation is up to date
- [ ] No regression
- [ ] Performance requirements met
- [ ] Code reviews approved

### 5. Dependencies
- Prerequisites before starting
- Required access/permissions
- Blocking tasks

### 6. Timeline and Effort
- Estimate: X hours/days
- Key milestones if applicable
- Time dependencies

### 7. Implementation Notes
- Potential gotchas
- Important tests
- Special documentation

---

**Next steps:** Refer to the QCM comment for response details."""

        base_spec += f"""

---

## Technical Information
- **Issue #:** {issue_number}
- **Type:** {issue_type.upper()}
- **Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')} UTC
- **Based on:** QCM Questionnaire (see comments)
- **Note:** Specification generated with fallback template. Refer to the QCM for full response details.
"""

        return base_spec

    def save_files(self, issue_number: int, qcm_comment: str, specification: str) -> str:
        """Save responses.json and specification.md to specifications/{issue-number}/"""
        spec_dir = f"specifications/issue-{issue_number}"
        os.makedirs(spec_dir, exist_ok=True)

        # Save QCM responses snapshot
        responses = {
            "issue_number": issue_number,
            "qcm_raw": qcm_comment,
            "timestamp": datetime.now().isoformat(),
            "version": 1
        }

        responses_file = f"{spec_dir}/qcm-responses.json"
        with open(responses_file, "w", encoding="utf-8") as f:
            json.dump(responses, f, indent=2, ensure_ascii=False)

        # Save specification
        spec_file = f"{spec_dir}/specification.md"
        with open(spec_file, "w", encoding="utf-8") as f:
            f.write(specification)

        print(f"✅ Saved: {responses_file}")
        print(f"✅ Saved: {spec_file}")

        return spec_dir

    def create_sub_issue(
        self,
        owner: str,
        repo: str,
        parent_issue_number: int,
        specification: str,
        token: str
    ) -> int:
        """Create a sub-issue with the detailed specification"""

        sub_issue_title = f"SPEC: Detailed specification for issue #{parent_issue_number}"

        sub_issue_body = f"""## Specification Document

Detailed specification generated from QCM responses for issue #{parent_issue_number}.

### Generated Specification

{specification}

---

**Parent Issue:** #{parent_issue_number}
**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')} UTC
**Type:** Specification Document

This specification is ready to guide implementation. Refer to this document while implementing the parent issue.
"""

        url = f"https://api.github.com/repos/{owner}/{repo}/issues"
        headers = {
            "Authorization": f"Bearer {token}",
            "Accept": "application/vnd.github.v3+json",
        }

        payload = {
            "title": sub_issue_title,
            "body": sub_issue_body,
            "labels": ["type:task", "specification"],
        }

        response = requests.post(url, json=payload, headers=headers)
        response.raise_for_status()
        sub_issue = response.json()

        print(f"✅ Sub-issue created: #{sub_issue['number']}")
        return sub_issue["number"]


def main():
    parser = argparse.ArgumentParser(
        description="Generate specification from QCM responses using Gemini"
    )
    parser.add_argument("--issue", type=int, required=True, help="Issue number")
    parser.add_argument("--owner", help="Repository owner (default: from env)")
    parser.add_argument("--repo", help="Repository name (default: from env)")
    parser.add_argument("--save-files", action="store_true", help="Save to specifications/")
    parser.add_argument("--create-sub-issue", action="store_true", help="Create sub-issue with specification")

    args = parser.parse_args()

    # Get credentials from environment
    gemini_api_key = os.getenv("GEMINI_API_KEY")
    github_token = os.getenv("GH_TOKEN") or os.getenv("GITHUB_TOKEN")
    owner = args.owner or os.getenv("GH_OWNER") or os.getenv("GITHUB_REPOSITORY_OWNER")
    repo = args.repo or os.getenv("GH_REPO") or os.getenv("GITHUB_REPOSITORY", "").split("/")[-1]

    if not gemini_api_key:
        print("❌ GEMINI_API_KEY environment variable not set")
        print("📚 Get your API key from: https://ai.google.dev/gemini-api/docs/api-key")
        sys.exit(1)

    if not github_token:
        print("❌ GH_TOKEN or GITHUB_TOKEN environment variable not set")
        sys.exit(1)

    if not owner or not repo:
        print("❌ Could not determine repository owner/name")
        print("Set GH_OWNER and GH_REPO environment variables")
        sys.exit(1)

    # Initialize generator
    generator = SpecificationGenerator(gemini_api_key)

    try:
        print(f"📥 Fetching issue #{args.issue} from {owner}/{repo}...")
        issue_data = generator.get_issue_details(owner, repo, args.issue, github_token)

        print(f"🤖 Generating specification from QCM responses...")
        specification = generator.generate_specification(issue_data)

        if args.save_files:
            generator.save_files(args.issue, issue_data["qcm_comment"], specification)

        if args.create_sub_issue:
            sub_issue_num = generator.create_sub_issue(
                owner, repo, args.issue, specification, github_token
            )
            print(f"✅ Sub-issue #{sub_issue_num} created with specification")

        print("✅ Specification generation completed successfully!")

    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
