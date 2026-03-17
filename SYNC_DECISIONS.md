# Main -> Vipps Sync Decisions

Tracks commit-by-commit decisions when evaluating `main` commits for inclusion in `vipps`.

## Last reviewed range

- Reviewed at: 2026-03-17
- Main head reviewed: `72acfb4`
- Vipps head at review: `ff76fc3`
- Range: `vipps..main`
- Execution status: complete (cherry-picks applied; partial ports committed; skips recorded)

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

---

## 4f7816d - Clarify worktree/branch mode boundaries: prevent premature implementation
- Date reviewed: 2026-03-17
- Decision: superseded
- Rationale:
  - Worktree-specific changes (agent scope, hard stop) superseded by vipps clone-mode rewrite (e9f7b2d).
  - Branch-mode approval gate ("wait for user approval of kickoff steps") already present in vipps feature-start via e9f7b2d.
- Vipps constraints considered:
  - local-clone-only (no worktree/fork workflow)
  - remote-auth commands delegated to user
- Next sync action:
  - cherry-pick safe? no
  - if partial: n/a — all valuable ideas already on vipps
- Related commits:
  - e9f7b2d (vipps clone-mode rewrite)

## ae8cd9d - Add network DNS resolution error workaround escalation directive
- Date reviewed: 2026-03-17
- Decision: skip
- Rationale:
  - DNS/sandbox escalation workaround specific to outside-vipps setup (user-confirmed).
  - Vipps environment does not encounter these sandbox restrictions.
- Vipps constraints considered:
  - local-clone-only (no worktree/fork workflow)
  - remote-auth commands delegated to user
- Next sync action:
  - cherry-pick safe? n/a
  - if partial: n/a
- Related commits:
  - none

## 497c31a - Strengthen branch-context trigger and two-phase workflow
- Date reviewed: 2026-03-17
- Decision: adopt-partial
- Rationale:
  - Two-phase branch-context (session-start snapshot + pre-implementation gate) is a strong generic improvement.
  - branch-context/SKILL.md had no vipps-specific changes, so main version applied directly.
  - AGENTS.md section manually ported (rename to "Branch Context Directives", add session-start trigger) since vipps AGENTS.md has diverged.
- Vipps constraints considered:
  - local-clone-only (no worktree/fork workflow)
  - remote-auth commands delegated to user
- Next sync action:
  - cherry-pick safe? no (AGENTS.md diverged)
  - if partial: branch-context/SKILL.md replaced with main version; AGENTS.md section manually updated (applied via 42a0aac)
- Related commits:
  - 505a7e0 (minor wording fix absorbed into this port)

## 47afd02 - Allow fcommit follow-up commits without amend requirement
- Date reviewed: 2026-03-17
- Decision: adopt-as-is
- Rationale:
  - Generic fcommit improvement removing "Never amend commits" line.
  - No conflict with vipps constraints.
- Vipps constraints considered:
  - local-clone-only (no worktree/fork workflow)
  - remote-auth commands delegated to user
- Next sync action:
  - cherry-pick safe? yes (applied on vipps via 26fc982)
  - if partial: n/a
- Related commits:
  - none

## 505a7e0 - Make branch-context mandatory on session start
- Date reviewed: 2026-03-17
- Decision: superseded
- Rationale:
  - Minor wording refinement ("the ... skill") on top of 497c31a.
  - Absorbed into the 497c31a manual port.
- Vipps constraints considered:
  - local-clone-only (no worktree/fork workflow)
  - remote-auth commands delegated to user
- Next sync action:
  - cherry-pick safe? n/a — absorbed into 497c31a port
  - if partial: n/a
- Related commits:
  - 497c31a

## 8481a32 - Merge branch 'main' of github.com:eivindeb/agent-skills
- Date reviewed: 2026-03-17
- Decision: skip
- Rationale:
  - Merge commit bringing remote main into local main. No unique content.
- Vipps constraints considered:
  - n/a
- Next sync action:
  - cherry-pick safe? n/a
  - if partial: n/a
- Related commits:
  - ae8cd9d, 497c31a, 47afd02, 505a7e0

## 72acfb4 - Add pr-address-comments skill for addressing PR review feedback
- Date reviewed: 2026-03-17
- Decision: adopt-as-is
- Rationale:
  - Brand new skill (pr-address-comments/SKILL.md). Fully generic, no conflict with vipps constraints.
- Vipps constraints considered:
  - local-clone-only (no worktree/fork workflow)
  - remote-auth commands delegated to user
- Next sync action:
  - cherry-pick safe? yes (applied on vipps via 7b92ce1)
  - if partial: n/a
- Related commits:
  - none
