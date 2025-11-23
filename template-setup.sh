#!/bin/bash
# Template Setup - Main entry point for project initialization
# This is the ONLY script users should run from the root

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Show help
show_help() {
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║   🚀 Project Setup - Quick Start                             ║
║                                                              ║
║   This initializes your project with GitHub management      ║
║   features (Project Boards, Labels, Workflows, etc.)        ║
╚══════════════════════════════════════════════════════════════╝

QUICK START (3 steps):

  1. Copy environment template:
     cp .env.example .env

  2. Edit .env with your settings:
     - GH_TOKEN: Your GitHub Personal Access Token
     - CLAUDE_API_KEY: Your Anthropic Claude API key (optional)

  3. Run setup:
     bash template-setup.sh

WHY THIS SCRIPT:
  - ✅ Creates GitHub labels automatically
  - ✅ Sets up GitHub Project v2 board
  - ✅ Links workflows from template/
  - ✅ Configures issue templates
  - ✅ Idempotent (safe to run multiple times)

BEFORE YOU START:
  Prerequisites:
    ✅ GitHub CLI (gh) installed
    ✅ Python 3.8+
    ✅ jq (optional, for better output)

  Setup GitHub CLI:
    gh auth login

OPTIONS:
  --help              Show this help
  --skip-completed    Skip already done steps
  --dry-run          Preview changes without applying
  --reset-state      Start fresh (discard previous state)
  --verbose          Show detailed output

DOCUMENTATION:
  📖 Full guide: README.md
  🤖 For LLMs: CLAUDE.md
  ⚙️  Advanced: template/docs/

EXAMPLES:

  # First time (interactive)
  bash template-setup.sh

  # Check existing setup
  bash template-setup.sh --skip-completed

  # Start over
  bash template-setup.sh --reset-state

  # Debug issues
  bash template-setup.sh --verbose

EOF
}

# Check if --help requested
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_help
    exit 0
fi

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
        ((errors++))
    else
        echo -e "${GREEN}✅ GitHub CLI${NC}"
    fi

    # Check Python
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}❌ Python 3 not found${NC}"
        echo "   Install Python 3.8 or higher"
        ((errors++))
    else
        echo -e "${GREEN}✅ Python 3${NC}"
    fi

    # Check Git
    if ! command -v git &> /dev/null; then
        echo -e "${RED}❌ Git not found${NC}"
        echo "   Install from: https://git-scm.com/"
        ((errors++))
    else
        echo -e "${GREEN}✅ Git${NC}"
    fi

    # Check GitHub CLI auth
    if command -v gh &> /dev/null; then
        if ! gh auth status &> /dev/null; then
            echo -e "${YELLOW}⚠️  GitHub CLI not authenticated${NC}"
            echo "   Run: gh auth login"
            ((errors++))
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

    # Load environment variables from .env if they exist
    # Check both script directory and current directory
    local env_file=""
    if [ -f "$SCRIPT_DIR/.env" ]; then
        env_file="$SCRIPT_DIR/.env"
    elif [ -f ".env" ]; then
        env_file=".env"
    fi

    if [ -n "$env_file" ]; then
        # Load GH_TOKEN
        if [ -z "$GH_TOKEN" ]; then
            export GH_TOKEN=$(grep '^GH_TOKEN=' "$env_file" | cut -d'=' -f2- | tr -d '"' | tr -d "'")
            if [ -n "$GH_TOKEN" ]; then
                echo -e "${GREEN}✅ Loaded GH_TOKEN from .env${NC}"
            fi
        fi

        # Load GH_OWNER
        if [ -z "$GH_OWNER" ]; then
            export GH_OWNER=$(grep '^GH_OWNER=' "$env_file" | cut -d'=' -f2- | tr -d '"' | tr -d "'")
            if [ -n "$GH_OWNER" ]; then
                echo -e "${GREEN}✅ Loaded GH_OWNER from .env${NC}"
            fi
        fi

        # Load GH_REPO
        if [ -z "$GH_REPO" ]; then
            export GH_REPO=$(grep '^GH_REPO=' "$env_file" | cut -d'=' -f2- | tr -d '"' | tr -d "'")
            if [ -n "$GH_REPO" ]; then
                echo -e "${GREEN}✅ Loaded GH_REPO from .env${NC}"
            fi
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

    # Ask for confirmation
    read -p "$(echo -e ${YELLOW})Continue setup for this repository? (y/n)$(echo -e ${NC}) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled."
        exit 0
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
