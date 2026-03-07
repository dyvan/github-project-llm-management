# AI Features (Gemini)

This project includes optional AI-powered workflows using Google Gemini.
All AI features are **opt-in** and skip cleanly when no API key is configured.

## Workflows Using Gemini

| Workflow | Trigger | What It Does |
|----------|---------|--------------|
| `code-review-agent.yml` | PR opened/synced | Posts an AI code review comment on the PR |
| `plan-with-gemini.yml` | Label `plan-with-gemini` | Generates a specification questionnaire (QCM) on the issue |
| `generate-specification.yml` | Label `generate-specification` | Generates a detailed specification from QCM answers |

## Behavior Without a Key

When no Gemini API key is configured, each workflow:

- Skips the main job entirely (neutral exit, no failure)
- Logs a message: *"AI ... skipped -- no Gemini API key configured."*
- Does **not** block PRs or issue workflows

No action is required to disable AI features -- they are off by default.

## How to Enable

1. Get a Gemini API key at <https://ai.google.dev/gemini-api/docs/api-key>
2. Add it as a repository secret named `GEMINI_API_KEY`
   (**Settings > Secrets and variables > Actions**)
3. AI workflows will activate automatically on the next trigger

## Per-Workflow Keys (Optional)

You can override the key for individual workflows:

| Secret | Used By |
|--------|---------|
| `GEMINI_REVIEW_API_KEY` | `code-review-agent.yml` |
| `GEMINI_PLAN_API_KEY` | `plan-with-gemini.yml` |
| `GEMINI_SPEC_API_KEY` | `generate-specification.yml` |

Each workflow falls back to `GEMINI_API_KEY` if its specific key is not set.
Only `GEMINI_API_KEY` is required; per-workflow keys are optional overrides.
