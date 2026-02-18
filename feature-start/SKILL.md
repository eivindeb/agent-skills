---
name: feature-start
description: Assess whether to create a feature branch when starting significant tasks. Use proactively when user presents new work requiring multiple commits or substantial changes.
---

# Input

The user provides a **task description** — a short explanation of the work they want to accomplish. Use this to determine branch name, clone path, and kickoff steps.

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

## Sibling Clone

After branch approval, suggest a **sibling clone** so work can happen in parallel without disturbing the main checkout. A local clone is used instead of `git worktree` because Cursor's sandbox restricts file writes to the workspace directory, and worktrees store metadata in the original repo's `.git/` which falls outside the clone workspace.

Location: `w-<repo-root>--<branch-slug>/` (sibling to the repo directory).
- Replace `/` in the branch name with `-` for the slug.
- The `w-` prefix groups all sibling clones together in directory listings and makes them easy to skip with tab-completion in the terminal.
- Example: repo at `~/Code/my-repo`, branch `feature/add-auth` → clone at `~/Code/w-my-repo--feature-add-auth/`

Creation commands (works from any branch, no stash/checkout needed):
```bash
REMOTE_URL=$(git remote get-url origin)
CLONE_DIR=../w-$(basename "$PWD")--<branch-slug>
git clone . "$CLONE_DIR"
cd "$CLONE_DIR"
git remote set-url origin "$REMOTE_URL"
git checkout -b <branch-name> origin/main
```

### Venv Symlink

If the source repo contains a `.venv/` directory, symlink it into the clone so that all Python tooling (pytest, linters, formatters, IDE interpreter detection) works without extra configuration:

```bash
ln -s ../<source-repo-dir>/.venv .venv
```

Where `<source-repo-dir>` is the basename of the repo you cloned from (e.g., `my-repo`).

This is a one-time setup step. The symlink means `pip install` in the clone modifies the main repo's venv — this is intentional (one canonical venv per project).

The user can decline the sibling clone and work on the branch in-place instead.

### Handoff Plan

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

During the planning conversation (before clone creation), provide **2-4 concrete kickoff steps** tailored to the task:

- **Clarifications** — what's ambiguous or needs user input before starting
- **Investigation** — existing code or docs to review first
- **Implementation steps** — for well-defined tasks, the ordered steps to take
- **Dependency checks** — packages, configs, or access to sort out

Keep steps specific to the task, not generic.

## Explicit Trigger Override

If user explicitly invokes `$feature-start`, skip qualification.

Do immediately:
- Suggest branch name
- Suggest sibling clone location
- Give first 2-4 kickoff steps
- Do not ask whether to use this skill

## Required Skill Chaining

When `feature-start` is used and work is on a feature branch, the agent must also load and apply the `fcommit` skill (a Cursor agent skill for structured commits on feature branches).

Requirements:
- Treat `fcommit` as active companion guidance for the entire feature-branch session
- Start using `fcommit` immediately after branch creation (or immediately if already on a feature branch)
- Continue using `fcommit` throughout development, not as a one-time reminder
- Make frequent progress commits following `fcommit` cadence and message format

## Workflow

1. **Check explicit trigger** — if `$feature-start` was explicitly requested, apply override
2. **Otherwise assess task** — check feature-branch criteria
3. **If YES**:
   - Suggest branch name → user approves/renames/declines
   - If branch approved: suggest sibling clone location → user accepts or declines
   - Present 2-4 kickoff steps → user accepts, adjusts, or discusses
   - Perform any investigation needed to populate the handoff plan
   - Create branch and sibling clone (if accepted), deliver PLAN.md via preferred delivery method
   - Tell user to open clone directory in new Cursor window and reference PLAN.md
   - If clone declined: create branch in-place, load `fcommit` skill, begin work
4. **If NO**:
   - Say direct commit is sufficient
   - Proceed

## Example Interaction

```
User: "Add SHAP waterfall plots to the device change evaluation notebook"

Agent: This looks like it would benefit from a feature branch.

**Branch:** `feature/add-shap-waterfall-plots`
Shall I create this branch, or would you prefer a different name?

**Sibling clone:** I can set up a parallel clone at:
  `~/Code/w-credit-af-ml--feature-add-shap-waterfall-plots/`
Want the sibling clone, or work on the branch in-place?

**Kickoff steps:**
1. Review `explain_predictions.py` in `device_change_evaluation/` and the shared
   helpers in `ml_utilities/model_explanations/`
2. Check which SHAP plots are already available and whether `shap.waterfall_plot`
   is supported by the installed version
3. Add the waterfall plot function to the shared explanations module
4. Integrate into the device change notebook and verify output

[User approves branch + clone, agrees to steps]

[Agent investigates code, then creates branch, clone, symlinks .venv, and writes PLAN.md]

Agent: Done! Clone is ready at `~/Code/w-credit-af-ml--feature-add-shap-waterfall-plots/`.
Open that directory in a new Cursor window and tell the agent to follow PLAN.md.
```

## Important Notes

- Explicit `$feature-start` invocation always bypasses qualification
- Check current branch first (don't suggest if already on a feature branch)
- Use judgment — when in doubt, suggest the branch (easy to decline)
- After creating or confirming a feature branch, load and use the `fcommit` skill throughout development
- PLAN.md is a handoff artifact — delete it before the final commit or PR
- Use `/PR` only after the branch is pushed and the working tree is clean
- Don't suggest feature branches for work already in progress
- A sibling clone is used instead of `git worktree` to avoid Cursor sandbox restrictions on writes to the parent repo's `.git/` directory
