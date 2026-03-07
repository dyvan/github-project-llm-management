# Architecture Decision Records

This page tracks key architectural and technical decisions using the ADR format.

## Template

When adding a new decision, copy this template:

```markdown
### ADR-NNN: Title

- **Date**: YYYY-MM-DD
- **Status**: Proposed | Accepted | Deprecated | Superseded by ADR-NNN
- **Context**: What is the issue or question?
- **Decision**: What did we decide?
- **Consequences**: What are the trade-offs?
```

## Decisions

### ADR-001: Use GitHub Projects v2 for task tracking

- **Date**: 2025-01-01
- **Status**: Accepted
- **Context**: We need a lightweight project management tool integrated with our codebase.
- **Decision**: Use GitHub Projects v2 with custom fields (Status, Priority, Effort, Type).
- **Consequences**: Tight integration with issues/PRs. Limited reporting compared to Jira. Free.

### ADR-002: Conventional Commits for commit messages

- **Date**: 2025-01-01
- **Status**: Accepted
- **Context**: We need consistent commit messages for changelogs and automation.
- **Decision**: Follow the Conventional Commits specification (feat, fix, docs, etc.).
- **Consequences**: Enables automated changelog generation. Requires team discipline.

---

<!-- Add new ADRs above this line -->

## How to Add a Decision

1. Copy the template above
2. Assign the next ADR number
3. Fill in all fields
4. Set status to "Proposed" for team discussion, or "Accepted" if already agreed
5. Update status when decisions change (Deprecated, Superseded)

## Related Pages

- [Architecture](Architecture) -- current system design
- [Conventions](Conventions) -- coding standards
