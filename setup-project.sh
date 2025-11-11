#!/bin/bash
# Setup script for new GitHub project using this template
# This script configures GitHub Projects v2, labels, and workflows

set -e

echo "🚀 GitHub Project LLM Management - Setup Script"
echo "================================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check prerequisites
echo -e "${BLUE}Checking prerequisites...${NC}"

if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI (gh) is not installed${NC}"
    echo "Install it from: https://cli.github.com/"
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 is not installed${NC}"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}⚠️  jq is not installed (optional but recommended)${NC}"
    echo "Install it from: https://stedolan.github.io/jq/"
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"
echo ""

# Get repository info
echo -e "${BLUE}Getting repository information...${NC}"
REPO_OWNER=$(gh repo view --json owner -q '.owner.login' 2>/dev/null || echo "")
REPO_NAME=$(gh repo view --json name -q '.name' 2>/dev/null || echo "")

if [ -z "$REPO_OWNER" ] || [ -z "$REPO_NAME" ]; then
    echo -e "${RED}❌ Could not detect repository. Make sure you're in a git repository with a GitHub remote.${NC}"
    exit 1
fi

echo -e "${GREEN}Repository: ${REPO_OWNER}/${REPO_NAME}${NC}"
echo ""

# Prompt for confirmation
read -p "Continue with setup for this repository? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled."
    exit 0
fi
echo ""

# Step 1: Configure GitHub Secrets
echo -e "${BLUE}Step 1/5: Checking GitHub Secrets...${NC}"
echo "Required secrets:"
echo "  - GH_TOKEN: GitHub Personal Access Token"
echo "  - CLAUDE_API_KEY: Anthropic Claude API key (for code review)"
echo ""
echo "To add secrets, run:"
echo "  gh secret set GH_TOKEN"
echo "  gh secret set CLAUDE_API_KEY"
echo ""
read -p "Have you configured the required secrets? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}⚠️  Please configure secrets before continuing${NC}"
    echo "You can continue the setup later by running this script again."
    exit 0
fi
echo -e "${GREEN}✅ Secrets configured${NC}"
echo ""

# Step 2: Create and configure labels
echo -e "${BLUE}Step 2/5: Creating GitHub labels...${NC}"

# Define labels (name:color:description)
declare -a LABELS=(
    "type:feature:0e8a16:New feature or enhancement"
    "type:bug:d73a4a:Bug or defect"
    "type:task:1d76db:Technical task"
    "type:docs:0075ca:Documentation"
    "type:infrastructure:5319e7:CI/CD, workflows, configuration"
    "status:backlog:ffffff:In backlog"
    "status:ready:c2e0c6:Ready to start"
    "status:in-progress:fbca04:Work in progress"
    "status:in-review:d4c5f9:In code review"
    "status:blocked:b60205:Blocked"
    "status:done:0e8a16:Completed"
    "priority:high:d73a4a:High priority"
    "priority:medium:fbca04:Medium priority"
    "priority:low:c2e0c6:Low priority"
    "auto-branch:ededed:Trigger automatic branch creation"
    "good-first-issue:7057ff:Good for newcomers"
    "help-wanted:008672:Extra attention is needed"
)

for label in "${LABELS[@]}"; do
    IFS=':' read -r name color description <<< "$label"

    # Check if label exists
    if gh label list | grep -q "^$name"; then
        echo "  ⏭️  Label '$name' already exists, skipping..."
    else
        gh label create "$name" --color "$color" --description "$description" 2>/dev/null && \
            echo -e "  ${GREEN}✅ Created label: $name${NC}" || \
            echo -e "  ${RED}❌ Failed to create label: $name${NC}"
    fi
done

echo -e "${GREEN}✅ Labels configured${NC}"
echo ""

# Step 3: Create GitHub Project
echo -e "${BLUE}Step 3/5: Creating GitHub Project v2...${NC}"
echo "This will create a new Project Board with custom fields."
echo ""

read -p "Enter project name (default: 'Project Backlog'): " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-"Project Backlog"}

# Check if project exists
EXISTING_PROJECT=$(gh project list --owner "$REPO_OWNER" --format json 2>/dev/null | jq -r ".projects[] | select(.title == \"$PROJECT_NAME\") | .number" || echo "")

if [ -n "$EXISTING_PROJECT" ]; then
    echo -e "${YELLOW}⚠️  Project '$PROJECT_NAME' already exists (number: $EXISTING_PROJECT)${NC}"
    read -p "Use existing project? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        PROJECT_NUMBER=$EXISTING_PROJECT
    else
        echo "Please choose a different project name and run the script again."
        exit 0
    fi
