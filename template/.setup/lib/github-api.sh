#!/bin/bash
# GitHub API wrapper functions

# Create labels with idempotency check
create_labels() {
    local labels_json=$1

    if ! command -v jq &> /dev/null; then
        warning "jq not available, skipping labels creation"
        return 0
    fi

    section "Creating GitHub Labels"

    local count=0
    local skipped=0

    while IFS= read -r label; do
        local name=$(echo "$label" | jq -r '.name')
        local description=$(echo "$label" | jq -r '.description // ""')
        local color=$(echo "$label" | jq -r '.color // "0075ca"')

        # Check if label already exists
        if gh label list --json name -q ".[].name" 2>/dev/null | grep -q "^${name}$"; then
            warning "Label '$name' already exists, skipping"
            ((skipped++))
        else
            if gh label create "$name" --description "$description" --color "$color" > /dev/null 2>&1; then
                success "Created label: $name"
                ((count++))
            else
                error "Failed to create label: $name"
            fi
        fi
    done < <(echo "$labels_json" | jq -c '.[]')

    success "Labels creation completed: $count created, $skipped already existed"
    return 0
}

# Create GitHub Project v2
create_project() {
    local project_name=$1

    section "Creating GitHub Project v2"

    if ! command -v gh &> /dev/null; then
        error "GitHub CLI not available"
        return 1
    fi

    # Check if project already exists (using correct jq syntax)
    local owner=$(get_repo_owner)
    local existing=$(gh project list --owner "$owner" --format json 2>/dev/null | jq -r ".projects[] | select(.title == \"$project_name\") | .number" | head -1)

    if [ -n "$existing" ] && [ "$existing" != "null" ]; then
        warning "Project '$project_name' already exists (number: $existing)"
        echo "$existing"
        return 0
    fi

    # Create project
    local owner=$(get_repo_owner)
    local result=$(gh project create --title "$project_name" --owner "$owner" --format json 2>/dev/null)

    if [ $? -eq 0 ]; then
        local project_num=$(echo "$result" | jq -r '.number' 2>/dev/null)
        if [ -n "$project_num" ] && [ "$project_num" != "null" ]; then
            success "Created GitHub Project: $project_name (#$project_num)"
            echo "$project_num"
            return 0
        fi
    fi

    error "Failed to create project"
    return 1
}

# Add issue to project
add_issue_to_project() {
    local issue_num=$1
    local project_num=$2

    if ! gh project item-add "$project_num" --issue "$issue_num" > /dev/null 2>&1; then
        warning "Could not add issue #$issue_num to project #$project_num"
        return 1
    fi

    success "Added issue #$issue_num to project"
    return 0
}

# List all existing projects
list_projects() {
    if ! command -v jq &> /dev/null; then
        gh project list
    else
        gh project list --json number,title -q ".[] | \"#\(.number) - \(.title)\""
    fi
}

# Get repository owner and name
get_repo_owner() {
    gh repo view --json owner -q '.owner.login' 2>/dev/null
}

get_repo_name() {
    gh repo view --json name -q '.name' 2>/dev/null
}

# Check if repository has GitHub Pages enabled
check_pages_enabled() {
    if gh api repos/{owner}/{repo}/pages > /dev/null 2>&1; then
        return 0
    fi
    return 1
}
