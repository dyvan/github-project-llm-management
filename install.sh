#!/bin/bash
#
# GitHub Project LLM Management - Template Installer
# Installs the template into an existing Git repository subdirectory
# Usage: curl -fsSL https://raw.githubusercontent.com/dyvan/github-project-llm-management/main/install.sh | bash
#

set +e

# Colors (minimal, essential only)
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'  # No Color

# Logging with colors
log() { echo "→ $*" >&2; }
ok() { echo -e "${GREEN}✓${NC} $*" >&2; }
err() { echo -e "${RED}✗${NC} $*" >&2; }
section() { echo "" >&2; echo -e "${BLUE}== $* ==${NC}" >&2; echo "" >&2; }
info() { echo "" >&2; echo "ℹ️  $*" >&2; }

# Safe read that works with piped stdin (tries /dev/tty first)
safe_read() {
    local prompt="$1"
    local var_name="$2"
    local input=""

    # Try to read from /dev/tty if available (works with curl piping)
    {
        read -p "$prompt" input < /dev/tty
    } 2>/dev/null && {
        eval "$var_name='$input'"
        return 0
    }

    # Fall back to stdin if /dev/tty not available
    read -p "$prompt" input
    eval "$var_name='$input'"
}

# ============================================================================
# Check Prerequisites
# ============================================================================

check_prerequisites() {
    section "Checking Prerequisites"

    if ! command -v git &>/dev/null; then
        err "Git not installed. Install from: https://git-scm.com/"
        return 1
    fi
    ok "Git available"

    if ! command -v gh &>/dev/null; then
        log "⚠️  GitHub CLI (gh) not installed - some features will be limited"
        log "   Install from: https://cli.github.com/"
    else
        ok "GitHub CLI available"
    fi

    return 0
}

# ============================================================================
# Detect Git Repository
# ============================================================================

detect_git_repo() {
    if git rev-parse --git-dir >/dev/null 2>&1; then
        return 0  # In a git repo
    else
        return 1  # Not in a git repo
    fi
}

# ============================================================================
# Collect Configuration
# ============================================================================

collect_info() {
    echo ""
    echo "🚀 Welcome to GitHub Project LLM Management Installer!"
    echo ""
    log "This wizard will collect your GitHub tokens to set up project management."
    log "The template will be installed in: github-project-llm-management/"
    echo ""

    # ========== 1. GitHub Token ==========
    section "1/2 - GitHub Personal Access Token (REQUIRED)"
    log "This token will be stored in your .env file and used for:"
    log "  • Creating and managing GitHub issues"
    log "  • Configuring project board automatically"
    log "  • Managing labels and workflows"
    echo ""
    log "📝 How to get your token:"
    log "   1. Go to: https://github.com/settings/tokens/new"
    log "   2. Select scopes: repo, project, workflow, read:org"
    log "   3. Generate and copy the token"
    echo ""
    log "👇 Please add your GitHub token:"
    echo ""

    local gh_token=""
    safe_read "GitHub Token: " gh_token

    if [ -z "$gh_token" ]; then
        err "GitHub token is required for this template."
        err "Please provide a valid token and try again."
        return 1
    fi
    ok "GitHub token configured"

    # ========== 2. Gemini API Key ==========
    section "2/2 - Google Gemini API Key (OPTIONAL)"
    log "This key will be stored in your .env file and enable:"
    log "  • Automatic QCM (questionnaire) generation"
    log "  • AI-assisted specification creation"
    log "  • Intelligent planning workflows"
    echo ""
    log "📝 How to get your key:"
    log "   Go to: https://aistudio.google.com/app/apikey"
    echo ""
    log "💡 You can leave this blank and add it later to your .env file"
    echo ""

    local gemini_key=""
    safe_read "Gemini API Key [optional]: " gemini_key

    if [ -z "$gemini_key" ]; then
        log "Gemini API key skipped - AI features will be disabled"
        gemini_key="PLACEHOLDER_CHANGE_ME"
    else
        ok "Gemini API key configured"
    fi

    # Export variables for use in other functions
    export COLLECTED_GH_TOKEN="$gh_token"
    export COLLECTED_GEMINI_KEY="$gemini_key"

    return 0
}

# ============================================================================
# Clone and Setup Template
# ============================================================================

