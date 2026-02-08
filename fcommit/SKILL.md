---
name: fcommit
description: Create concise progress commits during feature development. Use when completing logical steps on a feature branch to offload code details from context.
---

# Core Purpose

**Git log as context management tool:**
- Replace detailed code in active context with high-level commit messages
- Each commit is a summary you can reference: "what did I do in commit abc123?"
- Scan `git log` to understand feature progress without re-reading code
- Free up context for current work by archiving completed steps in commits

**Key principle**: Write commits so you can later ask "what changed?" and get the answer from `git log`, not from re-reading diffs.

## When to Commit

- Commit whenever we have made one logical chunk of work that can be abstracted to a "what and why"
- After completing a discrete step (even if feature incomplete)
- Every 15-30 minutes of meaningful progress
- Before switching focus to different part of feature
- When reaching a stable checkpoint
- To archive completed work and clear mental context

## Message Format

**Structure**: `<what changed>: <why it matters>`

**Good examples:**
- `Add user login form: enable authentication flow`
- `Extract validation logic: prepare for reuse in signup`
- `Fix password hashing: correct bcrypt salt rounds`

**Bad examples:**
- ❌ `Change bcrypt.hash() to use 12 rounds and async/await` (too detailed)
- ❌ `Update UserSchema class with roles array` (implementation detail)
- ❌ `Refactor code` (too vague, not searchable)

**Guidelines:**
- Start with verb: Add, Update, Fix, Extract, Remove, Refactor
- Keep under 72 characters
- Use searchable keywords (feature/component names)
- Describe what/why, never how
- Focus on intent and outcome, not implementation

## Workflow

1. Review changes: `git status` or `git diff`
2. Stage specific files: `git add <files>` (avoid `git add .`)
3. Craft high-level message following format above
4. Commit: `git commit -m "<message>"`
5. Confirm and continue

## Safety Checks

- ✓ On feature branch (warn if on main)
- ✓ No secrets in staged files (.env, credentials, keys)
- ✓ Each commit is atomic (one logical change)
- ✗ Never amend commits (breaks history)
- ✗ Never use `git add .` (stage specific files)

## Context Management Example

Instead of keeping this in context:
```
Changed auth.py lines 45-67 to add bcrypt hashing with 12 rounds,
updated validators.py to add email format check using regex,
modified schema.py to add roles field as string array...
```

Commit and reference:
```
git log --oneline
a1b2c3d Add password hashing: secure user credentials
b2c3d4e Add email validation: prevent invalid signups
c3d4e5f Update schema with user roles: support authorization
```

Now you can work on the next step without holding all those details in context.

## Usage Pattern

- Use after `/feature-start` creates branch
- Call frequently during development (5-10+ times per feature)
- Finish with `/ffinish` to squash all commits
