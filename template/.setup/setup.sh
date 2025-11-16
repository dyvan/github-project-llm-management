#!/bin/bash
# Main setup orchestrator - runs all setup steps

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SETUP_DIR="$SCRIPT_DIR"

# Source colors library
source "${SETUP_DIR}/lib/colors.sh"
source "${SETUP_DIR}/lib/state.sh"

# Show banner
banner() {
    echo ""
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════╗"
    echo "║  🚀 GitHub Project Management - Setup        ║"
    echo "║  Template: github-project-llm-management      ║"
    echo "╚════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Show help
show_help() {
    cat << EOF
🚀 GitHub Project Management Setup Script

USAGE:
    ./setup.sh [OPTIONS]

OPTIONS:
    --help              Show this help message
    --skip-completed    Skip already completed steps
    --dry-run          Show what would be done without doing it
    --verbose          Show detailed output
    --reset-state      Reset setup state (run from scratch)

WHAT THIS SCRIPT DOES:
    1. ✅ Checks prerequisites (gh, python3, jq)
    2. ✅ Validates repository context (GitHub repo)
    3. ✅ Creates GitHub labels (type:*, priority:*, status:*)
    4. ✅ Creates GitHub Project v2 board
    5. ✅ Links workflows and issue templates
    5.5. ✅ Copies CLAUDE.md to project root
    6. ✅ Finalizes setup and saves state for idempotent reruns

PREREQUISITES:
    - GitHub CLI (gh) installed and authenticated
    - Python 3.8+
    - jq (optional but recommended)
    - Git repository with GitHub remote

AFTER SETUP:
    1. The script creates a .setup-state.json file (gitignored)
    2. This tracks what's been done for idempotent reruns
    3. You can run this script again safely

DOCUMENTATION:
    - Full guide: ../README.md
    - LLM instructions: ../../CLAUDE.md
    - Troubleshooting: ../docs/TROUBLESHOOTING.md

EXAMPLES:
    # First time setup
    ./setup.sh

    # Verify/update existing setup
    ./setup.sh --skip-completed

    # Debug setup issues
    ./setup.sh --verbose

    # Start over completely
    ./setup.sh --reset-state

EOF
}

# Parse arguments
SKIP_COMPLETED=false
VERBOSE=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_help
            exit 0
            ;;
        --skip-completed)
            SKIP_COMPLETED=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --reset-state)
            rm -f "${SETUP_DIR}/.setup-state.json"
            info "Setup state reset. Running fresh setup..."
            shift
            ;;
        *)
            error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Main setup flow
main() {
    banner

    # Initialize state file
    init_state

    # Run each step
    local steps=(
        "1-check-state"
        "2-check-prerequisites"
        "3-init-labels"
        "4-create-project"
        "5-link-workflows"
        "5.5-copy-claude-md"
        "6-finalize"
    )

    for step in "${steps[@]}"; do
        step_file="${SETUP_DIR}/steps/${step}.sh"

        if [ ! -f "$step_file" ]; then
            error "Step file not found: $step_file"
            return 1
        fi

        # Check if should skip
        step_name=$(echo "$step" | sed 's/-/_/g')
        if [ "$SKIP_COMPLETED" = true ]; then
            local completed=$(is_step_completed "$step_name")
            if [ "$completed" = "true" ]; then
                warning "Step '$step' already completed, skipping..."
                continue
            fi
        fi

        # Run step
        info "Running: $step"
        echo ""

        if [ "$DRY_RUN" = true ]; then
            highlight "DRY-RUN: Would execute $step"
        else
            # Export GH_TOKEN to ensure it's available in subprocesses
            if ! GH_TOKEN="${GH_TOKEN}" bash "$step_file"; then
                error "Step '$step' failed"
                add_error "Step '$step' failed at $(date)"
                return 1
            fi
        fi

        echo ""
    done

    # Final status
    if [ "$DRY_RUN" != true ]; then
        info "Setup completed successfully!"
        print_status
    fi

    return 0
}

# Run main
main
exit $?