clone_and_setup() {
    local template_dir="github-project-llm-management"

    section "2. Installing Template"

    log "Downloading template from GitHub..."
    log "  Repository: github.com/dyvan/github-project-llm-management"
    log "  Destination: $template_dir/"
    echo ""

    if ! git clone https://github.com/dyvan/github-project-llm-management.git "$template_dir" 2>/dev/null; then
        err "Failed to clone template"
        return 1
    fi
    ok "Template downloaded"

    # Remove git history from template (we only want the files, not the template's git history)
    log "Cleaning up template git history..."
    rm -rf "$template_dir/.git" 2>/dev/null || true
    ok "Template git history removed"

    # Setup GitHub workflows in parent repo
    # Only copy user-relevant workflows (skip template validation workflows)
    log "Setting up GitHub workflows..."

    # Create .github/workflows if it doesn't exist
    mkdir -p .github/workflows

    # Whitelist of workflows to include (user-relevant only)
    local whitelist_workflows="create-branch.yml|code-review-agent.yml|auto-close-feature.yml|generate-specification.yml|plan-with-gemini.yml|update-project.yml"

    # Copy whitelisted workflows (no prefix, clean names)
    if [ -d "$template_dir/.github/workflows" ]; then
        while IFS= read -r workflow; do
            local filename=$(basename "$workflow")

            # Check if this workflow is in the whitelist
            if echo "$filename" | grep -E "^($whitelist_workflows)$" >/dev/null; then
                cp "$workflow" ".github/workflows/$filename"
            fi
        done < <(find "$template_dir/.github/workflows" -maxdepth 1 -name "*.yml" -type f)
        ok "Workflows installed in .github/workflows/"
    fi

    # Copy issue templates
    if [ -d "$template_dir/.github/ISSUE_TEMPLATE" ]; then
        mkdir -p .github/ISSUE_TEMPLATE
        cp "$template_dir/.github/ISSUE_TEMPLATE/"*.yml .github/ISSUE_TEMPLATE/ 2>/dev/null
        ok "Issue templates copied"
    fi

    # Copy PR template
    if [ -f "$template_dir/.github/PULL_REQUEST_TEMPLATE.md" ]; then
        cp "$template_dir/.github/PULL_REQUEST_TEMPLATE.md" .github/
        ok "PR template copied"
    fi

    # Copy project config
    if [ -f "$template_dir/.github/project.yml" ] && [ ! -f ".github/project.yml" ]; then
        cp "$template_dir/.github/project.yml" .github/
        ok "GitHub project configuration copied"
    fi

    # Copy scripts needed by workflows
    mkdir -p scripts
    for script in project_sync.py auto_close_parent_feature.py generate_specification.py generate_qcm.py; do
        if [ -f "$template_dir/scripts/$script" ]; then
            cp "$template_dir/scripts/$script" "scripts/$script"
        fi
    done
    ok "Helper scripts copied to scripts/"

    # Remove .github from template directory (moved to parent)
    rm -rf "$template_dir/.github" 2>/dev/null || true

    # Clean unnecessary files from template directory
    log "Removing unnecessary files from template..."
    cd "$template_dir" || return 1

    rm -rf agents/ docs/ tests/ specifications/ tools/ \
           AUTOMATION.md CLAUDE-USER-TEMPLATE.md CODE_OF_CONDUCT.md \
           CONTRIBUTING.md IMPROVEMENTS_TODO.md ISSUES_FIXED.md \
           PROJECT_BOARD_SETUP.md REFACTOR_SUMMARY.md ROADMAP.md \
           TEMPLATE_INDEX.md TESTING_PHASE_1_2.md WORKFLOW_SPECIFICATION.md \
           pytest.ini requirements-dev.txt mkdocs.yml .claude/ \
           install.sh bootstrap.sh 2>/dev/null || true

    ok "Unnecessary files removed from template directory"

    cd - > /dev/null
    return 0
}

# ============================================================================
# Create .env Configuration File
# ============================================================================

