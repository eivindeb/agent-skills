---
name: "pr"
description: "Use when asked to prepare pull request creation for a feature branch by validating guardrails and outputting a ready-to-run gh pr create command for the user."
---

## Purpose

PR-only endpoint for feature branches.

This skill does not stage, commit, push, or run `gh` directly. It validates branch/remotes state, prepares the feature branch against upstream main, runs full-project tests as part of preflight, and outputs the exact `gh pr create` command the user should run.

## Inputs expected

- Work is already committed on a feature branch.
- Branch is pushed (or nearly pushed) to the agent-writable fork.
- `origin` is the fork remote.
- `upstream` is the canonical/original remote.

## Guardrails

Before producing the PR command, verify:

1. Current branch is not `main`.
2. Branch name follows feature flow (prefer `feature/*`, allow `fix/*`, `refactor/*`, `enhance/*`, `experiment/*`).
3. `origin` and `upstream` both exist.
4. `origin` and `upstream` point to different owners but the same repository name.
5. Current branch tracks `origin/<branch>`.
6. Working tree is clean.
7. Branch contains commits not on `main`.

If any check fails:
- Stop immediately.
- Do not output a `gh pr create` command.
- Report which checks failed.
- Suggest corrective actions for the user to perform.

## PR Prerequisites

Complete these prerequisite steps before running preflight checks:

1. Fetch latest upstream main.
2. Merge upstream main into the current feature branch.
3. If merge conflicts occur:
- Stop before resolving.
- Inspect each conflicted file and summarize what each side changed.
- Provide a suggested resolution for each conflict.
- Get explicit user agreement for each suggested resolution.
- Apply the agreed resolutions, then continue.

If upstream sync or conflict resolution is incomplete:
- Stop immediately.
- Do not output a `gh pr create` command.
- Report what is blocking prerequisite completion.

## Preflight Checks

Run PR preflight checks only after prerequisites are complete.

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
- Stop immediately.
- Do not output a `gh pr create` command.
- Report failing command and key failure summary.

## PR Body Context Requirements

When preparing the PR title/body, do not summarize only recent commits.

Requirements:

1. Read full commit history for the feature branch since divergence from main (for example `git log --oneline main..HEAD`).
2. Reflect the entire branch scope in the PR body, including all meaningful changes.
3. Include intent/motivation for the feature branch, not just implementation details.
4. Look for a task document on the branch (for example `.agent/tasks/.../TASK.md`) and incorporate relevant background/context.

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

PR creation command:

```bash
gh pr create \
  --repo "<upstream_owner>/<repo_name>" \
  --base main \
  --head "<origin_owner>:$(git branch --show-current)" \
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

After the user explicitly states the PR has been merged, include and run these sync commands:

```bash
git checkout main
git fetch upstream
git rebase upstream/main
git push origin main
```

## PR text quality bar

- Title matches change intent and commit style.
- Body states:
  - Context/problem and motivation
  - What changed across the full branch
  - Validation performed (or explicitly not run)

## Relationship to other skills

- `feature-start`: branch setup policy.
- `fcommit`: progress commits during implementation.
- `PR`: final handoff command for user-run PR creation.
