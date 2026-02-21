---
name: "pr"
description: "Use when asked to prepare and create a pull request for a feature branch by validating guardrails, syncing with upstream main, running preflight checks, and executing push/gh PR commands when possible."
---

## Purpose

PR-only endpoint for feature branches.

This skill does not stage or commit. It validates branch/remotes state, prepares the feature branch against upstream main, runs full-project tests as part of preflight, and should execute push/PR commands directly when possible. If command execution fails, it outputs exact fallback commands for the user.

## Inputs expected

- Work is already committed on a feature branch.
- Branch is pushed (or nearly pushed) to the agent-writable fork.
- `origin` is the fork remote.
- `upstream` is the canonical/original remote.

## Establish Branch Context

Before proceeding with PR preparation, use the branch-context skill to understand:
- What has been implemented so far across all commits
- Branch intent and motivation
- Current state of the work

This context is essential for:
- Test failure analysis and fixes
- Comprehensive PR body generation
- Understanding the full scope of changes

Minimum history coverage requirements:

1. Review the complete branch commit history relative to `main` (not only recent session actions), including:
  - `git log --reverse --oneline main..HEAD`
  - `git log --reverse --name-status --format=fuller main..HEAD`
1. Identify branch intent from early commits and sustained themes across the full range.
1. Distinguish substantive feature work from sync mechanics (for example merge/rebase conflict resolution commits).
1. Build PR text as: "what this branch adds to main," not "what the agent did recently."

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

## Documentation Review

After establishing branch context and completing prerequisites, review whether the branch changes warrant updates to project documentation before proceeding to preflight checks.

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

Run PR preflight checks only after prerequisites and documentation review are complete.

Preflight checks are intended to be rerunnable.

1. Run the full-project test suite (see Test section below).

### Post-Test Revalidation

After tests pass, rerun preflight checks that can drift during preflight work, at minimum:
- working tree clean state
- branch still contains commits not on `main`
- current branch is still not `main`

If revalidation fails:
- Stop immediately.
- Report failed checks and corrective actions.
- Do not output or run `gh pr create`.

## Test (Part of Preflight)

Run a full-project test suite as the final preflight step.

Requirements:

1. Always identify and run the canonical run all tests command for the current project before producing a PR command.
2. Cache successful test runs so they are not rerun unnecessarily.
3. Cache key must include at least:
  - `HEAD` commit SHA
  - Test command string
1. Reuse cached success when key matches and no tracked files changed since the cached run.
1. Invalidate cache when:
  - `HEAD` changes
  - test command changes
  - tracked working tree content changes
1. Failed test runs must never be cached as pass.

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

## Final Gate (Required Immediately Before PR Creation)

Run this gate immediately before any push or PR creation command.

1. Run:
  - `git status --porcelain --untracked-files=all`

1. If output is non-empty:
  - Fail preflight immediately.
  - Inspect and summarize the pending changes for the user:
    - changed file list
    - high-level intent of those changes
    - likely impact on PR scope
  - Present a recommended next action with commands:
    - Include in PR: create a commit for these changes, then rerun final gate.
    - Exclude from PR: stash or discard, then rerun final gate.
  - Ask for user confirmation on which path to execute.
  - Do not output or run `git push` or `gh pr create` until final gate passes.

1. If output is empty:
  - Continue to PR creation flow.

## PR Body Context Requirements

When preparing the PR title/body, leverage the branch context established at the start.

Additional requirements:

1. Ensure full commit history was reviewed during initial branch-context run.
2. Reflect the entire branch scope in the PR body, including all meaningful changes.
3. Include intent/motivation for the feature branch, not just implementation details.
4. Reference task document context if it was found (for example `.agent/tasks/.../TASK.md`).
5. Explicitly prioritize net-new behavior/value relative to `main`.
6. Do not lead summary bullets with upstream sync mechanics (for example "merged upstream main") unless the PR's primary intent is branch synchronization.
7. If sync/merge conflict resolution was required, include it only as brief supporting context after substantive branch outcomes.

## Output contract

Hard rule:
- Do not output or run `gh pr create` unless the Final Gate has passed with a clean working tree.

When all preflight checks pass, output:

1. A short preflight status summary.
2. Attempt to push the branch (`git push -u origin <branch>` when needed).
3. Attempt to run `gh pr create` directly using a PR body file (`--body-file`).
4. Report command results and output the PR link as a standalone line in this exact format: `PR URL: <https://...>`.
5. If push or `gh` command fails, provide a ready-to-run fallback command for the user.

When preflight checks fail, output:

1. A short preflight status summary.
2. Which checks failed.
3. Suggested corrective actions (do not proceed to PR command).

## Command templates

Body transport strategy:

1. Agent-run PR creation path (default): use `--body-file` to preserve real newlines and avoid escaped `\n` artifacts.
2. User-run fallback path: use inline `--body` for a single ready-to-run command.

Execution order:

1. Ensure branch is pushed/up to date on `origin`.
2. Create a temporary PR body file with the generated body content.
3. Run `gh pr create` directly with `--body-file`.
4. Fetch the created PR URL and print `PR URL: <https://...>`.
5. Clean up the temporary file.
6. Only fall back to user-run commands when direct execution fails.

Agent-run PR creation (preferred):

```bash
BODY_FILE="$(mktemp)"
cat > "${BODY_FILE}" <<'EOF'
<summary of full branch context, motivation, and validation>
EOF

gh pr create \
  --repo "<upstream_owner>/<repo_name>" \
  --base main \
  --head "<origin_owner>:$(git branch --show-current)" \
  --title "<type>: <short summary>" \
  --body-file "${BODY_FILE}"

PR_URL="$(gh pr view --repo "<upstream_owner>/<repo_name>" --json url --jq '.url')"
echo "PR URL: <${PR_URL}>"
rm -f "${BODY_FILE}"
```

User-run fallback PR creation command (only when agent-run fails):

```bash
gh pr create \
  --repo "<upstream_owner>/<repo_name>" \
  --base main \
  --head "<origin_owner>:$(git branch --show-current)" \
  --title "<type>: <short summary>" \
  --body "<summary of full branch context, motivation, and validation>"
```

Push command (when upstream tracking is missing or branch not yet pushed):

```bash
git push -u origin "$(git branch --show-current)"
```

### Shell-safety directive for fallback inline `--body`

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
- `PR`: preflight + direct PR creation flow, with fallback command handoff only on execution failure.
