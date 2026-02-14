---
name: branch-context
description: Rebuild context on an in-progress feature branch by reviewing commits since main and summarizing what has already been done.
---

# Core Purpose

When a conversation starts on a feature branch with existing commits, establish shared context before making substantial changes.

This skill is for understanding branch progress, not for making commits.

## When to Use

- At the start of a conversation on a non-main branch
- When multiple humans/agents have contributed commits
- After context switches where prior branch work may affect decisions

## Workflow

1. Verify branch context:
   - Confirm current branch is a feature branch (not `main`)
2. Review branch history against main:
   - `git log --oneline main..HEAD`
3. Expand only relevant commits when needed:
   - `git show <sha>`
4. Produce a branch understanding summary:
   - What has been implemented so far
   - What appears to be in progress
   - Any immediate risks, assumptions, or open questions relevant to next steps

## Output Standard

Before substantial implementation, provide a brief summary that demonstrates understanding of completed feature-branch work based on commit history.

## Guardrails

- Keep review lightweight and task-focused
- Do not inspect every commit unless necessary
- Prefer high-signal commits tied to the current task
