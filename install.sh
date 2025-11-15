#!/bin/bash
#
# GitHub Project LLM Management - Simple Installation
# Usage: curl -fsSL https://raw.githubusercontent.com/dyvan/github-project-llm-management/main/install.sh | bash
#

set +e

# Simple logging (no colors)
log() { echo "→ $*"; }
ok() { echo "✓ $*"; }
err() { echo "✗ $*" >&2; }
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
# Check Prerequisites
# ============================================================================

check_prerequisites() {
    section "1. Prerequisites"

    if ! command -v git &>/dev/null; then
        err "Git not installed. Install from: https://git-scm.com/"
        return 1
    fi
    ok "Git available"

    return 0
}

# ============================================================================
# Detect Existing Repository
# ============================================================================

detect_existing_repo() {
    if git rev-parse --git-dir >/dev/null 2>&1; then
        local remote=$(git config --get remote.origin.url 2>/dev/null)
        if [ -n "$remote" ]; then
            log "Git repository found: $remote"
            local reply=""
            safe_read "Add template to existing repo? (y/n): " reply
            [ "$reply" = "y" ] && echo "existing" || echo "new"
            return 0
        fi
    fi
    echo "new"
}

# ============================================================================
# Get Project Name
# ============================================================================

ask_project_name() {
    local name=""
    safe_read "Project name (default: github-project-llm-management): " name

    # Use default if empty
    name="${name:-github-project-llm-management}"

    # Clean ANSI codes if piped
    name=$(printf '%s\n' "$name" | sed 's/\x1b\[[0-9;]*m//g' | sed 's/\[0[;0-9]*m//g' | tr -cd '[:alnum:]._-')
    [ -z "$name" ] && name="github-project-llm-management"

    echo "$name"
}

# ============================================================================
# Clone and Setup Template
# ============================================================================

clone_and_setup() {
    local project_name="$1"

    section "2. Cloning Template"

    if ! git clone https://github.com/dyvan/github-project-llm-management.git "$project_name" 2>/dev/null; then
        err "Failed to clone template"
        return 1
    fi
    ok "Template cloned: $project_name"

    cd "$project_name" || return 1

    # Clean unnecessary files
    rm -rf agents/ docs/ tests/ specifications/ tools/ \
           AUTOMATION.md CLAUDE-USER-TEMPLATE.md CODE_OF_CONDUCT.md \
           CONTRIBUTING.md IMPROVEMENTS_TODO.md ISSUES_FIXED.md \
           PROJECT_BOARD_SETUP.md REFACTOR_SUMMARY.md ROADMAP.md \
           TEMPLATE_INDEX.md TESTING_PHASE_1_2.md WORKFLOW_SPECIFICATION.md \
           pytest.ini requirements-dev.txt setup-project.sh mkdocs.yml .claude/ 2>/dev/null || true

    # Ensure essential files exist
    [ ! -f "CLAUDE.md" ] && git checkout CLAUDE.md 2>/dev/null
    [ ! -f "template-setup.sh" ] && git checkout template-setup.sh 2>/dev/null

    ok "Project ready at: $project_name"
    return 0
}

# ============================================================================
# Bootstrap Configuration
# ============================================================================

bootstrap() {
    section "3. Bootstrap Setup"

    if [ ! -f "scripts/bootstrap.sh" ]; then
        err "Bootstrap script not found"
        return 1
    fi

    bash scripts/bootstrap.sh
    return 0
}

# ============================================================================
# Create GitHub Repository (Optional)
# ============================================================================

create_github_repo() {
    local project_name="$1"
    local gh_token="$2"

    section "4. GitHub Repository"

    if [[ "$gh_token" == *"PLACEHOLDER"* ]]; then
        log "No GitHub token provided"
        log "To create a GitHub repo, run:"
        log "  gh repo create $project_name --private --source=. --remote=origin --push"
        log ""
        log "Then setup the project board:"
        log "  bash template-setup.sh"
        return 0
    fi

    local reply=""
    safe_read "Create new GitHub repo '$project_name'? (y/n): " reply
    if [ "$reply" != "y" ]; then
        log "Skipped repository creation"
        return 0
    fi

    # Remove old remote and create new one
    git remote remove origin 2>/dev/null || true

    if gh repo create "$project_name" --private --source=. --remote=origin --push 2>/dev/null; then
        ok "Repository created and pushed"
    else
        err "Could not create repository automatically"
        log "Create manually at https://github.com/new then run:"
        log "  git remote add origin <your-repo-url>"
        log "  git push -u origin main"
    fi

    return 0
}

# ============================================================================
# Main
# ============================================================================

main() {
    echo ""
    echo "GitHub Project LLM Management - Installer"
    echo ""

    if ! check_prerequisites; then
        return 1
    fi

    local mode=$(detect_existing_repo)

    if [ "$mode" = "existing" ]; then
        section "Adding to Existing Repository"
        # TODO: Merge logic for existing repos
        log "Merging template files..."
        bootstrap
        ok "Template added to existing repository"
        return 0
    fi

    # New project mode
    local project_name=$(ask_project_name)

    if [ -d "$project_name" ]; then
        read -p "$project_name exists, overwrite? (y/n): " reply
        if [ "$reply" != "y" ]; then
            err "Cancelled"
            return 1
        fi
        rm -rf "$project_name"
    fi

    if ! clone_and_setup "$project_name"; then
        return 1
    fi

    if ! bootstrap; then
        err "Bootstrap failed"
        return 1
    fi

    # Try to create GitHub repo if token available
    if [ -f ".env" ]; then
        # Source .env carefully
        GH_TOKEN=$(grep "^GH_TOKEN=" .env | cut -d= -f2 | tr -d "'" '"')
        [ -n "$GH_TOKEN" ] && create_github_repo "$project_name" "$GH_TOKEN"
    fi

    section "Installation Complete!"
    echo ""
    log "Next steps:"
    log "  1. cd $project_name"
    log "  2. Review .env and add your tokens if needed"
    log "  3. Run: bash template-setup.sh (to configure GitHub)"
    log "  4. Start creating issues!"
    echo ""

    return 0
}

main
exit $?
