#!/bin/bash
# State management for idempotent setup

# Path to state file (gitignored)
STATE_FILE="${SETUP_DIR}/.setup-state.json"

# Initialize default state
init_state() {
    if [ ! -f "$STATE_FILE" ]; then
        cat > "$STATE_FILE" << 'EOF'
{
  "version": "1.0",
  "setup_started_at": null,
  "setup_completed_at": null,
  "steps": {
    "check_prerequisites": false,
    "init_labels": false,
    "create_project": false,
    "setup_fields": false,
    "link_workflows": false,
    "create_symlinks": false,
    "setup_complete": false
  },
  "configuration": {
    "repo_owner": null,
    "repo_name": null,
    "project_number": null
  },
  "errors": []
}
EOF
        success "Initialized state file: $STATE_FILE"
    fi
}

# Check if a step is completed
is_step_completed() {
    local step=$1
    if [ -f "$STATE_FILE" ]; then
        if command -v jq &> /dev/null; then
            jq -r ".steps.\"$step\"" "$STATE_FILE" 2>/dev/null
        fi
    fi
    echo "false"
}

# Mark a step as completed
mark_step_completed() {
    local step=$1
    if [ -f "$STATE_FILE" ] && command -v jq &> /dev/null; then
        # Use temp file for atomic write
        local temp_file="${STATE_FILE}.tmp"
        jq ".steps.\"$step\" = true | .setup_started_at = (now | strftime(\"%Y-%m-%dT%H:%M:%SZ\"))" "$STATE_FILE" > "$temp_file" 2>/dev/null
        mv "$temp_file" "$STATE_FILE"
    fi
}

# Mark setup as completed
mark_setup_completed() {
    if [ -f "$STATE_FILE" ] && command -v jq &> /dev/null; then
        local temp_file="${STATE_FILE}.tmp"
        jq ".setup_completed_at = (now | strftime(\"%Y-%m-%dT%H:%M:%SZ\")) | .steps.setup_complete = true" "$STATE_FILE" > "$temp_file" 2>/dev/null
        mv "$temp_file" "$STATE_FILE"
    fi
}

# Store configuration
store_config() {
    local key=$1
    local value=$2
    if [ -f "$STATE_FILE" ] && command -v jq &> /dev/null; then
        local temp_file="${STATE_FILE}.tmp"
        jq ".configuration.\"$key\" = \"$value\"" "$STATE_FILE" > "$temp_file" 2>/dev/null
        mv "$temp_file" "$STATE_FILE"
    fi
}

# Get stored configuration
get_config() {
    local key=$1
    if [ -f "$STATE_FILE" ] && command -v jq &> /dev/null; then
        jq -r ".configuration.\"$key\"" "$STATE_FILE" 2>/dev/null
    fi
    echo null
}

# Print setup status
print_status() {
    if [ ! -f "$STATE_FILE" ]; then
        echo "No setup state found"
        return
    fi

    if command -v jq &> /dev/null; then
        echo ""
        section "Current Setup Status"
        echo ""
        jq '.steps | to_entries | .[] | "\(.key): \(if .value then "✅ Done" else "⏳ Pending" end)"' "$STATE_FILE" 2>/dev/null | tr -d '"'
        echo ""
    fi
}

# Add error to state
add_error() {
    local error_msg=$1
    if [ -f "$STATE_FILE" ] && command -v jq &> /dev/null; then
        local temp_file="${STATE_FILE}.tmp"
        jq ".errors += [\"$error_msg\"]" "$STATE_FILE" > "$temp_file" 2>/dev/null
        mv "$temp_file" "$STATE_FILE"
    fi
}
