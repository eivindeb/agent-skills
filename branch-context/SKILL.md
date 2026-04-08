---
name: branch-context
description: Review recent branch history and summarize what matters when branch context is relevant to the current task.
---

# Core Purpose

Establish shared branch context when recent commit history may affect the current task.

This skill is for understanding branch progress, not for making commits.

## When to Use

- When the user asks for branch context or references this skill
- When another skill explicitly calls for branch history review
- Before substantial implementation work if recent commits may affect the approach
- When multiple humans/agents have contributed commits
- After context switches where prior branch work may affect decisions

## Workflow

### Phase A: Branch Snapshot

1. Detect current branch:
   - `git branch --show-current`
2. Read the relevant commit log:
   - If on `main`: read last 12 commits
     - `git log --oneline -n 12`
   - If on feature branch: read all commits on branch delta
     - `git log --oneline main..HEAD`
3. Emit a short snapshot summary:
   - branch name
   - commit window reviewed
   - 2-4 bullets on recent themes/risk areas

### Phase B: Task Relevance Gate

1. State current task scope in one line (component/file area).
2. Re-check commit relevance from Phase A history.
3. Select relevance outcome:
   - 1-3 relevant SHAs with one sentence each on task impact, or
   - explicit "no relevant commits" note with one-sentence reason.
4. Decide whether code reads are needed now:
   - If commit summaries are insufficient to proceed safely, explicitly say code inspection is required and read the most relevant files.
5. Expand commit details only when needed:
   - `git show <sha>` for relevant commits only.
6. Provide one concrete decision-influence statement:
   - how branch context changes or confirms implementation approach.

## Output Standard

Output should include the phases that are useful for the current task.

Minimum Phase A output:
- Branch line
- Commit window line (`main -n12` or `main..HEAD`)
- 2-4 bullets on what has been done / in progress

Minimum Phase B output:
- Task scope line (what area is being changed now)
- Exactly one relevance outcome:
  - Relevant commits shortlist (1-3 SHAs), each with one sentence on task impact, or
  - Explicit "no relevant commits" note with one-sentence reason
- Code-read decision line:
  - "Code read required: yes/no" with a one-sentence reason
- One concrete "decision influence" statement describing how branch context affects next steps

## Guardrails

- Keep review lightweight and task-focused.
- Always read the full feature-branch commit subject list (`main..HEAD`).
- Use `git show` selectively for relevant commits when required.
- Avoid generic summaries that do not influence implementation choices.
