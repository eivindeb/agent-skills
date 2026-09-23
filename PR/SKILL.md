---
name: pr
description: Prepare and create a pull request for committed feature-branch work. Use when asked to open or prepare a PR, validate branch/remotes, sync with main, run preflight checks, push the branch, and create the PR. Prefer the GitHub connector for PR creation and PR metadata when available; use local git and gh for local branch state, pushes, auth checks, and GitHub Actions gaps.
---

# Pull Request Flow

Prepare and create a PR from committed branch work. This skill does not stage or commit.

## Tool Split

Use the strengths of each surface:

- **Local `git`**: working tree state, branch name, commit history, remote URLs, fetch, merge/rebase, push, and post-merge sync.
- **GitHub connector**: PR creation after the branch is pushed, PR metadata, PR comments, and structured API responses.
- **`gh` CLI**: auth checks, current-branch PR discovery, GitHub Actions checks/logs, and fallback PR creation when the connector is unavailable or cannot express the target cleanly.

If `tool_search` is available, search for the GitHub PR creation tool before creating the PR. Use the connector for PR creation when it exposes a suitable create-pull-request action and the repository, base, and head refs are unambiguous. Fall back to `gh pr create` when connector tooling is unavailable, fails, or the PR shape is better handled by `gh`.

## Inputs Expected

- Work is already committed on a feature branch.
- `origin` exists and points to the working repository.
- `upstream` may or may not exist.
- Workflow is either:
  - `fork-two-remote`: `origin` is a fork and `upstream` is canonical.
  - `single-remote`: `origin` is canonical and the PR head branch is in the same repo.

## Resolve Repository Model

Default modes:

- `pr_model=auto`
- `auth_scope=command` unless the user asks for a short subshell session.

Resolution:

1. Read `origin` and optional `upstream` URLs.
2. Parse each URL to `<owner>/<repo>`.
3. If both remotes exist, repo names match, and owners differ, use `fork-two-remote`.
4. If only `origin` exists, or both remotes resolve to the same owner/repo, use `single-remote`.
5. If remotes point to different repo names, stop and ask the user to resolve the target.

Derived values:

- `target_remote`: `upstream` for `fork-two-remote`, otherwise `origin`.
- `target_repo`: `<target_owner>/<repo>` from `target_remote`.
- `head_repo`: `<origin_owner>/<repo>`.
- `head_ref`: `<origin_owner>:<branch>` for fork PRs, otherwise `<branch>`.
- `sync_main_ref`: `<target_remote>/main`.

Treat `gh` auth and `git` SSH auth as separate. If SSH push fails and `gh` is authenticated, a one-command HTTPS push using the `gh` credential helper is an acceptable fallback when repo instructions allow it.

## Establish Branch Context

Before PR preparation, use the `branch-context` skill or equivalent local history inspection to understand what the branch adds relative to `main`.

Minimum coverage:

```bash
git log --reverse --oneline main..HEAD
git log --reverse --name-status --format=fuller main..HEAD
```

Build PR text as "what this branch adds to main," not "what the agent did recently." Distinguish substantive work from sync or conflict-resolution mechanics.

## Guardrails

Before syncing, testing, pushing, or creating a PR, verify:

1. Current branch is not `main` or `master`.
2. Branch name follows feature flow when the repo has a convention; prefer `feature/*`, `fix/*`, `refactor/*`, `enhance/*`, `experiment/*`, or repo-local equivalents.
3. `origin` exists.
4. Repository model resolves to `fork-two-remote` or `single-remote`.
5. If `upstream` exists, `origin` and `upstream` repo names match.
6. Branch contains commits not on `main`.

If any guardrail fails, stop. Do not create a PR with either connector or `gh`.

## Sync Prerequisites

Before preflight tests:

1. Fetch latest `main` from `target_remote`.
2. Merge or rebase the resolved `sync_main_ref` into the feature branch according to repo convention; default to merge if no convention is known.
3. If conflicts occur, stop before resolving. Inspect conflicted files, summarize each side, propose resolutions, and get explicit user agreement before applying them.

