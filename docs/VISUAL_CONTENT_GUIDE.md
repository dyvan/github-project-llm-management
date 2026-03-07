# 📸 Visual Content Creation Guide

This guide helps you create screenshots and videos to enhance the template documentation.

---

## 📁 File Structure

Create the folder to store images:

```bash
mkdir -p docs/images
mkdir -p docs/images/screenshots
mkdir -p docs/images/demo
```

---

## 🖼️ Screenshots to Create

### 1. Screenshot: GitHub Template Button
**File**: `docs/images/screenshots/01-use-template.png`

**What to capture**:
- GitHub page of the template repository
- Green "Use this template" button clearly visible
- Repository title at the top

**How**:
1. Go to https://github.com/dyvan/github-project-llm-management
2. Capture the top section of the page with the button
3. Annotate the button with an arrow or circle

**Used in**: README.md, Getting-Started.md

---

### 2. Screenshot: Setup Script in Action
**File**: `docs/images/screenshots/02-setup-running.png`

**What to capture**:
- Terminal running `./setup-project.sh`
- Colored messages (✅, ❌, emojis)
- At least 2-3 visible steps

**How**:
1. Run `./setup-project.sh` in a terminal
2. Capture when the steps are displayed
3. Make sure colors are visible

**Used in**: Getting-Started.md, Scripts-Reference.md

---

### 3. Screenshot: Created GitHub Project Board
**File**: `docs/images/screenshots/03-project-board.png`

**What to capture**:
- Overview of the Project Board
- Columns: Backlog, Ready, In Progress, In Review, Done
- At least 2-3 visible issues
- Custom fields (Priority, Effort, Type) visible

