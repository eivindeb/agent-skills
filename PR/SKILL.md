---
name: "pr"
description: "Use when asked to stage, commit, push, and open a GitHub pull request from an agent clone to the canonical repo."
---

## Purpose

Create PRs safely from agent clones using GitHub CLI (`gh`) and fork-based remotes.

## Prerequisites

- Require GitHub CLI `gh`. Check `gh --version`. If missing, ask user to install and stop.
- Require authenticated `gh` session. Run `gh auth status -h github.com`.
- Require agent clone remote layout:
  - `origin` -> bot fork (`git@github.com-bot:eivindeb-bot/home-server.git`)
  - `upstream` -> canonical repo (`git@github.com-personal:eivindeb/home-server.git`)

## Naming conventions

- Branch: `feature/{description}` when starting from `main`.
- Commit: Conventional Commit style, terse: `<type>: {description}` (examples: `fix: smb validation path`, `docs: add agent clone workflow`).
- PR title: keep concise and aligned with the commit message.

## Workflow

1. Validate environment and remotes.

```bash
gh --version
gh auth status -h github.com
git remote -v
git branch --show-current
```

2. If currently on `main`, create a feature branch.

```bash
git checkout -b "feature/{description}"
```

3. Confirm status, then stage and commit.

```bash
git status -sb
git add -A
git commit -m "<type>: {description}"
```

4. Push with tracking.

```bash
git push -u origin "$(git branch --show-current)"
```

5. Create PR to canonical repo `main`.

```bash
GH_PROMPT_DISABLED=1 GIT_TERMINAL_PROMPT=0 gh pr create \
  --repo eivindeb/home-server \
  --base main \
  --head "eivindeb-bot:$(git branch --show-current)" \
  --fill
```

## PR body quality bar

- Explain the problem/context.
- Summarize what changed and why.
- Note validation/tests run (or state if not run).
- Keep it factual and concise.

## Safety checks

- Never push directly to `upstream`.
- Never merge directly to `main` from agent session.
- If push is rejected as non-fast-forward, set upstream and rebase:

```bash
git branch --set-upstream-to=origin/"$(git branch --show-current)"
git pull --rebase
git push
```
