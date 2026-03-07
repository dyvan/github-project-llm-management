# ❓ Frequently Asked Questions (FAQ)

## Installation

### Do I need to know how to code?
No! The template is designed for non-developers. Just follow the [Getting Started guide](Getting-Started).

### What are the prerequisites?
- Git
- GitHub CLI
- Python 3.11+

All are easy to install, see [Getting Started](Getting-Started).

### How long does installation take?
About 5 minutes following the guide.

## Usage

### How do I create an issue that triggers automation?
```bash
gh issue create --title "My task" --label "type:feature,auto-branch"
```

### Can I disable Gemini AI?
Yes, simply don't configure `GEMINI_API_KEY`. The review will work in basic mode.

### How do I customize labels?
Edit `setup-project.sh` lines 86+ and re-run the script.

### Does it work with private repos?
Yes, fully.

## Technical

### Which model is used?
`gemini-2.0-flash` by default. Configurable in the workflow variables.

### Can I use a different LLM?
Currently, all workflows use Gemini. To use a different provider, you need to modify the workflows manually.

### Do the workflows consume a lot of GitHub Actions minutes?
No, very few. About 1-2 minutes per workflow.

### Can I use multiple projects?
Yes, specify `--project NUMBER` in the scripts.

## Troubleshooting

### "Project not found"
Check `.github/project.yml` and `gh project list --owner YOUR_USERNAME`.

### Workflows not triggering
Check Settings → Actions → "Allow all actions".

### More questions?
- [Troubleshooting](Troubleshooting)
- [Discussions](https://github.com/dyvan/github-project-llm-management/discussions)

[⬅️ Troubleshooting](Troubleshooting) | [➡️ Advanced](Advanced-Customization)
