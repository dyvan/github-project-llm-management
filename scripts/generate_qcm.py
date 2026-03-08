#!/usr/bin/env python3
"""
Generate QCM (Questionnaire) for GitHub Issues using Gemini

This script generates a customized questionnaire based on the issue type
to help clarify specifications before implementation.
"""

import os
import sys
import json
import argparse
import requests
from typing import Dict, Any, List, Optional


class GeminiQCMGenerator:
    """Generate QCM using Gemini AI"""

    def __init__(self, api_key: str):
        self.api_key = api_key
        self.api_url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"

    def get_issue_details(self, owner: str, repo: str, issue_number: int, token: str) -> Dict[str, Any]:
        """Fetch issue details from GitHub API"""
        url = f"https://api.github.com/repos/{owner}/{repo}/issues/{issue_number}"
        headers = {
            "Authorization": f"Bearer {token}",
            "Accept": "application/vnd.github.v3+json",
        }

        response = requests.get(url, headers=headers)
        response.raise_for_status()
        return response.json()

    def determine_issue_type(self, labels: List[Dict[str, str]]) -> str:
        """Determine issue type from labels"""
        for label in labels:
            label_name = label.get("name", "").lower()
            if "type:feature" in label_name:
                return "feature"
            elif "type:bug" in label_name:
                return "bug"
            elif "type:task" in label_name:
                return "task"
        return "general"

    def generate_qcm(self, issue_data: Dict[str, Any]) -> str:
        """Generate QCM using Gemini based on issue details"""
        issue_type = self.determine_issue_type(issue_data.get("labels", []))
        issue_title = issue_data.get("title", "")
        issue_body = issue_data.get("body", "")
        issue_number = issue_data.get("number", "")

        # Construct prompt for Gemini
        prompt = self._build_prompt(issue_type, issue_title, issue_body, issue_number)

        # Call Gemini API
        try:
            qcm_content = self._call_gemini_api(prompt)
            return qcm_content
        except Exception as e:
            print(f"❌ Error calling Gemini API: {e}")
            # Fallback to template-based QCM
            return self._generate_template_qcm(issue_type, issue_title, issue_number)

    def _build_prompt(self, issue_type: str, title: str, body: str, issue_number: int) -> str:
        """Build optimized prompt for Gemini to generate relevant questions"""
        base_prompt = f"""You are a senior technical project manager creating a focused questionnaire.

**Issue:** #{issue_number}: {title}
**Type:** {issue_type}

**Description:**
{body}

---

Generate 3-5 focused questions to clarify specifications before implementation.

**Question Requirements:**
1. Each question must be specific to this issue and focused on critical decisions
2. Provide 3-5 clear, mutually exclusive options (or indicate if open-ended)
3. Include context explaining WHY the question matters
4. Include one open-ended question at the end for additional details
5. Use English language throughout

**Question Focus by Issue Type:**"""

        if issue_type == "feature":
            base_prompt += """

For FEATURE, prioritize:
- Scope: MVP vs complete feature vs extended scope
- User Experience: What UI/UX is expected?
- Integration: How does this integrate with existing features?
- Performance: Any specific performance requirements?
- Timeline: What's the urgency/deadline?"""
        elif issue_type == "bug":
            base_prompt += """

For BUG, prioritize:
- Reproducibility: How consistently can it be reproduced?
- Impact: How severe is this bug? (Blocking/High/Medium/Low)
- Affected Systems: Which environments/components are affected?
- Root Cause: Any suspected root cause?
- Solution Approach: Hotfix vs permanent fix?"""
        elif issue_type == "task":
            base_prompt += """

For TASK, prioritize:
- Objective: What's the main goal? (Refactoring/Optimization/Setup/Documentation)
- Technical Approach: What's the recommended method?
- Dependencies: Are there blocking dependencies?
- Success Criteria: How do we measure success?
- Timeline: Estimated effort and timeline?"""
        else:
            base_prompt += """

For GENERAL issues, prioritize:
- Objective: What are we accomplishing?
- Scope: What's included/excluded?
- Success Criteria: How do we know it's done?
- Dependencies: What's needed to start?
- Timeline: When should this be done?"""

        base_prompt += """

**Output Format (Markdown):**

## 🎯 Specification Questionnaire - {issue_type.upper()}

> This questionnaire helps clarify details before implementation.

### Question 1: [Short, clear title]

**Context:** [Why this question matters]

- [ ] Option A: [Clear description]
- [ ] Option B: [Clear description]
- [ ] Option C: [Clear description]
- [ ] Other: _[Please specify]_

### Question 2: [Title]
...
(Continue with questions)

### Open-Ended Question: Additional Details

**Are there any important details, constraints, or special considerations?**

_[Your answer here]_

---

## ✅ Next Steps

**1. Complete this questionnaire:**
   - Check the relevant options
   - Edit this comment to add your answers
   - Fill in the open-ended question with details

**2. Once completed, trigger the detailed specification generation:**

   **Via command line:**
   ```bash
   gh issue edit {issue_number} --add-label "generate-specification"
   ```

   **Or via the GitHub interface:**
   - Click on "Labels" on the right
   - Find and check `generate-specification`
   - The workflow will run automatically

**3. A detailed report will be generated automatically! 🤖**
   - Specification report created
   - Sub-issue created with the full specification
   - Development branch ready to use

---

Generate ONLY the questionnaire in Markdown format above. Do not add any text before or after. Do not include explanations or preamble."""

        return base_prompt

    def _call_gemini_api(self, prompt: str) -> str:
        """Call Gemini API to generate content"""
        url = self.api_url
        headers = {"x-goog-api-key": self.api_key, "Content-Type": "application/json"}

        payload = {
            "contents": [
                {
                    "parts": [
                        {"text": prompt}
                    ]
                }
            ],
            "generationConfig": {
                "temperature": 0.7,
                "topK": 40,
                "topP": 0.95,
                "maxOutputTokens": 2048,
            }
        }

        response = requests.post(url, json=payload, headers=headers)
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

    def _generate_template_qcm(self, issue_type: str, title: str, issue_number: int) -> str:
        """Generate template-based QCM as fallback"""
        templates = {
            "feature": """## 🎯 Specification Questionnaire - Feature

> This questionnaire helps you clarify the details of this feature before implementation.

### Question 1: Feature Scope

**Context:** Clarify the boundaries and extent of the feature.

- [ ] Option A: Minimal feature (MVP) with basic functionality only
- [ ] Option B: Complete feature with all described functionality
- [ ] Option C: Extended feature with additional enhancements
- [ ] Other: _[Please specify]_

### Question 2: User Interface

**Context:** Define the expected user experience.

- [ ] Option A: Full graphical interface with all visual elements
- [ ] Option B: Minimal functional interface
- [ ] Option C: API/CLI only (no graphical interface)
- [ ] Option D: Reuse an existing component with modifications
- [ ] Other: _[Please specify]_

### Question 3: Integration and Dependencies

**Context:** Identify affected existing systems and features.

- [ ] Option A: Isolated feature, no major dependencies
- [ ] Option B: Integration with existing features
- [ ] Option C: Requires architectural changes
- [ ] Option D: Depends on external features or third-party APIs
- [ ] Other: _[Please specify]_

### Question 4: Performance and Scalability

**Context:** Anticipate performance requirements.

- [ ] Option A: Standard performance, low data volume
- [ ] Option B: High performance needed, large volumes expected
- [ ] Option C: Real-time required
- [ ] Option D: Specific optimizations needed
- [ ] Other: _[Please specify]_

### Open-Ended Question: Additional Information

**Are there any important details, technical constraints, or security considerations we should take into account?**

_[Your answer here]_

---

**Instructions:** Please check the relevant options and add your comments. Once completed, we can start implementation with all the necessary information.
""",
            "bug": """## 🐛 Specification Questionnaire - Bug

> This questionnaire helps you clarify the details of this bug before fixing it.

### Question 1: Severity and Impact

**Context:** Assess the priority for fixing.

- [ ] Option A: Critical - Blocks usage or causes data loss
- [ ] Option B: High - Important functionality affected
- [ ] Option C: Medium - Functionality usable with workaround
- [ ] Option D: Low - Cosmetic or minor issue
- [ ] Other: _[Please specify]_

### Question 2: Reproducibility

**Context:** Understand how frequently the bug occurs.

- [ ] Option A: Always reproducible with the provided steps
- [ ] Option B: Reproducible under certain conditions
- [ ] Option C: Intermittent and difficult to reproduce
- [ ] Option D: Observed only once
- [ ] Other: _[Please specify]_

### Question 3: Affected Environment

**Context:** Identify the impacted environments.

- [ ] Option A: Production only
- [ ] Option B: All environments (dev, staging, prod)
- [ ] Option C: Development environments only
- [ ] Option D: Specific configuration or browser
- [ ] Other: _[Please specify]_

### Question 4: Preferred Fix Approach

**Context:** Define the resolution strategy.

- [ ] Option A: Quick fix (hotfix)
- [ ] Option B: Complete fix with refactoring
- [ ] Option C: Temporary workaround then fix in a future release
- [ ] Option D: In-depth investigation required before fixing
- [ ] Other: _[Please specify]_

### Open-Ended Question: Additional Information

**Are there any logs, stack traces, or additional debugging information available?**

_[Your answer here]_

---

**Instructions:** Please check the relevant options and add your comments. Once completed, we can start the fix with all the necessary information.
""",
            "task": """## 📋 Specification Questionnaire - Task

> This questionnaire helps you clarify the details of this task before execution.

### Question 1: Main Objective

**Context:** Clarify the purpose of this task.

- [ ] Option A: Refactoring / Improving existing code
- [ ] Option B: Configuration / Infrastructure setup
- [ ] Option C: Technical documentation
- [ ] Option D: Technical debt / Optimization
- [ ] Other: _[Please specify]_

### Question 2: Technical Approach

**Context:** Define the execution method.

- [ ] Option A: Follow a specific technical plan (to be detailed)
- [ ] Option B: Investigation then propose an approach
- [ ] Option C: Standard implementation with best practices
- [ ] Option D: POC/Prototype first
- [ ] Other: _[Please specify]_

### Question 3: Dependencies and Blockers

**Context:** Identify prerequisites.

- [ ] Option A: No dependencies, can start immediately
- [ ] Option B: Depends on other issues in progress
- [ ] Option C: Requires validation/approval before starting
- [ ] Option D: Requires external resources (access, credentials, etc.)
- [ ] Other: _[Please specify]_

### Question 4: Success Criteria

**Context:** Define the expected deliverables.

- [ ] Option A: Working code with tests
- [ ] Option B: Complete documentation
- [ ] Option C: Configuration deployed and validated
- [ ] Option D: Improvement metrics/benchmarks
- [ ] Other: _[Please specify]_

### Open-Ended Question: Additional Information

**Are there any time constraints, budget limitations, or specific technical considerations for this task?**

_[Your answer here]_

---

**Instructions:** Please check the relevant options and add your comments. Once completed, we can start execution with all the necessary information.
"""
        }

        template = templates.get(issue_type, templates["task"])
        return f"# Issue #{issue_number}: {title}\n\n{template}"

    def post_comment_to_issue(
        self,
        owner: str,
        repo: str,
        issue_number: int,
        comment: str,
        token: str
    ) -> bool:
        """Post QCM as a comment on the issue"""
        url = f"https://api.github.com/repos/{owner}/{repo}/issues/{issue_number}/comments"
        headers = {
            "Authorization": f"Bearer {token}",
            "Accept": "application/vnd.github.v3+json",
        }

        payload = {"body": comment}

        try:
            response = requests.post(url, json=payload, headers=headers)
            response.raise_for_status()
            print(f"✅ Comment posted successfully to issue #{issue_number}")
            return True
        except Exception as e:
            print(f"❌ Failed to post comment: {e}")
            return False


