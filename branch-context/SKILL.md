---
name: branch-context
description: Rebuild branch context at session start and before implementation by reviewing recent commit history and summarizing what matters.
---

# Core Purpose

Establish shared context twice:
1) immediately at new-session start, and
2) again right before substantial implementation.

This skill is for understanding branch progress, not for making commits.

## When to Use

- At the start of every new conversation session (all branches)
- Before substantial implementation work
- When multiple humans/agents have contributed commits
- After context switches where prior branch work may affect decisions

## Workflow

### Phase A: Session-Start Snapshot (mandatory, immediate)

1. Detect current branch:
   - `git branch --show-current`
2. Read commit log immediately:
   - If on `main`: read last 12 commits
     - `git log --oneline -n 12`
   - If on feature branch: read all commits on branch delta
     - `git log --oneline main..HEAD`
3. Emit a short snapshot summary:
   - branch name
   - commit window reviewed
   - 2-4 bullets on recent themes/risk areas

### Phase B: Pre-Implementation Relevance Gate (mandatory before coding)

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

Output must include both phases when applicable in a session.

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

- Phase A must happen immediately in new sessions; do not delay it until implementation.
- Keep review lightweight and task-focused.
- Always read the full feature-branch commit subject list (`main..HEAD`).
- Use `git show` selectively for relevant commits when required.
- Avoid generic summaries that do not influence implementation choices.
