#!/bin/bash
# Template Setup - Single entry point for project initialization
# Handles both .env creation (if missing) and full project setup
#
# Usage:
#   bash template-setup.sh          # Interactive setup
#   bash template-setup.sh --help   # Show help

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Non-interactive mode (--yes / -y)
YES_MODE=false

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

# Show help
show_help() {
    cat << 'EOF'
Project Setup - Single entry point for project initialization

This script handles everything:
  1. Creates .env configuration (if missing)
  2. Validates prerequisites
  3. Sets up GitHub labels, project board, workflows, and templates

USAGE:
  bash template-setup.sh

OPTIONS:
  --help              Show this help
  --yes, -y           Non-interactive mode (skip all prompts, use defaults)
  --skip-completed    Skip already done steps
  --dry-run           Preview changes without applying
  --reset-state       Start fresh (discard previous state)
  --verbose           Show detailed output

PREREQUISITES:
  - GitHub CLI (gh) installed and authenticated
  - Python 3.8+
  - jq (optional, for better output)

EXAMPLES:
  # First time (interactive)
  bash template-setup.sh

  # Check existing setup
  bash template-setup.sh --skip-completed

  # Start over
  bash template-setup.sh --reset-state

EOF
}

# Parse flags before main
PASS_THROUGH_ARGS=()
for arg in "$@"; do
    case "$arg" in
        --help|-h)
            show_help
            exit 0
            ;;
        --yes|-y)
            YES_MODE=true
            ;;
        *)
            PASS_THROUGH_ARGS+=("$arg")
            ;;
    esac
done
set -- "${PASS_THROUGH_ARGS[@]}"

# ============================================================================
# Ensure .env exists (merged from bootstrap.sh)
# ============================================================================

ensure_env() {
    local env_file=".env"

    if [ -f "$env_file" ]; then
        echo -e "${GREEN}Found existing .env file${NC}"
        return 0
    fi

    echo -e "${YELLOW}No .env file found - creating one now...${NC}"
    echo ""

    # Get GitHub owner/repo from git if possible
    local gh_owner=""
    local gh_repo=""

    if git rev-parse --git-dir >/dev/null 2>&1; then
        local url=$(git config --get remote.origin.url 2>/dev/null)
        if [ -n "$url" ]; then
            gh_owner=$(echo "$url" | sed -E 's|.*[:/]([^/]+)/[^/]+\.git?$|\1|')
            gh_repo=$(echo "$url" | sed -E 's|.*[:/][^/]+/([^/]+)\.git?$|\1|')
        fi
    fi

    # Check if GH_TOKEN is already set in environment (e.g., in CI/CD)
    local gh_token="${GH_TOKEN:-}"

    if [ -z "$gh_token" ]; then
        if [ "$YES_MODE" = true ]; then
            echo -e "${RED}GH_TOKEN is required but --yes mode cannot prompt for it.${NC}"
            echo "  Set GH_TOKEN in environment before using --yes."
            return 1
        fi
        echo -e "${BLUE}GitHub Personal Access Token (REQUIRED)${NC}"
        echo "  Used for: issues, labels, project board, workflows"
        echo "  Get one at: https://github.com/settings/tokens/new"
        echo "  Required scopes: repo, project, workflow, read:org"
        echo ""
        safe_read "Paste your GH_TOKEN (or leave blank): " gh_token

        if [ -z "$gh_token" ]; then
            echo -e "${RED}GH_TOKEN is required for this template.${NC}"
            echo "  1. Create token: https://github.com/settings/tokens/new"
            echo "  2. Select scopes: repo, project, workflow, read:org"
            echo "  3. Copy the token"
            echo "  4. Create .env from .env.example and set GH_TOKEN"
            echo "  5. Run: bash template-setup.sh"
            return 1
        fi
    fi

    echo -e "${GREEN}GH_TOKEN configured${NC}"

    # Check if GEMINI_API_KEY is already set in environment
    local gemini_key="${GEMINI_API_KEY:-}"

    if [ -z "$gemini_key" ]; then
        if [ "$YES_MODE" = true ]; then
            echo "  Gemini API Key skipped (--yes mode) - AI features will be disabled"
            gemini_key="PLACEHOLDER_GEMINI_API_KEY_CHANGE_ME"
        else
            echo ""
            echo -e "${BLUE}Google Gemini API Key (OPTIONAL - for AI features)${NC}"
            echo "  Used for: QCM generation, specification generation, AI planning"
            echo "  Get one at: https://aistudio.google.com/app/apikey"
            echo "  If skipped: AI features will be disabled (add later if needed)"
            echo ""
            safe_read "Paste your GEMINI_API_KEY (or leave blank to skip): " gemini_key

            if [ -z "$gemini_key" ]; then
                echo "  Gemini API Key skipped - AI features will be disabled"
                gemini_key="PLACEHOLDER_GEMINI_API_KEY_CHANGE_ME"
            else
                echo -e "${GREEN}GEMINI_API_KEY configured${NC}"
            fi
        fi
    else
        echo -e "${GREEN}GEMINI_API_KEY configured (from environment)${NC}"
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

# GitHub Project Board (configured during setup)
# Find in your GitHub Projects v2 URL: github.com/users/YOUR_NAME/projects/NUMBER
GH_PROJECT_NUMBER=0

# Gemini API Key (OPTIONAL - for AI/QCM features)
# ================================================
# Get key at: https://aistudio.google.com/app/apikey
# If not set: AI features and QCM generation will be disabled
GEMINI_API_KEY=$gemini_key

# LLM Configuration
LLM_PROVIDER=gemini
LLM_MODEL=gemini-2.0-flash

# Logging
LOG_LEVEL=INFO

EOF

    echo ""
    echo -e "${GREEN}.env file created${NC}"

    # Ensure .env is in .gitignore
    if [ -f ".gitignore" ]; then
        if ! grep -q "^\.env$" ".gitignore"; then
            echo ".env" >> ".gitignore"
            echo -e "${GREEN}Added .env to .gitignore${NC}"
        fi
    fi

    return 0
}

