#!/bin/bash
# Step 1: Check current setup state and show status

SETUP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

source "${SETUP_DIR}/lib/colors.sh"
source "${SETUP_DIR}/lib/state.sh"

run_step() {
    section "Step 1/6: Checking Setup State"

    # Initialize state file if needed
    init_state

    # Print current status
    if [ -f "$STATE_FILE" ]; then
        if command -v jq &> /dev/null; then
            # Check if setup is already complete
            local is_complete=$(jq -r '.steps.setup_complete' "$STATE_FILE" 2>/dev/null)
            if [ "$is_complete" = "true" ]; then
                success "Setup is already complete!"
                echo ""
                info "Last completed at: $(jq -r '.setup_completed_at' "$STATE_FILE" 2>/dev/null)"
                echo ""
                read -p "Run setup again to verify/update? (y/n) " -n 1 -r || true
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    return 0
                fi
            fi
        fi

        # Show current status
        print_status
    else
        info "Starting fresh setup..."
    fi

    mark_step_completed "check_state"
    return 0
}

# Run if called directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    run_step
    exit $?
fi
