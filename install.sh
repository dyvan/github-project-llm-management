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

detect_existing_repo() {
    log_section "1. Repository Detection"

    # Check if we're in a git repository
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local current_repo=$(git config --get remote.origin.url 2>/dev/null)
        if [ -n "$current_repo" ]; then
            echo -e "${GREEN}✅ Git repository detected!${NC}" >&2
            echo -e "  Remote: ${CYAN}$current_repo${NC}" >&2
            echo "" >&2
            echo -e "${YELLOW}Do you want to ADD the template to this existing repo?${NC}" >&2
            read -p "Add to existing repo? (y/n): " use_existing

            if [[ "$use_existing" =~ ^[Yy]$ ]]; then
                echo "existing"
                return 0
            fi
        fi
    fi

    echo "new"
    return 0
}

ask_project_name() {
    log_section "1. Project Name"

    local project_name=""
    # Show a clearer prompt with better default
    echo -e "${BLUE}Project Name Configuration${NC}" >&2
    echo -e "  ${YELLOW}Default: github-project-llm-management${NC}" >&2
    echo -e "  ${CYAN}Examples: my-project, awesome-app, team-dashboard${NC}" >&2
    echo "" >&2

    # Loop until we get a valid project name
    local attempts=0
    while [ -z "$project_name" ] && [ $attempts -lt 5 ]; do
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

        # Validate the name
        if [ -z "$project_name" ]; then
            log_error "Project name cannot be empty or contain only invalid characters"
            project_name=""
            ((attempts++))
        fi
    done

    # If still empty after all attempts, use default
    if [ -z "$project_name" ]; then
        project_name="github-project-llm-management"
    fi

    echo "$project_name"
}

