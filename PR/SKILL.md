---
name: "pr"
description: "Use when asked to prepare pull request creation for a feature branch by validating guardrails and outputting a ready-to-run gh pr create command for the user."
---

## Purpose

PR-only endpoint for feature branches.

This skill does not stage, commit, push, or run `gh` directly. It validates branch/remotes state and outputs the exact `gh pr create` command the user should run.

## Inputs expected

- Work is already committed on a feature branch.
- Branch is pushed (or nearly pushed) to bot fork.
- `origin` should be bot fork and `upstream` should be canonical repo.

## Guardrails

Before producing the PR command, verify:

1. Current branch is not `main`.
2. Branch name follows feature flow (prefer `feature/*`, allow `fix/*`, `refactor/*`, `enhance/*`, `experiment/*`).
3. `origin` points to `git@github.com-bot:eivindeb-bot/home-server.git`.
4. `upstream` points to `git@github.com-personal:eivindeb/home-server.git`.
5. Working tree is clean.

If any check fails, stop and output exact corrective commands first.

## Output contract

Always output:

1. A short preflight status summary.
2. If needed, the push command to set upstream for current branch.
3. A ready-to-run `gh pr create` command for the user.

## Command templates

If branch is not yet tracking/pushed, include:

```bash
git push -u origin "$(git branch --show-current)"
```

Always provide PR creation command:

```bash
gh pr create \
  --repo eivindeb/home-server \
  --base main \
  --head "eivindeb-bot:$(git branch --show-current)" \
  --title "<type>: <short summary>" \
  --body "<summary of change and validation>"
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
