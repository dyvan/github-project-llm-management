#!/bin/bash
# Validators for prerequisites and configuration

# Check if command exists
check_command() {
    local cmd=$1
    local name=$2

    if ! command -v "$cmd" &> /dev/null; then
        error "$name is not installed"
        return 1
    fi
    success "$name is installed"
    return 0
}

# Check all prerequisites
check_prerequisites() {
    section "Checking Prerequisites"

    local all_ok=true

    # Required: GitHub CLI
    if ! check_command "gh" "GitHub CLI (gh)"; then
        error "Please install from: https://cli.github.com/"
        all_ok=false
    fi

    # Required: Python 3
    if ! check_command "python3" "Python 3"; then
        error "Please install Python 3.8+"
        all_ok=false
    fi

    # Optional but recommended: jq
    if ! check_command "jq" "jq (JSON processor)"; then
        warning "jq is optional but recommended for better state management"
    fi

    # Check GitHub CLI authentication
    if command -v gh &> /dev/null; then
        if ! gh auth status &> /dev/null; then
            error "GitHub CLI is not authenticated"
            error "Run: gh auth login"
            all_ok=false
        else
            success "GitHub CLI is authenticated"
        fi
    fi

    if [ "$all_ok" = true ]; then
        success "All prerequisites are met"
        return 0
    else
        return 1
    fi
}

# Validate repository context
validate_repo_context() {
    section "Validating Repository Context"

    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        error "Not in a git repository"
        return 1
    fi
    success "In a git repository"

    # Check if it's a GitHub repo
    if ! gh repo view > /dev/null 2>&1; then
        error "Not in a GitHub repository (or gh not authenticated)"
        return 1
    fi
    success "In a GitHub repository"

    return 0
}

# Get repo info safely
get_repo_info() {
    if ! gh repo view --json owner,name,nameWithOwner -q '.owner.login, .name' 2>/dev/null; then
        error "Could not retrieve repository information"
        return 1
    fi
    return 0
}

# Check if labels already exist
check_labels_exist() {
    local label=$1
    if gh label list --json name -q ".[].name" 2>/dev/null | grep -q "^${label}$"; then
        return 0
    fi
    return 1
}

# Check if project exists
check_project_exists() {
    local project_num=$1
    if gh project view "$project_num" > /dev/null 2>&1; then
        return 0
    fi
    return 1
}

# Validate project number format
validate_project_number() {
    local num=$1
    if [[ $num =~ ^[0-9]+$ ]]; then
        return 0
    fi
    return 1
}