# Print banner
banner() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  🚀 Setting up your GitHub project...          ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Validation
validate_env() {
    echo -e "${BLUE}Checking prerequisites...${NC}"
    echo ""

    local errors=0

    # Check gh
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}❌ GitHub CLI (gh) not found${NC}"
        echo "   Install from: https://cli.github.com/"
        errors=$((errors + 1))
    else
        echo -e "${GREEN}✅ GitHub CLI${NC}"
    fi

    # Check Python
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}❌ Python 3 not found${NC}"
        echo "   Install Python 3.8 or higher"
        errors=$((errors + 1))
    else
        echo -e "${GREEN}✅ Python 3${NC}"
    fi

    # Check Git
    if ! command -v git &> /dev/null; then
        echo -e "${RED}❌ Git not found${NC}"
        echo "   Install from: https://git-scm.com/"
        errors=$((errors + 1))
    else
        echo -e "${GREEN}✅ Git${NC}"
    fi

    # Check GitHub CLI auth
    if command -v gh &> /dev/null; then
        if ! gh auth status &> /dev/null; then
            echo -e "${YELLOW}⚠️  GitHub CLI not authenticated${NC}"
            echo "   Run: gh auth login"
            errors=$((errors + 1))
        else
            echo -e "${GREEN}✅ GitHub authenticated${NC}"
        fi
    fi

    # Optional: jq
    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}⚠️  jq not found (optional but recommended)${NC}"
        echo "   Install from: https://stedolan.github.io/jq/"
    else
        echo -e "${GREEN}✅ jq${NC}"
    fi

    echo ""

    if [ $errors -gt 0 ]; then
        echo -e "${RED}❌ Some prerequisites are missing${NC}"
        return 1
    fi

    echo -e "${GREEN}✅ All prerequisites met!${NC}"
    echo ""
    return 0
}

