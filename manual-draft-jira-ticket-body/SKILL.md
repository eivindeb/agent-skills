---
name: manual-draft-jira-ticket-body
description: Use only when explicitly invoked to draft Jira ticket bodies and, after user approval, create Jira tickets through the Jira MCP.
---

# Manual Draft Jira Ticket Body

Produce a complete Jira ticket body even when the user provides incomplete notes. Keep the draft concise, concrete, and ready to paste into Jira. After the user approves the title/body, create the Jira ticket through the Jira MCP when available.

## Manual Invocation Gate

Proceed only when the user has explicitly invoked `$manual-draft-jira-ticket-body` or clearly directed the agent to use this skill in the current conversation.

If this condition is not met, stop and do not run this skill workflow.

## Workflow

1. Extract what the user provided:
- background context,
- current situation or missing capability,
- proposed solution or hypotheses (if provided),
- acceptance criteria,
- links or evidence.
2. Classify ticket type:
- `implementation`: asks to build/change/fix behavior.
- `investigation`: asks to analyze, document findings, or validate hypotheses.
3. Identify gaps: determine whether any missing details materially affect scope, acceptance criteria, or the correctness of the ticket body. Summarize your understanding of the request in 2-4 sentences so the user can confirm or correct it.
4. **Assumption gate (mandatory, separate message):**
- List every candidate assumption you identified during analysis. Present them to the user as questions.
- When assumptions or clarification questions exist, format them as a numbered Markdown list (`1.`, `2.`, `3.`) so the user can address each item explicitly.
- If you have no candidate assumptions, explicitly state: "No assumptions to confirm."
- Include any other clarification questions (material gaps) in this same message.
- Clarify Jira issue type whenever the user has not explicitly chosen `Task` or `Story`.
- Clarify the parent issue whenever the user has not explicitly provided a parent key or clear parent name. If the user says there is no parent, proceed without one.
- Do NOT draft the ticket body or title in this message. Stop and wait for the user to respond.
- The user will either: answer the questions, confirm that certain assumptions belong in the ticket as-is, or clear you to proceed.
5. Draft a complete body using the template for the classified ticket type.
6. Suggest a concise Jira title that matches the body.
7. Revise quickly based on user edits and produce an updated full title + body.
8. After the user approves the final title/body for creation, create the Jira ticket through the Jira MCP.

## Ask-Before-Draft Rule

NEVER produce the full ticket body and follow-up questions in the same response. The assumption gate (step 4) must be a separate message containing only:
- A brief summary of your current understanding (2-4 sentences).
- Candidate assumptions and/or clarification questions presented to the user as a numbered Markdown list, OR an explicit "No assumptions to confirm."

Draft the ticket only after the user has responded and cleared you to proceed.

## All Assumptions Go to the User

Every candidate assumption MUST be surfaced to the user before drafting. The agent does not decide which assumptions are "material" or "implementation details" — all of them go to the user. The user decides which ones they can resolve, which ones belong in the ticket as assumptions, or whether to proceed without any.

Research uncertainties first using available tools. Any that remain unresolved after research must be presented to the user in the assumption gate. The "Assumptions to Confirm" section in the final ticket is reserved only for items the user has explicitly confirmed cannot be resolved before ticket creation.

### Negative Example — Do Not Do This

> Agent identifies that velocity data could come from Redis or the database. This clearly affects implementation scope and the user can answer it immediately. Instead of asking, the agent drafts the full ticket and lists "Velocity counter will be implemented as a Redis-based counter" under Assumptions to Confirm.

This is wrong. The agent rationalized an answerable question as an "implementation detail" and used the Assumptions section as an escape hatch to avoid the clarification gate. The correct action is to present it to the user in the assumption gate before drafting.

## Required Output

When drafting (step 5-6), always output:

1. `Suggested Title`
2. `Ticket Body`

## Jira MCP Creation

Default Jira project key: `RSM`.

Before creating a ticket:

1. Confirm the Jira issue type is either `Task` or `Story`.
2. Confirm the parent issue key or parent name, or confirm that no parent should be used.
3. Use the Jira MCP/Atlassian Rovo tools when available:
   - discover the accessible Atlassian cloud/site when needed;
   - inspect `RSM` project issue types if needed;
   - resolve a parent name to a Jira issue key using JQL/search when the user gives a name instead of a key;
   - create the issue with project key `RSM`, the confirmed issue type, summary, Markdown description, and parent when applicable.
4. If multiple parent candidates match, stop and ask the user to choose one before creating the ticket.
5. If the Jira MCP is unavailable or creation fails, return the approved title/body and a concise explanation of what blocked creation.

Do not create the Jira ticket at the same time as the first draft. Wait for explicit user approval of the final title/body or an explicit instruction to create the ticket from the approved draft.

### Title Rules

- Keep title concise and concrete (prefer 6-12 words).
- Reflect the main problem and intended outcome.
- Avoid filler words and terminal punctuation.
- Normalize typos in the title while preserving technical meaning.

## Template Selection

Use exactly one template:

### Implementation Ticket Template

```
Suggested Title: <concise title>

## Background
...

## Current Situation / What Is Missing
...

## Potential Solution
...

## Evidence / References
- [link text](url)

## Acceptance Criteria
- criterion one
- criterion two

## Assumptions to Confirm
- assumption one
```

Omit `Potential Solution` if the user did not provide one. Omit `Evidence / References` if no evidence is provided. Omit `Assumptions to Confirm` when not needed. This section is only for assumptions that cannot be resolved before ticket creation — see "All Assumptions Go to the User" above.

### Investigation Ticket Template

```
Suggested Title: <concise title>

## Background
...

## Current Situation / What Is Missing
...

## Investigation Scope / Hypotheses
...

## Evidence / References
- [link text](url)

## Acceptance Criteria
- criterion one
- criterion two

## Assumptions to Confirm
- assumption one
```

Omit `Evidence / References` if no evidence is provided. Omit `Assumptions to Confirm` when not needed. This section is only for assumptions that cannot be resolved before ticket creation — see "All Assumptions Go to the User" above.

## Acceptance Criteria Quality Gate

- Provide 3-7 bullet items using `-` (Markdown unordered list).
- Write each criterion as observable and verifiable.
- Prefer outcome-focused language over implementation details.
- Include non-blocking or safety guardrails when relevant (for example: "must not block request processing").
- Avoid vague criteria such as "works better" or "improve performance" without a measurable signal.

## Output Format Rules

All ticket body output MUST use standard Markdown. Jira now renders Markdown natively.

## Drafting Rules

- Keep wording plain and specific; avoid filler.
- Do not invent product, system, or business facts.
- Preserve and include user-provided links under `Evidence / References`.
- Normalize obvious typos and grammar while preserving intent.
- Keep scope bounded to what the user requested.
- Use standard Markdown syntax in the ticket body.

## Example Inputs To Recognize

- Broken local dev environment and incomplete migrations with request for end-to-end testability.
- Metrics path that can block requests due to Redis dependency and needs best-effort behavior.
- Device-change feature request requiring production and historical parity.
- Investigation/documentation ticket with Confluence as deliverable.
- Session overcounting bug investigation with hypotheses and GitHub/Slack references.
