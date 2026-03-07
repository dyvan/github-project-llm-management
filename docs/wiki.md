# Wiki Templates

The template includes starter pages for your GitHub Wiki, providing a shared knowledge base for human developers and AI tools.

## Enabling the Wiki

1. Go to your repo **Settings > Features** and check **Wikis**
2. Create one initial page via the GitHub UI (this initializes the wiki git repo)

## Initializing Wiki Pages

```bash
./scripts/init-wiki.sh
```

This clones your wiki repo, copies the template pages, and pushes them. Existing pages are not overwritten.

## Included Pages

| Page | Purpose |
|------|---------|
| `Home.md` | Project overview and quick links |
| `Architecture.md` | System design, components, data flow |
| `Decisions.md` | Architecture Decision Records (ADR log) |
| `Conventions.md` | Code style, naming, git workflow |
| `Onboarding.md` | Setup guide for new contributors |

## How AI Tools Use the Wiki

AI assistants can read wiki pages to understand project context. **Architecture** clarifies component boundaries, **Decisions** explains rationale, and **Conventions** ensures generated code matches project style. Keep pages concise and current.

## Customization

Edit templates in `template/wiki/` before running `init-wiki.sh`, or edit pages directly in the GitHub Wiki UI after initialization.