def main():
    parser = argparse.ArgumentParser(
        description="Generate QCM for GitHub issue using Gemini"
    )
    parser.add_argument("--issue", type=int, required=True, help="Issue number")
    parser.add_argument("--owner", help="Repository owner (default: from env)")
    parser.add_argument("--repo", help="Repository name (default: from env)")
    parser.add_argument("--post-comment", action="store_true", help="Post QCM as comment on issue")
    parser.add_argument("--output", help="Output file for QCM (optional)")

    args = parser.parse_args()

    # Get credentials from environment
    gemini_api_key = os.getenv("GEMINI_API_KEY")
    github_token = os.getenv("GH_TOKEN") or os.getenv("GITHUB_TOKEN")
    owner = args.owner or os.getenv("GH_OWNER") or os.getenv("GITHUB_REPOSITORY_OWNER")
    repo = args.repo or os.getenv("GH_REPO") or os.getenv("GITHUB_REPOSITORY", "").split("/")[-1]

    if not gemini_api_key:
        print("❌ GEMINI_API_KEY environment variable not set")
        print("📚 See: https://ai.google.dev/gemini-api/docs/api-key")
        sys.exit(1)

    if not github_token:
        print("❌ GH_TOKEN or GITHUB_TOKEN environment variable not set")
        sys.exit(1)

    if not owner or not repo:
        print("❌ Could not determine repository owner/name")
        print("Set GH_OWNER and GH_REPO environment variables")
        sys.exit(1)

    # Initialize generator
    generator = GeminiQCMGenerator(gemini_api_key)

    try:
        # Fetch issue details
        print(f"📥 Fetching issue #{args.issue} from {owner}/{repo}...")
        issue_data = generator.get_issue_details(owner, repo, args.issue, github_token)

        # Generate QCM
        print(f"🤖 Generating QCM using Gemini AI...")
        qcm_content = generator.generate_qcm(issue_data)

        # Output QCM
        if args.output:
            with open(args.output, "w", encoding="utf-8") as f:
                f.write(qcm_content)
            print(f"✅ QCM saved to {args.output}")
        else:
            print("\n" + "="*80)
            print(qcm_content)
            print("="*80 + "\n")

        # Post as comment if requested
        if args.post_comment:
            print(f"📤 Posting QCM as comment on issue #{args.issue}...")
            success = generator.post_comment_to_issue(
                owner, repo, args.issue, qcm_content, github_token
            )
            if not success:
                sys.exit(1)

        print("✅ QCM generation completed successfully")

    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
