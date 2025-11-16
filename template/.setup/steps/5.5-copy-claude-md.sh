#!/bin/bash
# Step 5.5: Copy CLAUDE.md to project root

SETUP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

source "${SETUP_DIR}/lib/colors.sh"
source "${SETUP_DIR}/lib/state.sh"

run_step() {
    section "Step 5.5/6: Copying CLAUDE.md to Project Root"

    # Get paths
    local TEMPLATE_CLAUDE="${SETUP_DIR}/../CLAUDE.md"
    local PROJECT_CLAUDE="${PWD}/CLAUDE.md"

    # Check if source file exists
    if [ ! -f "$TEMPLATE_CLAUDE" ]; then
        warning "Source CLAUDE.md not found at $TEMPLATE_CLAUDE"
        warning "Skipping CLAUDE.md copy step"
        mark_step_completed "copy_claude_md"
        return 0
    fi

    # Check if CLAUDE.md already exists in project root
    if [ -f "$PROJECT_CLAUDE" ]; then
        # Check if it's the same file or a customized version
        if diff -q "$TEMPLATE_CLAUDE" "$PROJECT_CLAUDE" > /dev/null 2>&1; then
            success "CLAUDE.md already copied (identical)"
        else
            info "CLAUDE.md exists but appears customized"
            info "Not overwriting custom version"
        fi
    else
        # Copy CLAUDE.md to project root
        cp "$TEMPLATE_CLAUDE" "$PROJECT_CLAUDE"
        success "Copied CLAUDE.md to project root"
        info "Documentation available at: ./CLAUDE.md"
    fi

    mark_step_completed "copy_claude_md"
    return 0
}

# Run if called directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    run_step
    exit $?
fi
