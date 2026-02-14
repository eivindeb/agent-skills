---
name: fcommit
description: Apply feature-branch commit philosophy to create concise, atomic progress commits.
---

# Core Purpose

Use commits as context anchors during feature development:
- Archive logical progress in small, searchable commits
- Capture intent (what/why), not implementation details (how)
- Keep branch history easy for humans and agents to scan later

## Commit Philosophy (Feature Branches)

- Commit one logical chunk at a time
- Prefer frequent progress commits over large bundled commits
- Message format: `<what changed>: <why it matters>`
- Focus on intent/outcome, not low-level implementation
- Write messages you can later use to reconstruct progress quickly from `git log`

## Message Format

**Structure**: `<what changed>: <why it matters>`

**Good examples:**
- `Add user login form: enable authentication flow`
- `Extract validation logic: prepare reuse in signup`
- `Fix password hashing: align with auth requirements`

**Bad examples:**
- `Change bcrypt.hash() to use 12 rounds` (too implementation-specific)
- `Update UserSchema class` (too low-level)
- `Refactor code` (too vague)

## Workflow

1. Review working tree: `git status` or `git diff`
2. Stage intentionally: `git add <files>` (avoid `git add .`)
3. Craft message using `<what changed>: <why it matters>`
4. Commit: `git commit -m "<message>"`
5. Verify: `git log -1 --oneline`

## Safety Checks

- On feature branch (warn if on `main`)
- No secrets in staged files
- Commit is atomic (single logical change)
- Never amend commits
- Never use `git add .`
