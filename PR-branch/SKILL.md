---
name: pr-branch
description: "Use when asked to prepare pull request creation for a feature branch in a single-remote workflow (sibling clone or in-place). Validates guardrails and outputs a ready-to-run gh pr create command for the user."
---

## Purpose

PR-only endpoint for feature branches in a single-remote workflow (sibling clone or in-place branch).

This skill does not stage, commit, push, or run `gh` directly. It validates branch/remote state, prepares the feature branch against main, runs full-project tests as part of preflight, and outputs the exact `gh pr create` command the user should run.

## Inputs expected

- Work is already committed on a feature branch.
- Branch is pushed (or nearly pushed) to `origin`.
- `origin` is the single remote pointing to the canonical repository.

## Establish Branch Context

Before proceeding with PR preparation, use the branch-context skill to understand:
- What has been implemented so far across all commits
- Branch intent and motivation
- Current state of the work

This context is essential for:
- Test failure analysis and fixes
- Comprehensive PR body generation
- Understanding the full scope of changes

## Guardrails

Before producing the PR command, verify:

1. Current branch is not `main`.
2. Branch name follows feature flow (prefer `feature/*`, allow `fix/*`, `refactor/*`, `enhance/*`, `experiment/*`).
3. `origin` remote exists and points to the canonical repository (not a local path — sibling clones initially have `origin` pointing to the local source repo and must have been corrected during setup).
4. Current branch tracks `origin/<branch>`.
5. Working tree is clean (see PLAN.md note below).
6. Branch contains commits not on `main`.

**PLAN.md note:** `PLAN.md` at the repo root is a planning artifact from the `feature-start` skill. It must remain **untracked** and must **not** be committed. If `git status` shows `PLAN.md` as an untracked file, this is expected and does not violate the clean-working-tree check. If `PLAN.md` has been staged or committed, warn the user and suggest removing it from the index.

If any check fails:
- Stop immediately.
- Do not output a `gh pr create` command.
- Report which checks failed.
- Suggest corrective actions for the user to perform.

## User Prerequisites

Agent cannot perform git operations that require authentication. Output a single copy-paste-ready command for the user:

```bash
git fetch origin main && git merge origin/main && git push origin $(git branch --show-current)
```

**Summary**: "Sync with main, resolve any conflicts, and push"

Wait for user confirmation that this command completed successfully before proceeding to preflight checks.

If merge conflicts occur, the user will resolve them and re-run the command.

## Documentation Review

After establishing branch context and completing user prerequisites, review whether the branch changes warrant updates to project documentation before proceeding to preflight checks.

Common triggers:

- New modules, files, or directories added — the project overview or file tree in `AGENTS.md` may need updating.
- Material changes to tests — test commands or instructions in project documentation may be outdated.
- New or renamed public APIs, CLI commands, or configuration options — usage documentation may need corresponding updates.
- Changes to build, deploy, or development workflows — relevant guides or READMEs may need revision.

If any documentation appears stale relative to the branch changes:

- Present the specific updates needed to the user with clear rationale.
- Wait for the user to confirm the updates are complete (or explicitly decline them) before proceeding to preflight checks.

Do not block on purely cosmetic or trivial gaps — focus on changes that would leave a reader of the documentation with an incorrect understanding of the project.

## Preflight Checks

Run PR preflight checks only after user prerequisites and documentation review are complete.

Preflight checks are intended to be rerunnable.

1. Run the full-project test suite (see Test section below).

## Test (Part of Preflight)

Run a full-project test suite as the final preflight step.

Requirements:

1. Always identify and run the canonical run all tests command for the current project before producing a PR command.
2. Cache successful test runs so they are not rerun unnecessarily.
3. Cache key must include at least:
- `HEAD` commit SHA
- Test command string
4. Reuse cached success when key matches and no tracked files changed since the cached run.
5. Invalidate cache when:
- `HEAD` changes
- test command changes
- tracked working tree content changes
6. Failed test runs must never be cached as pass.

Recommended cache implementation:

- Store cache in `.git` metadata (for example, `.git/pr_preflight_test_cache.json`) so it remains local to the repository.
- Record timestamp, commit SHA, command, and result.

If tests fail:
- Use branch-context skill (already run at start) to understand branch work and intent.
- Analyze test failures in the context of branch changes.
- Create an implementation plan to resolve test issues.
- Execute fixes.
- Re-run tests.
- Only proceed when tests pass.
- Do not output a `gh pr create` command until tests pass.

## PR Body Context Requirements

When preparing the PR title/body, leverage the branch context established at the start.

Additional requirements:

1. Ensure full commit history was reviewed during initial branch-context run.
2. Reflect the entire branch scope in the PR body, including all meaningful changes.
3. Include intent/motivation for the feature branch, not just implementation details.
4. Reference task document context if it was found (for example `.agent/tasks/.../TASK.md`).

## Output contract

When all preflight checks pass, output:

1. A short preflight status summary.
2. A ready-to-run `gh pr create` command for the user.

When preflight checks fail, output:

1. A short preflight status summary.
2. Which checks failed.
3. Suggested corrective actions (do not proceed to PR command).

## Command templates

Use inline `--body` output by default.

Derive `<owner>/<repo_name>` from the `origin` remote URL.

PR creation command:

```bash
gh pr create \
  --repo "<owner>/<repo_name>" \
  --base main \
  --head "$(git branch --show-current)" \
  --title "<type>: <short summary>" \
  --body "<summary of full branch context, motivation, and validation>"
```

### Shell-safety directive for generated `--body`

When generating inline `--body` text, avoid characters that commonly break pasted shell commands.

- Do not use markdown backticks.
- Do not use double quotes.
- Do not use command-substitution markers like `$(` or backticks.
- Prefer plain text headings and hyphen bullets.
- If code identifiers are needed, write them as plain words without quoting.

## Post-merge behavior

After the user explicitly states the PR has been merged, output a single chained command for cleanup. For a sibling clone, just remove the clone directory:

```bash
rm -rf <clone-path>
```

If the user is in the main repo and wants to update it as well:

```bash
cd <main-repo-path> && git fetch origin && git branch -d <branch-name>
```

The `git fetch` updates remote tracking branches (including `origin/main` with the merge) without requiring checkout or disrupting the working tree state.

The remote branch is typically deleted by GitHub on merge; skip remote deletion unless the user asks.

## PR text quality bar

- Title matches change intent and commit style.
- Body states:
  - Context/problem and motivation
  - What changed across the full branch
  - Validation performed (or explicitly not run)

## Relationship to other skills

- `feature-start`: branch setup policy (sibling clone creation).
- `fcommit`: progress commits during implementation.
- `PR-branch`: this skill — final handoff command for user-run PR creation.
