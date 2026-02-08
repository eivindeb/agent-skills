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

## Workflow

1. **Assess the task** - Determine if it meets feature branch criteria
2. **If YES**:
   - Suggest a branch name based on the task
   - Explain why a feature branch is recommended
   - Ask user to approve/decline or provide alternative name
   - If approved: Create the branch and switch to it
   - Remind user to use `/fcommit` for progress tracking
3. **If NO**:
   - Briefly note that this is a small task suitable for direct commits to current branch
   - Proceed with the work

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

- Check current branch first (don't suggest if already on a feature branch)
- Use judgment - when in doubt, suggest the branch (easy to decline)
- After creating branch, remind about `/fcommit` during development and `/PR` to open the pull request. Use `/PR` only after the branch is pushed and the working tree is clean
- Don't suggest feature branches for work already in progress
