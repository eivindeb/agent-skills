---
name: feature-start
description: Assess whether to create a feature branch when starting significant tasks. Use proactively when user presents new work requiring multiple commits or substantial changes.
---

# Input

The user provides a **task description** — a short explanation of the work they want to accomplish. Use this to determine branch name and kickoff steps.

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

## Kickoff Steps

During the planning conversation, provide **2-4 concrete kickoff steps** tailored to the task:

- **Clarifications** — what's ambiguous or needs user input before starting
- **Investigation** — existing code or docs to review first
- **Implementation steps** — for well-defined tasks, the ordered steps to take
- **Dependency checks** — packages, configs, or access to sort out

Keep steps specific to the task, not generic.

## Explicit Trigger Override

If user explicitly invokes `$feature-start`, skip qualification.

Do immediately:
- Suggest branch name
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
   - Present 2-4 kickoff steps → user accepts, adjusts, or discusses
   - If approved: create and switch branch
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

**Kickoff steps:**
1. Review existing auth-related code and middleware setup
2. Decide on session-based vs token-based authentication
3. Implement auth module with login/logout endpoints
4. Add route protection and tests

[User approves branch, agrees to steps]

[Agent creates branch, loads fcommit skill, begins work]
```

## Important Notes

- Explicit `$feature-start` invocation always bypasses qualification
- Check current branch first (don't suggest if already on a feature branch)
- Use judgment — when in doubt, suggest the branch (easy to decline)
- After creating or confirming a feature branch, load and use the `fcommit` skill throughout development
- Use `/PR` only after the branch is pushed and the working tree is clean
- Don't suggest feature branches for work already in progress
