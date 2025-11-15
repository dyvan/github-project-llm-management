#!/bin/bash
#
# 🚀 Bootstrap Script - Complete Project Setup
# GitHub Project LLM Management
#
# This script provides complete project initialization:
# 1. Generates .env with API keys
# 2. Creates .gitignore
# 3. If GH_TOKEN provided: automatically runs template-setup.sh
# 4. If GH_TOKEN not provided: shows clear instructions for manual setup
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

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# ============================================================================
# Helper Functions
# ============================================================================

banner() {
    echo -e "${CYAN}" >&2
    echo "╔════════════════════════════════════════════════════════════════╗" >&2
    echo "║  🚀 GitHub Project LLM Management - Complete Bootstrap         ║" >&2
    echo "║                                                                ║" >&2
    echo "║  This script will initialize your project completely           ║" >&2
    echo "╚════════════════════════════════════════════════════════════════╝" >&2
    echo -e "${NC}" >&2
}

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}" >&2
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}" >&2
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" >&2
}

log_error() {
    echo -e "${RED}❌ $1${NC}" >&2
}

log_section() {
    echo "" >&2
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" >&2
    echo -e "${MAGENTA}$1${NC}" >&2
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" >&2
    echo "" >&2
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

    # Check gh (GitHub CLI)
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI (gh) not found. Required for project setup."
        echo "   Install from: https://cli.github.com/"
        ((errors++))
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

    echo "" >&2
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" >&2
    echo -e "${MAGENTA}${token_name}${NC}" >&2
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" >&2
    echo "" >&2
    echo -e "${BLUE}${description}${NC}" >&2
    echo "" >&2
    echo -e "📖 Get your token here: ${CYAN}${link}${NC}" >&2
    echo "" >&2

    # Read token with validation
    local token_value=""
    local attempts=0

    while [ -z "$token_value" ] && [ $attempts -lt 3 ]; do
        # Use simple plain text prompt without ANSI codes for better visibility
        read -p "Enter your $token_name (or 'skip' to skip): " token_value

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
        "Used for creating issues, labels, project boards, and workflows
Required scopes: repo, project, workflow, read:org" \
        "https://github.com/settings/tokens/new" \
        "GH_TOKEN"

    prompt_for_token \
        "Google Gemini API Key (GEMINI_API_KEY)" \
        "Used for AI-powered QCM and specification generation (optional)" \
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
# Needed for: Creating issues, labels, project boards, and workflows
# Generate at: https://github.com/settings/tokens/new
# Required scopes: repo, project, workflow, read:org
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

run_template_setup() {
    log_section "4. Running Template Setup"

    echo -e "${BLUE}Initializing GitHub Project Board, labels, and workflows...${NC}"
    echo ""

    # Run template-setup.sh with auto-confirmation
    if [ -f "$PROJECT_ROOT/template-setup.sh" ]; then
        echo "y" | bash "$PROJECT_ROOT/template-setup.sh"
        local setup_status=$?

        if [ $setup_status -eq 0 ]; then
            log_success "Template setup completed successfully"
            return 0
        else
            log_warning "Template setup completed with warnings (see above)"
            return 0  # Don't fail completely, user can retry
        fi
    else
        log_error "template-setup.sh not found at $PROJECT_ROOT/template-setup.sh"
        return 1
    fi
}

show_next_steps_with_token() {
    log_section "5. Project Ready! Next Steps"

    echo -e "${GREEN}Your project is now fully initialized and ready to use!${NC}"
    echo ""

    echo -e "${MAGENTA}1️⃣  Configure GitHub Secrets (Recommended)${NC}"
    echo -e "${CYAN}   Add your tokens to GitHub so workflows can use them:${NC}"
    echo ""
    echo "   # Via GitHub CLI:"
    echo "   ${CYAN}gh secret set GEMINI_API_KEY < <(echo \$GEMINI_API_KEY)${NC}"
    echo ""
    echo "   # Or manually at:"
    echo "   ${CYAN}https://github.com/<owner>/<repo>/settings/secrets/actions${NC}"
    echo ""

    echo -e "${MAGENTA}2️⃣  Create Your First Issue${NC}"
    echo -e "${CYAN}   Test the setup with a real issue:${NC}"
    echo ""
    echo "   ${CYAN}gh issue create \\${NC}"
    echo "     ${CYAN}--title \"TEST: Try QCM generation\" \\${NC}"
    echo "     ${CYAN}--body \"Testing questionnaire generation\" \\${NC}"
    echo "     ${CYAN}--label \"type:feature,plan-with-gemini\"${NC}"
    echo ""

    echo -e "${MAGENTA}3️⃣  Start Using Your Project${NC}"
    echo -e "${CYAN}   Read the documentation and start creating issues:${NC}"
    echo ""
    echo "   ${CYAN}cat CLAUDE.md${NC}  (For LLM project management)"
    echo "   ${CYAN}cat README.md${NC}   (Full documentation)"
    echo ""

    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✨ Complete! Your project is initialized and ready to use!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

show_next_steps_without_token() {
    log_section "5. Important: Complete Configuration Required"

    echo -e "${YELLOW}⚠️  GH_TOKEN was not provided (using placeholder)${NC}"
    echo ""
    echo -e "${CYAN}To complete the setup, you need to:${NC}"
    echo ""

    echo -e "${MAGENTA}Step 1: Add your GitHub Token to .env${NC}"
    echo ""
    echo "   1. Generate a token at: https://github.com/settings/tokens/new"
    echo "   2. Select these scopes:"
    echo "      - ${CYAN}repo${NC} (full control of private repositories)"
    echo "      - ${CYAN}project${NC} (full control of projects)"
    echo "      - ${CYAN}workflow${NC} (update GitHub Action workflows)"
    echo "      - ${CYAN}read:org${NC} (read organization data)"
    echo "   3. Copy the token"
    echo "   4. Edit ${CYAN}.env${NC} and replace:"
    echo "      ${YELLOW}GH_TOKEN=PLACEHOLDER_GH_TOKEN_CHANGE_ME${NC}"
    echo "      with your token value"
    echo ""

    echo -e "${MAGENTA}Step 2: Run Template Setup${NC}"
    echo ""
    echo "   Once .env is updated with your GH_TOKEN, run:"
    echo ""
    echo "   ${CYAN}bash template-setup.sh${NC}"
    echo ""
    echo "   This will:"
    echo "   ${GREEN}✅${NC} Create GitHub labels"
    echo "   ${GREEN}✅${NC} Initialize Project Board"
    echo "   ${GREEN}✅${NC} Link workflows and issue templates"
    echo ""

    echo -e "${MAGENTA}Step 3: Add Optional API Keys${NC}"
    echo ""
    echo "   If you want AI-powered features, also add to .env:"
    echo "   - ${YELLOW}GEMINI_API_KEY${NC} from https://aistudio.google.com/app/apikey"
    echo ""
    echo "   Then configure GitHub Secrets:"
    echo "   ${CYAN}gh secret set GEMINI_API_KEY${NC}"
    echo ""

    echo -e "${MAGENTA}Step 4: Start Using Your Project${NC}"
    echo ""
    echo "   Create your first issue:"
    echo "   ${CYAN}gh issue create --title \"My first task\" --label \"type:feature\"${NC}"
    echo ""

    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}⏸️  Bootstrap created .env and .gitignore${NC}"
    echo -e "${YELLOW}🔐 Add your GH_TOKEN to .env, then run: bash template-setup.sh${NC}"
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

is_token_placeholder() {
    local token="$1"
    [[ "$token" == *"PLACEHOLDER"* ]]
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

    # Step 5: Determine if we can run template-setup
    if is_token_placeholder "$GH_TOKEN"; then
        # No token provided - show manual instructions
        show_next_steps_without_token
        return 0
    else
        # Token provided - run template-setup automatically
        log_section "4. Running Automatic Setup"
        echo -e "${BLUE}Using provided GH_TOKEN to automatically configure your project...${NC}"
        echo ""

        if run_template_setup; then
            show_next_steps_with_token
            return 0
        else
            log_warning "Template setup had issues, but .env and .gitignore are ready"
            show_next_steps_without_token
            return 0
        fi
    fi
}

# Run main function
main
exit $?
