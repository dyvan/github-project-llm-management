# Conventions

## Code Style

<!-- Define language-specific style rules -->

- Use the project's linter and formatter configuration
- Run `npm run lint` / `python -m flake8` before committing
- Keep functions short and focused (< 50 lines preferred)
- Write descriptive variable and function names

## Naming Patterns

| Element | Convention | Example |
|---------|-----------|---------|
| Files | kebab-case | `user-service.ts` |
| Classes | PascalCase | `UserService` |
| Functions | camelCase / snake_case | `getUser` / `get_user` |
| Constants | UPPER_SNAKE | `MAX_RETRIES` |
| Database tables | snake_case, plural | `user_accounts` |

## Git Conventions

### Branch Naming

- Features: `feat/{issue-number}-{short-description}`
- Bug fixes: `fix/{issue-number}-{short-description}`
- Documentation: `docs/{issue-number}-{short-description}`
- Refactoring: `refactor/{issue-number}-{short-description}`

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description (#issue-number)
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`, `ci`

### Pull Request Standards

- Reference the issue: `Closes #123`
- Keep PRs focused on one change
- Include a description of what and why
- Add test plan or testing notes
- Respond to review comments before merging

## Testing

- Write tests for new features and bug fixes
- Target > 80% code coverage
- Name tests descriptively: `test_user_login_with_invalid_password_fails`
- Keep unit tests fast (< 1s each)

## Documentation

- Update docs when changing public APIs or behavior
- Keep wiki pages under 80 lines
- Use code examples where helpful

## Related Pages

- [Architecture](Architecture) -- system design
- [Decisions](Decisions) -- why we chose these conventions
- [Onboarding](Onboarding) -- getting started
