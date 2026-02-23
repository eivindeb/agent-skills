---
name: feature-start
description: Assess whether to create a feature branch when starting significant tasks. Use proactively when user presents new work requiring multiple commits or substantial changes.
---

# Input

The user provides a **task description** — a short explanation of the work they want to accomplish. Use this to determine branch name, execution mode, worktree path (if applicable), Python environment strategy, and kickoff steps.

# When to Suggest Feature Branch

**YES - Suggest feature branch for:**
- New features or functionality
- All code changes
- Bug fixes requiring investigation and multiple attempts
- Tasks explicitly described as "features" or "projects"

**NO - Skip feature branch for:**
- Already on feature branch (not on main)
- Service restarts or deployments
- Research, exploration, or reading code
- Quick experiments or tests
- File ownership fixes or permission changes

## Branch Naming Convention

Format: `<type>/<brief-description>` (kebab-case)
- Types: `feature`, `fix`, `refactor`, `enhance`, `experiment`
- Examples: `feature/add-auth-system`, `fix/plex-transcoding-errors`, `refactor/split-docker-services`

## Execution Modes

Use one skill with two supported modes:

- **Branch mode (in-place):** create/switch to a feature branch in the current repo and continue work there.
- **Worktree mode (sibling worktree):** create a sibling worktree for isolated parallel work.

### Mode Selection Rules

- If the user explicitly asks for a worktree/sibling worktree, use **worktree mode**.
- If the user explicitly asks to stay in the current repo, use **branch mode**.
- Otherwise, default to **branch mode** and mention that **worktree mode** is available.

## Worktree Mode (Sibling Worktree)

After branch approval, suggest a **sibling worktree** so work can happen in parallel without disturbing the main checkout. Use `git worktree` directly.

Location: `w-<repo-root>--<branch-slug>/` (sibling to the repo directory).
- Replace `/` in the branch name with `-` for the slug.
- The `w-` prefix groups all sibling worktrees together in directory listings and makes them easy to skip with tab-completion in the terminal.
- Example: repo at `~/Code/my-repo`, branch `feature/add-auth` → worktree at `~/Code/w-my-repo--feature-add-auth/`

Creation commands (works from any branch, no stash/checkout needed):
```bash
WORKTREE_DIR=../w-$(basename "$PWD")--<branch-slug>
git worktree add -b <branch-name> "$WORKTREE_DIR" origin/main
cd "$WORKTREE_DIR"
```

### Python Environment Detection And Symlink

Do not hardcode `.venv`.

Before creating a symlink or suggesting Python commands, detect the project virtual environment directory name from repository guidance.

Detection order:

1. Project instructions/docs (for example `AGENTS.md`, task docs, README) that explicitly name the environment directory.
2. Repository config/tooling files (for example `pyproject.toml`, `uv.toml`, `Makefile`, CI config) that set `UV_PROJECT_ENVIRONMENT` or document the venv path.
3. If still unknown, ask the user which environment directory to use.

If a directory name is resolved (for example `.venv-linux`), symlink that same directory name into the worktree:

```bash
ln -s ../<source-repo-dir>/<venv-dir> <venv-dir>
```

Where `<source-repo-dir>` is the basename of the main repo directory (e.g., `my-repo`).

This is a one-time setup step. The symlink means `pip install` in the worktree modifies the main repo's virtual environment — this is intentional (one canonical environment per project).

If the environment directory cannot be determined automatically, stop and ask the user before continuing setup.

### Sandbox-safe `uv` command prefix (Worktree mode)

When the project uses `uv run` in the worktree, use:

`UV_PROJECT_ENVIRONMENT=<venv-dir> UV_CACHE_DIR=/tmp/uv-cache`

Examples:

- `UV_PROJECT_ENVIRONMENT=<venv-dir> UV_CACHE_DIR=/tmp/uv-cache uv run pytest -q ...`
- `UV_PROJECT_ENVIRONMENT=<venv-dir> UV_CACHE_DIR=/tmp/uv-cache uv run ruff check ...`
- `UV_PROJECT_ENVIRONMENT=<venv-dir> UV_CACHE_DIR=/tmp/uv-cache uv run ruff format --check ...`

This keeps both environment and cache in writable sandbox locations and avoids permission prompts caused by `~/.cache/uv`.

The user can decline worktree mode and work on the branch in-place instead.

### Handoff Plan (Worktree Mode Only)

When a sibling worktree is created, a handoff plan must be produced so the next agent session has full context. The plan must include all of the following sections:

1. **Task description** — the user's original request
2. **Branch name** — for immediate context
3. **Investigation results** — what the agent found by reading code during planning
4. **Clarifications** — Q&A that happened between user and agent
5. **Key decisions / constraints** — choices made during planning (e.g., "reuse existing helpers, don't add new dependencies")
6. **Implementation steps** — the agreed-upon ordered steps
7. **Relevant file paths** — so the new agent doesn't have to re-explore the codebase
8. **Definition of done** — what "complete" looks like
9. **Development instructions** — must include: *"Use the `fcommit` skill (a Cursor agent skill for structured commits) throughout development on this branch. Make frequent progress commits."*
10. **Execution environment notes** — include the resolved `<venv-dir>` and any required `uv` command prefix (for example `UV_PROJECT_ENVIRONMENT=<venv-dir> UV_CACHE_DIR=/tmp/uv-cache`).

### Hard Stop After Handoff (Worktree Mode Only)

After creating the sibling worktree and delivering `PLAN.md`, the current agent session must stop implementation work.

- Do not start coding in the sibling worktree in the same session.
- Do not edit files under the sibling worktree path from the original session.
- End with a handoff message telling the user to open the worktree in a new agent window and instruct that agent to follow `PLAN.md`.

