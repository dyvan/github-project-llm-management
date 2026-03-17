---
description: Validate a feature on a preview URL by following the Gherkin acceptance criteria
allowed-tools: Bash(gh:*), Bash(GITHUB_TOKEN=:*), Bash(curl:*), Read, Grep, Glob, WebFetch
argument-hint: <pr-number>
---

# Validate Feature

Test a feature deployed on a preview environment by following the Gherkin acceptance criteria from the linked issue.

## Steps

1. **Fetch PR and linked issue**:
   - `gh pr view $ARGUMENTS --json number,title,body,headRefName,state`
   - Extract the linked issue number from PR body (e.g., "Closes #123")
   - `gh issue view {issue-number} --json number,title,body`
   - Extract the Gherkin scenarios from `## Acceptance Criteria` section
   - **If no Gherkin found**: STOP and tell the user to run `/write-acceptance-tests {issue-number}` first. Do NOT proceed without acceptance criteria.

2. **Determine the preview URL**:
   - Check PR comments or environment deployments for the preview URL
   - Common patterns: `http://pr-$ARGUMENTS.{domain}`, Vercel/Netlify preview URLs
   - Ask the user if no preview URL can be determined automatically

3. **Verify the preview is accessible**:
   - `curl -s -o /dev/null -w '%{http_code}' {preview-url}/`
   - If not 200, report the issue and check for deployment problems

4. **Execute each scenario**:
   For each Gherkin scenario, validate it using available tools:

   **For API/server-side tests:**
   - Use `curl` to test endpoints, form submissions, redirects
   - Check HTTP status codes, response bodies, redirects
   - Test form actions by POSTing form data

   **For page rendering tests:**
   - Use `curl` or `WebFetch` to fetch the page HTML
   - Check that expected elements are present (buttons, forms, text)
   - Verify `data-testid` attributes are present in the HTML
   - Verify links point to correct URLs

   **For data flow tests:**
   - Query APIs or database if accessible
   - Verify data was created/updated/deleted after form submissions

   **For auth/redirect tests:**
   - Test without auth cookie -- should redirect to login
   - Test with invalid IDs -- should return 404 or redirect

   **For each scenario, report:**
   ```
   PASS -- Scenario: {name}
   ```
   or
   ```
   FAIL -- Scenario: {name}
      Expected: {expected}
      Actual: {actual}
      Detail: {what went wrong}
   ```

5. **Test the manual checklist**:
   Go through each checklist item and verify what can be verified programmatically.
   Note items that require visual/manual verification with: `MANUAL -- requires visual verification`

6. **Generate validation report**:
   The report must be **concise**. Do NOT copy the Gherkin scenarios -- they live in the issue. Just reference them by number/name and link to the issue.

   ```markdown
   ## Validation -- PR #$ARGUMENTS

   **Preview**: {preview-url}
   **Acceptance criteria**: #{issue-number} ({N} scenarios)
   **Date**: {date}

   ### Test URLs
   | Page | URL |
   |------|-----|
   | Home | {preview-url}/ |
   | {page name} | {preview-url}/{route} |

   ### Results

   | # | Scenario | Result | Method |
   |---|----------|--------|--------|
   | 1 | {short name} | PASS | {curl POST 200 / GET 302 / DB check / etc.} |
   | 2 | {short name} | FAIL | {method} |
   | 3 | {short name} | MANUAL | JS interaction -- manual verification |

   ### Failures

   **S2: {name}** FAIL
   - **Expected**: {expected}
   - **Actual**: {actual}
   - **Cause**: {root cause if known}

   ### Summary
   **X/Y PASS -- Z/Y MANUAL -- W/Y FAIL**
   Blockers: {list or "none"}
   ```

7. **Post the report**:
   - Comment the validation report on the PR:
     `gh pr comment $ARGUMENTS --body "..."`
   - If all scenarios pass, say the PR is ready to merge
   - If failures, list what needs to be fixed
   - IMPORTANT: Do NOT copy the Gherkin scenarios into the report. Keep the report concise.

8. **Check data-testid coverage**:
   - Fetch the page HTML and check which `data-testid` attributes from the issue's "Required data-testid" table are present
   - Report missing `data-testid` as warnings:
     ```markdown
     ### Missing data-testid
     - WARNING: `campaign-edit-btn` -- not found in HTML
     ```
   - If all present: "All required data-testid attributes are present"

## Limitations
- Cannot interact with JavaScript-rendered UI (no browser). Tests are limited to:
  - Server-rendered HTML inspection
  - HTTP request/response validation
  - Database state verification (if accessible)
  - API endpoint testing
  - `data-testid` presence verification
- Scenarios requiring JS interaction (drag & drop, modals, animations) are marked as MANUAL
- For full UI testing, recommend Playwright or Cypress

## Important
- This command does NOT modify code -- it only reads, tests, and reports
- Be honest about what can and cannot be validated programmatically
- Always check deployment logs if something fails unexpectedly
