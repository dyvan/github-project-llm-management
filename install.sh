#!/bin/bash
#
# GitHub Project LLM Management - Simple Installation
# Usage: curl -fsSL https://raw.githubusercontent.com/dyvan/github-project-llm-management/main/install.sh | bash
#

set +e

# Simple logging (no colors)
log() { echo "→ $*" >&2; }
ok() { echo "✓ $*" >&2; }
err() { echo "✗ $*" >&2; }
section() { echo "" >&2; echo "== $* ==" >&2; echo "" >&2; }
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
# Welcome & Collect Configuration
# ============================================================================

welcome_and_collect_info() {
    echo ""
    echo "🚀 Welcome to GitHub Project LLM Management Installer!"
    echo ""
    log "This wizard will help you set up your project in a few simple steps."
    log "We'll collect 3 pieces of information to configure your installation."
    echo ""

    # ========== 1. Project Name ==========
    section "1/3 - Project Name"
    log "This will be the name of your Git repository and local directory."
    log "Examples: my-project, awesome-app, team-dashboard"
    echo ""

    local project_name=""
    safe_read "Project name [github-project-llm-management]: " project_name

    # Use default if empty
    project_name="${project_name:-github-project-llm-management}"

    # Clean ANSI codes and special chars if piped
    project_name=$(printf '%s\n' "$project_name" | sed 's/\x1b\[[0-9;]*m//g' | sed 's/\[0[;0-9]*m//g' | tr -cd '[:alnum:]._-')
    [ -z "$project_name" ] && project_name="github-project-llm-management"

    ok "Project name: $project_name"

    # ========== 2. GitHub Token ==========
    section "2/3 - GitHub Personal Access Token (REQUIRED)"
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

    local gh_token=""
    safe_read "GitHub Token (required): " gh_token

    if [ -z "$gh_token" ]; then
        err "GitHub token is required for this template."
        err "You can configure it later by editing the .env file"
        gh_token="PLACEHOLDER_CHANGE_ME"
    else
        ok "GitHub token configured"
    fi

    # ========== 3. Gemini API Key ==========
    section "3/3 - Google Gemini API Key (OPTIONAL)"
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
    export COLLECTED_PROJECT_NAME="$project_name"
    export COLLECTED_GH_TOKEN="$gh_token"
    export COLLECTED_GEMINI_KEY="$gemini_key"

    return 0
}

# ============================================================================
# Clone and Setup Template
# ============================================================================

clone_and_setup() {
    local project_name="$1"

    section "2. Cloning Template"

    log "Downloading template from GitHub..."
    log "  Repository: github.com/dyvan/github-project-llm-management"
    log "  Destination: $project_name/"
    echo ""

    if ! git clone https://github.com/dyvan/github-project-llm-management.git "$project_name" 2>/dev/null; then
        err "Failed to clone template"
        return 1
    fi
    ok "Template downloaded"

    cd "$project_name" || return 1

    log "Removing unnecessary files..."
    # Clean unnecessary files (keep only essentials)
    rm -rf agents/ docs/ tests/ specifications/ tools/ \
           AUTOMATION.md CLAUDE-USER-TEMPLATE.md CODE_OF_CONDUCT.md \
           CONTRIBUTING.md IMPROVEMENTS_TODO.md ISSUES_FIXED.md \
           PROJECT_BOARD_SETUP.md REFACTOR_SUMMARY.md ROADMAP.md \
           TEMPLATE_INDEX.md TESTING_PHASE_1_2.md WORKFLOW_SPECIFICATION.md \
           pytest.ini requirements-dev.txt setup-project.sh mkdocs.yml .claude/ 2>/dev/null || true

    # Ensure essential files exist
    [ ! -f "CLAUDE.md" ] && git checkout CLAUDE.md 2>/dev/null
    [ ! -f "template-setup.sh" ] && git checkout template-setup.sh 2>/dev/null

    # Remove the template's remote origin
    log "Preparing for new repository..."
    git remote remove origin 2>/dev/null || true

    ok "Project ready at: $project_name/"
    return 0
}

# ============================================================================
# Create .env Configuration File
# ============================================================================

