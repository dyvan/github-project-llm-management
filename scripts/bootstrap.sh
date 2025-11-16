#!/bin/bash
#
# Bootstrap - Project Setup & Configuration
#
# Generates:
# - .env with GitHub and API configuration
# - .gitignore with common exclusions
# Validates required tokens and explains setup
#

set +e

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
# Create .env
# ============================================================================

create_env() {
    section "1. Environment Configuration"

    local env_file=".env"

    if [ -f "$env_file" ]; then
        log ".env already exists"
        local reply=""
        safe_read "Overwrite? (y/n): " reply
        [ "$reply" != "y" ] && return 0
    fi

    # Get GitHub owner/repo from git if possible
    local gh_owner=""
    local gh_repo=""

    if git rev-parse --git-dir >/dev/null 2>&1; then
        local url=$(git config --get remote.origin.url 2>/dev/null)
        if [ -n "$url" ]; then
            # Extract owner/repo from git URL
            # Handle both https://github.com/user/repo.git and git@github.com:user/repo.git
            gh_owner=$(echo "$url" | sed -E 's|.*[:/]([^/]+)/[^/]+\.git?$|\1|')
            gh_repo=$(echo "$url" | sed -E 's|.*[:/][^/]+/([^/]+)\.git?$|\1|')
        fi
    fi

    # Check if GH_TOKEN is already set in environment (e.g., in CI/CD)
    local gh_token="${GH_TOKEN:-}"

    # If not in environment and we can read from user, ask for it
    if [ -z "$gh_token" ]; then
        # Prompt for GitHub Token (REQUIRED for project board features)
        echo ""
        info "GitHub Personal Access Token (REQUIRED)"
        log "Used for:"
        log "  • Creating GitHub project board"
        log "  • Creating and managing issues"
        log "  • Setting up labels and workflows"
        log ""
        log "Get your token here:"
        log "  https://github.com/settings/tokens/new"
        log ""
        log "Required scopes:"
        log "  ✓ repo (full control of repositories)"
        log "  ✓ project (full control of projects)"
        log "  ✓ workflow (update workflows)"
        log "  ✓ read:org (read organization data)"
        log ""
        safe_read "Paste your GH_TOKEN (or leave blank): " gh_token

        if [ -z "$gh_token" ]; then
            err ""
            err "GH_TOKEN is required for this template!"
            err ""
            err "To use this template, you need:"
            err "  1. Create token: https://github.com/settings/tokens/new"
            err "  2. Select required scopes (repo, project, workflow, read:org)"
            err "  3. Copy the token"
            err "  4. Edit .env and set GH_TOKEN=<your-token>"
            err "  5. Run: bash scripts/bootstrap.sh again"
            err ""
            return 1
        fi
    fi

    ok "GH_TOKEN configured"

    # Check if GEMINI_API_KEY is already set in environment
    local gemini_key="${GEMINI_API_KEY:-}"

    # If not in environment, ask user (but it's optional)
    if [ -z "$gemini_key" ]; then
        # Prompt for Gemini API Key (OPTIONAL for AI/QCM features)
        echo ""
        info "Google Gemini API Key (OPTIONAL - for AI features)"
        log "Used for:"
        log "  • QCM (Questionnaire) generation"
        log "  • Specification generation from QCM"
        log "  • AI-powered planning workflows"
        log ""
        log "Get your key here:"
        log "  https://aistudio.google.com/app/apikey"
        log ""
        log "If skipped: AI features will be disabled (add later if needed)"
        log ""
        safe_read "Paste your GEMINI_API_KEY (or leave blank to skip): " gemini_key

        if [ -z "$gemini_key" ]; then
            log "Gemini API Key skipped - AI features will be disabled"
            gemini_key="PLACEHOLDER_GEMINI_API_KEY_CHANGE_ME"
        else
            ok "GEMINI_API_KEY configured"
        fi
    else
        ok "GEMINI_API_KEY configured (from environment)"
    fi

    # Try to create GitHub project board
    local gh_project_number=""
    if [ -n "$gh_owner" ] && [ -n "$gh_repo" ]; then
        log "Creating GitHub project board..."
        local project_title="Project Board : $gh_repo"

        # Try to create the project
        gh_project_number=$(gh project create --owner "$gh_owner" --title "$project_title" --format json 2>/dev/null | grep -o '"number":[0-9]*' | cut -d: -f2)

        if [ -n "$gh_project_number" ]; then
            ok "GitHub project board created (#$gh_project_number)"
        else
            log "Note: Could not auto-create project board - you can create it manually"
        fi
    fi

    # Write .env
    cat > "$env_file" << EOF
# ============================================================================
# Environment Configuration
# ============================================================================
# NEVER commit this file to git - it contains secrets!
# It's already excluded by .gitignore

# GitHub Configuration (REQUIRED)
# ===============================
# Personal Access Token for GitHub operations
# Get it at: https://github.com/settings/tokens/new
# Required scopes: repo, project, workflow, read:org
GH_TOKEN=$gh_token

# Repository Context (auto-detected from git)
GH_OWNER=${gh_owner:-your-username}
GH_REPO=${gh_repo:-your-repository}

# GitHub Project Board (auto-created if possible)
# Find in your GitHub Projects v2 URL: github.com/users/YOUR_NAME/projects/NUMBER
GH_PROJECT_NUMBER=${gh_project_number:-0}

# Gemini API Key (OPTIONAL - for AI/QCM features)
# ================================================
# Get key at: https://aistudio.google.com/app/apikey
# If not set: AI features and QCM generation will be disabled
GEMINI_API_KEY=$gemini_key

# LLM Configuration
LLM_PROVIDER=claude
LLM_MODEL=claude-3-5-sonnet-20241022

# Logging
LOG_LEVEL=INFO

EOF

    ok ".env created with configuration"
    return 0
}

