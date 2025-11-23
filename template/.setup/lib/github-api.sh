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

        # Check if label already exists using -F for fixed string matching (no regex)
        if gh label list --json name -q ".[].name" 2>/dev/null | grep -qF "$name"; then
            warning "Label '$name' already exists, skipping"
            ((skipped++))
        else
            if gh label create "$name" --description "$description" --color "$color" > /dev/null 2>&1; then
                success "Created label: $name"
                ((count++))
            else
                # If it fails, it might already exist - try with --force to update
                if gh label create "$name" --description "$description" --color "$color" --force > /dev/null 2>&1; then
                    success "Updated label: $name"
                    ((count++))
                else
                    error "Failed to create/update label: $name"
                fi
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

# Link project to repository
link_project_to_repo() {
    local project_num=$1
    local owner=$(get_repo_owner)
    local repo=$(get_repo_name)

    if [ -z "$project_num" ] || [ -z "$owner" ] || [ -z "$repo" ]; then
        error "Missing required parameters for linking project to repo"
        return 1
    fi

    # Get repository ID
    local repo_id=$(gh api graphql -f query="
query {
  repository(owner: \"$owner\", name: \"$repo\") {
    id
  }
}" -q '.data.repository.id' 2>&1)

    if [ -z "$repo_id" ] || [ "$repo_id" = "null" ]; then
        error "Could not retrieve repository ID for $owner/$repo"
        return 1
    fi

    # Get project ID from project number
    local project_id=$(gh api graphql -f query="
query {
  user(login: \"$owner\") {
    projectV2(number: $project_num) {
      id
    }
  }
}" -q '.data.user.projectV2.id' 2>/dev/null)

    # If user query fails, try organization query
    if [ -z "$project_id" ] || [ "$project_id" = "null" ]; then
        project_id=$(gh api graphql -f query="
query {
  organization(login: \"$owner\") {
    projectV2(number: $project_num) {
      id
    }
  }
}" -q '.data.organization.projectV2.id' 2>/dev/null)
    fi

    if [ -z "$project_id" ] || [ "$project_id" = "null" ]; then
        error "Could not retrieve project ID for project #$project_num"
        return 1
    fi

    # Link project to repository
    local result=$(gh api graphql -f query="
mutation {
  linkProjectV2ToRepository(input: {
    projectId: \"$project_id\",
    repositoryId: \"$repo_id\"
  }) {
    repository {
      id
      name
    }
  }
}" 2>&1)

    if [ $? -eq 0 ]; then
        success "Linked project #$project_num to repository $owner/$repo"
        return 0
    else
        warning "Could not link project to repository: $result"
        return 1
    fi
}
