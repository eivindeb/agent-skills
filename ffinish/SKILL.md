---
name: ffinish
description: Complete feature branch by squashing commits into a single comprehensive commit. Use when feature development is complete and ready for final review or merge.
---

# Purpose

Transform a series of incremental progress commits into a single, well-documented commit that represents the complete feature. This:
- Keeps main branch history clean and readable
- Preserves detailed progress in feature branch (before squash)
- Creates searchable, meaningful history entries
- Prepares work for review or direct merge

## When to Use

**Use `/ffinish` when:**
- Feature is complete and tested
- All planned functionality is implemented
- Ready to merge back to main branch
- Want to create a pull request for review
- Abandoning feature branch and want clean summary

**Prerequisites:**
- Currently on a feature branch
- All changes committed (no dirty working directory)
- Feature is in desired final state

## Workflow

1. **Verify state**
   - Check we're on a feature branch (not main)
   - Ensure working directory is clean
   - Show summary of commits that will be squashed

2. **Review commits**
   - Display `git log` of all commits since branching from main
   - Count total commits to be squashed

3. **Generate summary message**
   - Analyze all commit messages
   - Create comprehensive summary covering:
     - What was built/changed
     - Why it was needed
     - Key technical decisions (if relevant)
     - Any breaking changes or migration notes
   - Follow conventional commit format if project uses it

4. **Present plan to user**
   - Show the squash commit message
   - Ask for approval or edits
   - Offer options:
     - Squash and stay on branch
     - Squash and merge to main
     - Squash and create PR
     - Cancel

5. **Execute chosen action**
   - Never rewrite feature branch history
   - For merge to main: checkout `main`, then `git merge --squash <feature-branch>` and `git commit`
   - For create PR: `gh pr create` (no squash)
   - Clean up feature branch if merged (optional)

## Commit Message Format

**Structure** for squashed commit:
```
<Brief title (50 chars)>

## Summary
<2-4 sentences describing what was built and why>

## Changes
- Key change 1
- Key change 2
- Key change 3

## Technical notes
<Optional: Important technical decisions or context>
```

**Example:**
```
Add user authentication system

## Summary
Implemented complete authentication flow including login, registration,
and password reset. Users can now securely access protected routes with
JWT-based session management.

## Changes
- Add login/registration forms with validation
- Implement JWT token generation and verification
- Create password hashing with bcrypt
- Add protected route middleware
- Build password reset flow with email tokens

## Technical notes
- Used bcrypt with 12 rounds for password hashing
- JWT tokens expire after 24 hours
- Email tokens expire after 1 hour
```

## Options and Variations

**After squashing, user can choose:**

1. **Do nothing** - Keep feature branch as-is
2. **Merge to main** - Squash into main via `git merge --squash` while preserving feature branch history
3. **Create PR** - Open pull request for review (no squash)

## Example Interaction

```
User: "Feature is done, let's finish this branch"

Agent:
Finishing feature branch: feature/add-user-auth

Found 8 commits to squash:
- Add user login form: enable authentication flow
- Extract validation logic: prepare for reuse in signup
- Fix password hashing: correct bcrypt salt rounds
[... 5 more ...]

Proposed squash commit message:

---
Add user authentication system

## Summary
Implemented complete authentication flow including login, registration,
and password reset. Users can now securely access protected routes with
JWT-based session management.

## Changes
- Add login/registration forms with validation
- Implement JWT token generation and verification
- Create password hashing with bcrypt
- Add protected route middleware
- Build password reset flow with email tokens

---

What would you like to do?
1. Do nothing
2. Squash and merge to main (preserve feature branch history)
3. Create PR (no squash)
4. Edit message first
```

## Important Notes

- **Backup option** - Offer to create a backup branch before squashing
- **No force push** - Never force push to main
- **Preserve original** - Feature branch history is never rewritten by this skill
- **Review first** - Always show the squash message for approval

## Safety Checks

Before squashing:
- ✓ Not on main branch
- ✓ Working directory clean
- ✓ At least 2 commits to squash (otherwise just merge)
- ✓ User has reviewed and approved

If any check fails, explain and abort.

## Relationship to Other Skills

- Used after multiple `/fcommit` calls during development
- Started with `/feature-start` to create the branch
- Final step in feature branch workflow
