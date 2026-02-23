# Main -> Vipps Sync Decisions

Tracks commit-by-commit decisions when evaluating `main` commits for inclusion in `vipps`.

## Last reviewed range

- Reviewed at: 2026-02-23
- Main head reviewed: `f6dfeac`
- Vipps head at review: `960b0aa`
- Range: `vipps..main`
- Execution status: in progress (direct adopts cherry-picked; partial ports applied manually; skip remains skipped)

---

## 24a99c4 - Tighten fcommit timing directive: enforce pre-edit skill loading without redundant policy
- Date reviewed: 2026-02-23
- Decision: adopt-as-is
- Rationale:
  - Reinforces feature-branch commit discipline with no workflow conflict.
  - Aligns with existing `fcommit` usage expectations on `vipps`.
- Vipps constraints considered:
  - local-clone-only (no worktree/fork workflow)
  - remote-auth commands delegated to user
- Next sync action:
  - cherry-pick safe? yes (applied on vipps via `72aac29`)
  - if partial: n/a
- Related commits:
  - 340d439

## 340d439 - Strengthen fcommit gates: enforce commit evidence and dirty-tree handling
- Date reviewed: 2026-02-23
- Decision: adopt-as-is
- Rationale:
  - Improves `fcommit` execution quality and dirty-tree handling.
  - Generic process hardening useful across both `main` and `vipps`.
- Vipps constraints considered:
  - local-clone-only (no worktree/fork workflow)
  - remote-auth commands delegated to user
- Next sync action:
  - cherry-pick safe? yes (applied on vipps via `20e2e1f`)
  - if partial: n/a
- Related commits:
  - 24a99c4

## 947ce08 - Harden PR skill flow: prevent incomplete or malformed PR creation
- Date reviewed: 2026-02-23
- Decision: adopt-partial
- Rationale:
  - Valuable additions: full-history context requirements, post-test revalidation, final clean-tree gate.
  - Contains direct push/gh execution flow that conflicts with vipps remote-auth delegation.
- Vipps constraints considered:
  - local-clone-only (no worktree/fork workflow)
  - remote-auth commands delegated to user
- Next sync action:
  - cherry-pick safe? no
  - if partial: port guardrails and revalidation; keep user-run command handoff for auth-sensitive steps (applied manually)
- Related commits:
  - dab91df
  - f6dfeac

## dd6ec15 - Add shared markdownlint config: align linting with AI-authored docs
- Date reviewed: 2026-02-23
- Decision: adopt-as-is
- Rationale:
  - Reduces markdown lint noise and normalizes documentation style.
  - Independent of vipps-specific workflow constraints.
- Vipps constraints considered:
  - local-clone-only (no worktree/fork workflow)
  - remote-auth commands delegated to user
- Next sync action:
  - cherry-pick safe? yes (applied on vipps via `920f62c`)
  - if partial: n/a
- Related commits:
  - 93e1a30

## 93e1a30 - Normalize AGENTS markdown structure: keep lint checks actionable
- Date reviewed: 2026-02-23
- Decision: adopt-as-is
- Rationale:
  - Formatting normalization complements markdownlint configuration.
  - No conflict with vipps branch-specific behavior.
- Vipps constraints considered:
  - local-clone-only (no worktree/fork workflow)
  - remote-auth commands delegated to user
- Next sync action:
  - cherry-pick safe? yes (applied on vipps via `cc5fffb`)
  - if partial: n/a
- Related commits:
  - dd6ec15

## dab91df - Generalize PR workflow detection: support fork and single-remote repos
- Date reviewed: 2026-02-23
- Decision: skip
- Rationale:
  - Focuses on fork/two-remote and bot-auth complexity not needed for vipps local-clone workflow.
  - Risks increasing maintenance burden without clear local value.
- Vipps constraints considered:
  - local-clone-only (no worktree/fork workflow)
  - remote-auth commands delegated to user
- Next sync action:
  - cherry-pick safe? no
  - if partial: optionally port narrowly useful wording improvements only
- Related commits:
  - 947ce08

## f6dfeac - Update feature-start and PR skills for worktree workflows
- Date reviewed: 2026-02-23
- Decision: adopt-partial
- Rationale:
  - Worktree setup/cleanup guidance conflicts with vipps local-clone-only policy.
  - Sandbox-safe environment guidance (for example uv cache/env handling) may still add value.
- Vipps constraints considered:
  - local-clone-only (no worktree/fork workflow)
  - remote-auth commands delegated to user
- Next sync action:
  - cherry-pick safe? no
  - if partial: port uv/env detection hardening, exclude worktree-only logic (applied manually)
- Related commits:
  - dab91df
  - 947ce08
