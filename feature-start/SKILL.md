---
name: feature-start
description: Assess whether to create a feature branch when starting significant tasks. Use proactively when user presents new work requiring multiple commits or substantial changes.
---

# When to Suggest Feature Branch

**YES - Suggest feature branch for:**
- New features or functionality
- Refactoring that touches multiple files
- Bug fixes requiring investigation and multiple attempts
- Work that will need review/testing before merging
- Tasks explicitly described as "features" or "projects"
- Anything requiring more than 2-3 commits

**NO - Skip feature branch for:**
- Configuration file changes (ansible vars, docker-compose, etc.)
- Service restarts or deployments
- Small bug fixes (1-2 line changes)
- Documentation or comment updates
- Research, exploration, or reading code
- Quick experiments or tests
- File ownership fixes or permission changes

## Branch Naming Convention

Use descriptive, kebab-case names:
- `feature/add-auth-system`
- `fix/plex-transcoding-errors`
- `refactor/split-docker-services`
- `enhance/improve-homepage-layout`

Format: `<type>/<brief-description>`
- Types: `feature`, `fix`, `refactor`, `enhance`, `experiment`

## Explicit Trigger Override

If user explicitly invokes `$feature-start`, skip qualification.

Do immediately:
- Suggest branch name
- Give first 2-4 kickoff steps
- Do not ask whether to use this skill

## Required Skill Chaining

When `feature-start` is used and work is on a feature branch, the agent must also load and apply the `$fcommit` skill.

Requirements:
- Treat `$fcommit` as active companion guidance for the entire feature-branch session
- Start using `$fcommit` immediately after branch creation (or immediately if already on a feature branch)
- Continue using `$fcommit` throughout development, not as a one-time reminder
- Make frequent progress commits following `$fcommit` cadence and message format

## Workflow

1. **Check explicit trigger** - If `$feature-start` was explicitly requested, apply override and continue
2. **Otherwise assess task** - Check feature-branch criteria
3. **If YES**:
   - Suggest branch name
   - State brief reason for feature branch
   - Ask for approve/rename
   - If approved: create and switch branch
   - Load and apply `$fcommit` skill for ongoing development on this branch
   - Commit frequently using `$fcommit` guidance (not just a reminder)
4. **If NO**:
   - Say direct commit is sufficient
   - Proceed

## Example Interaction

```
User: "Add user authentication to the app"

Agent: This looks like a significant task that would benefit from a feature branch.
I suggest creating: `feature/add-user-authentication`

This will allow us to:
- Make incremental commits as we build the feature
- Review changes before merging
- Keep main branch stable

Should I create this branch? (or suggest a different name)
```

## Important Notes

- Explicit `$feature-start` invocation always bypasses qualification
- Check current branch first (don't suggest if already on a feature branch)
- Use judgment - when in doubt, suggest the branch (easy to decline)
- After creating or confirming a feature branch, explicitly load `$fcommit` and keep using it during development
- Use `/PR` only after the branch is pushed and the working tree is clean
- Don't suggest feature branches for work already in progress
