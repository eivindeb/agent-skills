# Agent Skills

Repo to store user-level skills.

Also holds user-level AGENTS.md.

## Branch model

The `vipps` branch carries work-specific skills and overrides as a rebased patch series on top of `main`. Generic improvements always land on `main` first; `vipps` rebases to pick them up.

To see what `vipps` adds on top of `main`: `git log --oneline main..vipps`.

Main -> vipps sync workflow source of truth:
- Skill: `.cursor/skills/sync-main-into-vipps`
- Decision log: `SYNC_DECISIONS.md`

## Vipps-specific changes

Skills and overrides that exist only on the `vipps` branch:
* `manual-draft-jira-ticket-body` — Jira ticket body drafting
* `PR` — PR skill for single-remote workflow (sibling clone or in-place)
* `feature-start` — extended with sibling clone workflow, PLAN.md handoff, venv symlink
