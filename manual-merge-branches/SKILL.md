---
name: manual-merge-branches
description: Use only when the user explicitly invokes `$manual-merge-branches` or directly instructs using this skill.
---

# Core Purpose

Perform branch merges safely and resolve conflicts only with explicit user authorization.

## Manual Invocation Gate

Proceed only when the user has explicitly invoked `$manual-merge-branches` or clearly directed the agent to use this skill in the current conversation.

If this condition is not met, stop and do not run merge/conflict commands under this skill.

## Required Entry Conditions

Accept exactly one of these starting conditions:

1. Active merge conflict state already exists.
2. User provides one branch to merge into the current branch.
3. User provides a source branch and a target branch.

If none applies, ask the user for missing branch input before running merge commands.

## Required Pre-Step

Load `branch-context` before:

- starting any merge flow, or
- suggesting resolutions when the repo is already mid-merge.

## Workflow

1. Detect current state.
2. Choose one entry path from the required conditions.
3. Synchronize required branches with remote (`fetch`, then `pull --ff-only` when possible).
4. Run merge.
5. If conflicts occur, run the conflict resolution protocol.

### Path 1: Already In Merge Conflict State

1. Confirm merge state (`git status` and unresolved files).
2. Do not start a new merge.
3. Move directly to the conflict resolution protocol.

### Path 2: Merge One Provided Branch Into Current Branch

1. Record current branch as target branch.
2. Validate source branch exists (local or remote).
3. Synchronize source branch:
   - `git fetch --all --prune`
   - If source branch can be checked out safely, checkout source and run `git pull --ff-only`, then return to target.
   - If checkout/pull is not possible, fetch source and merge from `origin/<source>` as fallback.
4. Run merge from target branch.

### Path 3: Merge Source Branch Into Named Target Branch

1. Validate both branch names exist (local or remote).
2. Ensure workspace is safe for branch switching.
3. Synchronize both branches:
   - `git fetch --all --prune`
   - Checkout source and run `git pull --ff-only` when possible.
   - Checkout target and run `git pull --ff-only` when possible.
   - If either pull is not possible, use fetched remote refs (`origin/<branch>`) as fallback.
4. From target branch, run merge using source.

## Conflict Resolution Protocol

When merge conflicts exist:

1. Enumerate conflicts with `git diff --name-only --diff-filter=U`.
2. Process each conflicted file individually.
3. For each file, inspect conflict hunks and produce a suggested resolution that includes:
   - what to keep from `ours`,
   - what to keep from `theirs`,
   - any combined/manual rewrite needed,
   - brief rationale and risk note.
4. Request explicit approval before applying each suggestion.
5. Accept either:
   - per-conflict approvals, or
   - blanket approval (for example: "resolve all conflicts yourself").
6. Apply only approved resolutions. It is valid to resolve a subset and leave others pending.
7. After each approved change:
   - stage resolved file(s),
   - report remaining conflicted files.
8. Continue until all conflicts are resolved or user stops.

## Approval Guardrail

Never apply a conflict resolution without explicit approval coverage for that change.

## Completion

After conflicts are resolved:

1. Confirm no unresolved conflicts remain.
2. Show concise merge summary (`git status` and resolved files).
3. Ask user before any final commit/push action unless already explicitly requested.
