#!/bin/bash
#
# 🚀 GitHub Project LLM Management - One-Line Installation
# Download and install the template with a single command:
#   curl -fsSL https://raw.githubusercontent.com/dyvan/github-project-llm-management/main/install.sh | bash
#

set +e  # Don't exit on errors, handle them explicitly

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# ============================================================================
# Helper Functions
# ============================================================================

banner() {
    echo -e "${CYAN}" >&2
    echo "╔════════════════════════════════════════════════════════════════╗" >&2
    echo "║  🚀 GitHub Project LLM Management - Installation               ║" >&2
    echo "║                                                                ║" >&2
    echo "║  This will clone and bootstrap your project                    ║" >&2
    echo "╚════════════════════════════════════════════════════════════════╝" >&2
    echo -e "${NC}" >&2
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}" >&2
}

log_error() {
    echo -e "${RED}❌ $1${NC}" >&2
}

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}" >&2
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" >&2
}

log_section() {
    echo "" >&2
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" >&2
    echo -e "${MAGENTA}$1${NC}" >&2
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" >&2
    echo "" >&2
}

# ============================================================================
# Installation Steps
# ============================================================================

ask_project_name() {
    log_section "1. Project Name"

    local project_name=""
    # Show a clearer prompt with better default
    echo -e "${BLUE}Project Name Configuration${NC}" >&2
    echo -e "  ${YELLOW}Default: github-project-llm-management${NC}" >&2
    echo "" >&2

    # Use plain read without fancy ANSI codes in prompt to avoid issues
    read -p "Enter your project name (or press Enter for default): " project_name

    if [ -z "$project_name" ]; then
        project_name="github-project-llm-management"
    fi

    # Remove all ANSI escape sequences thoroughly
    # Using two methods to ensure cleanup: sed with octal codes + sed with ESC pattern
    project_name=$(echo "$project_name" | \
        sed 's/\x1b\[[0-9;]*m//g' | \
        sed 's/\[0[;0-9]*m//g' | \
        tr -d '\n' | \
        tr -cd '[:alnum:]._-')

    echo "$project_name"
}

clone_template() {
    local project_name="$1"

    log_section "2. Cloning Template"

    log_info "Cloning template into: ${CYAN}$project_name${NC}"

    if git clone https://github.com/dyvan/github-project-llm-management.git "$project_name" 2>/dev/null; then
        log_success "Template cloned successfully"

        # Remove unnecessary files/directories to keep project clean
        log_info "Cleaning up unnecessary files..."
        cd "$project_name" || return 1

        # Keep only essential files for a new project
        # Note: claude.md is kept as it's essential documentation
        rm -rf agents/ docs/ tests/ specifications/ tools/ \
               AUTOMATION.md CLAUDE-USER-TEMPLATE.md CODE_OF_CONDUCT.md \
               CONTRIBUTING.md IMPROVEMENTS_TODO.md ISSUES_FIXED.md \
               PROJECT_BOARD_SETUP.md REFACTOR_SUMMARY.md ROADMAP.md \
               TEMPLATE_INDEX.md TESTING_PHASE_1_2.md WORKFLOW_SPECIFICATION.md \
               pytest.ini requirements-dev.txt setup-project.sh mkdocs.yml \
               .claude/ 2>/dev/null || true

        log_success "Project cleaned (kept only essentials)"
        cd - > /dev/null || return 1

        echo "$project_name"
        return 0
    else
        log_error "Failed to clone template"
        log_info "Make sure you have git installed: https://git-scm.com/"
        return 1
    fi
}

ensure_claude_md() {
    local project_dir="$1"

    # Ensure claude.md exists (it should already be at root from cloning)
    # This is the main documentation file for LLM project management
    if [ -f "$project_dir/claude.md" ]; then
        log_info "✅ claude.md documentation is present" >&2
        return 0
    else
        log_warning "claude.md not found at project root" >&2
        return 0
    fi
}

launch_bootstrap() {
    local project_dir="$1"

    log_section "3. Running Bootstrap Setup"

    log_info "Entering project directory and launching bootstrap..."
    echo ""

    # Change to project directory
    cd "$project_dir" || return 1

    # Ensure CLAUDE.md exists BEFORE bootstrap (in case bootstrap skips)
    ensure_claude_md "$(pwd)"

    # Run bootstrap
    bash scripts/bootstrap.sh

    return 0
}

# ============================================================================
# Main Flow
# ============================================================================

main() {
    banner

    # Check prerequisites
    log_section "Checking Prerequisites"

    if ! command -v git &> /dev/null; then
        log_error "Git is not installed"
        echo "   Install from: https://git-scm.com/"
        return 1
    fi

    log_success "Git is installed"
    echo ""

    # Ask for project name
    PROJECT_NAME=$(ask_project_name)

    # Check if directory already exists
    if [ -d "$PROJECT_NAME" ]; then
        log_warning "$PROJECT_NAME directory already exists"
        read -p "$(printf '%b' ${YELLOW})Overwrite? (y/n):$(printf '%b' ${NC}) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_error "Installation cancelled"
            return 1
        fi
        rm -rf "$PROJECT_NAME"
    fi

    # Clone template
    if ! clone_template "$PROJECT_NAME"; then
        return 1
    fi

    # Launch bootstrap
    if ! launch_bootstrap "$PROJECT_NAME"; then
        log_error "Bootstrap failed"
        return 1
    fi

    # Final message
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✨ Installation Complete!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}Your project is ready at: ${GREEN}$PROJECT_NAME/${NC}"
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo "  1. ${YELLOW}cd $PROJECT_NAME${NC}"
    echo "  2. Start creating issues!"
    echo ""

    return 0
}

# Run main function
main
exit $?
