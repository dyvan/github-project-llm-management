# Specification Questionnaire with Gemini

## 📋 Overview

The **Specification Questionnaire** feature uses Gemini AI to automatically generate a tailored specification questionnaire when an issue is ready to be planned. This questionnaire helps clarify technical and functional details before implementation begins.

## 🎯 Purpose

This feature enables you to:

- **Clarify requirements** before development starts
- **Identify ambiguities** in issue descriptions
- **Standardize** the specification gathering process
- **Improve implementation quality** through better preparation
- **Reduce back-and-forth** between developers and product owners

## 🚀 How to Use

### Method 1: Automatic via Label

1. **Create or select an issue** in your GitHub project
2. **Move the issue to the "Ready" column** on your Project Board
3. **Add the `plan-with-gemini` label** to the issue
4. **Wait a few seconds** - A GitHub Actions workflow will trigger
5. **Check the comment** - The questionnaire will be posted automatically as a comment

### Method 2: Manual via Workflow Dispatch

1. Go to the **Actions** tab of your repository
2. Select the **"Plan with Gemini QCM"** workflow
3. Click **"Run workflow"**
4. Enter the issue number
5. Click **"Run workflow"** to start

## 📝 Types of Generated Questions

The questionnaire automatically adapts to the issue type:

### For Features (`type:feature`)

- **Feature scope** (MVP vs full feature)
- **User interface** (expected UI/UX)
- **Integration and dependencies** (affected systems)
- **Performance and scalability** (performance constraints)
- **Open question** for additional details

### For Bugs (`type:bug`)

- **Severity and impact** (bug criticality)
- **Reproducibility** (frequency and conditions)
- **Affected environment** (dev, staging, prod)
- **Fix approach** (hotfix vs full fix)
- **Open question** for logs and debugging

### For Tasks (`type:task`)

- **Main objective** (refactoring, setup, documentation)
- **Technical approach** (technical plan vs investigation)
- **Dependencies and blockers** (prerequisites)
- **Success criteria** (expected deliverables)
- **Open question** for specific constraints

## ⚙️ Configuration

### Prerequisites

1. **Gemini API Key**: Obtain a key from [Google AI Studio](https://ai.google.dev/gemini-api/docs/api-key)
2. **GitHub Secret**: Configure `GEMINI_API_KEY` in the repository secrets

### Setting Up the Secret

```bash
# In your repository's GitHub settings
Settings → Secrets and variables → Actions → New repository secret

Name: GEMINI_API_KEY
Value: <your-gemini-api-key>
```

### Environment Variables (optional)

You can also configure in `.env` for local testing:

```bash
GEMINI_API_KEY=your_gemini_api_key_here
GH_TOKEN=your_github_token_here
GH_OWNER=your_github_username
GH_REPO=project-name
```

## 🔧 Command Line Usage

The script can also be run manually:

```bash
# Generate a questionnaire for issue #42
python scripts/generate_qcm.py --issue 42

# Generate and automatically post as a comment
python scripts/generate_qcm.py --issue 42 --post-comment

# Save to a file
python scripts/generate_qcm.py --issue 42 --output qcm-issue-42.md
```

### Available Options

| Option | Description |
|--------|-------------|
| `--issue` | Issue number (required) |
| `--owner` | Repository owner (optional, defaults from env) |
| `--repo` | Repository name (optional, defaults from env) |
| `--post-comment` | Post the questionnaire as a comment on the issue |
| `--output` | Output file to save the questionnaire |

## 📊 GitHub Actions Workflow

The workflow `.github/workflows/plan-with-gemini.yml`:

- **Triggers on**: `plan-with-gemini` label added to an issue
- **Can also be triggered**: Manually via workflow_dispatch
- **Generates**: A tailored questionnaire using Gemini
- **Posts**: The questionnaire as a comment on the issue
- **Adds**: The `qcm-generated` label once complete

### Process Diagram

```
Issue created → Moved to "Ready" → "plan-with-gemini" label added
                                              ↓
                                    GitHub Actions workflow triggered
                                              ↓
                                    Python script executed
                                              ↓
                                    Gemini generates the questionnaire
                                              ↓
                                    Questionnaire posted as comment
                                              ↓
                                    "qcm-generated" label added
```

## 🎨 Questionnaire Format

The generated questionnaire follows this Markdown format:

```markdown
## 🎯 Specification Questionnaire

> This questionnaire helps you clarify the details...

### Question 1: [Question Title]

**Context:** [Why this question matters]

- [ ] Option A: [Description]
- [ ] Option B: [Description]
- [ ] Option C: [Description]

### Open Question: Additional Information

**Are there any important details to consider?**

[Space for free-form answer]

---

**Instructions:** Please check the relevant options...
```

## 🔍 Example Output

For a feature issue requesting "Add dark mode", the questionnaire might include:

1. **Scope**: Simple toggle vs fully customizable theme
2. **Persistence**: localStorage vs user preferences in DB
3. **Auto-detection**: Whether or not to respect system preferences
4. **Components**: Which UI elements should support dark mode
5. **Open question**: Specific colors, accessibility, etc.

## ❓ FAQ

### How do I customize the questions?

The questions are generated by Gemini based on the issue content. To get more relevant questions:

- Provide a detailed description in the issue
- Use the appropriate issue templates
- Add context in the "Motivation" section

### What if the questionnaire isn't generated?

1. Verify that `GEMINI_API_KEY` is configured in the secrets
2. Check the workflow logs in the Actions tab
3. Verify the Gemini API quota hasn't been exceeded
4. Retry by removing and re-adding the label

### Can I modify the questionnaire template?

Yes! Edit the `_generate_template_qcm()` method in `scripts/generate_qcm.py` to customize the fallback templates.

### Can the questionnaire be regenerated?

Yes, remove the `plan-with-gemini` label and add it again to trigger a new generation.

## 🛠️ Troubleshooting

### Error: "GEMINI_API_KEY not set"

**Solution**: Configure the `GEMINI_API_KEY` secret in the repository settings.

### Error: "API rate limit exceeded"

**Solution**: Wait a few minutes or use an API key with a higher quota.

### The workflow doesn't trigger

**Checks**:
- The exact label is `plan-with-gemini` (case-sensitive)
- The workflow file exists in `.github/workflows/`
- The GITHUB_TOKEN permissions are correct

### The comment isn't posted

**Checks**:
- The GitHub token has `issues: write` permissions
- The issue isn't locked
- Check the workflow logs for more details

## 📚 Resources

- [Gemini API Documentation](https://ai.google.dev/gemini-api/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Script generate_qcm.py](../scripts/generate_qcm.py)
- [Workflow plan-with-gemini.yml](../.github/workflows/plan-with-gemini.yml)

## 🔄 Integration with Existing Workflow

This feature integrates with the existing project management workflow:

1. **Backlog** → Issue created
2. **Ready** → `plan-with-gemini` label added → Questionnaire generated
3. **Answer the questionnaire** → Team responds to the questions
4. **In Progress** → `auto-branch` label added → Branch created
5. **In Review** → PR opened
6. **Done** → PR merged

## 🎯 Best Practices

1. **Systematically add the `plan-with-gemini` label** for complex features
2. **Answer the questionnaire** before adding the `auto-branch` label
3. **Keep the answers** in the issue for future reference
4. **Iterate if needed** by regenerating the questionnaire if questions remain
5. **Document the decisions** made following the questionnaire in the issue

## 📈 Metrics and Tracking

The `qcm-generated` label allows you to track:
- Number of issues that received a questionnaire
- Questionnaire completion rate
- Impact on implementation quality