merge_template_to_existing() {
    log_section "2. Merging Template into Existing Repository"

    local temp_clone="/tmp/github-project-llm-template-$$"
    local current_dir=$(pwd)

    log_info "Cloning template to temporary directory..."
    if ! git clone https://github.com/dyvan/github-project-llm-management.git "$temp_clone" 2>/dev/null; then
        log_error "Failed to clone template"
        return 1
    fi

    log_info "Merging essential template files..."

    # Copy essential files/directories
    cp -r "$temp_clone/.github" "$current_dir/.github.template" 2>/dev/null || true
    cp -r "$temp_clone/scripts" "$current_dir/scripts.template" 2>/dev/null || true
    cp -r "$temp_clone/template" "$current_dir/template" 2>/dev/null || true

    # Copy essential configuration files
    cp "$temp_clone/claude.md" "$current_dir/claude.md" 2>/dev/null || true
    cp "$temp_clone/template-setup.sh" "$current_dir/template-setup.sh" 2>/dev/null || true

    # Merge .github/workflows if it doesn't exist
    if [ ! -d "$current_dir/.github/workflows" ]; then
        mkdir -p "$current_dir/.github/workflows"
        cp -r "$temp_clone/.github/workflows/"* "$current_dir/.github/workflows/" 2>/dev/null || true
    else
        log_warning ".github/workflows already exists, copying new workflows with .template suffix"
        cp -r "$temp_clone/.github/workflows/"* "$current_dir/.github.template/workflows/" 2>/dev/null || true
    fi

    # Merge scripts
    if [ ! -d "$current_dir/scripts" ]; then
        mkdir -p "$current_dir/scripts"
        cp -r "$temp_clone/scripts/"* "$current_dir/scripts/" 2>/dev/null || true
    else
        log_warning "scripts/ already exists, merging template scripts"
        for script in "$temp_clone/scripts"/*; do
            if [ -f "$script" ]; then
                cp "$script" "$current_dir/scripts/$(basename "$script")" 2>/dev/null || true
            fi
        done
    fi

    # Cleanup
    rm -rf "$temp_clone"

    log_success "Template merged successfully into existing repository"
    return 0
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

setup_github_repo() {
    local project_dir="$1"
    local project_name="$2"
    local gh_token="$3"

    log_section "4. GitHub Repository Setup"

    # Check if GH_TOKEN was actually provided (not a placeholder)
    if [[ "$gh_token" == *"PLACEHOLDER"* ]]; then
        log_warning "No GitHub token provided - cannot create/configure new repository"
        log_info "To use all features, you'll need to:"
        echo "  1. Create a new repository on GitHub: https://github.com/new" >&2
        echo "  2. Add the repository URL as remote: git remote set-url origin <your-repo-url>" >&2
        echo "  3. Push the code: git push -u origin main" >&2
        echo "  4. Run: bash template-setup.sh" >&2
        return 0
    fi

    log_info "GitHub token found - configuring repository..." >&2

    # Remove the old remote (pointing to template repo)
    cd "$project_dir" || return 1
    git remote remove origin 2>/dev/null || true

    # Ask user if they want to create a new repo or use existing
    echo "" >&2
    echo -e "${YELLOW}Do you want to create a new GitHub repository?${NC}" >&2
    read -p "Create new repo '$project_name'? (y/n): " create_repo

    if [[ "$create_repo" =~ ^[Yy]$ ]]; then
        log_info "Creating new GitHub repository: $project_name..." >&2

        # Try to create the repo with gh CLI
        if gh repo create "$project_name" --private --source=. --remote=origin --push 2>&1; then
            log_success "Repository created successfully!"
            return 0
        else
            log_warning "Could not create repository automatically"
            log_info "You can create it manually at: https://github.com/new" >&2
            return 0
        fi
    else
        log_warning "Skipped automatic repo creation"
        log_info "Remember to create a new repo and run: git remote add origin <your-repo-url>" >&2
        return 0
    fi
}

launch_bootstrap() {
    local project_dir="$1"
    local project_name="$2"

    log_section "3. Running Bootstrap Setup"

    log_info "Entering project directory and launching bootstrap..."
    echo ""

    # Change to project directory
    cd "$project_dir" || return 1

    # Ensure CLAUDE.md exists BEFORE bootstrap (in case bootstrap skips)
    ensure_claude_md "$(pwd)"

    # Run bootstrap - this generates .env
    bash scripts/bootstrap.sh

    # Setup GitHub repository only for NEW projects (not "." which means existing repo)
    if [ "$project_name" != "." ] && [ -f ".env" ]; then
        # Source the .env to get GH_TOKEN
        set +a  # Turn off automatic export
        source .env
        set -a  # Turn on automatic export

        # Setup GitHub repo (only for new projects)
        setup_github_repo "$(pwd)" "$project_name" "$GH_TOKEN"
    fi

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

    # Detect if we're in an existing repo
    REPO_MODE=$(detect_existing_repo)

    if [ "$REPO_MODE" = "existing" ]; then
        # Existing repository mode
        log_section "Adding Template to Existing Repository"

        if ! merge_template_to_existing; then
            log_error "Failed to merge template"
            return 1
        fi

        # Launch bootstrap in current directory
        if ! launch_bootstrap "." "."; then
            log_error "Bootstrap failed"
            return 1
        fi

        echo ""
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}✨ Template Added Successfully!${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "${CYAN}Next steps:${NC}"
        echo "  1. Review merged template files"
        echo "  2. Run: ${YELLOW}bash template-setup.sh${NC} to configure your board"
        echo "  3. Commit and push the changes!"
        echo ""

    else
        # New project mode
        PROJECT_NAME=$(ask_project_name)

        # Check if directory already exists
        if [ -d "$PROJECT_NAME" ]; then
            log_warning "$PROJECT_NAME directory already exists"
            safe_read_single_char "$(printf '%b' ${YELLOW})Overwrite? (y/n):$(printf '%b' ${NC}) " REPLY
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

        # Launch bootstrap (with repo setup)
        if ! launch_bootstrap "$PROJECT_NAME" "$PROJECT_NAME"; then
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
    fi

    return 0
}

# Run main function
main
exit $?
