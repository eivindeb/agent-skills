---
name: pr-address-comments
description: Process GitHub PR review feedback. Use when the user wants to inspect, address, reply to, or resolve comments on a pull request. Prefer the GitHub connector for PR metadata, comments, diffs, patches, and posting replies when available; use gh as a fallback for auth, current-branch discovery, and GraphQL-only unresolved-thread details.
---

# Address PR Comments

Read PR feedback, independently verify each claim as far as practical, decide which comments need replies or code changes, present an approval plan, then apply approved changes and/or post approved replies. A review comment is a hypothesis to investigate, not evidence that its diagnosis or proposed fix is correct.

## Tool Split

Use the strengths of each surface:

- **GitHub connector**: PR metadata, normalized discussion timeline, inline review comments, issue comments, per-file patches, full PR diffs, and posting replies/comments.
- **Local filesystem and `git`**: inspecting and editing the checked-out repo, searching usages, running tests, and preparing commits.
- **`gh` CLI**: auth checks, current-branch PR discovery, and fallback for data not exposed by the connector, especially unresolved review-thread state through GraphQL.

If `tool_search` is available, search for GitHub PR comment/review/diff tools before using `gh`. Prefer connector tools when they provide the needed data or write action.

## Input

- A PR URL, for example `https://github.com/vippsas/credit-af-ml/pull/188`, or enough local context to discover the current branch PR.
- Optional filter: unresolved only, new only, specific reviewer, specific files, or selected thread/comment numbers.

Parse the PR URL into:

- `repo_full_name`: `<owner>/<repo>`
- `pr_number`

If no URL is provided, use local `git` and `gh pr view --json url` to discover the current branch PR. If discovery is ambiguous, ask for the PR URL.

## Fetch PR Context

Preferred connector sequence when available:

1. Fetch PR metadata with the connector PR-info/fetch-PR tool.
2. Fetch comments with the connector PR-comments tool. Prefer a normalized timeline that includes issue comments, inline review comments, and review submissions.
3. List changed filenames with the connector file-list tool.
4. Fetch per-file patches for files mentioned by comments. Fetch the full PR patch/diff only when needed for context.

Useful connector capabilities, when discovered:

- get/fetch PR info
- fetch PR comments or discussion timeline
- list PR changed filenames
- fetch one changed file patch
- fetch full PR patch or diff
- reply to inline review comment
- add top-level PR conversation comment
- update comments or add reactions when explicitly useful

Fallback `gh` reads:

```bash
gh pr view <pr_number> --repo <repo_full_name> --json body,comments,reviews,files,headRefName,baseRefName,author
```

For unresolved review threads, use connector data only if it includes resolved state. Otherwise use `gh api graphql` against `pullRequest.reviewThreads` or state clearly that unresolved filtering is unavailable from the fetched data.

If connector access and `gh` access both fail, stop and report the auth/connectivity blocker. Do not scrape the GitHub web UI.

## Filtering

Default: process all actionable comments.

Apply filters when requested:

- **Unresolved only**: process only unresolved review threads. Requires resolved-state data from connector or GraphQL.
- **New only / no author reply**: process comments without a later reply from the PR author or branch owner.
- **No reply**: process comments with no replies at all.
- **File/reviewer/user selected**: process only matching comments.

When resolved-state or reply-thread structure is missing, say which filter could not be applied reliably and either ask whether to continue with best-effort filtering or use the `gh` GraphQL fallback.

## Per-Comment Analysis

For each selected comment:

1. Identify author, comment kind, file path, line/range, comment ID, and thread/reply relationship when available.
2. Classify it as nit, question, requested change, correctness issue, performance issue, security issue, docs/test request, or block.
3. Read local file context when this repo is checked out locally. If the PR repo is not the current workspace, work from connector patches and fetched snippets only and say so.
4. Treat every factual claim in the comment as unverified until independently checked. Use the strongest practical evidence for the claim: relevant implementation and surrounding call sites, tests or a minimal runtime reproduction, configuration/data contracts, or the actual artifact/external-system behavior. Do not rely on the reviewer’s authority, confidence, or suggested fix as evidence.
5. Search usages when the comment concerns behavior, API shape, shared helpers, or non-local side effects.
6. Record the evidence and decide:
   - **Reply only**: comment is already satisfied, incorrect, out of scope, or asks for explanation.
   - **Code change**: comment is valid and should be addressed in code.
   - **Code change + reply**: code should change and the reviewer needs a short note.
   - **Skip**: duplicate, stale, or intentionally deferred.
   - **Investigate first**: available evidence is insufficient to assess the claim or choose a safe resolution.

Never label a comment **Valid** or propose a concrete code resolution until the relevant claim has been verified as far as practical. If verification is blocked or disproportionately expensive, say what was checked, what remains unknown, and request direction rather than treating the comment as correct.

## Approval Plan

Before editing files or posting replies, present one block per selected comment:

```markdown
## Comment [N]: [file path or Conversation] - [one-line summary]

**Reviewer:** [author]
**Kind:** [inline review | review body | conversation comment]
**Location:** [file:line/range or none]
**Evidence checked:** [specific code, runtime test, contract, artifact, or unavailable evidence]
**Assessment:** [Verified valid | Verified partially valid | Verified not applicable | Nit | Question | Needs investigation]
**Proposed action:** [Reply only | Code change | Reply + code change | Skip | Investigate first]

**Draft reply:**
[reply text, if any]

**Code resolution:**
[concrete file/line changes or patch plan, if the claim is verified]
```

Ask for approval before applying actions unless the user explicitly asked to handle all comments autonomously.

## Applying Approved Code Changes

For approved code changes:

1. Edit local files using normal repo editing rules.
2. Run the smallest relevant validation for the changed area.
3. Summarize changed files and validation.
4. Commit/push only if the user explicitly asked for that or the active workflow requires it.

If a requested change appears worse than an existing supported approach, explain the existing approach, why it is better, the tradeoff in the requested change, and ask before implementing it.

## Posting Approved Replies

Prefer connector write tools:

- Inline review thread reply: use the connector reply-to-review-comment tool with the top-level inline review comment ID.
- Top-level PR conversation reply: use the connector add-comment-to-issue tool.
- New aggregate review comment: use the connector add-review-to-PR tool only when a review-level response is more appropriate than per-thread replies.

Use `gh` or `gh api` fallback only when connector write tooling is unavailable or cannot target the comment correctly.

Never post a reply whose target is ambiguous. If a review submission body has no thread/comment target, prefer a top-level PR comment that references the reviewer and topic.

## Output Summary

End with:

- comments addressed by code
- comments answered with replies
- comments skipped or deferred, with reason
- validation run and result
- commit/push/PR status if any remote actions were requested
