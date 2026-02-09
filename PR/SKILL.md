---
name: "pr"
description: "Use when asked to prepare pull request creation for a feature branch by validating guardrails and outputting a ready-to-run gh pr create command for the user."
---

## Purpose

PR-only endpoint for feature branches.

This skill does not stage, commit, push, or run `gh` directly. It validates branch/remotes state and outputs the exact `gh pr create` command the user should run.

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
  --body "<summary of change and validation>"
```

### Shell-safety directive for generated `--body`

When generating inline `--body` text, avoid characters that commonly break pasted shell commands.

- Do not use markdown backticks.
- Do not use double quotes.
- Do not use command-substitution markers like `$(` or backticks.
- Prefer plain text headings and hyphen bullets.
- If code identifiers are needed, write them as plain words without quoting.

## Post-merge behavior

Do not output post-merge sync commands during PR preparation.

After the user explicitly states the PR has been merged, the agent should execute the post-merge sync steps itself.

## PR text quality bar

- Title matches change intent and commit style.
- Body states:
  - Context/problem
  - What changed
  - Validation performed (or explicitly not run)

## Relationship to other skills

- `feature-start`: branch setup policy.
- `fcommit`: progress commits during implementation.
- `PR`: final handoff command for user-run PR creation.