Use the model-aware sync target:

- `fork-two-remote`: `upstream/main`
- `single-remote`: `origin/main`

## Documentation Review

Before final tests, check whether branch changes require documentation updates.

Block and ask the user only for material drift: new public APIs, CLI/config behavior, build/deploy workflow changes, test command changes, or project overview/file-tree changes that would mislead future readers. Do not block on cosmetic documentation gaps.

## Preflight Tests

Run the canonical full-project test/check command for the repo after sync and documentation review. Prefer project instructions over guesses.

For `uv run` commands, avoid sandbox cache writes by resolving the project venv path and prefixing:

```bash
UV_PROJECT_ENVIRONMENT=<venv-dir> UV_CACHE_DIR=/tmp/uv-cache uv run <command>
```

Cache a successful preflight only when all are unchanged:

- `HEAD` commit SHA
- test command string
- tracked working tree content

Store cache in `.git/pr_preflight_test_cache.json` if caching is useful. Never cache failed tests as passing.

If tests fail, analyze failures using branch context, fix when appropriate, rerun, and proceed only after tests pass.

After tests pass, revalidate at minimum:

- current branch is still not `main` or `master`
- branch still contains commits not on `main`

## Uncommitted Changes

A dirty working tree does not block PR creation because the PR reflects pushed commits only. Before push/PR creation, summarize uncommitted changes so the user knows what is not included.

## PR Title And Body

Use full branch context. The body must cover:

- context/problem and motivation
- what changed across the full branch
- validation performed, or explicitly not run
- task document context if found
- sync/conflict-resolution details only as supporting context

Default to a draft PR unless the user explicitly asks for ready-for-review.

## Push And Create PR

Hard rule: do not push or create a PR until guardrails, sync prerequisites, documentation review, and tests are complete.

Execution order:

1. Push the current branch to `origin` if needed:

```bash
git push -u origin "$(git branch --show-current)"
```

2. Prefer connector PR creation when available. Use the discovered GitHub create-pull-request tool with:

- `repository_full_name`: `target_repo`
- `base` or `base_branch`: `main`
- `head` or `head_branch`: `head_ref`
- `head_repo`: `head_repo` for fork PRs when supported
- `title`: generated PR title
- `body`: generated PR body
- `draft`: `true` unless the user asked for ready-for-review
- `maintainer_can_modify`: `true` when supported

3. If connector creation succeeds, report the returned URL exactly:

```text
PR URL: <https://...>
```

4. If the connector is unavailable or fails, fall back to `gh pr create` with a body file:

```bash
BODY_FILE="$(mktemp)"
gh pr create \
  --repo "<target_repo>" \
  --base main \
  --head "<head_ref>" \
  --title "<title>" \
  --body-file "${BODY_FILE}" \
  --draft
```

5. If both direct creation paths fail, provide the user a ready-to-run fallback command. For inline fallback `--body`, avoid shell-fragile characters: no backticks, no double quotes, and no command-substitution markers.

## When To Prefer `gh` Over The Connector

Use `gh` instead of the connector for:

- checking `gh auth status`
- discovering an existing PR for the current local branch
- inspecting or watching GitHub Actions checks/logs
- PR creation when the connector cannot represent a cross-fork head cleanly
- fallback when connector errors are opaque and `gh` can produce a clearer failure

## Post-Merge Behavior

Only after the user explicitly says the PR was merged, sync the local main branch:

```bash
git checkout main
git fetch <target_remote>
git rebase <target_remote>/main
git push origin main
```

If running from a sibling worktree or clone-workaround directory, clean it up only after moving out of it. Ask before any destructive `rm -rf`.

Real worktree cleanup:

```bash
WORKTREE_DIR="$(git rev-parse --show-toplevel)"
PRIMARY_REPO_DIR="$(cd "$(git rev-parse --git-common-dir)/.." && pwd)"
cd "${PRIMARY_REPO_DIR}"
git worktree remove "${WORKTREE_DIR}"
git worktree prune
```

Clone-workaround cleanup requires explicit user confirmation before removal.
