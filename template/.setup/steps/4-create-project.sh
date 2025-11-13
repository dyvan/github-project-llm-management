#!/bin/bash
# Step 4: Create GitHub Project v2

SETUP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

source "${SETUP_DIR}/lib/colors.sh"
source "${SETUP_DIR}/lib/github-api.sh"
source "${SETUP_DIR}/lib/validators.sh"
source "${SETUP_DIR}/lib/state.sh"

run_step() {
    section "Step 4/6: Creating GitHub Project v2"

    local PROJECT_NAME="${1:-Project Board}"

    if [ -z "$PROJECT_NAME" ]; then
        read -p "Enter project name (default: 'Project Board'): " PROJECT_NAME
        PROJECT_NAME="${PROJECT_NAME:-Project Board}"
    fi

    # Get or create project
    local project_output=$(create_project "$PROJECT_NAME")
    local exit_code=$?

    if [ $exit_code -ne 0 ]; then
        error "Failed to create project"
        return 1
    fi

    # Extract only the project number (last line of output, which should be a number)
    local project_num=$(echo "$project_output" | tail -1 | grep -oE '^[0-9]+$' || echo "")
    if [ -z "$project_num" ]; then
        error "Could not extract project number from output"
        return 1
    fi

    # Store in state
    store_config "project_number" "$project_num"

    success "Project setup complete: #$project_num"

    # Configure custom fields
    info "Configuring custom fields..."
    echo ""

    local owner=$(get_repo_owner)
    local repo_root="$(cd "${SETUP_DIR}/../.." && pwd)"
    if command -v python3 &> /dev/null; then
        # Get GH_TOKEN from environment or .env file
        local gh_token="${GH_TOKEN:-}"
        if [ -z "$gh_token" ] && [ -f "${repo_root}/.env" ]; then
            gh_token=$(grep "^GH_TOKEN=" "${repo_root}/.env" | cut -d'=' -f2)
        fi

        if [ -z "$gh_token" ]; then
            gh_token=$(gh auth token 2>/dev/null || echo "")
        fi

        if [ -n "$gh_token" ]; then
            if GH_TOKEN="$gh_token" python3 "${repo_root}/scripts/setup_project_fields.py" --project-number "$project_num" --owner "$owner"; then
                success "Custom fields configured successfully"
                store_config "setup_fields" "true"
            else
                warning "Could not configure custom fields automatically"
                warning "You can configure them manually with:"
                highlight "  python3 scripts/setup_project_fields.py --project-number $project_num --owner $owner"
            fi
        else
            warning "GitHub token not found, skipping field configuration"
            warning "You can configure them manually with:"
            highlight "  python3 scripts/setup_project_fields.py --project-number $project_num --owner $owner"
        fi
    else
        warning "Python 3 not found, skipping field configuration"
    fi

    mark_step_completed "create_project"
    return 0
}

# Run if called directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    run_step "$@"
    exit $?
fi
