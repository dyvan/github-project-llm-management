#!/bin/bash
# Step 5: Copy workflows, templates, scripts and CLAUDE.md to project root

SETUP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
REPO_ROOT="$(cd "${SETUP_DIR}/../.." && pwd)"
TEMPLATE_ROOT="$(cd "${SETUP_DIR}/.." && pwd)"

source "${SETUP_DIR}/lib/colors.sh"
source "${SETUP_DIR}/lib/state.sh"

copy_workflows() {
    local src="${REPO_ROOT}/.github/workflows"
    local dest="${PWD}/.github/workflows"

    # If we're running from the template repo itself, source is the repo's workflows
    # If installed as subdirectory, source is the parent repo (install.sh already copied them)
    if [ "$REPO_ROOT" = "$PWD" ]; then
        success "Workflows already in place (running from repo root)"
        return 0
    fi

    mkdir -p "$dest"

    # Workflows to copy (user-relevant only)
    local workflows=(
        "create-branch.yml"
        "code-review-agent.yml"
        "auto-close-feature.yml"
        "generate-specification.yml"
        "plan-with-gemini.yml"
        "update-project.yml"
    )

    local count=0
    for wf in "${workflows[@]}"; do
        if [ -f "$src/$wf" ]; then
            cp "$src/$wf" "$dest/$wf"
            ((count++))
        elif [ -f "${REPO_ROOT}/.github/workflows/$wf" ]; then
            cp "${REPO_ROOT}/.github/workflows/$wf" "$dest/$wf"
            ((count++))
        fi
    done

    if [ $count -gt 0 ]; then
        success "Copied $count workflows to .github/workflows/"
    else
        warning "No workflows found to copy"
    fi
}

copy_issue_templates() {
    local src="${REPO_ROOT}/.github/ISSUE_TEMPLATE"
    local dest="${PWD}/.github/ISSUE_TEMPLATE"

    if [ "$REPO_ROOT" = "$PWD" ]; then
        success "Issue templates already in place"
        return 0
    fi

    if [ -d "$src" ]; then
        mkdir -p "$dest"
        cp "$src"/*.yml "$dest/" 2>/dev/null
        success "Copied issue templates"
    else
        warning "No issue templates found at $src"
    fi
}

copy_pr_template() {
    local src="${REPO_ROOT}/.github/PULL_REQUEST_TEMPLATE.md"
    local dest="${PWD}/.github/PULL_REQUEST_TEMPLATE.md"

    if [ "$REPO_ROOT" = "$PWD" ]; then
        success "PR template already in place"
        return 0
    fi

    if [ -f "$src" ]; then
        mkdir -p "${PWD}/.github"
        cp "$src" "$dest"
        success "Copied PR template"
    fi
}

copy_scripts() {
    local src="${REPO_ROOT}/scripts"
    local dest="${PWD}/scripts"

    if [ "$REPO_ROOT" = "$PWD" ]; then
        success "Scripts already in place"
        return 0
    fi

    mkdir -p "$dest"

    # Scripts needed by workflows
    local scripts=(
        "project_sync.py"
        "auto_close_parent_feature.py"
        "generate_specification.py"
        "generate_qcm.py"
        "setup_project_fields.py"
    )

    local count=0
    for script in "${scripts[@]}"; do
        if [ -f "$src/$script" ]; then
            cp "$src/$script" "$dest/$script"
            ((count++))
        fi
    done

    if [ $count -gt 0 ]; then
        success "Copied $count scripts to scripts/"
    fi
}

copy_claude_md() {
    local src="${TEMPLATE_ROOT}/CLAUDE-USER-TEMPLATE.md"
    local dest="${PWD}/CLAUDE.md"

    # Try multiple source locations
    if [ ! -f "$src" ]; then
        src="${REPO_ROOT}/CLAUDE-USER-TEMPLATE.md"
    fi
    if [ ! -f "$src" ]; then
        src="${REPO_ROOT}/CLAUDE.md"
    fi

    if [ ! -f "$src" ]; then
        warning "No CLAUDE.md template found, skipping"
        return 0
    fi

    if [ -f "$dest" ]; then
        if diff -q "$src" "$dest" > /dev/null 2>&1; then
            success "CLAUDE.md already up to date"
        else
            info "CLAUDE.md already exists (customized), not overwriting"
        fi
    else
        cp "$src" "$dest"
        success "Copied CLAUDE.md to project root"
    fi
}

run_step() {
    section "Step 5/6: Copying Files to Project"

    copy_workflows
    copy_issue_templates
    copy_pr_template
    copy_scripts
    copy_claude_md

    mark_step_completed "link_workflows"
    mark_step_completed "copy_claude_md"
    return 0
}

# Run if called directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    run_step
    exit $?
fi
