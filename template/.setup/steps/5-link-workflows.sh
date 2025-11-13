#!/bin/bash
# Step 5: Link workflows and issue templates via symlinks

SETUP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

source "${SETUP_DIR}/lib/colors.sh"
source "${SETUP_DIR}/lib/state.sh"

run_step() {
    section "Step 5/6: Linking Workflows and Templates"

    local TEMPLATE_GITHUB="${SETUP_DIR}/../.github"
    local REPO_GITHUB="${PWD}/.github"

    # Create .github directory if it doesn't exist
    mkdir -p "$REPO_GITHUB"

    # Create symlinks for workflows
    local workflows_dir="${REPO_GITHUB}/workflows"
    if [ ! -d "$workflows_dir" ]; then
        ln -s "${TEMPLATE_GITHUB}/workflows" "$workflows_dir"
        success "Created symlink: .github/workflows → template/.github/workflows"
    else
        if [ -L "$workflows_dir" ]; then
            success "Workflows symlink already exists"
        else
            warning "Workflows directory exists but is not a symlink"
            info "Consider removing and recreating as symlink for future updates"
        fi
    fi

    # Create symlinks for issue templates
    local templates_dir="${REPO_GITHUB}/ISSUE_TEMPLATE"
    if [ ! -d "$templates_dir" ]; then
        ln -s "${TEMPLATE_GITHUB}/ISSUE_TEMPLATE" "$templates_dir"
        success "Created symlink: .github/ISSUE_TEMPLATE → template/.github/ISSUE_TEMPLATE"
    else
        if [ -L "$templates_dir" ]; then
            success "ISSUE_TEMPLATE symlink already exists"
        else
            warning "ISSUE_TEMPLATE directory exists but is not a symlink"
            info "Consider removing and recreating as symlink for future updates"
        fi
    fi

    # Create symlink for PR template if it exists
    if [ -f "${TEMPLATE_GITHUB}/PULL_REQUEST_TEMPLATE.md" ]; then
        local pr_template="${REPO_GITHUB}/PULL_REQUEST_TEMPLATE.md"
        if [ ! -f "$pr_template" ]; then
            ln -s "${TEMPLATE_GITHUB}/PULL_REQUEST_TEMPLATE.md" "$pr_template"
            success "Created symlink: .github/PULL_REQUEST_TEMPLATE.md"
        else
            if [ -L "$pr_template" ]; then
                success "PR template symlink already exists"
            else
                warning "PR template file exists but is not a symlink"
            fi
        fi
    fi

    mark_step_completed "link_workflows"
    return 0
}

# Run if called directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    run_step
    exit $?
fi