# ============================================================================
# Create .gitignore
# ============================================================================

create_gitignore() {
    section "2. Git Ignore (.gitignore)"

    local gitignore_file=".gitignore"

    if [ -f "$gitignore_file" ]; then
        if grep -q "^\.env$" "$gitignore_file"; then
            ok ".env already in .gitignore"
            return 0
        else
            log ".env not in .gitignore, adding..."
            echo ".env" >> "$gitignore_file"
            ok "Added .env to .gitignore"
            return 0
        fi
    fi

    # Create comprehensive .gitignore
    cat > "$gitignore_file" << 'EOF'
# ============================================================================
# Environment & Secrets
# ============================================================================
.env
.env.local
.env.*.local
*.pem
*.key
secrets/
credentials/

# ============================================================================
# IDE & Editor
# ============================================================================
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store
.sublime-project
.sublime-workspace

# ============================================================================
# Python
# ============================================================================
__pycache__/
*.py[cod]
*$py.class
*.egg-info/
dist/
build/
.pytest_cache/

# ============================================================================
# Node
# ============================================================================
node_modules/
.npm
package-lock.json
yarn.lock

# ============================================================================
# Misc
# ============================================================================
.cache/
.temp/
*.log
.DS_Store
EOF

    ok ".gitignore created"
    return 0
}

# ============================================================================
# Summary
# ============================================================================

summary() {
    section "Setup Complete"
    echo ""
    ok "Files created:"
    log "  • .env (configuration with GitHub tokens and project board)"
    log "  • .gitignore (excludes .env and artifacts)"
    echo ""

    # Check what features are enabled
    local gemini_status="disabled (add GEMINI_API_KEY to enable)"
    if [ -f ".env" ] && grep -q "PLACEHOLDER_GEMINI" .env; then
        gemini_status="disabled (add key to .env)"
    elif [ -f ".env" ] && ! grep -q "PLACEHOLDER_GEMINI" .env; then
        gemini_status="enabled ✓"
    fi

    # Check project board status
    local project_status="not created yet"
    if [ -f ".env" ] && grep -q "GH_PROJECT_NUMBER=" .env; then
        local proj_num=$(grep "^GH_PROJECT_NUMBER=" .env | cut -d= -f2)
        if [ "$proj_num" != "0" ]; then
            project_status="created ✓ (#$proj_num)"
        fi
    fi

    echo ""
    info "Feature Status:"
    log "  • GitHub Repository: configured ✓"
    log "  • GitHub Project Board: $project_status"
    log "  • Issue Management: ready ✓"
    log "  • AI/QCM Features: $gemini_status"
    echo ""

    info "Next steps:"
    log "  1. Review .env configuration:"
    log "     cat .env"
    log ""
    log "  2. (Optional) Add GEMINI_API_KEY for AI/QCM features"
    log ""
    log "  3. Configure custom fields on project board:"
    log "     bash template-setup.sh"
    log ""
    log "  4. Start creating issues:"
    log "     gh issue create --title 'Your task' --label type:feature"
    echo ""
}

# ============================================================================
# Main
# ============================================================================

main() {
    echo ""
    echo "Project Bootstrap - Environment Setup"
    echo ""

    if ! create_env; then
        err "Bootstrap failed - GH_TOKEN is required"
        return 1
    fi

    if ! create_gitignore; then
        err "Failed to create .gitignore"
        return 1
    fi

    summary

    return 0
}

main
exit $?
