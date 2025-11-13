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
    if [ -L "$workflows_dir" ]; then
        # Already a symlink, verify it points to the right place
        success "Workflows symlink already exists"
    elif [ -d "$workflows_dir" ]; then
        # Directory exists but is not a symlink - replace it
        info "Removing existing workflows directory to create symlink..."
        rm -rf "$workflows_dir"
        ln -s "${TEMPLATE_GITHUB}/workflows" "$workflows_dir"
        success "Created symlink: .github/workflows → template/.github/workflows"
    else
        # Directory doesn't exist - create symlink
        ln -s "${TEMPLATE_GITHUB}/workflows" "$workflows_dir"
        success "Created symlink: .github/workflows → template/.github/workflows"
    fi

    # Create symlinks for issue templates
    local templates_dir="${REPO_GITHUB}/ISSUE_TEMPLATE"
    if [ -L "$templates_dir" ]; then
        # Already a symlink, verify it points to the right place
        success "ISSUE_TEMPLATE symlink already exists"
    elif [ -d "$templates_dir" ]; then
        # Directory exists but is not a symlink - replace it
        info "Removing existing ISSUE_TEMPLATE directory to create symlink..."
        rm -rf "$templates_dir"
        ln -s "${TEMPLATE_GITHUB}/ISSUE_TEMPLATE" "$templates_dir"
        success "Created symlink: .github/ISSUE_TEMPLATE → template/.github/ISSUE_TEMPLATE"
    else
        # Directory doesn't exist - create symlink
        ln -s "${TEMPLATE_GITHUB}/ISSUE_TEMPLATE" "$templates_dir"
        success "Created symlink: .github/ISSUE_TEMPLATE → template/.github/ISSUE_TEMPLATE"
    fi

    # Create symlink for PR template if it exists
    if [ -f "${TEMPLATE_GITHUB}/PULL_REQUEST_TEMPLATE.md" ]; then
        local pr_template="${REPO_GITHUB}/PULL_REQUEST_TEMPLATE.md"
        if [ -L "$pr_template" ]; then
            # Already a symlink
            success "PR template symlink already exists"
        elif [ -f "$pr_template" ]; then
            # File exists but is not a symlink - replace it
            info "Removing existing PR template file to create symlink..."
            rm -f "$pr_template"
            ln -s "${TEMPLATE_GITHUB}/PULL_REQUEST_TEMPLATE.md" "$pr_template"
            success "Created symlink: .github/PULL_REQUEST_TEMPLATE.md"
        else
            # File doesn't exist - create symlink
            ln -s "${TEMPLATE_GITHUB}/PULL_REQUEST_TEMPLATE.md" "$pr_template"
            success "Created symlink: .github/PULL_REQUEST_TEMPLATE.md"
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