create_env_file() {
    local gh_token="$1"
    local gemini_key="$2"
    local template_dir="github-project-llm-management"

    section "Creating Configuration"

    # Get GitHub owner/repo from current git repo
    local gh_owner=""
    local gh_repo=""

    if git rev-parse --git-dir >/dev/null 2>&1; then
        local url=$(git config --get remote.origin.url 2>/dev/null)
        if [ -n "$url" ]; then
            # Extract owner/repo from git URL (handle both https and ssh)
            gh_owner=$(echo "$url" | sed -E 's|.*[:/]([^/]+)/[^/]+\.git?$|\1|')
            gh_repo=$(echo "$url" | sed -E 's|.*[:/][^/]+/([^/]+)\.git?$|\1|')
        fi
    fi

    # Fallback if detection fails
    if [ -z "$gh_owner" ] || [ -z "$gh_repo" ]; then
        gh_owner="your-username"
        gh_repo="your-repo"
    fi

    # Write .env file at project root (not in subdirectory)
    cat > ".env" << EOF
# ============================================================================
# Environment Configuration
# ============================================================================
# ⚠️  IMPORTANT: Never commit this file - it contains secrets!
# It's already excluded by .gitignore

# GitHub Configuration (REQUIRED)
# ================================
# Personal Access Token for GitHub operations
# Get it at: https://github.com/settings/tokens/new
# Required scopes: repo, project, workflow, read:org
GH_TOKEN=$gh_token

# Repository Context (auto-detected from git)
GH_OWNER=${gh_owner}
GH_REPO=${gh_repo}

# GitHub Project Board Number (configured via template-setup.sh)
GH_PROJECT_NUMBER=0

# Gemini API Key (OPTIONAL - for AI features)
# ============================================
# Get key at: https://aistudio.google.com/app/apikey
# If not set: AI features and QCM generation will be disabled
GEMINI_API_KEY=$gemini_key

# LLM Configuration
LLM_PROVIDER=gemini
LLM_MODEL=gemini-2.0-flash

# Logging
LOG_LEVEL=INFO

EOF

    ok ".env file created"

    # Create or update .gitignore in parent repo
    if [ ! -f ".gitignore" ]; then
        log "Creating .gitignore..."
        cat > ".gitignore" << 'EOF'
# Environment & Secrets
.env
.env.local
.env.*.local
*.pem
*.key
secrets/
credentials/

# IDE & Editor
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store

# Python
__pycache__/
*.py[cod]
*$py.class
*.egg-info/
dist/
build/
.pytest_cache/

# Node
node_modules/
.npm
package-lock.json
yarn.lock

# Misc
.cache/
.temp/
*.log
EOF
        ok ".gitignore created"
    elif ! grep -q "^\.env$" ".gitignore"; then
        echo ".env" >> ".gitignore"
        ok ".env added to .gitignore"
    fi

    return 0
}

# ============================================================================
# Main
# ============================================================================

main() {
    if ! check_prerequisites; then
        return 1
    fi

    # Check if we're in a git repo
    if ! detect_git_repo; then
        err "Not in a Git repository!"
        err ""
        err "To use this template, you need to be in a Git repository."
        err "Create one first:"
        err "  mkdir my-project"
        err "  cd my-project"
        err "  git init"
        err "  bash <(curl ...) install.sh"
        return 1
    fi

    ok "In a Git repository"
    echo ""

    # Collect configuration
    if ! collect_info; then
        err "Configuration collection failed"
        return 1
    fi

    local gh_token="$COLLECTED_GH_TOKEN"
    local gemini_key="$COLLECTED_GEMINI_KEY"

    # Clone and setup template
    if ! clone_and_setup; then
        err "Failed to setup template"
        return 1
    fi

    # Create .env file
    if ! create_env_file "$gh_token" "$gemini_key"; then
        err "Failed to create configuration"
        return 1
    fi

    # Final summary
    section "✨ Installation Complete!"
    echo ""
    ok "GitHub Project LLM Management is ready!"
    echo ""

    log "Files installed:"
    log "  .env                          (your tokens - NEVER commit!)"
    log "  .github/workflows/            (6 automation workflows)"
    log "  .github/ISSUE_TEMPLATE/       (issue templates)"
    log "  .github/PULL_REQUEST_TEMPLATE.md"
    log "  scripts/                      (helper scripts)"
    log "  github-project-llm-management/ (template config & setup)"
    echo ""

    log "Next steps:"
    log ""
    log "  1. Review your configuration:"
    log "     cat .env"
    log ""
    log "  2. Setup GitHub project board and labels:"
    log "     bash github-project-llm-management/template-setup.sh"
    log ""
    log "  3. Add files to git:"
    log "     git add .github/ scripts/ github-project-llm-management/ .gitignore"
    log "     git commit -m 'feat: Add GitHub Project LLM Management'"
    log ""
    log "  4. Start creating issues:"
    log "     gh issue create --title 'Your first task' --label type:feature"
    log ""

    if [[ "$gemini_key" == *"PLACEHOLDER"* ]]; then
        info "AI features disabled"
        log "To enable QCM and AI-assisted specifications:"
        log "  - Add your GEMINI_API_KEY to .env"
        log "  - Get it at: https://aistudio.google.com/app/apikey"
        echo ""
    fi

    ok "Happy coding! 🚀"
    echo ""

    return 0
}

main
exit $?
