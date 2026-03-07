# 🚀 GitHub Project Management - Automated Template

[![Template Validation](https://github.com/dyvan/github-project-llm-management/actions/workflows/template-validation.yml/badge.svg)](https://github.com/dyvan/github-project-llm-management/actions/workflows/template-validation.yml)
[![CI Tests](https://github.com/dyvan/github-project-llm-management/actions/workflows/ci-tests.yml/badge.svg)](https://github.com/dyvan/github-project-llm-management/actions/workflows/ci-tests.yml)

**Turnkey template for managing your projects with GitHub**
Automated Kanban • Smart Issues • AI Code Review • Zero configuration

## 💡 Who is this for?

✅ **Product managers** who want to organize their backlog without writing code
✅ **Project leads** who want automated tracking
✅ **Teams** who want GitHub Projects synced automatically
✅ **Developers** who want an LLM-managed project (Claude Code, etc.)

**No technical skills required** - Everything is automated 🎯

---

## Quick Start

There are two ways to get started:

### Option 1: New project (curl install)

```bash
curl -fsSL https://raw.githubusercontent.com/dyvan/github-project-llm-management/main/install.sh | bash
```

The script will clone the template, collect your tokens, and configure everything.

### Option 2: Existing clone

```bash
git clone https://github.com/dyvan/github-project-llm-management.git my-project
cd my-project
bash template-setup.sh
```

`template-setup.sh` is the single entry point. It handles everything:
- Creates `.env` interactively if missing (asks for GH_TOKEN, optional GEMINI_API_KEY)
- Validates prerequisites (gh CLI, Python, git)
- Sets up GitHub labels, project board, workflows, and issue templates
- Idempotent: safe to run multiple times

---

## 🎯 What does it do?

| Feature | Description |
|---------|-------------|
| 📋 **Auto Project Board** | Issues are automatically added to the Kanban board |
| 🌿 **Automatic Branches** | Add the `auto-branch` label and a branch is created |
| 📝 **Specification Questionnaire** | Gemini generates a questionnaire to clarify specs |
| 📄 **Spec Generation** | Gemini generates detailed specs from questionnaire answers |
| 🤖 **AI Code Review** | Gemini analyzes your PRs and suggests improvements |
| ✅ **Automated Tests** | Every PR is validated automatically |
| 🔄 **Synchronization** | Status updates automatically (Backlog → Done) |
| 🔒 **Auto-close Features** | Parent issues auto-close when all sub-issues are done |

**Watch the video**: [How it works in 2 minutes](../../wiki/Understanding-Workflows)

---

## 📚 Documentation

**Getting started:**
- 🚀 [Getting Started Guide](../../wiki/Getting-Started) - Setup in 5 minutes
- ⚙️ [Configuration](../../wiki/Configuration) - Customize the template
- 🎓 [Using the Template](../../wiki/Using-The-Template) - Complete guide

**Going deeper:**
- 🔧 [Scripts & Automation](../../wiki/Scripts-Reference) - Understand the scripts
- 🔀 [GitHub Automations](../../wiki/Understanding-Workflows) - How it works
- ❓ [FAQ](../../wiki/FAQ) - Frequently asked questions
- 🐛 [Troubleshooting](../../wiki/Troubleshooting) - Solving common issues

**Contributing:**
- 🤝 [Contributing Guide](../../wiki/Contributing) - How to participate
- 🎨 [Advanced Customization](../../wiki/Advanced-Customization) - Adapt to your needs

➡️ **[📖 Browse the full documentation](../../wiki)**

---

## 💬 Need help?

- ❓ **Question?** → [Discussions](../../discussions)
- 🐛 **Bug?** → [Open an issue](../../issues)
- 📖 **Documentation** → [Full Wiki](../../wiki)

---

## ⭐ Key Features

### Project Board Automation
- ✅ Issues automatically added to the backlog
- ✅ Status updates based on labels
- ✅ Custom fields (Priority, Effort, Type)

### Automatic Branch Creation
- ✅ `auto-branch` label → branch created instantly
- ✅ Automatic naming (`feat/123-issue-title`)
- ✅ Comment posted with git commands

### Specification Questionnaire with Gemini
- ✅ `plan-with-gemini` label → questionnaire generated automatically
- ✅ Questions tailored to the issue type (Feature, Bug, Task)
- ✅ Spec clarification before implementation
- ✅ Questionnaire posted as a comment on the issue

### Specification Generation with Gemini
- ✅ `generate-specification` label → detailed spec from QCM responses
- ✅ Sub-issue created with full specification document
- ✅ Branch auto-created for implementation

### AI Code Review
- ✅ Automatic PR analysis by Gemini AI
- ✅ Improvement suggestions
- ✅ Potential bug detection

### Auto-close Parent Features
- ✅ Merging a PR auto-checks if all sub-issues are done
- ✅ Parent feature issue closed automatically when complete

### Built-in Tests
- ✅ Automatic validation on every PR
- ✅ All files verified
- ✅ Code quality report

---

## 📄 License

MIT License - Free to use for any project

---

**Built with ❤️ to simplify project management on GitHub**

[Documentation](../../wiki) • [Support](../../discussions) • [Contribute](../../wiki/Contributing)
