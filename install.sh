#!/bin/bash
#
# 🚀 GitHub Project LLM Management - One-Line Installation
# Download and install the template with a single command:
#   curl -fsSL https://raw.githubusercontent.com/dyvan/github-project-llm-management/main/install.sh | bash
#

set -e

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
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║  🚀 GitHub Project LLM Management - Installation               ║"
    echo "║                                                                ║"
    echo "║  This will clone and bootstrap your project                    ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_section() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}$1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# ============================================================================
# Installation Steps
# ============================================================================

ask_project_name() {
    log_section "1. Project Name"

    local project_name=""
    read -p "$(echo -e ${YELLOW})Enter your project name (or press Enter for 'github-project'):$(echo -e ${NC}) " project_name

    if [ -z "$project_name" ]; then
        project_name="github-project"
    fi

    echo "$project_name"
}

clone_template() {
    local project_name="$1"

    log_section "2. Cloning Template"

    log_info "Cloning template into: ${CYAN}$project_name${NC}"

    if git clone https://github.com/dyvan/github-project-llm-management.git "$project_name" 2>/dev/null; then
        log_success "Template cloned successfully"
        echo "$project_name"
        return 0
    else
        log_error "Failed to clone template"
        log_info "Make sure you have git installed: https://git-scm.com/"
        return 1
    fi
}

launch_bootstrap() {
    local project_dir="$1"

    log_section "3. Running Bootstrap Setup"

    log_info "Entering project directory and launching bootstrap..."
    echo ""

    # Change to project directory and run bootstrap
    cd "$project_dir" || return 1

    # Run bootstrap - this will be interactive or show instructions
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
        read -p "$(echo -e ${YELLOW})Overwrite? (y/n):$(echo -e ${NC}) " -n 1 -r
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
