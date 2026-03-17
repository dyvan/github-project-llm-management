---
description: Generate Gherkin acceptance criteria for a GitHub issue
allowed-tools: Bash(gh:*), Bash(GITHUB_TOKEN=:*), Read, Grep, Glob
argument-hint: <issue-number>
---

# Write Acceptance Tests

Generate structured Gherkin acceptance criteria for issue #$ARGUMENTS and add them to the issue.

## Steps

1. **Fetch issue details**:
   - `gh issue view $ARGUMENTS --json number,title,body,labels,milestone,comments`
   - Extract: feature description, any existing acceptance criteria, technical notes

2. **Scan the codebase for context**:
   - Identify the affected routes, components, and modules from the issue description
   - Read relevant source files to understand:
     - What data models are involved
     - What routes/endpoints exist or need to be created
     - What edge cases exist (auth, empty states, validation)
   - Check for existing tests that cover related functionality
   - Check for existing `data-testid` patterns in nearby files

3. **Generate Gherkin scenarios**:
   Write scenarios following this structure:

   ```gherkin
   Feature: {feature title}

     Background:
       Given an authenticated user

     # --- Happy paths ---

     Scenario: {main user action}
       Given {precondition}
       When the user clicks [data-testid="{page}-{action}-btn"]
       And enters "value" in [data-testid="{page}-{field}-input"]
       Then [data-testid="{page}-alert-success"] contains "message"
       And [data-testid="{page}-{field}-display"] contains "value"

     # --- Edge cases ---

     Scenario: {edge case}
       ...

     # --- Error cases ---

     Scenario: {error scenario}
       ...
   ```

   **Rules for good scenarios:**
   - Each scenario tests ONE behavior
   - Cover: happy path, empty states, validation errors, unauthorized access, edge cases
   - **Use `[data-testid="..."]` selectors** for all UI interactions and verifications
   - Include data verification steps
   - Include navigation flows
   - For forms: test required fields, invalid inputs, successful submission
   - For destructive actions: test confirmation dialog
   - Aim for 5-10 scenarios per feature

   **data-testid naming convention:**
   - `{page}-{action}-btn` -- action buttons
   - `{page}-{action}-confirm` -- confirmation buttons
   - `{page}-{field}-input` -- form inputs
   - `{page}-{field}-select` -- select dropdowns
   - `{page}-{field}-display` -- read-only display
   - `{page}-{element}-badge` -- badges
   - `{page}-form` -- form container
   - `{page}-alert-{type}` -- alerts
   - `{page}-empty-state` -- empty state
   - `{page}-card` -- clickable card in list

4. **List required data-testid attributes**:
   After the Gherkin, list all `data-testid` attributes the developer must add:
   ```markdown
   ### Required data-testid
   | Attribute | Element | File |
   |-----------|---------|------|
   | `campaign-edit-btn` | Edit button | `src/routes/campaigns/[id]/+page.svelte` |
   ...
   ```

5. **Add a manual test checklist**:
   ```markdown
   ### Manual test checklist
   - [ ] Step 1: description
   - [ ] Step 2: description
   ...
   ```

6. **Save the .feature file in the repo**:
   - Write the Gherkin to `tests/acceptance/{issue-number}-{short-slug}.feature`
   - Use standard Gherkin format with `# language: en` header
   - Include issue source URL as comment at the top
   - Include the required data-testid table as a comment block at the end

7. **Update the issue on GitHub**:
   - Read the current issue body
   - Append (or replace if `## Acceptance Criteria` already exists) the Gherkin section:
     ```markdown
     ## Acceptance Criteria

     ```gherkin
     {scenarios}
     ```

     ### Required data-testid
     | Attribute | Element | File |
     ...

     ### Manual test checklist
     - [ ] ...
     ```
   - Update with: `gh issue edit $ARGUMENTS --body "..."`
   - Use a HEREDOC for the body to preserve formatting

8. **Display summary**:
   - Show the generated scenarios
   - Count: X scenarios (Y happy path, Z edge cases, W error cases)
   - Count: N data-testid attributes required
   - Confirm the issue was updated

## Important
- This is a read + update command -- only modifies the GitHub issue body, no code changes
- Always READ the existing codebase to write realistic scenarios (not generic ones)
- Scenarios must be specific enough that another agent can validate them on a preview URL
- Every When/Then step that touches UI MUST use a `[data-testid="..."]` selector