### Delivery Methods (in order of preference)

The plan content above can be delivered via any of these mechanisms:

1. **Agent writes `PLAN.md`** (default) — If the agent can write files, create `PLAN.md` at the worktree root. This is the preferred method because it persists automatically and the next agent can read it directly.

2. **Plan mode output** — If the plan was created via a plan-only mode (Cursor Plan mode, Claude Code `--plan`), the plan document already exists on disk. Do NOT rewrite or regenerate the content — use `cp` to copy the file directly into the worktree as `PLAN.md`. This avoids wasting tokens and prevents content drift from paraphrasing. Example:
   ```bash
   cp /path/to/plan-document.md <worktree-root>/PLAN.md
   ```
   Cursor plan files are typically stored at `~/.cursor/plans/`. Look there if the path is unknown.

3. **Conversation reference** — As a fallback, the user can point the next agent to the plan conversation. This is least preferred because it requires manual context transfer.

**Regardless of delivery method**, the plan must end up as a readable artifact (ideally `PLAN.md` at worktree root) before the next agent session begins. The next agent's first instruction should be: *"Follow PLAN.md"*.

**Plan mode note:** If operating in a read-only or plan-only mode, present the branch creation commands, worktree setup, and PLAN.md content as a complete handoff. The user should then switch to agent/edit mode (or run the commands manually) to execute the setup.

**Cleanup:** Delete `PLAN.md` before the final commit or PR — it is a planning artifact, not documentation.

## Kickoff Steps

During the planning conversation (before worktree creation in worktree mode), provide **2-4 concrete kickoff steps** tailored to the task:

- **Clarifications** — what's ambiguous or needs user input before starting
- **Investigation** — existing code or docs to review first
- **Implementation steps** — for well-defined tasks, the ordered steps to take
- **Dependency checks** — packages, configs, or access to sort out

Keep steps specific to the task, not generic.

## Explicit Trigger Override

If user explicitly invokes `$feature-start`, skip qualification.

Do immediately:
- Suggest branch name
- Suggest execution mode (`branch` or `worktree`)
- If worktree mode is selected: suggest sibling worktree location
- Give first 2-4 kickoff steps
- Do not ask whether to use this skill

## Required Skill Chaining

When `feature-start` is used and work is on a feature branch, the agent must also load and apply the `fcommit` skill (a Cursor agent skill for structured commits on feature branches).

Requirements:
- Treat `fcommit` as active companion guidance for the entire feature-branch session
- Start using `fcommit` immediately after branch creation (or immediately if already on a feature branch)
- Continue using `fcommit` throughout development, not as a one-time reminder
- Make frequent progress commits following `fcommit` cadence and message format
- In worktree mode, the current session should hand off after `PLAN.md`; `fcommit` execution begins in the next session opened in the sibling worktree.

## Workflow

1. **Check explicit trigger** — if `$feature-start` was explicitly requested, apply override
2. **Otherwise assess task** — check feature-branch criteria
3. **If YES**:
   - Suggest branch name → user approves/renames/declines
   - Suggest execution mode (`branch` or `worktree`) → user chooses
   - If `worktree`: suggest sibling worktree location → user accepts or declines
   - Present 2-4 kickoff steps → user accepts, adjusts, or discusses
   - If `worktree` accepted:
     - Perform any investigation needed to populate the handoff plan
     - Resolve project virtual environment directory from docs/config; if unresolved, ask user
     - Create branch and sibling worktree, deliver `PLAN.md` via preferred delivery method
     - Tell user to open worktree directory in new Cursor window and reference `PLAN.md`
     - Stop. Do not continue implementation in the current session
   - If `branch` mode (or worktree declined):
     - Create and switch branch in-place
     - Load `fcommit` skill, begin work
4. **If NO**:
   - Say direct commit is sufficient
   - Proceed

## Example Interaction

```
User: "Add user authentication to the app"

Agent: This looks like it would benefit from a feature branch.

**Branch:** `feature/add-user-authentication`
Shall I create this branch, or would you prefer a different name?

**Mode:** Do you want to work in-place on this branch, or use worktree mode (sibling worktree)?

**Sibling worktree (if worktree):**
`~/Code/w-my-repo--feature-add-user-authentication/`

**Kickoff steps:**
1. Review existing auth-related code and middleware setup
2. Decide on session-based vs token-based authentication
3. Implement auth module with login/logout endpoints
4. Add route protection and tests

[User approves branch, picks mode, agrees to steps]

[If worktree mode: agent creates worktree + PLAN.md, then stops and hands off]
[If branch mode: agent executes setup and continues with fcommit]
```

## Important Notes

- Explicit `$feature-start` invocation always bypasses qualification
- Check current branch first (don't suggest if already on a feature branch)
- Use judgment — when in doubt, suggest the branch (easy to decline)
- After creating or confirming a feature branch, load and use the `fcommit` skill throughout development
- In worktree mode, stop after creating the worktree and `PLAN.md`; do not implement in that same session
- In worktree mode, use sibling worktree naming: `w-<repo-root>--<branch-slug>`
- In worktree mode, do not assume `.venv`; resolve the project environment directory from docs/config, or ask the user
- In worktree mode, for `uv run` commands use `UV_PROJECT_ENVIRONMENT=<venv-dir> UV_CACHE_DIR=/tmp/uv-cache`
- In worktree mode, `PLAN.md` is a handoff artifact — delete it before the final commit or PR
- Use `/PR` only after the branch is pushed and the working tree is clean
- Don't suggest feature branches for work already in progress
- Worktree mode should use real `git worktree` setup, not a clone fallback
