#!/bin/bash
#
# 🚀 Bootstrap Script - Quick Setup for GitHub Project LLM Management
# This script sets up a new project with .env configuration and .gitignore
#
# Usage: bash scripts/bootstrap.sh
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

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# ============================================================================
# Helper Functions
# ============================================================================

banner() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║  🚀 GitHub Project LLM Management - Bootstrap Setup            ║"
    echo "║                                                                ║"
    echo "║  This script will guide you through project initialization     ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_section() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}$1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

check_prerequisites() {
    log_section "1. Checking Prerequisites"

    local errors=0

    # Check bash
    if ! command -v bash &> /dev/null; then
        log_error "Bash not found"
        ((errors++))
    else
        log_success "Bash available"
    fi

    # Check git
    if ! command -v git &> /dev/null; then
        log_error "Git not found. Install from: https://git-scm.com/"
        ((errors++))
    else
        log_success "Git available"
    fi

    # Check gh (GitHub CLI) - optional but recommended
    if ! command -v gh &> /dev/null; then
        log_warning "GitHub CLI (gh) not found. Optional but recommended."
        log_info "Install from: https://cli.github.com/"
    else
        log_success "GitHub CLI available"
    fi

    echo ""

    if [ $errors -gt 0 ]; then
        log_error "Some prerequisites are missing. Please install them and try again."
        return 1
    fi

    return 0
}

prompt_for_token() {
    local token_name="$1"
    local description="$2"
    local link="$3"
    local var_name="$4"

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}$token_name${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BLUE}$description${NC}"
    echo ""
    echo -e "📖 Get your token here: ${CYAN}$link${NC}"
    echo ""

    # Read token with validation
    local token_value=""
    local attempts=0

    while [ -z "$token_value" ] && [ $attempts -lt 3 ]; do
        read -p "$(echo -e ${YELLOW})Enter your $token_name (or 'skip' to skip):$(echo -e ${NC}) " token_value

        if [ "$token_value" = "skip" ] || [ "$token_value" = "Skip" ]; then
            log_warning "Skipped $token_name (you can add it later to .env)"
            token_value="PLACEHOLDER_${var_name}_CHANGE_ME"
        elif [ -z "$token_value" ]; then
            log_error "Token cannot be empty"
            ((attempts++))
        fi
    done

    eval "$var_name='$token_value'"
}

create_env_file() {
    log_section "2. Generating .env File"

    # Prompt for tokens
    prompt_for_token \
        "GitHub Personal Access Token (GH_TOKEN)" \
        "Used for GitHub CLI operations and GitHub Actions authentication" \
        "https://github.com/settings/tokens/new" \
        "GH_TOKEN"

    prompt_for_token \
        "Google Gemini API Key (GEMINI_API_KEY)" \
        "Used for AI-powered QCM and specification generation" \
        "https://aistudio.google.com/app/apikey" \
        "GEMINI_API_KEY"

    echo ""

    # Create .env file
    local env_file="$PROJECT_ROOT/.env"

    if [ -f "$env_file" ]; then
        log_warning ".env file already exists"
        read -p "$(echo -e ${YELLOW})Overwrite existing .env? (y/n)$(echo -e ${NC}) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info ".env file kept as is"
            return 0
        fi
    fi

    # Write .env file
    cat > "$env_file" << EOF
# ============================================================================
# GitHub Project LLM Management - Environment Configuration
# ============================================================================
#
# This file contains sensitive configuration. NEVER commit this to git!
# It is added to .gitignore automatically.
#

# GitHub Configuration
# ======================
# Personal Access Token for GitHub CLI operations
# Generate at: https://github.com/settings/tokens/new
# Required scopes: repo, workflow, read:org
GH_TOKEN=$GH_TOKEN

# Gemini AI Configuration
# =======================
# Google Gemini API Key for AI-powered features:
# - QCM (Questionnaire) generation
# - Specification generation from QCM responses
# Get your key at: https://aistudio.google.com/app/apikey
GEMINI_API_KEY=$GEMINI_API_KEY

# Optional: GitHub Owner and Repo (auto-detected if not set)
# GH_OWNER=your-github-username
# GH_REPO=your-repository-name

# Optional: Debug Mode
# DEBUG=false
# LOG_LEVEL=INFO

EOF

    log_success ".env file created at: $env_file"
    log_warning "⚠️  IMPORTANT: This file contains secrets. Never commit it!"
    log_info "It's automatically excluded by .gitignore"

    return 0
}

