#!/bin/bash
#
# Bootstrap - Simple Setup for New Project
#
# Generates:
# - .env with API key placeholders
# - .gitignore with common exclusions
#

set +e

log() { echo "→ $*"; }
ok() { echo "✓ $*"; }
section() { echo ""; echo "== $* =="; echo ""; }

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
    section "1. Environment Configuration (.env)"

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

    # Ask for tokens
    local gh_token=""
    local gemini_key=""
    safe_read "GitHub Token (GH_TOKEN) - leave blank to skip: " gh_token
    safe_read "Gemini API Key (optional) - leave blank to skip: " gemini_key

    # Write .env
    cat > "$env_file" << EOF
# Environment Configuration
# NEVER commit this file to git - it contains secrets

# GitHub Configuration
# Get token: https://github.com/settings/tokens/new
# Required scopes: repo, project, workflow, read:org
GH_TOKEN=${gh_token:-PLACEHOLDER_GH_TOKEN_CHANGE_ME}

# Repository Context (auto-detected from git)
GH_OWNER=${gh_owner:-your-username}
GH_REPO=${gh_repo:-your-repository}

# Gemini API Key (optional, for AI features)
# Get key: https://aistudio.google.com/app/apikey
GEMINI_API_KEY=${gemini_key:-PLACEHOLDER_GEMINI_API_KEY_CHANGE_ME}

# LLM Configuration
LLM_PROVIDER=claude
LLM_MODEL=claude-3-5-sonnet-20241022

# Logging
LOG_LEVEL=INFO
EOF

    ok ".env created"
    [ -z "$gh_token" ] && log "Note: Add GH_TOKEN to .env to enable GitHub setup" || ok "GitHub token configured"
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
# Environment & Secrets
.env
.env.local
.env.*.local
*.pem
*.key
secrets/

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

# Node
node_modules/
.npm
package-lock.json

# Misc
.cache/
.temp/
*.log
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
    log "Files created:"
    log "  - .env (configuration, keep secret!)"
    log "  - .gitignore (excludes .env and common artifacts)"
    echo ""
    log "Next steps:"
    log "  1. Review .env and add your tokens:"
    log "     - GH_TOKEN for GitHub features"
    log "     - GEMINI_API_KEY for AI features (optional)"
    log ""
    log "  2. To configure GitHub project board, run:"
    log "     bash template-setup.sh"
    echo ""
}

# ============================================================================
# Main
# ============================================================================

main() {
    echo ""
    echo "Project Bootstrap"
    echo ""

    create_env || return 1
    create_gitignore || return 1
    summary

    return 0
}

main
exit $?
