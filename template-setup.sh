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

    # Load GH_TOKEN from .env if not already set
    if [ -z "$GH_TOKEN" ] && [ -f ".env" ]; then
        export GH_TOKEN=$(grep '^GH_TOKEN=' .env | cut -d'=' -f2- | tr -d '"' | tr -d "'")
        if [ -n "$GH_TOKEN" ]; then
            echo -e "${GREEN}✅ Loaded GH_TOKEN from .env${NC}"
            echo ""
        fi
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

    if ! gh repo view > /dev/null 2>&1; then
        echo -e "${RED}❌ Not in a GitHub repository${NC}"
        echo "Make sure you've pushed this to GitHub and gh is authenticated"
        exit 1
    fi

    local repo=$(gh repo view --json nameWithOwner -q '.nameWithOwner')
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
