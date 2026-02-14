---
name: uninterrupted-execution-planner
description: Create or normalize a persistent task agreement for long-running work before implementation begins. Use when an agent needs to define acceptance criteria, milestone verification, error escalation policy, evidence mapping, and final closure checks in `.agent/tasks/.../TASK.md`.
---

# Uninterrupted Execution Planner

Create a durable execution contract before implementation. Do not implement code changes in this skill.

## Output Location

Write the agreement to:
- `.agent/tasks/<YYYY-MM-DD>-<short-task-name>/TASK.md`

If `.agent/tasks` does not exist, create it. If directory or file creation fails, escalate immediately.

Use `assets/TASK.template.md` as the canonical template. If `TASK.md` is missing, copy the template and fill it.

## Input Handling

If the user provides existing planning inputs (spec, ticket, doc, notes), treat them as primary sources and normalize into `TASK.md`.

Preserve references in `Source Inputs`. Ask only for missing required fields.

## Required Sections

Ensure `TASK.md` includes all sections below:

1. Metadata
- Task ID
- Created
- Requester
- Agent
- Source Inputs

2. Objective
- One-sentence intended outcome.

3. Acceptance Criteria
- `AC1..ACn`, each testable.

4. Milestone Plan
- `M1..Mn`, each with a deliverable and verification action.

5. Verification Plan
- Relevant checks/commands.
- Pass conditions.

6. Error Policy
- Classes: `code`, `test`, `env_tooling`, `requirements_ambiguity`, `external_dependency`.
- Fingerprint format: `<class>|<command_or_test>|<key_error_text>`.
- Escalation trigger: same fingerprint appears 3 times.

7. Evidence Map
- Map every AC to required proof artifacts.

8. Final Closure Gate
- Completion checklist covering AC satisfaction, evidence completeness, relevant checks passing, and no open blockers/escalations.

## Preflight Completion Criteria

Finish planning only when all are true:

1. Every required section is present in `TASK.md`.
2. Every AC has at least one evidence artifact in the evidence map.
3. Every milestone has a verification action.
4. Verification plan and pass conditions are explicit.
5. Error policy is complete and unambiguous.

When these pass, hand off to `uninterrupted-execution` for implementation.
