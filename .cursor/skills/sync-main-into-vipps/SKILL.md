---
name: sync-main-into-vipps
description: Review commits present on main but missing from vipps, evaluate value under vipps constraints, and produce commit-by-commit adopt/partial/skip recommendations. Use when syncing main into vipps or reassessing prior sync decisions.
---

# Sync Main Into Vipps

## Purpose

Use this skill to decide which `main` commits should be brought into `vipps`.

`vipps` is a rebased patch series over `main`:
- generic improvements should flow from `main` into `vipps`
- `vipps` keeps branch-specific overrides where justified

## Vipps Constraints

Treat these as hard constraints unless user says otherwise:
- workflow uses local clones (not worktrees, not forks)
- remote-auth commands are delegated to the user

## Inputs expected

- Current branch is `vipps` (or user confirms target branch)
- Repo has both `main` and `vipps`
- Historical decisions are tracked in `SYNC_DECISIONS.md` at repo root

If `SYNC_DECISIONS.md` does not exist, create it before closing the task.

## Classification

For each missing `main` commit, choose exactly one:
- `adopt-as-is` - safe to cherry-pick directly
- `adopt-partial` - carry selected ideas via manual port
- `skip` - do not carry into `vipps`
- `superseded` - already covered by a newer commit or existing `vipps` behavior

## Workflow

1. Confirm branch context:
   - `git branch -vv`
2. List missing commits:
   - `git log --reverse --oneline vipps..main`
3. For each missing commit:
   - inspect with `git show --stat --patch <sha>`
   - evaluate against vipps constraints
   - cross-check `SYNC_DECISIONS.md` for prior decisions on same/related areas
4. Produce recommendation per commit:
   - decision label (`adopt-as-is` / `adopt-partial` / `skip` / `superseded`)
   - short rationale (value vs constraints)
   - action guidance (cherry-pick, manual port, or ignore)
5. Output integration plan:
   - ordered list of direct cherry-picks
   - manual-port checklist for partial commits
   - conflicts/risks to watch
6. Update `SYNC_DECISIONS.md` with reviewed commits and rationale.

## Output format

Provide:

1. A short branch-context summary.
2. A commit table:
   - `sha`
   - `subject`
   - `decision`
   - `why`
   - `next action`
3. Final recommendation:
   - direct cherry-pick list in order
   - partial-port items
   - skipped items

## Decision log format (`SYNC_DECISIONS.md`)

Use this entry template:

```md
## <sha> - <subject>
- Date reviewed: YYYY-MM-DD
- Decision: adopt-as-is | adopt-partial | skip | superseded
- Rationale:
  - ...
- Vipps constraints considered:
  - local-clone-only (no worktree/fork workflow)
  - remote-auth commands delegated to user
- Next sync action:
  - cherry-pick safe? yes/no
  - if partial: what to port / what to exclude
- Related commits:
  - ...
```

## Guardrails

- Do not assume all generic `main` improvements should always be cherry-picked blindly.
- Prefer manual ports when a commit mixes high-value logic with non-vipps workflow assumptions.
- Keep decisions stable over time: if changing a prior decision, explain why in `SYNC_DECISIONS.md`.