create_env_file() {
    section "Creating Configuration"

    local gh_token="$1"
    local gemini_key="$2"

    # Use the collected project name as the repo name
    local gh_repo="$COLLECTED_PROJECT_NAME"
    local gh_owner=""

    # Try to detect the GitHub username using the provided token
    if command -v gh &>/dev/null && [[ "$gh_token" != *"PLACEHOLDER"* ]]; then
        gh_owner=$(GH_TOKEN="$gh_token" gh api user -q .login 2>/dev/null || echo "")
    fi

    # Fallback to placeholder if detection fails
    if [ -z "$gh_owner" ]; then
        gh_owner="your-username"
    fi

    # Write .env file
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
GH_OWNER=${gh_owner:-your-username}
GH_REPO=${gh_repo}

# GitHub Project Board Number (configured via template-setup.sh)
GH_PROJECT_NUMBER=0

# Gemini API Key (OPTIONAL - for AI features)
# ============================================
# Get key at: https://aistudio.google.com/app/apikey
# If not set: AI features and QCM generation will be disabled
GEMINI_API_KEY=$gemini_key

# LLM Configuration
LLM_PROVIDER=claude
LLM_MODEL=claude-3-5-sonnet-20241022

# Logging
LOG_LEVEL=INFO

EOF

    ok ".env file created"

    # Create or update .gitignore
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
# Create GitHub Repository (Optional)
# ============================================================================

create_github_repo() {
    local project_name="$1"
    local gh_token="$2"

    section "Creating GitHub Repository (Optional)"

    if [[ "$gh_token" == *"PLACEHOLDER"* ]]; then
        log "GitHub token not provided - skipping repository creation"
        log ""
        log "To create a GitHub repo later, run:"
        log "  gh repo create $project_name --private --source=. --remote=origin --push"
        return 0
    fi

    if ! command -v gh &>/dev/null; then
        log "GitHub CLI not available - manual creation required"
        log "Create manually at https://github.com/new then:"
        log "  git remote add origin <your-repo-url>"
        log "  git push -u origin main"
        return 0
    fi

    local reply=""
    safe_read "Create new GitHub repository '$project_name'? (y/n): " reply
    if [ "$reply" != "y" ]; then
        log "Skipped repository creation"
        return 0
    fi

    # Remove old remote and create new one (defensive, already done in clone_and_setup)
    git remote remove origin 2>/dev/null || true

    log "Creating repository..."
    if GH_TOKEN="$gh_token" gh repo create "$project_name" --private --source=. --remote=origin --push 2>/dev/null; then
        ok "Repository created and pushed to GitHub"
    else
        err "Could not create repository automatically"
        log "Create manually at https://github.com/new then:"
        log "  git remote add origin <your-repo-url>"
        log "  git push -u origin main"
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

    # Collect all information upfront
    if ! welcome_and_collect_info; then
        err "Configuration collection interrupted"
        return 1
    fi

    local project_name="$COLLECTED_PROJECT_NAME"
    local gh_token="$COLLECTED_GH_TOKEN"
    local gemini_key="$COLLECTED_GEMINI_KEY"

    # Check if directory exists
    if [ -d "$project_name" ]; then
        local reply=""
        echo ""
        safe_read "⚠️  Directory '$project_name' already exists, overwrite? (y/n): " reply
        if [ "$reply" != "y" ]; then
            err "Installation cancelled"
            return 1
        fi
        rm -rf "$project_name"
    fi

    # Clone and setup
    if ! clone_and_setup "$project_name"; then
        return 1
    fi

    # Create .env with collected information
    if ! create_env_file "$gh_token" "$gemini_key"; then
        err "Failed to create configuration"
        return 1
    fi

    # Track if template-setup was run
    local template_setup_run=false

    # Try to create GitHub repo if token provided and valid
    if [[ "$gh_token" != *"PLACEHOLDER"* ]]; then
        create_github_repo "$project_name" "$gh_token"

        # Offer to setup project board
        echo ""
        local setup_reply=""
        safe_read "Setup GitHub project board and labels now? (y/n): " setup_reply
        if [ "$setup_reply" = "y" ]; then
            echo ""
            log "Running template setup..."
            echo ""
            cd "$project_name" || return 1
            if bash template-setup.sh; then
                echo ""
                ok "Project board configured successfully!"
                template_setup_run=true
            else
                warning "Project board setup encountered some issues"
                warning "You can retry with: cd $project_name && bash template-setup.sh"
            fi
            cd - > /dev/null
        else
            log "You can setup the project board later with: cd $project_name && bash template-setup.sh"
        fi
    fi

    # Final summary
    section "✨ Installation Complete!"
    echo ""
    ok "Your project is ready at: $project_name/"
    echo ""

    log "Next steps:"
    log ""
    log "  1. Enter your project directory:"
    log "     cd $project_name"
    log ""
    log "  2. Review your configuration:"
    log "     cat .env"
    log ""

    if [[ "$gh_token" == *"PLACEHOLDER"* ]]; then
        log "  3. ⚠️  Configure your GH_TOKEN in .env"
        log "     Edit .env and set: GH_TOKEN=<your-github-token>"
        log ""
        if [ "$template_setup_run" = true ]; then
            log "  4. Start creating issues!"
        else
            log "  4. Setup project board (if GH_TOKEN is configured):"
            log "     bash template-setup.sh"
            log ""
            log "  5. Start creating issues!"
        fi
    else
        if [ "$template_setup_run" = true ]; then
            log "  3. Start creating issues!"
        else
            log "  3. Setup project board:"
            log "     bash template-setup.sh"
            log ""
            log "  4. Start creating issues!"
        fi
    fi
    log "     gh issue create --title 'Your first task' --label type:feature"
    log ""

    if [[ "$gemini_key" == *"PLACEHOLDER"* ]]; then
        info "AI features disabled"
        log "To enable QCM and AI-assisted specifications:"
        log "  - Add your GEMINI_API_KEY to the .env file"
        log "  - Get it at: https://aistudio.google.com/app/apikey"
        echo ""
    fi

    echo ""
    ok "Happy coding! 🚀"
    echo ""

    return 0
}

main
exit $?
