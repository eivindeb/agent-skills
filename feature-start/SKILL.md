---
name: feature-start
description: Assess whether to create a feature branch when starting significant tasks. Use proactively when user presents new work requiring multiple commits or substantial changes.
---

# Input

The user provides a **task description** — a short explanation of the work they want to accomplish. Use this to determine branch name, execution mode, clone path (if applicable), Python environment strategy, and kickoff steps.

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
- **Clone mode (sibling clone):** create a lightweight local clone for isolated parallel work.

### Mode Selection Rules

- If the user explicitly asks for a sibling clone, use **clone mode**.
- If the user explicitly asks to stay in the current repo, use **branch mode**.
- Otherwise, default to **branch mode** and mention that **clone mode** is available.

## Clone Mode (Sibling Clone)

After branch approval, suggest a **sibling clone** so work can happen in parallel without disturbing the current checkout. Use `git clone` with a local path (default local-clone behavior uses hardlinks for objects — fast and space-efficient, fully independent repo).

**Agent scope in clone mode:** planning discussion with the user, investigation (reading code, exploring the codebase) to build a comprehensive handoff plan, clone creation, and `PLAN.md` delivery. The agent must NOT implement any of the plan — all implementation happens in the new clone in a separate agent session.

Location: `w-<repo-root>--<branch-slug>/` (sibling to the repo directory).
- Replace `/` in the branch name with `-` for the slug.
- The `w-` prefix groups all sibling working directories together in directory listings and makes them easy to skip with tab-completion in the terminal.
- Example: repo at `~/Code/my-repo`, branch `feature/add-auth` → clone at `~/Code/w-my-repo--feature-add-auth/`

Creation commands (works from any branch, no stash/checkout needed):
```bash
CLONE_DIR=../w-$(basename "$PWD")--<branch-slug>
git clone "$PWD" "$CLONE_DIR"
cd "$CLONE_DIR"
git checkout -b <branch-name>
```

Note: the clone's `origin` remote points to the local source repo. If the clone needs to push directly to the real remote, update it:
```bash
git remote set-url origin "$(git -C ../<source-repo-dir> remote get-url origin)"
```

### Python Environment Detection And Symlink

Do not hardcode `.venv`.

Before creating a symlink or suggesting Python commands, detect the project virtual environment directory name from repository guidance.

Detection order:

1. Project instructions/docs (for example `AGENTS.md`, task docs, README) that explicitly name the environment directory.
2. Repository config/tooling files (for example `pyproject.toml`, `uv.toml`, `Makefile`, CI config) that set `UV_PROJECT_ENVIRONMENT` or document the venv path.
3. If still unknown, ask the user which environment directory to use.

If a directory name is resolved (for example `.venv-linux`), symlink that same directory name into the clone:

```bash
ln -s ../<source-repo-dir>/<venv-dir> <venv-dir>
```

Where `<source-repo-dir>` is the basename of the main repo directory (e.g., `my-repo`).

This is a one-time setup step. The symlink means `pip install` in the clone modifies the main repo's virtual environment — this is intentional (one canonical environment per project).

If the environment directory cannot be determined automatically, stop and ask the user before continuing setup.

### Sandbox-safe `uv` command prefix (Clone mode)

When the project uses `uv run` in the clone, use:

`UV_PROJECT_ENVIRONMENT=<venv-dir> UV_CACHE_DIR=/tmp/uv-cache`

Examples:

- `UV_PROJECT_ENVIRONMENT=<venv-dir> UV_CACHE_DIR=/tmp/uv-cache uv run pytest -q ...`
- `UV_PROJECT_ENVIRONMENT=<venv-dir> UV_CACHE_DIR=/tmp/uv-cache uv run ruff check ...`
- `UV_PROJECT_ENVIRONMENT=<venv-dir> UV_CACHE_DIR=/tmp/uv-cache uv run ruff format --check ...`

This keeps both environment and cache in writable sandbox locations and avoids permission prompts caused by `~/.cache/uv`.

The user can decline clone mode and work on the branch in-place instead.

### Handoff Plan (Clone Mode Only)

When a sibling clone is created, a handoff plan must be produced so the next agent session has full context. The plan must include all of the following sections:

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

### Hard Stop After Handoff (Clone Mode Only)

After creating the sibling clone and delivering `PLAN.md`, the current agent session must stop. The only actions the agent performs after the plan is finalized are:

1. Create the sibling clone and feature branch
2. Set up environment symlinks if applicable
3. Write/copy `PLAN.md` into the clone root
4. Tell the user to open the clone in a new agent window

Investigation and code reading to build a comprehensive `PLAN.md` is expected and encouraged — that happens *before* clone creation, during the planning phase. What is prohibited is implementing the plan:

- Do not implement any of the plan steps in the current repo. This is the most common failure mode: the agent builds a good plan and then starts coding it in-place instead of handing off.
- Do not start coding in the sibling clone in the same session.
- Do not edit source files under the sibling clone path from the original session.

### Delivery Methods (in order of preference)

The plan content above can be delivered via any of these mechanisms:

1. **Agent writes `PLAN.md`** (default) — If the agent can write files, create `PLAN.md` at the clone root. This is the preferred method because it persists automatically and the next agent can read it directly.

2. **Plan mode output** — If the plan was created via a plan-only mode (Cursor Plan mode, Claude Code `--plan`), the plan document already exists on disk. Do NOT rewrite or regenerate the content — use `cp` to copy the file directly into the clone as `PLAN.md`. This avoids wasting tokens and prevents content drift from paraphrasing. Example:
   ```bash
   cp /path/to/plan-document.md <clone-root>/PLAN.md
   ```
   Cursor plan files are typically stored at `~/.cursor/plans/`. Look there if the path is unknown.

