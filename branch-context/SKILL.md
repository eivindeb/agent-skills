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
4. Identify relevance to the current task:
   - State the current task scope in one line (component/file area)
   - Select 1-3 commits likely relevant to the current request
   - For each, note why it matters to upcoming work
   - If no commit appears relevant, state that explicitly and why
5. Produce a branch understanding summary:
   - What has been implemented so far
   - What appears to be in progress
   - Any immediate risks, assumptions, or open questions relevant to next steps
   - One concrete way this context changes (or confirms) the implementation approach

## Output Standard

Before substantial implementation, provide a brief, task-linked summary that demonstrates understanding of completed feature-branch work based on commit history.

Minimum output:
- Task scope line (what area is being changed now)
- Exactly one relevance outcome:
  - Relevant commits shortlist (1-3 SHAs), each with one sentence on task impact, or
  - Explicit "no relevant commits" note with one-sentence reason
- One concrete "decision influence" statement describing how branch context affects next steps

## Guardrails

- Keep review lightweight and task-focused
- Do not inspect every commit unless necessary
- Prefer high-signal commits tied to the current task
- Avoid generic summaries that do not influence implementation choices
