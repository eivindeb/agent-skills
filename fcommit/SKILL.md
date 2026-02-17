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

The why-clause must distinguish concrete impact. If it's generic enough to apply to any commit ("improve observability", "improve reproducibility"), rewrite it with the specific outcome or risk avoided.

**Good examples:**
- `Add user login form: enable authentication flow`
- `Extract validation logic: prepare reuse in signup`
- `Fix password hashing: align with auth requirements`
- `Track readiness timing: surface gaps that caused false-negative health checks`

**Bad examples:**
- `Change bcrypt.hash() to use 12 rounds` (too implementation-specific)
- `Update UserSchema class` (too low-level)
- `Refactor code` (too vague)
- `Track readiness timing: improve deployment observability` (generic why — what observability gap?)

### Commit Body (for high-scope commits)

**First: split before adding a body.** If a commit is large but separable into coherent atomic commits, split it. Use a body only when splitting would hurt coherence — e.g., a new module where the parts don't make sense independently.

The body captures **boundaries and constraints**, not code-level detail. Use whichever of these apply:
- **Introduces**: what was added at a component/module level
- **Decision**: key design choices or tradeoffs made
- **Out of scope**: what this deliberately does *not* touch

**When to add a body** — the primary trigger is conceptual surface area, not file count:
- A new subsystem, workflow, or API contract is introduced
- There are non-obvious constraints or tradeoffs worth recording
- The subject alone wouldn't let someone understand the scope without reading code

File count is a secondary hint (~5+ files suggests high scope), but a 2-file commit introducing a new contract warrants a body, while a 10-file mechanical rename may not.

**When subject-only is fine:**
- Small, focused commits (single concern)
- The subject fully communicates intent and scope
- Mechanically repetitive changes (renames, formatting, version bumps)
- This is the common case (~80% of commits)

**Body example:**
```
Add eval input transformations: unblock stage-based runs

- Introduces: transformation pipeline with routing, service, and pipeline modules
- Decision: stage adapters declare required input keys via protocol; transforms
  are composable and applied per-example before scoring
- Out of scope: existing harness scoring path unchanged
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
3. Assess scope: can this be split into smaller coherent commits? If yes, split first.
4. Craft subject using `<what changed>: <why it matters>` — check the why-clause is specific, not generic
5. If high conceptual scope: add a body (Introduces / Decision / Out of scope)
6. Commit: `git commit -m "<message>"` (or use HEREDOC for multi-line)
7. Verify: `git log -1` (use `--oneline` for subject-only, full for body commits)

## Safety Checks

- On feature branch (warn if on `main`)
- No secrets in staged files
- Commit is atomic (single logical change)
- Never amend commits
- Never use `git add .`
