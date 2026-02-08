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
5. Current branch tracks `origin/<branch>` (or provide push command).
6. Working tree is clean.

If any check fails, stop and output exact corrective commands first.

## Output contract

Always output:

1. A short preflight status summary.
2. If needed, the push command to set upstream for current branch.
3. A ready-to-run `gh pr create` command for the user.
4. A post-merge sync reminder for the agent clones.

## Command templates

If branch is not yet tracking/pushed, include:

```bash
git push -u origin "$(git branch --show-current)"
```

Always provide PR creation command:

```bash
gh pr create \
  --repo "<upstream_owner>/<repo_name>" \
  --base main \
  --head "<origin_owner>:$(git branch --show-current)" \
  --title "<type>: <short summary>" \
  --body "<summary of change and validation>"
```

After merge, always include this sync sequence:

```bash
git checkout main
git fetch upstream
git rebase upstream/main
git push origin main
```

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
