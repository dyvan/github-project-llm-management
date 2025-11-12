#!/bin/bash
# Validation script to check if the GitHub project template is properly configured

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

echo "🔍 GitHub Project Template - Setup Validation"
echo "=============================================="
echo ""

# Check 1: Prerequisites
echo -e "${BLUE}[1/8] Checking prerequisites...${NC}"

if command -v gh &> /dev/null; then
    echo "  ✅ GitHub CLI (gh) installed"
else
    echo -e "  ${RED}❌ GitHub CLI (gh) not found${NC}"
    ERRORS=$((ERRORS + 1))
fi

if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version | awk '{print $2}')
    echo "  ✅ Python 3 installed ($PYTHON_VERSION)"
else
    echo -e "  ${RED}❌ Python 3 not found${NC}"
    ERRORS=$((ERRORS + 1))
fi

if command -v git &> /dev/null; then
    echo "  ✅ Git installed"
else
    echo -e "  ${RED}❌ Git not found${NC}"
    ERRORS=$((ERRORS + 1))
fi

echo ""

# Check 2: Repository context
echo -e "${BLUE}[2/8] Checking repository context...${NC}"

if git rev-parse --git-dir > /dev/null 2>&1; then
    echo "  ✅ Inside a Git repository"

    REPO_OWNER=$(gh repo view --json owner -q '.owner.login' 2>/dev/null || echo "")
    REPO_NAME=$(gh repo view --json name -q '.name' 2>/dev/null || echo "")

    if [ -n "$REPO_OWNER" ] && [ -n "$REPO_NAME" ]; then
        echo "  ✅ Repository: $REPO_OWNER/$REPO_NAME"
    else
        echo -e "  ${YELLOW}⚠️  Could not detect GitHub repository info${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "  ${RED}❌ Not in a Git repository${NC}"
    ERRORS=$((ERRORS + 1))
fi

echo ""

# Check 3: GitHub authentication
echo -e "${BLUE}[3/8] Checking GitHub authentication...${NC}"

if gh auth status &> /dev/null; then
    echo "  ✅ GitHub CLI authenticated"
else
    echo -e "  ${RED}❌ GitHub CLI not authenticated${NC}"
    echo "     Run: gh auth login"
    ERRORS=$((ERRORS + 1))
fi

echo ""

# Check 4: Required secrets
echo -e "${BLUE}[4/8] Checking GitHub Secrets...${NC}"

if [ -n "$REPO_OWNER" ] && [ -n "$REPO_NAME" ]; then
    SECRETS=$(gh secret list 2>/dev/null || echo "")

    if echo "$SECRETS" | grep -q "GH_TOKEN\|GITHUB_TOKEN"; then
        echo "  ✅ GH_TOKEN or GITHUB_TOKEN configured"
    else
        echo -e "  ${YELLOW}⚠️  GH_TOKEN secret not found${NC}"
        echo "     The GITHUB_TOKEN is automatically provided by Actions"
        WARNINGS=$((WARNINGS + 1))
    fi

    if echo "$SECRETS" | grep -q "CLAUDE_API_KEY"; then
        echo "  ✅ CLAUDE_API_KEY configured"
    else
        echo -e "  ${YELLOW}⚠️  CLAUDE_API_KEY secret not configured${NC}"
        echo "     Code review agent will run in basic mode"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "  ${YELLOW}⚠️  Skipping secrets check (not in GitHub repo)${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""

# Check 5: Labels
echo -e "${BLUE}[5/8] Checking GitHub labels...${NC}"

REQUIRED_LABELS=(
    "type:feature"
    "type:bug"
    "type:task"
    "priority:high"
    "priority:medium"
    "priority:low"
    "auto-branch"
)

if [ -n "$REPO_OWNER" ] && [ -n "$REPO_NAME" ]; then
    LABELS=$(gh label list --json name -q '.[].name' 2>/dev/null || echo "")

    MISSING_LABELS=0
    for label in "${REQUIRED_LABELS[@]}"; do
        if echo "$LABELS" | grep -q "^$label$"; then
            : # Label exists
        else
            MISSING_LABELS=$((MISSING_LABELS + 1))
        fi
    done

    if [ $MISSING_LABELS -eq 0 ]; then
        echo "  ✅ All required labels exist"
    else
        echo -e "  ${YELLOW}⚠️  $MISSING_LABELS required labels missing${NC}"
        echo "     Run: ./setup-project.sh to create labels"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "  ${YELLOW}⚠️  Skipping labels check (not in GitHub repo)${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""

# Check 6: GitHub Project
echo -e "${BLUE}[6/8] Checking GitHub Project...${NC}"

if [ -n "$REPO_OWNER" ]; then
    PROJECTS=$(gh project list --owner "$REPO_OWNER" --format json 2>/dev/null || echo "[]")
    PROJECT_COUNT=$(echo "$PROJECTS" | jq '. | length' 2>/dev/null || echo "0")

    if [ "$PROJECT_COUNT" -gt 0 ]; then
        echo "  ✅ Found $PROJECT_COUNT project(s)"

        # Check if .github/project.yml exists
        if [ -f ".github/project.yml" ]; then
            echo "  ✅ Configuration file .github/project.yml exists"
        else
            echo -e "  ${YELLOW}⚠️  .github/project.yml not found${NC}"
            echo "     Workflows won't know which project to use"
            WARNINGS=$((WARNINGS + 1))
        fi
    else
        echo -e "  ${YELLOW}⚠️  No GitHub Projects found${NC}"
        echo "     Run: ./setup-project.sh to create a project"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "  ${YELLOW}⚠️  Skipping project check${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""

# Check 7: Workflows
echo -e "${BLUE}[7/8] Checking GitHub Actions workflows...${NC}"

REQUIRED_WORKFLOWS=(
    ".github/workflows/ci-tests.yml"
    ".github/workflows/update-project.yml"
    ".github/workflows/create-branch.yml"
    ".github/workflows/code-review-agent.yml"
)

MISSING_WORKFLOWS=0
for workflow in "${REQUIRED_WORKFLOWS[@]}"; do
    if [ -f "$workflow" ]; then
        : # Workflow exists
    else
        echo -e "  ${RED}❌ Missing: $workflow${NC}"
        MISSING_WORKFLOWS=$((MISSING_WORKFLOWS + 1))
        ERRORS=$((ERRORS + 1))
    fi
done

if [ $MISSING_WORKFLOWS -eq 0 ]; then
    echo "  ✅ All required workflows exist"
fi

echo ""

# Check 8: Python dependencies
echo -e "${BLUE}[8/8] Checking Python dependencies...${NC}"

if [ -f "requirements.txt" ]; then
    echo "  ✅ requirements.txt exists"

    if python3 -c "import requests" 2>/dev/null; then
        echo "  ✅ requests library installed"
    else
        echo -e "  ${YELLOW}⚠️  requests library not installed${NC}"
        echo "     Run: pip install -r requirements.txt"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "  ${YELLOW}⚠️  requirements.txt not found${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""
echo "=============================================="

# Summary
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed! Template is ready to use.${NC}"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Setup complete with $WARNINGS warning(s).${NC}"
    echo "Template is functional but some optional features may not work."
    exit 0
else
    echo -e "${RED}❌ Setup incomplete: $ERRORS error(s), $WARNINGS warning(s).${NC}"
    echo ""
    echo "Please fix the errors above before using this template."
    exit 1
fi
