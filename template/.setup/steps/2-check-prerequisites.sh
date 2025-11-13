#!/bin/bash
# Step 2: Check all prerequisites

SETUP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

source "${SETUP_DIR}/lib/colors.sh"
source "${SETUP_DIR}/lib/validators.sh"
source "${SETUP_DIR}/lib/state.sh"

run_step() {
    section "Step 2/6: Checking Prerequisites"

    # Check prerequisites
    if ! check_prerequisites; then
        error "Please install all prerequisites and try again"
        return 1
    fi

    # Validate repository context
    if ! validate_repo_context; then
        error "Please run this script from a GitHub repository root"
        return 1
    fi

    mark_step_completed "check_prerequisites"
    return 0
}

# Run if called directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    run_step
    exit $?
fi