3. **Conversation reference** — As a fallback, the user can point the next agent to the plan conversation. This is least preferred because it requires manual context transfer.

**Regardless of delivery method**, the plan must end up as a readable artifact (ideally `PLAN.md` at clone root) before the next agent session begins. The next agent's first instruction should be: *"Follow PLAN.md"*.

**Plan mode note:** If operating in a read-only or plan-only mode, present the branch creation commands, clone setup, and PLAN.md content as a complete handoff. The user should then switch to agent/edit mode (or run the commands manually) to execute the setup.

**Cleanup:** Delete `PLAN.md` before the final commit or PR — it is a planning artifact, not documentation.

## Kickoff Steps

During the planning conversation, provide **2-4 concrete kickoff steps** tailored to the task:

- **Clarifications** — what's ambiguous or needs user input before starting
- **Investigation** — existing code or docs to review first
- **Implementation steps** — for well-defined tasks, the ordered steps to take
- **Dependency checks** — packages, configs, or access to sort out

Keep steps specific to the task, not generic.

**In branch mode:** the agent presents these steps and waits for user approval before executing.
**In clone mode:** the agent may investigate (read code, explore the codebase) to produce a thorough plan, but must NOT implement any steps. The kickoff steps feed into `PLAN.md` for the next agent session to execute.

## Explicit Trigger Override

If user explicitly invokes `$feature-start`, skip qualification.

Do immediately:
- Suggest branch name
- Suggest execution mode (`branch` or `clone`)
- If clone mode is selected: suggest sibling clone location
- Give first 2-4 kickoff steps
- Do not ask whether to use this skill

## Required Skill Chaining

When `feature-start` is used and work is on a feature branch, the agent must also load and apply the `fcommit` skill (a Cursor agent skill for structured commits on feature branches).

Requirements:
- Treat `fcommit` as active companion guidance for the entire feature-branch session
- Start using `fcommit` immediately after branch creation (or immediately if already on a feature branch)
- Continue using `fcommit` throughout development, not as a one-time reminder
- Make frequent progress commits following `fcommit` cadence and message format
- In clone mode, the current session should hand off after `PLAN.md`; `fcommit` execution begins in the next session opened in the sibling clone.

## Workflow

1. **Check explicit trigger** — if `$feature-start` was explicitly requested, apply override
2. **Otherwise assess task** — check feature-branch criteria
3. **If YES**:
   - Suggest branch name → user approves/renames/declines
   - Suggest execution mode (`branch` or `clone`) → user chooses
   - If `clone`: suggest sibling clone location → user accepts or declines
   - Present 2-4 kickoff steps → user accepts, adjusts, or discusses
   - If `clone` accepted:
     - Perform investigation needed to populate a comprehensive handoff plan (read code, explore codebase)
     - Resolve project virtual environment directory from docs/config; if unresolved, ask user
     - Create sibling clone and feature branch
     - Set up environment symlinks if applicable
     - Deliver `PLAN.md` into clone root via preferred delivery method
     - Tell user to open clone directory in new Cursor window and reference `PLAN.md`
     - Stop. Do not implement any of the plan — not in the current repo, not in the clone
   - If `branch` mode (or clone declined):
     - Create and switch branch in-place
     - Load `fcommit` skill
     - Wait for user approval of kickoff steps before beginning implementation
4. **If NO**:
   - Say direct commit is sufficient
   - Proceed

## Example Interaction

```
User: "Add user authentication to the app"

Agent: This looks like it would benefit from a feature branch.

**Branch:** `feature/add-user-authentication`
Shall I create this branch, or would you prefer a different name?

**Mode:** Do you want to work in-place on this branch, or use clone mode (sibling clone)?

**Sibling clone (if clone mode):**
`~/Code/w-my-repo--feature-add-user-authentication/`

**Kickoff steps:**
1. Review existing auth-related code and middleware setup
2. Decide on session-based vs token-based authentication
3. Implement auth module with login/logout endpoints
4. Add route protection and tests

[User approves branch, picks clone mode, agrees to steps]

[Agent investigates codebase to build comprehensive PLAN.md]
[Agent creates sibling clone, writes PLAN.md into it, stops]
[Agent does NOT implement any of the plan — that's for the next session]
[User opens clone in new Cursor window, tells that agent: "Follow PLAN.md"]
```

## Important Notes

- Explicit `$feature-start` invocation always bypasses qualification
- Check current branch first (don't suggest if already on a feature branch)
- Use judgment — when in doubt, suggest the branch (easy to decline)
- After creating or confirming a feature branch, load and use the `fcommit` skill throughout development
- In clone mode, stop after creating the clone and `PLAN.md`; do not implement in that same session
- In clone mode, use sibling clone naming: `w-<repo-root>--<branch-slug>`
- In clone mode, do not assume `.venv`; resolve the project environment directory from docs/config, or ask the user
- In clone mode, for `uv run` commands use `UV_PROJECT_ENVIRONMENT=<venv-dir> UV_CACHE_DIR=/tmp/uv-cache`
- In clone mode, `PLAN.md` is a handoff artifact — delete it before the final commit or PR
- Use `/PR` only after the branch is pushed and the working tree is clean
- Don't suggest feature branches for work already in progress
- Clone mode uses lightweight local `git clone` (hardlinked objects), not `git worktree`