else
    echo "Creating project '$PROJECT_NAME'..."

    # Create project using GitHub CLI
    PROJECT_CREATE_OUTPUT=$(gh project create --owner "$REPO_OWNER" --title "$PROJECT_NAME" --format json 2>/dev/null || echo "")

    if [ -n "$PROJECT_CREATE_OUTPUT" ]; then
        PROJECT_NUMBER=$(echo "$PROJECT_CREATE_OUTPUT" | jq -r '.number' 2>/dev/null || echo "")
        if [ -n "$PROJECT_NUMBER" ]; then
            echo -e "${GREEN}✅ Project created: #$PROJECT_NUMBER${NC}"
        else
            echo -e "${RED}❌ Failed to parse project number${NC}"
            exit 1
        fi
    else
        echo -e "${RED}❌ Failed to create project${NC}"
        echo "You may need to create it manually: https://github.com/orgs/$REPO_OWNER/projects"
        exit 1
    fi
fi

echo ""
echo -e "${YELLOW}📋 Project created. You need to manually configure custom fields:${NC}"
echo ""
echo "1. Go to: https://github.com/orgs/$REPO_OWNER/projects/$PROJECT_NUMBER"
echo "2. Click Settings (gear icon) → Fields"
echo "3. Add these custom fields:"
echo ""
echo "   Field: Priority"
echo "   Type: Single select"
echo "   Options: High, Medium, Low"
echo ""
echo "   Field: Effort"
echo "   Type: Single select"
echo "   Options: 1, 2, 3, 5, 8"
echo ""
echo "   Field: Type"
echo "   Type: Single select"
echo "   Options: Feature, Bug, Task, Docs, Infrastructure"
echo ""
echo "   Field: Owner"
echo "   Type: People"
echo ""
echo "   Field: Target Version"
echo "   Type: Text"
echo ""
read -p "Press Enter after configuring custom fields..." -r
echo ""

# Step 4: Link repository to project
echo -e "${BLUE}Step 4/5: Linking repository to project...${NC}"

# Note: This requires GraphQL and is complex to automate
# We'll provide instructions instead
echo -e "${YELLOW}📋 To link issues/PRs to the project automatically:${NC}"
echo ""
echo "1. Go to: https://github.com/orgs/$REPO_OWNER/projects/$PROJECT_NUMBER"
echo "2. Click '...' menu → Settings"
echo "3. Under 'Workflows', enable:"
echo "   - Auto-add items: Set to 'issues and pull requests'"
echo "   - Filter: Select your repository"
echo ""
read -p "Press Enter after configuring workflows..." -r
echo ""

# Step 5: Install Python dependencies
echo -e "${BLUE}Step 5/5: Installing Python dependencies...${NC}"

if [ -f "requirements.txt" ]; then
    python3 -m pip install -r requirements.txt --quiet && \
        echo -e "${GREEN}✅ Python dependencies installed${NC}" || \
        echo -e "${YELLOW}⚠️  Failed to install dependencies (may need manual installation)${NC}"
else
    echo -e "${YELLOW}⚠️  requirements.txt not found${NC}"
fi
echo ""

# Final summary
echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo "Your GitHub project is now configured with:"
echo "  ✅ Labels for type, status, and priority"
echo "  ✅ GitHub Project v2 board"
echo "  ✅ GitHub Actions workflows (already in repo)"
echo "  ✅ Python dependencies"
echo ""
echo "Next steps:"
echo "  1. Create your first issue: gh issue create"
echo "  2. Add 'auto-branch' label to auto-create a branch"
echo "  3. Start coding and open a PR"
echo "  4. The Code Review Agent (Claude) will review automatically"
echo ""
echo "Useful commands:"
echo "  gh issue list                    # List all issues"
echo "  gh issue create                  # Create new issue"
echo "  gh pr create                     # Create pull request"
echo "  gh project list --owner $REPO_OWNER    # List projects"
echo ""
echo "Documentation:"
echo "  - README.md: Complete guide"
echo "  - claude.md: Instructions for Claude AI"
echo "  - PROJECT_BOARD_SETUP.md: Project board setup details"
echo "  - CONTRIBUTING.md: Contribution guidelines"
echo ""
echo -e "${BLUE}Happy coding! 🚀${NC}"
