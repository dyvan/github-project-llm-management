---
hide:
  - navigation
  - toc
  - footer
---

<style>
/* ── Reset & Base ── */
.md-typeset h1 { display: none; }
.md-content__inner { padding: 0 !important; margin: 0 !important; max-width: 100% !important; }
.md-main__inner { margin-top: 0; }
.md-content { max-width: 100%; }
.md-typeset .headerlink { display: none; }

/* ── Hero ── */
.hero {
  text-align: center;
  padding: 6em 2em 4.5em;
  background: linear-gradient(135deg, #0f0c29 0%, #1a1a3e 40%, #24243e 100%);
  color: #e8e8e8;
  position: relative;
  overflow: hidden;
}
.hero::before {
  content: '';
  position: absolute;
  top: -50%;
  left: -50%;
  width: 200%;
  height: 200%;
  background: radial-gradient(ellipse at 25% 50%, rgba(99, 102, 241, 0.12) 0%, transparent 55%),
              radial-gradient(ellipse at 75% 30%, rgba(139, 92, 246, 0.08) 0%, transparent 50%),
              radial-gradient(ellipse at 50% 80%, rgba(245, 158, 11, 0.06) 0%, transparent 45%);
  pointer-events: none;
  animation: heroGlow 8s ease-in-out infinite alternate;
}
@keyframes heroGlow {
  0% { opacity: 0.7; transform: scale(1); }
  100% { opacity: 1; transform: scale(1.05); }
}
.hero-title {
  font-size: 3.2em;
  font-weight: 800;
  margin: 0 0 0.3em;
  color: #fff;
  letter-spacing: -0.03em;
  line-height: 1.1;
  position: relative;
}
.hero-title .accent {
  background: linear-gradient(135deg, #818cf8 0%, #a78bfa 40%, #f59e0b 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}
.hero .subtitle {
  font-size: 1.25em;
  color: #94a3b8;
  margin-bottom: 2.5em;
  max-width: 680px;
  margin-left: auto;
  margin-right: auto;
  line-height: 1.7;
  position: relative;
}
.hero .cta-row {
  display: flex;
  justify-content: center;
  gap: 1em;
  flex-wrap: wrap;
  position: relative;
}
.btn-primary {
  background: linear-gradient(135deg, #6366f1, #8b5cf6);
  color: #fff !important;
  padding: 0.85em 2.2em;
  border-radius: 10px;
  font-weight: 600;
  font-size: 1em;
  text-decoration: none !important;
  transition: all 0.3s ease;
  border: none;
  display: inline-block;
  box-shadow: 0 4px 15px rgba(99, 102, 241, 0.3);
}
.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 30px rgba(99, 102, 241, 0.45);
}
.btn-secondary {
  background: rgba(255,255,255,0.06);
  color: #e8e8e8 !important;
  padding: 0.85em 2.2em;
  border-radius: 10px;
  font-weight: 600;
  font-size: 1em;
  text-decoration: none !important;
  transition: all 0.3s ease;
  border: 1px solid rgba(255,255,255,0.12);
  display: inline-block;
  backdrop-filter: blur(10px);
}
.btn-secondary:hover {
  background: rgba(255,255,255,0.12);
  transform: translateY(-2px);
  border-color: rgba(255,255,255,0.2);
}

/* ── Stats ── */
.stats-bar {
  display: flex;
  justify-content: center;
  gap: 0;
  background: linear-gradient(180deg, #1a1a3e 0%, rgba(26,26,62,0) 100%);
  padding: 2em 1em 3em;
  position: relative;
}
[data-md-color-scheme="default"] .stats-bar {
  background: linear-gradient(180deg, #eef2ff 0%, transparent 100%);
}
.stat-card {
  text-align: center;
  padding: 1.8em 2.5em;
  position: relative;
}
.stat-card + .stat-card::before {
  content: '';
  position: absolute;
  left: 0;
  top: 25%;
  height: 50%;
  width: 1px;
  background: rgba(255,255,255,0.08);
}
[data-md-color-scheme="default"] .stat-card + .stat-card::before {
  background: rgba(0,0,0,0.08);
}
.stat-number {
  font-size: 2.8em;
  font-weight: 800;
  background: linear-gradient(135deg, #818cf8, #a78bfa);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  display: block;
  line-height: 1.2;
}
[data-md-color-scheme="default"] .stat-number {
  background: linear-gradient(135deg, #4f46e5, #7c3aed);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}
.stat-label {
  font-size: 0.75em;
  color: #64748b;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  margin-top: 0.3em;
  font-weight: 500;
}

/* ── Install Box ── */
.install-section {
  text-align: center;
  padding: 4em 2em 3em;
  max-width: 800px;
  margin: 0 auto;
}
.install-box {
  background: #0d1117;
  border: 1px solid #21262d;
  border-radius: 12px;
  padding: 1.2em 1.8em;
  max-width: 700px;
  margin: 1.5em auto;
  position: relative;
  text-align: left;
  font-family: var(--md-code-font);
  display: flex;
  align-items: center;
  gap: 1em;
}
[data-md-color-scheme="default"] .install-box {
  background: #1e293b;
  border-color: #334155;
}
.install-box .prompt { color: #8b5cf6; font-weight: 700; flex-shrink: 0; }
.install-box code {
  color: #c4b5fd !important;
  font-size: 0.88em;
  background: none !important;
  border: none !important;
  padding: 0 !important;
  word-break: break-all;
}
.install-hint {
  color: #64748b;
  font-size: 0.9em;
  margin-top: 1.2em;
  line-height: 1.6;
}

/* ── Section headings ── */
.landing-section h2,
.comparison-wrap h2,
.workflow-wrap h2,
.faq-wrap h2 {
  text-align: center;
  font-size: 2.2em;
  font-weight: 800;
  margin-bottom: 0.2em;
  color: var(--md-default-fg-color);
  letter-spacing: -0.02em;
}
.section-sub {
  text-align: center;
  color: var(--md-default-fg-color--light);
  margin-bottom: 2.5em;
  font-size: 1.1em;
}

/* ── Section wrappers ── */
.landing-section {
  padding: 3em 2em;
  max-width: 1100px;
  margin: 0 auto;
}

/* ── Feature Cards ── */
.features-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1.5em;
  margin-top: 2.5em;
}
.feature-card {
  padding: 2em;
  border-radius: 16px;
  border: 1px solid rgba(255,255,255,0.06);
  background: rgba(255,255,255,0.02);
  transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}
.feature-card::after {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: 16px;
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.05), transparent);
  opacity: 0;
  transition: opacity 0.35s ease;
}
.feature-card:hover::after { opacity: 1; }
.feature-card:hover {
  transform: translateY(-5px);
  border-color: rgba(129, 140, 248, 0.25);
  box-shadow: 0 20px 40px rgba(99, 102, 241, 0.12);
}
[data-md-color-scheme="default"] .feature-card {
  background: #fff;
  border: 1px solid #e2e8f0;
  box-shadow: 0 1px 3px rgba(0,0,0,0.04);
}
[data-md-color-scheme="default"] .feature-card:hover {
  border-color: #a5b4fc;
  box-shadow: 0 20px 40px rgba(79, 70, 229, 0.08);
}
.feature-icon {
  width: 44px;
  height: 44px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 1em;
  font-size: 1.3em;
  font-weight: 700;
  color: #fff;
  position: relative;
  z-index: 1;
}
.feature-icon.icon-commands  { background: linear-gradient(135deg, #6366f1, #818cf8); }
.feature-icon.icon-agent     { background: linear-gradient(135deg, #8b5cf6, #a78bfa); }
.feature-icon.icon-board     { background: linear-gradient(135deg, #4f46e5, #6366f1); }
.feature-icon.icon-review    { background: linear-gradient(135deg, #7c3aed, #8b5cf6); }
.feature-icon.icon-branch    { background: linear-gradient(135deg, #6d28d9, #7c3aed); }
.feature-icon.icon-spec      { background: linear-gradient(135deg, #6366f1, #a78bfa); }
.feature-icon.icon-memory    { background: linear-gradient(135deg, #059669, #10b981); }
.feature-icon.icon-hooks     { background: linear-gradient(135deg, #d97706, #f59e0b); }
.feature-icon.icon-plugin    { background: linear-gradient(135deg, #dc2626, #f87171); }
.feature-icon.icon-close     { background: linear-gradient(135deg, #0891b2, #22d3ee); }
.feature-icon.icon-test      { background: linear-gradient(135deg, #4338ca, #6366f1); }
.feature-icon.icon-setup     { background: linear-gradient(135deg, #7c3aed, #a78bfa); }
.feature-card h3 {
  font-size: 1.1em;
  font-weight: 700;
  margin: 0.4em 0;
  color: var(--md-default-fg-color);
  position: relative;
  z-index: 1;
}
.feature-card p {
  font-size: 0.9em;
  color: var(--md-default-fg-color--light);
  line-height: 1.65;
  margin: 0;
  position: relative;
  z-index: 1;
}

/* ── Command List ── */
.commands-section {
  max-width: 900px;
  margin: 0 auto;
  padding: 3em 2em;
}
.commands-section h2 {
  text-align: center;
  font-size: 2.2em;
  font-weight: 800;
  margin-bottom: 0.2em;
  color: var(--md-default-fg-color);
  letter-spacing: -0.02em;
}
.commands-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1em;
  margin-top: 2em;
}
.cmd-card {
  display: flex;
  align-items: flex-start;
  gap: 1em;
  padding: 1.2em 1.4em;
  border-radius: 12px;
  border: 1px solid rgba(255,255,255,0.06);
  background: rgba(255,255,255,0.02);
  transition: all 0.2s ease;
}
.cmd-card:hover {
  border-color: rgba(129, 140, 248, 0.2);
  background: rgba(99, 102, 241, 0.04);
}
[data-md-color-scheme="default"] .cmd-card {
  background: #fff;
  border: 1px solid #e2e8f0;
}
[data-md-color-scheme="default"] .cmd-card:hover {
  border-color: #a5b4fc;
  background: #f5f3ff;
}
.cmd-name {
  font-family: var(--md-code-font);
  font-size: 0.88em;
  font-weight: 700;
  color: #818cf8;
  white-space: nowrap;
  min-width: 130px;
}
[data-md-color-scheme="default"] .cmd-name {
  color: #4f46e5;
}
.cmd-desc {
  font-size: 0.88em;
  color: var(--md-default-fg-color--light);
  line-height: 1.5;
}

/* ── Workflow Pipeline ── */
.workflow-wrap {
  text-align: center;
  max-width: 1000px;
  margin: 0 auto;
  padding: 2em 2em 1em;
}
.pipeline-container {
  margin: 2.5em auto 1em;
  max-width: 520px;
  display: flex;
  gap: 2em;
  justify-content: center;
}
.pipeline-group {
  flex: 1;
  max-width: 240px;
  position: relative;
}
.pipeline-group-border {
  border: 1px solid rgba(99, 102, 241, 0.25);
  border-radius: 20px;
  padding: 1.5em 1.2em;
  position: relative;
}
.pipeline-group-border.auto-border {
  border-color: rgba(245, 158, 11, 0.3);
}
[data-md-color-scheme="default"] .pipeline-group-border {
  border-color: rgba(99, 102, 241, 0.2);
}
[data-md-color-scheme="default"] .pipeline-group-border.auto-border {
  border-color: rgba(245, 158, 11, 0.25);
}
.pipeline-group-label {
  position: absolute;
  top: -0.7em;
  left: 1.5em;
  font-size: 0.7em;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.12em;
  padding: 0 0.6em;
  background: var(--md-default-bg-color, #1a1a2e);
}
.pipeline-group-label.manual-label { color: #818cf8; }
.pipeline-group-label.auto-label { color: #f59e0b; }
[data-md-color-scheme="default"] .pipeline-group-label {
  background: var(--md-default-bg-color, #fff);
}
.flow-card {
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 12px;
  padding: 0.9em 1.1em;
  text-align: center;
}
[data-md-color-scheme="default"] .flow-card {
  background: #f8fafc;
  border-color: #e2e8f0;
}
.flow-card .flow-title {
  font-weight: 700;
  font-size: 0.88em;
  color: var(--md-default-fg-color);
  display: block;
  margin-bottom: 0.15em;
}
.flow-card .flow-desc {
  font-size: 0.75em;
  color: var(--md-default-fg-color--light);
  display: block;
  line-height: 1.4;
}
.flow-card.done-card {
  background: linear-gradient(135deg, rgba(245, 158, 11, 0.15), rgba(217, 119, 6, 0.1));
  border-color: rgba(245, 158, 11, 0.3);
}
[data-md-color-scheme="default"] .flow-card.done-card {
  background: linear-gradient(135deg, #fffbeb, #fef3c7);
  border-color: #fcd34d;
}
.flow-card.done-card .flow-title { color: #f59e0b; }
[data-md-color-scheme="default"] .flow-card.done-card .flow-title { color: #b45309; }
.flow-connector {
  display: flex;
  justify-content: center;
  padding: 0.4em 0;
}
.flow-connector .dash {
  width: 1px;
  height: 20px;
  border-left: 2px dashed rgba(255, 255, 255, 0.12);
}
[data-md-color-scheme="default"] .flow-connector .dash {
  border-left-color: rgba(0, 0, 0, 0.1);
}
.pipeline-bridge {
  display: flex;
  align-items: center;
  justify-content: center;
  align-self: center;
  flex-shrink: 0;
  padding-top: 1em;
}
.pipeline-bridge svg {
  width: 32px;
  height: 32px;
}
.pipeline-bridge svg path {
  fill: none;
  stroke: #475569;
  stroke-width: 1.5;
  stroke-dasharray: 4 3;
}
[data-md-color-scheme="default"] .pipeline-bridge svg path {
  stroke: #94a3b8;
}
@media (max-width: 600px) {
  .pipeline-container {
    flex-direction: column;
    align-items: center;
    gap: 1em;
  }
  .pipeline-group { max-width: 280px; }
  .pipeline-bridge { transform: rotate(90deg); padding: 0; }
}

/* ── Comparison Table ── */
.comparison-wrap {
  max-width: 820px;
  margin: 0 auto;
  padding: 3em 2em;
}
.comparison-table {
  width: 100%;
  border-collapse: separate;
  border-spacing: 0;
  border-radius: 16px;
  overflow: hidden;
  border: 1px solid rgba(255,255,255,0.06);
  margin-top: 2em;
}
[data-md-color-scheme="default"] .comparison-table {
  border: 1px solid #e2e8f0;
}
.comparison-table th {
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.15), rgba(139, 92, 246, 0.1));
  padding: 1em 1.3em;
  font-weight: 700;
  text-align: left;
  font-size: 0.82em;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: #818cf8;
}
[data-md-color-scheme="default"] .comparison-table th {
  background: linear-gradient(135deg, #eef2ff, #ede9fe);
  color: #4338ca;
}
.comparison-table td {
  padding: 1em 1.3em;
  border-bottom: 1px solid rgba(255,255,255,0.04);
  font-size: 0.92em;
}
[data-md-color-scheme="default"] .comparison-table td {
  border-bottom: 1px solid #f1f5f9;
}
.comparison-table tr:last-child td { border-bottom: none; }
.comparison-table tr:hover td {
  background: rgba(99, 102, 241, 0.04);
}
.comparison-table td:nth-child(3) {
  color: #a78bfa;
  font-weight: 600;
}
[data-md-color-scheme="default"] .comparison-table td:nth-child(3) {
  color: #6d28d9;
}

/* ── Steps ── */
.steps-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 2em;
  margin-top: 2.5em;
}
.step-card {
  padding: 2em;
  border-radius: 16px;
  border: 1px solid rgba(255,255,255,0.06);
  background: rgba(255,255,255,0.02);
  position: relative;
}
.md-typeset .step-card,
.md-typeset .step-card h3 {
  text-align: center !important;
}
.md-typeset .step-card .highlight {
  text-align: left;
}
.md-typeset .step-card pre {
  overflow-x: auto;
  white-space: pre;
  word-break: normal;
}
.md-typeset .step-card pre code {
  font-size: 0.75em !important;
}
[data-md-color-scheme="default"] .step-card {
  background: #fff;
  border: 1px solid #e2e8f0;
  box-shadow: 0 1px 3px rgba(0,0,0,0.04);
}
.step-number {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  border-radius: 12px;
  background: linear-gradient(135deg, #6366f1, #8b5cf6);
  color: #fff;
  font-weight: 800;
  font-size: 1em;
  margin-bottom: 1em;
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.25);
}
.step-card h3 {
  font-size: 1.1em;
  font-weight: 700;
  margin: 0.3em 0 0.8em;
  color: var(--md-default-fg-color);
}
.step-card pre {
  font-size: 0.8em !important;
  border-radius: 8px !important;
  text-align: left;
}

/* ── FAQ ── */
.faq-wrap {
  max-width: 780px;
  margin: 0 auto;
  padding: 3em 2em;
}
:root {
  --md-admonition-icon--question: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M11.07 12.85c.77-1.39 2.25-2.21 3.11-3.44.91-1.29.4-3.7-2.18-3.7-1.69 0-2.52 1.28-2.87 2.34L6.54 6.96C7.25 4.83 9.18 3 11.99 3c2.35 0 3.96 1.07 4.78 2.41.7 1.15 1.11 3.3.03 4.9-1.2 1.77-2.35 2.31-2.97 3.45-.25.46-.35.76-.35 2.24h-2.89c-.01-.78-.13-2.05.48-3.15M14 20c0 1.1-.9 2-2 2s-2-.9-2-2 .9-2 2-2 2 .9 2 2"/></svg>');
}
.md-typeset .admonition.question,
.md-typeset details.question {
  border-color: #6366f1 !important;
}
.md-typeset .question > .admonition-title,
.md-typeset .question > summary {
  background-color: rgba(99, 102, 241, 0.1) !important;
}
.md-typeset .question > .admonition-title::before,
.md-typeset .question > summary::before {
  background-color: #6366f1 !important;
}

/* ── Footer CTA ── */
.footer-cta {
  text-align: center;
  padding: 5em 2em 6em;
  background: linear-gradient(135deg, #0f0c29 0%, #1a1a3e 40%, #24243e 100%);
  color: #e8e8e8;
  position: relative;
  overflow: hidden;
}
.footer-cta::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(99,102,241,0.3), transparent);
}
.footer-cta h2 {
  font-size: 2.2em;
  font-weight: 800;
  color: #fff;
  margin-bottom: 0.3em;
  letter-spacing: -0.02em;
}
.footer-cta p {
  color: #94a3b8;
  margin-bottom: 2.5em;
  font-size: 1.15em;
}
[data-md-color-scheme="default"] .footer-cta {
  background: linear-gradient(135deg, #eef2ff 0%, #e0e7ff 50%, #ede9fe 100%);
  color: #1e293b;
}
[data-md-color-scheme="default"] .footer-cta::before {
  background: linear-gradient(90deg, transparent, rgba(79,70,229,0.2), transparent);
}
[data-md-color-scheme="default"] .footer-cta h2 { color: #1e293b; }
[data-md-color-scheme="default"] .footer-cta p { color: #475569; }
[data-md-color-scheme="default"] .btn-secondary {
  color: #1e293b !important;
  border-color: rgba(0,0,0,0.12);
  background: rgba(0,0,0,0.04);
}
[data-md-color-scheme="default"] .btn-secondary:hover {
  background: rgba(0,0,0,0.08);
}

/* ── Responsive ── */
@media (max-width: 900px) {
  .features-grid, .steps-grid { grid-template-columns: 1fr; }
  .commands-grid { grid-template-columns: 1fr; }
}
@media (max-width: 768px) {
  .hero-title { font-size: 2em; }
  .hero .subtitle { font-size: 1em; }
  .stat-card { padding: 1em 1.5em; }
  .stat-number { font-size: 2em; }
  .landing-section h2, .comparison-wrap h2, .workflow-wrap h2, .commands-section h2, .faq-wrap h2, .footer-cta h2 { font-size: 1.6em; }
}
</style>

# GitHub Project LLM Management

<!-- Hero -->
<div class="hero">
<div class="hero-title">AI-Powered GitHub<br>Project <span class="accent">Management</span></div>
<p class="subtitle">
Slash commands, a PM agent, Gemini workflows, and a full Kanban board -- all wired into your repo. You write code. The template handles everything else.
</p>
<div class="cta-row">
<a href="Getting-Started/" class="btn-primary">Get Started</a>
<a href="https://github.com/dyvan/github-project-llm-management" class="btn-secondary">View on GitHub</a>
</div>
</div>

<!-- Stats -->
<div class="stats-bar">
<div class="stat-card">
<span class="stat-number">8</span>
<span class="stat-label">Slash Commands</span>
</div>
<div class="stat-card">
<span class="stat-number">9</span>
<span class="stat-label">Workflows</span>
</div>
<div class="stat-card">
<span class="stat-number">1</span>
<span class="stat-label">Command Setup</span>
</div>
<div class="stat-card">
<span class="stat-number">0</span>
<span class="stat-label">Config Needed</span>
</div>
</div>

<!-- Install -->
<div class="install-section" markdown>

## Install in one command

<div class="install-box">
<span class="prompt">$</span>
<code>curl -fsSL https://raw.githubusercontent.com/dyvan/github-project-llm-management/main/install.sh | bash</code>
</div>

<p class="install-hint">The setup wizard asks for your GitHub token and optional Gemini API key.<br>Labels, project board, and workflows are configured automatically.</p>

</div>

<!-- Core Features -->
<div class="landing-section" markdown>

## What you get

<p class="section-sub">Slash commands, an AI agent, automated workflows, and plugin packaging -- all in one template.</p>

<div class="features-grid">
<div class="feature-card">
<div class="feature-icon icon-commands">
<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="4 17 10 11 4 5"/><line x1="12" y1="19" x2="20" y2="19"/></svg>
</div>
<h3>Slash Commands</h3>
<p>Eight built-in commands for Claude Code: start tasks, finish PRs, plan sprints, pick the next task, save session context, and more.</p>
</div>
<div class="feature-card">
<div class="feature-icon icon-agent">
<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2a4 4 0 0 1 4 4c0 1.95-1.4 3.57-3.25 3.92"/><path d="M12 2a4 4 0 0 0-4 4c0 1.95 1.4 3.57 3.25 3.92"/><path d="M15.24 9.71a2 2 0 0 1 .76 1.58v.22a2 2 0 0 1-2 2h-4a2 2 0 0 1-2-2v-.22a2 2 0 0 1 .76-1.58"/><rect x="8" y="16" width="8" height="5" rx="1"/><path d="M12 13.5v2.5"/><path d="M8 18h8"/></svg>
</div>
<h3>PM Agent</h3>
<p>A dedicated project management agent that understands your board, priorities, milestones, and can orchestrate multi-step workflows autonomously.</p>
</div>
<div class="feature-card">
<div class="feature-icon icon-review">
<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/><line x1="9" y1="10" x2="15" y2="10"/></svg>
</div>
<h3>AI Code Review</h3>
<p>Every PR is analyzed by Gemini AI with improvement suggestions, bug detection, and security checks -- posted as a PR comment automatically.</p>
</div>
<div class="feature-card">
<div class="feature-icon icon-board">
<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/></svg>
</div>
<h3>Auto Project Board</h3>
<p>Issues and PRs flow through your Kanban board automatically. Status moves from Backlog to Done without any manual dragging.</p>
</div>
<div class="feature-card">
<div class="feature-icon icon-spec">
<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
</div>
<h3>Spec Questionnaire</h3>
<p>Gemini generates a tailored questionnaire to clarify requirements before any code is written. Answers feed into a detailed specification.</p>
</div>
<div class="feature-card">
<div class="feature-icon icon-branch">
<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="6" y1="3" x2="6" y2="15"/><circle cx="18" cy="6" r="3"/><circle cx="6" cy="18" r="3"/><path d="M18 9a9 9 0 0 1-9 9"/></svg>
</div>
<h3>Automatic Branches</h3>
<p>Add the <code>auto-branch</code> label to any issue. A branch named <code>feat/123-title</code> is created and linked in seconds.</p>
</div>
<div class="feature-card">
<div class="feature-icon icon-memory">
<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/><line x1="8" y1="7" x2="16" y2="7"/><line x1="8" y1="11" x2="13" y2="11"/></svg>
</div>
<h3>Project Memory</h3>
<p>Persistent context stored in <code>.ai/memory/</code> survives between sessions. Decisions, architecture choices, and blockers are never forgotten.</p>
</div>
<div class="feature-card">
<div class="feature-icon icon-hooks">
<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/></svg>
</div>
<h3>Hooks</h3>
<p>Lifecycle hooks let you inject custom logic at key moments -- before commits, after branch creation, on PR events. Fully extensible.</p>
</div>
<div class="feature-card">
<div class="feature-icon icon-plugin">
<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"/><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/></svg>
</div>
<h3>Plugin Packaging</h3>
<p>Distribute as a Claude Code plugin via <code>.claude-plugin/</code>. Drop it into any repo to get the full PM toolkit instantly.</p>
</div>
<div class="feature-card">
<div class="feature-icon icon-close">
<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="16 12 12 8 8 12"/><line x1="12" y1="16" x2="12" y2="8"/></svg>
</div>
<h3>Auto-close Features</h3>
<p>Parent issues close automatically when all sub-issues are done. No manual tracking required.</p>
</div>
<div class="feature-card">
<div class="feature-icon icon-test">
<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 11 12 14 22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
</div>
<h3>CI/CD Out of the Box</h3>
<p>Lint, tests, and build run on every PR. Results are posted as comments. Zero CI setup needed.</p>
</div>
<div class="feature-card">
<div class="feature-icon icon-setup">
<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg>
</div>
<h3>One-command Setup</h3>
<p>A single <code>curl</code> command installs everything: labels, project board, workflows, scripts, and documentation. Idempotent and re-runnable.</p>
</div>
</div>

</div>

<!-- Slash Commands -->
<div class="commands-section" markdown>

## Slash commands for Claude Code

<p class="section-sub">Type <code>/</code> in Claude Code to access project management directly from your terminal.</p>

<div class="commands-grid">
<div class="cmd-card">
<span class="cmd-name">/start-task</span>
<span class="cmd-desc">Pick an issue, create a branch, update the board to In Progress</span>
</div>
<div class="cmd-card">
<span class="cmd-name">/finish-task</span>
<span class="cmd-desc">Open a PR, move the issue to In Review</span>
</div>
<div class="cmd-card">
<span class="cmd-name">/next-task</span>
<span class="cmd-desc">Auto-pick the highest priority Ready task from the board</span>
</div>
<div class="cmd-card">
<span class="cmd-name">/plan-task</span>
<span class="cmd-desc">Break down a feature into estimated sub-tasks</span>
</div>
<div class="cmd-card">
<span class="cmd-name">/task-status</span>
<span class="cmd-desc">Show current task status, branch, and board state</span>
</div>
<div class="cmd-card">
<span class="cmd-name">/sprint-report</span>
<span class="cmd-desc">Generate a sprint progress report with velocity metrics</span>
</div>
<div class="cmd-card">
<span class="cmd-name">/save-session</span>
<span class="cmd-desc">Save session context to an issue comment for later</span>
</div>
<div class="cmd-card">
<span class="cmd-name">/load-session</span>
<span class="cmd-desc">Restore context from a previous session</span>
</div>
</div>

</div>

<!-- Comparison -->
<div class="comparison-wrap" markdown>

## Manual work vs. this template

<p class="section-sub">See what changes when automation takes over.</p>

<table class="comparison-table">
<thead>
<tr><th>Task</th><th>Without</th><th>With template</th></tr>
</thead>
<tbody>
<tr><td>Start a task</td><td>Create branch, update board, assign</td><td><code>/start-task</code></td></tr>
<tr><td>Track issue status</td><td>Drag cards on the board</td><td>Automatic: Backlog &rarr; Done</td></tr>
<tr><td>Code review</td><td>Wait for humans</td><td>Gemini reviews in seconds</td></tr>
<tr><td>Pick next task</td><td>Scan board, check priorities</td><td><code>/next-task</code></td></tr>
<tr><td>Clarify requirements</td><td>Meetings, back-and-forth</td><td>Gemini generates a spec questionnaire</td></tr>
<tr><td>Close parent issues</td><td>Remember to check manually</td><td>Auto-closes when sub-issues are done</td></tr>
<tr><td>Sprint report</td><td>Spreadsheet or manual notes</td><td><code>/sprint-report</code></td></tr>
<tr><td>Session context</td><td>Lost between sessions</td><td><code>/save-session</code> + <code>/load-session</code></td></tr>
</tbody>
</table>

</div>

<!-- Workflow -->
<div class="workflow-wrap" markdown>

## How it works

<div class="pipeline-container">
<div class="pipeline-group">
<div class="pipeline-group-border">
<span class="pipeline-group-label manual-label">You</span>
<div class="flow-card">
<span class="flow-title">/start-task</span>
<span class="flow-desc">Pick an issue, branch is created</span>
</div>
<div class="flow-connector"><div class="dash"></div></div>
<div class="flow-card">
<span class="flow-title">Develop & Push</span>
<span class="flow-desc">Write code on your branch</span>
</div>
<div class="flow-connector"><div class="dash"></div></div>
<div class="flow-card">
<span class="flow-title">/finish-task</span>
<span class="flow-desc">PR created, board updated</span>
</div>
</div>
</div>
<div class="pipeline-bridge"><svg viewBox="0 0 32 20"><path d="M2 10h28M24 5l6 5-6 5"/></svg></div>
<div class="pipeline-group">
<div class="pipeline-group-border auto-border">
<span class="pipeline-group-label auto-label">Automated</span>
<div class="flow-card">
<span class="flow-title">AI Code Review</span>
<span class="flow-desc">Gemini analyzes your PR</span>
</div>
<div class="flow-connector"><div class="dash"></div></div>
<div class="flow-card">
<span class="flow-title">CI Tests</span>
<span class="flow-desc">Lint, test, build</span>
</div>
<div class="flow-connector"><div class="dash"></div></div>
<div class="flow-card done-card">
<span class="flow-title">Done</span>
<span class="flow-desc">Issue closed, board updated</span>
</div>
</div>
</div>
</div>

</div>

<!-- Steps -->
<div class="landing-section" markdown>

## Get started in 3 steps

<div class="steps-grid">
<div class="step-card" markdown>
<span class="step-number">1</span>
<h3>Install</h3>

```bash
curl -fsSL https://raw.github\
usercontent.com/dyvan/github-\
project-llm-management/main/\
install.sh | bash
```

</div>
<div class="step-card" markdown>
<span class="step-number">2</span>
<h3>Start a task</h3>

```bash
# In Claude Code, type:
/start-task
# Pick issue, branch is created,
# board moves to In Progress
```

</div>
<div class="step-card" markdown>
<span class="step-number">3</span>
<h3>Ship it</h3>

```bash
# When done, type:
/finish-task
# PR created, AI review runs,
# issue auto-closes on merge
```

</div>
</div>

</div>

<!-- FAQ -->
<div class="faq-wrap" markdown>

## Frequently asked questions

??? question "Do I need a Gemini API key?"
    It's optional. Without it you still get automatic branches, project board sync, CI tests, slash commands, the PM agent, and auto-close. The Gemini key enables AI code review and specification questionnaires.

??? question "What AI coding tools does this work with?"
    The slash commands and PM agent are built for Claude Code, but the GitHub workflows and automation work with any tool -- Cursor, GitHub Copilot, Windsurf, or plain vim.

??? question "Can I use this with an existing repo?"
    Yes. The install script creates a new project, but you can also copy the workflows, commands, and scripts into an existing repo manually.

??? question "Is this only for Python projects?"
    No. The template works with any language. The Python scripts power the automation layer. Your project code can be anything.

??? question "What GitHub token scopes do I need?"
    The token needs `repo`, `project`, and `workflow` scopes. The setup wizard tells you exactly what to configure.

??? question "What is the PM Agent?"
    A dedicated Claude Code agent (defined in `.claude/agents/pm-agent.md`) that understands your project board, priorities, and milestones. It can orchestrate multi-step project management workflows autonomously.

??? question "How does project memory work?"
    Session context and project decisions are stored in `.ai/memory/` and issue comments. Use `/save-session` before ending work and `/load-session` to pick up where you left off.

</div>

<!-- Footer CTA -->
<div class="footer-cta">
<h2>Ready to automate your project?</h2>
<p>Set up in under 5 minutes. No credit card. No account. Just GitHub.</p>
<div class="cta-row">
<a href="Getting-Started/" class="btn-primary">Get Started</a>
<a href="https://github.com/dyvan/github-project-llm-management" class="btn-secondary">Star on GitHub</a>
</div>
</div>