# Main
main() {
    banner

    # Step 0: Ensure .env exists (creates interactively if missing)
    if ! ensure_env; then
        echo -e "${RED}Setup cannot continue without .env configuration${NC}"
        exit 1
    fi

    # Load environment variables from .env
    local env_file=""
    if [ -f ".env" ]; then
        env_file=".env"
    elif [ -f "$SCRIPT_DIR/.env" ]; then
        env_file="$SCRIPT_DIR/.env"
    fi

    if [ -n "$env_file" ]; then
        # Load all env vars from .env file
        while IFS='=' read -r key value; do
            # Skip comments and empty lines
            [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue
            # Trim whitespace and quotes
            value=$(echo "$value" | tr -d '"' | tr -d "'")
            # Export from .env (overrides environment for project-specific config)
            if [ -n "$value" ]; then
                export "$key=$value"
                echo -e "${GREEN}✅ Loaded $key from .env${NC}"
            fi
        done < "$env_file"

        # gh CLI uses GITHUB_TOKEN — override with GH_TOKEN from .env
        # This ensures the project-specific token is used, not a global one
        if [ -n "$GH_TOKEN" ]; then
            export GITHUB_TOKEN="$GH_TOKEN"
            echo -e "${GREEN}✅ Set GITHUB_TOKEN from GH_TOKEN${NC}"
        fi
        echo ""
    fi

    # Validate environment
    if ! validate_env; then
        echo -e "${RED}Please install missing prerequisites and try again${NC}"
        exit 1
    fi

    # Confirm repo context
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}❌ Not in a git repository${NC}"
        echo "Please run this script from your project root"
        exit 1
    fi

    # Use GH_OWNER and GH_REPO from .env if available
    local repo=""
    if [ -n "$GH_OWNER" ] && [ -n "$GH_REPO" ]; then
        repo="$GH_OWNER/$GH_REPO"

        # Verify the GitHub repository exists and is accessible
        if ! gh repo view "$repo" > /dev/null 2>&1; then
            echo -e "${RED}❌ GitHub repository not found or not accessible${NC}"
            echo "   Repository: $repo"
            echo "   Make sure:"
            echo "   1. The repository exists on GitHub"
            echo "   2. Your GH_TOKEN has access to it"
            echo "   3. Check GH_OWNER and GH_REPO in .env"
            exit 1
        fi
    else
        # Fallback to gh repo view (requires remote origin)
        if ! gh repo view > /dev/null 2>&1; then
            echo -e "${RED}❌ Could not determine GitHub repository${NC}"
            echo "   Either:"
            echo "   1. Set GH_OWNER and GH_REPO in .env, OR"
            echo "   2. Add a git remote: git remote add origin <url>"
            exit 1
        fi

        repo=$(gh repo view --json nameWithOwner -q '.nameWithOwner')
    fi

    echo -e "${CYAN}Repository: $repo${NC}"
    echo ""

    # Ask for confirmation (skip in non-interactive mode)
    if [ "$YES_MODE" = true ]; then
        echo -e "${GREEN}Auto-confirming setup (--yes mode)${NC}"
    else
        read -p "$(echo -e ${YELLOW})Continue setup for this repository? (y/n)$(echo -e ${NC}) " -n 1 -r || true
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Setup cancelled."
            exit 0
        fi
    fi

    echo ""

    # Run actual setup from template
    echo -e "${BLUE}Launching setup from template...${NC}"
    echo ""

    bash "${SCRIPT_DIR}/template/.setup/setup.sh" "$@"
    local setup_status=$?

    if [ $setup_status -eq 0 ]; then
        echo ""
        echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║  ✨ Setup Complete!                            ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${CYAN}Next steps:${NC}"
        echo "1. Read ${CYAN}CLAUDE.md${NC} to understand LLM project management"
        echo "2. Check your GitHub Project board"
        echo "3. Start creating issues!"
        echo ""
    else
        echo ""
        echo -e "${RED}Setup failed. Check errors above.${NC}"
    fi

    exit $setup_status
}

main "$@"
