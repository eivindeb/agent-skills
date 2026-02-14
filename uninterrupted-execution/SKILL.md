---
name: uninterrupted-execution
description: Execute long-running tasks from an existing `.agent/tasks/.../TASK.md` until objective completion or explicit escalation. Use when an agent must run milestone-by-milestone with verification gates, regular progress heartbeats, repeated-error escalation, and evidence-backed final closure.
---

# Uninterrupted Execution

Execute from a persisted task agreement. Do not perform planning from scratch in this skill.

## Required Input

Require an existing task agreement file at:
- `.agent/tasks/<YYYY-MM-DD>-<short-task-name>/TASK.md`

If `TASK.md` is missing or incomplete, stop and direct handoff to `uninterrupted-execution-planner`.

## Preflight Validation

Before implementation, verify `TASK.md` contains:

1. Objective.
2. Acceptance Criteria (`AC1..ACn`).
3. Milestone Plan with verification actions.
4. Verification Plan with pass conditions.
5. Error Policy with classes and fingerprint rule.
6. Evidence Map for every AC.
7. Final Closure Gate checklist.

If any required element is missing, escalate for planner handoff.

## Heartbeat Rules

Emit progress heartbeats while continuing work:
- After each milestone boundary.
- Every 5 minutes while working on the current milestone.
- Never pause execution only to wait for heartbeats.

Use this format:
- `milestone`: current milestone ID/title
- `status`: `in_progress` | `verification_passed` | `verification_failed` | `escalated`
- `elapsed`: time spent on current milestone
- `next`: immediate next action
- `blockers`: `none` or short blocker text

## Milestone Execution Gate

At each milestone boundary:

1. Run milestone verification actions from `TASK.md`.
2. If verification fails, classify error as one of:
- `code`
- `test`
- `env_tooling`
- `requirements_ambiguity`
- `external_dependency`
3. Track fingerprint as `<class>|<command_or_test>|<key_error_text>`.
4. Retry only with a materially different approach.
5. If the same fingerprint appears 3 times, stop and escalate to user.
6. If gate passes, emit heartbeat and continue.

## Escalation Behavior

Escalate when either is true:
1. Same fingerprint appears 3 times.
2. Required dependency/permission is missing with no safe workaround.

Escalation message must include:
- `reason`
- `fingerprint` (if applicable)
- `attempts` and what changed
- `impact`
- `options` (2-3 concrete choices with tradeoffs)
- `decision_needed`

## Final Closure Gate (Mandatory)

Declare completion only when all are true:

1. Every AC is satisfied.
2. Every AC has mapped evidence and artifacts are present.
3. All relevant checks from verification plan pass.
4. No unresolved blocker or open escalation remains.

If any condition fails, continue execution or escalate per policy.