create_gitignore() {
    log_section "3. Creating .gitignore"

    local gitignore_file="$PROJECT_ROOT/.gitignore"

    if [ -f "$gitignore_file" ]; then
        log_info ".gitignore already exists"
        # Check if .env is in gitignore
        if grep -q "^.env$" "$gitignore_file"; then
            log_success ".env is already in .gitignore"
            return 0
        else
            log_warning ".env is not in .gitignore, adding it..."
            echo ".env" >> "$gitignore_file"
            log_success "Added .env to .gitignore"
            return 0
        fi
    fi

    # Create new .gitignore with comprehensive exclusions
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
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
venv/
ENV/
env/
.venv

# ============================================================================
# Node.js
# ============================================================================
node_modules/
npm-debug.log
yarn-error.log
package-lock.json

# ============================================================================
# Ruby
# ============================================================================
Gemfile.lock
.bundle/
vendor/

# ============================================================================
# Build outputs
# ============================================================================
dist/
build/
*.log
*.tmp

# ============================================================================
# OS-specific
# ============================================================================
.DS_Store
Thumbs.db
.directory
ehthumbs.db

# ============================================================================
# Project-specific
# ============================================================================
*.backup
.venv-test
test-results/
coverage/
.pytest_cache/

EOF

    log_success ".gitignore created at: $gitignore_file"
    return 0
}

show_next_steps() {
    log_section "4. Next Steps"

    echo -e "${GREEN}Great! Your project is now bootstrapped.${NC}"
    echo ""

    echo -e "${MAGENTA}1️⃣  Configure GitHub Secrets${NC}"
    echo -e "${CYAN}   Run the following commands to set GitHub secrets:${NC}"
    echo ""
    echo "   # Configure GH_TOKEN secret"
    echo "   ${CYAN}gh secret set GH_TOKEN < <(echo \$GH_TOKEN)${NC}"
    echo ""
    echo "   # Configure GEMINI_API_KEY secret"
    echo "   ${CYAN}gh secret set GEMINI_API_KEY < <(echo \$GEMINI_API_KEY)${NC}"
    echo ""
    echo -e "   Or do it manually at:"
    echo -e "   ${CYAN}https://github.com/<owner>/<repo>/settings/secrets/actions${NC}"
    echo ""

    echo -e "${MAGENTA}2️⃣  Run Template Setup${NC}"
    echo -e "${CYAN}   Initialize your GitHub Project Board and workflows:${NC}"
    echo ""
    echo "   ${CYAN}bash template-setup.sh${NC}"
    echo ""

    echo -e "${MAGENTA}3️⃣  Create Your First Issue${NC}"
    echo -e "${CYAN}   Test the setup with a real issue:${NC}"
    echo ""
    echo "   ${CYAN}gh issue create \\${NC}"
    echo "     ${CYAN}--title \"TEST: Try QCM generation\" \\${NC}"
    echo "     ${CYAN}--body \"Testing questionnaire generation\" \\${NC}"
    echo "     ${CYAN}--label \"type:feature,plan-with-gemini\"${NC}"
    echo ""

    echo -e "${MAGENTA}4️⃣  Verify Configuration${NC}"
    echo -e "${CYAN}   Check that everything is set up correctly:${NC}"
    echo ""
    echo "   ${CYAN}bash template/scripts/validate_setup.sh${NC}"
    echo ""

    echo -e "${MAGENTA}5️⃣  Read Documentation${NC}"
    echo -e "${CYAN}   Learn how to use the template:${NC}"
    echo ""
    echo "   ${CYAN}cat CLAUDE.md${NC}  (For LLM project management)"
    echo "   ${CYAN}cat README.md${NC}   (Full documentation)"
    echo ""

    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✨ Bootstrap complete! Your project is ready to use.${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

show_files_created() {
    log_section "Files Created/Modified"

    echo -e "${GREEN}✅ .env${NC}"
    echo "   Location: $PROJECT_ROOT/.env"
    echo "   Status: Contains your API keys (keep it secret!)"
    echo ""

    echo -e "${GREEN}✅ .gitignore${NC}"
    echo "   Location: $PROJECT_ROOT/.gitignore"
    echo "   Status: Excludes .env and other secrets from git"
    echo ""
}

# ============================================================================
# Main Flow
# ============================================================================

main() {
    banner

    # Step 1: Check prerequisites
    if ! check_prerequisites; then
        return 1
    fi

    # Step 2: Create .env file
    if ! create_env_file; then
        return 1
    fi

    # Step 3: Create .gitignore
    if ! create_gitignore; then
        return 1
    fi

    # Step 4: Show what was created
    show_files_created

    # Step 5: Show next steps
    show_next_steps

    return 0
}

# Run main function
main
exit $?
