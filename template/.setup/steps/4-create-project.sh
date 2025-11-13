#!/bin/bash
# Step 4: Create GitHub Project v2

SETUP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

source "${SETUP_DIR}/lib/colors.sh"
source "${SETUP_DIR}/lib/github-api.sh"
source "${SETUP_DIR}/lib/state.sh"

run_step() {
    section "Step 4/6: Creating GitHub Project v2"

    local PROJECT_NAME="${1:-Project Board}"

    if [ -z "$PROJECT_NAME" ]; then
        read -p "Enter project name (default: 'Project Board'): " PROJECT_NAME
        PROJECT_NAME="${PROJECT_NAME:-Project Board}"
    fi

    # Get or create project
    local project_num=$(create_project "$PROJECT_NAME")
    if [ $? -ne 0 ]; then
        error "Failed to create project"
        return 1
    fi

    # Store in state
    store_config "project_number" "$project_num"

    success "Project setup complete: #$project_num"
    info "Next step: Configure custom fields"
    echo ""
    echo "To configure custom fields, run:"
    highlight "  python3 ../scripts/setup_project_fields.py --project-number $project_num"

    mark_step_completed "create_project"
    return 0
}

# Run if called directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    run_step "$@"
    exit $?
fi
