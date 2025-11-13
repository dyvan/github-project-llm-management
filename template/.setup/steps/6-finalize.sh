#!/bin/bash
# Step 6: Finalize setup

SETUP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

source "${SETUP_DIR}/lib/colors.sh"
source "${SETUP_DIR}/lib/state.sh"

run_step() {
    section "Step 6/6: Finalizing Setup"

    # Store repo info
    local REPO_OWNER=$(get_repo_owner)
    local REPO_NAME=$(get_repo_name)

    store_config "repo_owner" "$REPO_OWNER"
    store_config "repo_name" "$REPO_NAME"

    # Update .env with project information
    local project_num=$(get_config "project_number")
    if [ "$project_num" != "null" ] && [ -n "$project_num" ]; then
        update_env_file "GH_PROJECT_NUMBER" "$project_num"
    fi

    # Mark setup as complete
    mark_setup_completed

    # Print summary
    echo ""
    section "✨ Setup Complete!"
    echo ""
    success "Your project is now configured with:"
    echo "  ✅ GitHub labels (type:, priority:, status:)"
    echo "  ✅ GitHub Project v2 board"
    echo "  ✅ Workflows linked (create-branch, code-review, etc.)"
    echo "  ✅ Issue templates linked"
    echo "  ✅ CLAUDE.md copied to project root"
    echo ""
    highlight "Project: $REPO_OWNER/$REPO_NAME"
    echo ""

    # Get project number from state
    local project_num=$(get_config "project_number")
    if [ "$project_num" != "null" ] && [ -n "$project_num" ]; then
        highlight "Project Board: #$project_num"
        echo ""
    fi

    section "Next Steps"
    echo ""
    echo "1. Read CLAUDE.md to understand LLM project management"
    echo "2. Configure custom fields (if not done):"
    echo "   python3 template/scripts/setup_project_fields.py --project-number $project_num"
    echo ""
    echo "3. Validate setup:"
    echo "   bash template/.setup/steps/6-finalize.sh"
    echo ""
    echo "4. Add GitHub secrets (if using CI/CD):"
    echo "   gh secret set GH_TOKEN"
    echo "   gh secret set CLAUDE_API_KEY"
    echo ""

    return 0
}

# Helper to get repo info
get_repo_owner() {
    gh repo view --json owner -q '.owner.login' 2>/dev/null || echo "unknown"
}

get_repo_name() {
    gh repo view --json name -q '.name' 2>/dev/null || echo "unknown"
}

# Helper to get config
get_config() {
    local key=$1
    if [ -f "$SETUP_DIR/.setup-state.json" ] && command -v jq &> /dev/null; then
        jq -r ".configuration.\"$key\"" "$SETUP_DIR/.setup-state.json" 2>/dev/null || echo "null"
    else
        echo "null"
    fi
}

# Helper to update .env file
update_env_file() {
    local key=$1
    local value=$2
    local env_file="$(cd "$SETUP_DIR/../.." && pwd)/.env"

    if [ ! -f "$env_file" ]; then
        warning ".env file not found at $env_file"
        return 1
    fi

    # Check if key already exists
    if grep -q "^$key=" "$env_file"; then
        # Update existing key
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS sed
            sed -i "" "s/^$key=.*/$key=$value/" "$env_file"
        else
            # Linux sed
            sed -i "s/^$key=.*/$key=$value/" "$env_file"
        fi
    else
        # Append new key
        echo "$key=$value" >> "$env_file"
    fi

    success "Updated $env_file: $key=$value"
}

# Run if called directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    run_step
    exit $?
fi