**How**:
1. Go to your GitHub Project (https://github.com/users/YOUR_NAME/projects/X)
2. Use "Table" view to see the fields
3. Capture the full width of the table

**Used in**: README.md, Using-The-Template.md, Configuration.md

---

### 4. Screenshot: Auto-Branch in Action
**File**: `docs/images/screenshots/04-auto-branch-comment.png`

**What to capture**:
- Issue with `auto-branch` label
- Automatic bot comment with git commands
- Newly created branch visible

**How**:
1. Create an issue
2. Add the `auto-branch` label
3. Wait 30 seconds
4. Capture the automatic comment

**Used in**: README.md, Understanding-Workflows.md

---

### 5. Screenshot: Code Review by Gemini AI
**File**: `docs/images/screenshots/05-gemini-review.png`

**What to capture**:
- Pull Request with Gemini comment
- Improvement suggestions
- Emojis and markdown formatting

**How**:
1. Create a PR with some code
2. Wait for Gemini's automatic review
3. Capture the full comment

**Used in**: README.md, Understanding-Workflows.md

---

### 6. Screenshot: GitHub Actions Workflows
**File**: `docs/images/screenshots/06-github-actions.png`

**What to capture**:
- Repository "Actions" tab
- List of workflows (validation, tests, etc.)
- Green statuses (✓) to show everything is working

**How**:
1. Go to the repository's "Actions" tab
2. Capture the list of recent runs
3. Make sure green checkmarks are visible

**Used in**: Understanding-Workflows.md, Template-Validation.md

---

### 7. Screenshot: Configured Labels
**File**: `docs/images/screenshots/07-labels.png`

**What to capture**:
- Repository labels page
- Labels organized by category (type:, status:, priority:)
- Distinct colors

**How**:
1. Go to Issues → Labels
2. Capture the full list
3. Show at least 10-15 labels

**Used in**: Getting-Started.md, Configuration.md

---

### 8. Screenshot: Validation Script Output
**File**: `docs/images/screenshots/08-validation.png`

**What to capture**:
- Terminal running `./scripts/validate_setup.sh`
- All checks passed (✅)
- Final score

**How**:
1. Run `./scripts/validate_setup.sh`
2. Capture the full output
3. Make sure the score is visible

**Used in**: Getting-Started.md, Troubleshooting.md

---

## 🎬 Demo Video to Create

### Video: Full Workflow (2-3 minutes)
**File**: Hosted on YouTube/Vimeo, linked in README

**Detailed Script**:

#### 0:00-0:15 - Introduction
- Show the template README
- On-screen text: "GitHub Project Management - Setup in 2 minutes"
- Brief explanation: "Turnkey template to manage your projects"

#### 0:15-0:45 - Step 1: Use the Template
- Click "Use this template"
- Fill in the new repository name
- Click "Create repository"
- Text: "1️⃣ Create your repository from the template"

#### 0:45-1:15 - Step 2: Setup Script
- Clone the repository locally
- Open a terminal
- Run `./setup-project.sh`
- Show the steps executing (sped up if needed)
- Text: "2️⃣ Run the automatic setup script"

#### 1:15-1:45 - Step 3: Project Board
- Open the created Project Board
- Show the columns
- Show the custom fields
- Quickly create an issue
- Show it automatically appearing on the board
- Text: "3️⃣ Your Project Board is ready!"

#### 1:45-2:15 - Step 4: Automations
- Add the `auto-branch` label to an issue
- Show the automatic comment that appears
- Create a branch from the commands
- Make a commit and open a PR
- Text: "4️⃣ Automations work: branches, reviews, sync"

#### 2:15-2:30 - Step 5: Code Review
- Show Gemini AI reviewing the PR automatically
- Zoom in on a suggestion comment
- Text: "5️⃣ Gemini AI reviews your code automatically"

#### 2:30-2:45 - Conclusion
- Summary of benefits:
  - ✅ Automatic Project Board
  - ✅ Auto-created branches
  - ✅ AI code review
  - ✅ Automated tests
- Text: "Ready in 2 minutes. No technical skills required."
- Display the repository link

#### 2:45-3:00 - Call to Action
- Text: "Try it now!"
- Display: github.com/dyvan/github-project-llm-management
- Display: "⭐ Star the project if it helps you!"

---

## 📝 Where to Use Screenshots

### README.md
```markdown
## ⚡ Quick Start

1. **Click "Use this template"**
   ![Use Template](docs/images/screenshots/01-use-template.png)

2. **Run the setup**
   ```bash
   ./setup-project.sh
   ```
   ![Setup Running](docs/images/screenshots/02-setup-running.png)

3. **Your Project Board is ready!**
   ![Project Board](docs/images/screenshots/03-project-board.png)

**[Watch the full demo video (2 min) →](https://youtube.com/...)**
```

### docs/Getting-Started.md
Add screenshots for each step:
- Step 1: `01-use-template.png`
- Step 2: `02-setup-running.png`
- Step 3: `03-project-board.png`
- Step 4: `07-labels.png`
- Step 5: `08-validation.png`

### docs/Understanding-Workflows.md
Add screenshots to explain:
- Auto-branch: `04-auto-branch-comment.png`
- Code review: `05-gemini-review.png`
- GitHub Actions: `06-github-actions.png`

### docs/Home.md (Wiki Homepage)
Add the demo video at the top:
```markdown
# 🚀 GitHub Project Management

**Presentation video (2 min)**: [Watch the full workflow →](https://youtube.com/...)

![Project Board Example](docs/images/screenshots/03-project-board.png)
```

---

## 🛠️ Recommended Tools

### For Screenshots
- **macOS**: Cmd+Shift+4 (selection), Cmd+Shift+3 (full screen)
- **Windows**: Windows+Shift+S (Snipping Tool)
- **Linux**: `gnome-screenshot` or `flameshot`
- **Annotation**: [Skitch](https://evernote.com/products/skitch) (free)

### For Video
- **Screencast**:
  - [OBS Studio](https://obsproject.com/) (free, cross-platform)
  - [Loom](https://www.loom.com/) (free for short videos)
  - macOS QuickTime (Cmd+Shift+5)
- **Editing**:
  - [DaVinci Resolve](https://www.blackmagicdesign.com/products/davinciresolve) (free)
  - iMovie (macOS)
  - Windows Video Editor

### For Hosting
- **YouTube**: Unlimited, good SEO
- **Vimeo**: More professional
- **Asciinema**: For terminal demos (https://asciinema.org/)

---

## ✅ Publishing Checklist

Before updating the documentation:

- [ ] All screenshots are created (8 files)
- [ ] Screenshots are in PNG or JPG format
- [ ] Minimum resolution: 1920x1080 for wide screenshots
- [ ] Clear annotations (arrows, circles) where needed
- [ ] Demo video recorded (2-3 minutes)
- [ ] Video uploaded to YouTube/Vimeo
- [ ] Video has subtitles/captions (accessibility)
- [ ] Video link tested (not set to private)
- [ ] All files are in `docs/images/`
- [ ] README.md updated with screenshots
- [ ] Wiki pages updated with visuals
- [ ] Committed and pushed to the repository

---

## 🎯 Expected Outcome

After adding visual content:

1. **README.md** becomes much more visually engaging
2. **Wiki** has illustrated guides that are easy to follow
3. **Demo video** lets people understand the project in 2 minutes
4. **Adoption rate** increases (users understand faster)
5. **Fewer questions** (everything is shown visually)

---

## 📚 Additional Resources

- [GitHub Docs - Images in Markdown](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#images)
- [GitHub Wiki Best Practices](https://docs.github.com/en/communities/documenting-your-project-with-wikis/about-wikis)
- [YouTube Video Optimization](https://creatoracademy.youtube.com/)

---

**Note**: This guide is a template. Adapt it to your needs and visual style!
