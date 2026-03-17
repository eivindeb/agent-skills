---
name: pr-address-comments
description: Process a GitHub PR URL to read review comments. Use when the user wants to address PR feedback, respond to review comments, or asks to handle comments on a pull request.
---

# Address PR Comments

Process a pull request link, read its comments, and for each comment produce either a suggested reply (when no code change is needed) or a suggested code resolution, then present each for approval.

## Input

- **PR URL** (e.g. `https://github.com/vippsas/credit-af-ml/pull/188`).
- **Optional**: Filtering preference (see [Comment filtering](#comment-filtering)).

## Parse the PR URL

From the URL extract:

- `owner` (e.g. `vippsas`)
- `repo` (e.g. `credit-af-ml`)
- `pull_number` (e.g. `188`)

Use these for `gh` commands and for locating the repo locally if the workspace is that repository.

## Obtaining PR Comments

Run:

```bash
gh pr view <pull_number> --repo <owner>/<repo> --json body,comments,reviews
```

Parse the JSON:

- `body` — PR description.
- `comments` — issue-level comments (each has `body`, `author.login`, `createdAt`).
- `reviews` — review submissions; each has `body` (the review text), `author.login`, `state` (e.g. COMMENTED, APPROVED).

**If the command fails** (non-zero exit, "authentication required", or similar): do not fall back to other methods. Tell the user that GitHub authentication is required and they should run `gh auth login` (or `gh auth refresh` if already logged in), then retry the skill.

## Comment filtering

Use filtering when it is not the first round of review and some comments are already addressed.

**Options (choose one or combine as user prefers):**

1. **Unresolved threads only** – If using GitHub’s “Resolved” state (e.g. from API or from a fetched page), process only threads that are not marked resolved.
2. **No reply from PR author** – Process only comments that do not yet have a reply from the PR author (or the branch committer). Reduces duplicate work on threads already answered.
3. **Reply presence** – Process only comments that have no reply at all, to focus on new feedback.
4. **User-specified** – User lists which threads or files to address (e.g. “only the three comments on `src/foo.py`” or “only the first five threads”).

If the user does not specify a filter, process all comments. If they say “only new” or “only unresolved,” apply the matching filter above.

## Per-comment workflow

For each comment (after filtering):

### 1. Analyze the comment

- Identify the **file and location** (path, line or range).
- Classify the **type**: nit, suggestion, question, requested change, block.
- Infer the **reviewer’s concern** (correctness, style, performance, security, clarity, etc.).

### 2. Optional: look up code and blast radius

When the comment is about behavior or design:

- Open the **relevant file(s)** and the **exact lines** (and surrounding context) in the workspace.
- If the repo is not the current workspace, say so and work from the comment and any pasted snippets only.
- Consider **blast radius**: callers, tests, and dependent code. Search for usages of the function/class/symbol in question and note impact of potential changes.

### 3. Decide how to address

- **Text-only:** Comment is incorrect, outdated, or already satisfied; or the change would be wrong or out of scope. Plan a **reply** that explains why no code change is needed.
- **Code change:** Comment is valid and should be addressed in code. Plan **concrete changes** (and optionally a short reply).

### 4. Produce the suggestion

**If textual response:**

- Draft a **reply to the reviewer** that:
  - Acknowledges the comment.
  - Explains the situation (e.g. why the current code is correct, or why the suggested change is not applied).
  - Is polite and concise.

**If code changes:**

- Propose a **resolution**: what to change (file, line range, before/after or steps).
- Optionally add a **short reply** for the thread (e.g. “Done in commit X” or “Fixed by …”).

### 5. Present for approval

For each comment, output a single block for the user to approve:

```markdown
## Comment [N]: [file path] — [one-line summary]

**Reviewer:** [author]  
**Quote:** “[exact or summarized comment text]”

**Assessment:** [Valid / Partially valid / Not applicable / Nit]

**Proposed action:** [Reply only | Code change | Reply + code change]

**Draft reply (if any):**
[Text to post as a comment]

**Code resolution (if any):**
[Steps or patch description]
```

Ask the user to confirm each item (e.g. “Approve / Edit / Skip”) before proceeding to the next comment or before applying code changes.

## Summary

After processing all (filtered) comments:

- List which comments got a **reply only**, which got **code + reply**, and which were **skipped**.
- If code changes were approved, apply them in the workspace and remind the user to commit and push; delegate any `gh` or git remote operations to the user per their auth preferences.
