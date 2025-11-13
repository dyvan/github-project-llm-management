#!/bin/bash
# Step 3: Initialize GitHub labels

SETUP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

source "${SETUP_DIR}/lib/colors.sh"
source "${SETUP_DIR}/lib/github-api.sh"
source "${SETUP_DIR}/lib/state.sh"

run_step() {
    section "Step 3/6: Initializing GitHub Labels"

    local LABELS_CONFIG="${SETUP_DIR}/../config/labels.json"

    if [ ! -f "$LABELS_CONFIG" ]; then
        error "Labels configuration not found: $LABELS_CONFIG"
        return 1
    fi

    # Load and create labels
    if ! create_labels "$(cat "$LABELS_CONFIG")"; then
        error "Failed to create labels"
        return 1
    fi

    mark_step_completed "init_labels"
    return 0
}

# Run if called directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    run_step
    exit $?
fi
