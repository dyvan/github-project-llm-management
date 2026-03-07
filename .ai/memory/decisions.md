# Decisions

> Architecture Decision Records (ADRs) -- key choices and their rationale.
> Add new decisions at the bottom with a date.

## ADR-001: Gemini for all AI workflows (2025-11)

**Decision**: Use Google Gemini for all AI-powered workflows (code review, planning, specification).

**Rationale**: Free tier available, good quality output, single provider simplifies configuration.

**Alternatives considered**: Claude API, OpenAI API -- higher cost, no significant quality advantage for these tasks.

## ADR-002: Slash commands over CLAUDE.md tutorials (2026-02)

**Decision**: Replace long CLAUDE.md workflow tutorials with slash commands in `.claude/commands/`.

**Rationale**: Zero context cost -- commands load only when invoked. CLAUDE.md tutorials consumed tokens on every interaction.

## ADR-003: Gemini features are opt-in (2026-03)

**Decision**: Keep Gemini workflows but make them opt-in, not required for template users.

**Rationale**: Template should work without any AI API keys. Users who want AI features can enable them.

## ADR-004: Per-workflow API keys with fallback (2025-12)

**Decision**: Support dedicated keys (GEMINI_PLAN_API_KEY, GEMINI_SPEC_API_KEY, GEMINI_REVIEW_API_KEY) with fallback to GEMINI_API_KEY.

**Rationale**: Allows rate-limit isolation per workflow while keeping simple single-key setup as default.

## ADR-005: Setup idempotency via state file (2025-11)

**Decision**: Track setup progress in `.setup-state.json` so steps can be re-run safely.

**Rationale**: Users may interrupt setup or need to re-run after fixing an issue. Idempotent steps prevent duplication.

## ADR-006: English only for all docs and code (2026-03)

**Decision**: All documentation, code comments, and commit messages in English.

**Rationale**: Broader accessibility for international contributors. Translated from French in PR #91.
