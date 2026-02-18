---
name: manual-draft-jira-ticket-body
description: Use only when explicitly invoked to create Jira ticket bodies.
---

# Manual Draft Jira Ticket Body

Produce a complete Jira ticket body even when the user provides incomplete notes. Keep the draft concise, concrete, and ready to paste into Jira.

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
3. Identify missing inputs and add only lightweight, clearly-labeled assumptions.
4. Draft a complete body using the template for the classified ticket type.
5. Suggest a concise Jira title that matches the body.
6. Ask up to 3 targeted follow-up questions only when missing details materially affect scope or acceptance criteria.
7. Revise quickly based on user edits and produce an updated full title + body.

## Required Output

Always output:

1. `Suggested Title`
2. `Ticket Body`

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

h2. Background
...

h2. Current Situation / What Is Missing
...

h2. Potential Solution
...

h2. Evidence / References
* [link text|url]

h2. Acceptance Criteria
* criterion one
* criterion two

h2. Assumptions to Confirm
* assumption one
```

Omit `Potential Solution` if the user did not provide one. Omit `Evidence / References` if no evidence is provided. Omit `Assumptions to Confirm` when not needed.

### Investigation Ticket Template

```
Suggested Title: <concise title>

h2. Background
...

h2. Current Situation / What Is Missing
...

h2. Investigation Scope / Hypotheses
...

h2. Evidence / References
* [link text|url]

h2. Acceptance Criteria
* criterion one
* criterion two

h2. Assumptions to Confirm
* assumption one
```

Omit `Evidence / References` if no evidence is provided. Omit `Assumptions to Confirm` when not needed.

## Acceptance Criteria Quality Gate

- Provide 3-7 bullet items using `*` (Jira bullet syntax).
- Write each criterion as observable and verifiable.
- Prefer outcome-focused language over implementation details.
- Include non-blocking or safety guardrails when relevant (for example: "must not block request processing").
- Avoid vague criteria such as "works better" or "improve performance" without a measurable signal.

## Output Format Rules

All ticket body output MUST use Jira Wiki Markup, NOT Markdown. Jira does not render Markdown.

Quick reference (Markdown → Jira Wiki Markup):

| Element | Markdown | Jira Wiki Markup |
|---|---|---|
| Heading 2 | `## Title` | `h2. Title` |
| Heading 3 | `### Title` | `h3. Title` |
| Bold | `**text**` | `*text*` |
| Italic | `*text*` | `_text_` |
| Inline code | `` `code` `` | `{{code}}` |
| Bullet list | `- item` | `* item` |
| Numbered list | `1. item` | `# item` |
| Link | `[text](url)` | `[text\|url]` |
| Table header | `\| H1 \| H2 \|` | `\|\|H1\|\|H2\|\|` |
| Table row | `\| c1 \| c2 \|` | `\|c1\|c2\|` |
| Code block | ` ```lang ``` ` | `{code:lang}...{code}` |

## Drafting Rules

- Keep wording plain and specific; avoid filler.
- Do not invent product, system, or business facts.
- Preserve and include user-provided links under `Evidence / References`.
- Normalize obvious typos and grammar while preserving intent.
- Keep scope bounded to what the user requested.
- Never use Markdown syntax in the ticket body; always use Jira Wiki Markup.

## Example Inputs To Recognize

- Broken local dev environment and incomplete migrations with request for end-to-end testability.
- Metrics path that can block requests due to Redis dependency and needs best-effort behavior.
- Device-change feature request requiring production and historical parity.
- Investigation/documentation ticket with Confluence as deliverable.
- Session overcounting bug investigation with hypotheses and GitHub/Slack references.
