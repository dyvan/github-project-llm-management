#!/bin/bash
# Step 4: Create GitHub Project v2

SETUP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

source "${SETUP_DIR}/lib/colors.sh"
source "${SETUP_DIR}/lib/github-api.sh"
source "${SETUP_DIR}/lib/validators.sh"
source "${SETUP_DIR}/lib/state.sh"

run_step() {
    section "Step 4/6: Creating GitHub Project v2"

    # Get repo info for unique project name
    local REPO_NAME=$(get_repo_name)
    local PROJECT_NAME="${1:-Project Board : $REPO_NAME}"

    if [ -z "$PROJECT_NAME" ] || [ "$PROJECT_NAME" = "Project Board :" ]; then
        read -p "Enter project name (default: 'Project Board : $REPO_NAME'): " PROJECT_NAME
        PROJECT_NAME="${PROJECT_NAME:-Project Board : $REPO_NAME}"
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

    # Link project to repository
    info "Linking project to repository..."
    if link_project_to_repo "$project_num"; then
        success "Project linked to repository"
    else
        warning "Could not link project to repository"
        warning "You can still access the project at: https://github.com/users/$(get_repo_owner)/projects/$project_num"
    fi

    # Note: Custom fields (Status, Priority, Effort, Type) must be created
    # manually on the GitHub Project Board settings page. The GitHub API does
    # not support creating custom fields programmatically.
    info "Remember to create custom fields manually on your Project Board settings."
    echo ""

    mark_step_completed "create_project"
    return 0
}

# Run if called directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    run_step "$@"
    exit $?
fi
