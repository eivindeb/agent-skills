---
name: fcommit
description: Apply feature-branch commit philosophy to create concise, atomic progress commits.
---

# Core Purpose

Use commits as context anchors during feature development:
- Archive logical progress in small, searchable commits
- Capture intent (what/why), not implementation details (how)
- Keep branch history easy for humans and agents to scan later
- The git log should be sufficient for ~80% of commits; use `git show` for the rest

## Commit Philosophy (Feature Branches)

- Commit one logical chunk at a time
- Prefer frequent progress commits over large bundled commits
- Message format: `<what changed>: <why it matters>`
- Focus on intent/outcome, not low-level implementation
- Write messages you can later use to reconstruct progress quickly from `git log`

## Message Format

### Subject Line (always required)

**Structure**: `<what changed>: <why it matters>`

**Good examples:**
- `Add user login form: enable authentication flow`
- `Extract validation logic: prepare reuse in signup`
- `Fix password hashing: align with auth requirements`

**Bad examples:**
- `Change bcrypt.hash() to use 12 rounds` (too implementation-specific)
- `Update UserSchema class` (too low-level)
- `Refactor code` (too vague)

### Commit Body (for high-scope commits)

Add a 3-6 line body when the commit has high scope: many files, new modules, cross-layer changes, migrations, or notable design decisions.

The body captures **boundaries and constraints**, not code-level detail:
- What was introduced or removed at a component level
- Key design decisions or tradeoffs made
- Scope boundaries (what this deliberately does *not* touch)

**When to add a body:**
- Commit touches ~5+ files or introduces a new module/subsystem
- There are non-obvious constraints or tradeoffs worth recording
- The subject alone would require `git show` to understand the scope

**When subject-only is fine:**
- Small, focused commits (1-4 files, single concern)
- The subject fully communicates intent and scope
- This is the common case (~80% of commits)

**Body example:**
```
Add eval input transformations: unblock stage-based runs

- New transformation pipeline with routing, service, and pipeline modules
- Each stage adapter declares required input keys via protocol
- Transforms are composable and applied per-example before scoring
- Tests cover pipeline composition and routing dispatch
- Does not change existing harness scoring path
```

## Context Reconstruction

The git log is an abstraction layer, not a replacement for code:
- `git log --oneline` should reconstruct the feature narrative for anyone scanning
- For commits where the subject is enough, no further reading needed
- For high-scope commits, the body should tell you *whether* to dig deeper and *what to look for*
- Use `git show <hash>` when you need actual code changes — the log tells you which commits warrant that

## Workflow

1. Review working tree: `git status` or `git diff`
2. Stage intentionally: `git add <files>` (avoid `git add .`)
3. Assess scope: is this a small focused change, or a high-scope commit?
4. Craft subject using `<what changed>: <why it matters>`
5. For high-scope commits: add a body capturing boundaries and constraints
6. Commit: `git commit -m "<message>"` (or use HEREDOC for multi-line)
7. Verify: `git log -1` (use `--oneline` for subject-only, full for body commits)

## Safety Checks

- On feature branch (warn if on `main`)
- No secrets in staged files
- Commit is atomic (single logical change)
- Never amend commits
- Never use `git add .`
