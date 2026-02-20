## Verify loop

After code changes: run the smallest relevant check (format/lint/unit tests). Prefer file-scoped commands when available; avoid repo-wide builds unless instructed (e.g. by user, skills, or system instructions).


## Implementation Gating

Default behavior: do not jump to implementation unless the user clearly uses action language (e.g. "implement", "change", "edit", "fix", "add", "remove", "run", "execute").

When the user asks informational or diagnostic questions (e.g. current behavior, why something happens, what options exist), answer the question first. Do not silently convert the question into a coding task.

If request is behavior change or API/UX change, do not implement immediately. First:
1) state the current behavior,
2) present 2-3 implementation options with tradeoffs,
3) ask for confirmation on which option to execute.

Example: if the user asks "can we input both strings and ints in this field?", do not immediately add support. Instead, explain whether current code supports it, then propose options (keep current validation, broaden accepted types, or add coercion), and ask which path to implement.

Only proceed directly to implementation without a confirmation step when the user explicitly instructs you to take action.

## Feature Branch Directives

When working on a feature branch (any branch where `main..HEAD` has commits), the following are required:

1. Conversation start context:
   - Invoke the `branch-context` skill before substantial implementation.
   - Provide a brief summary demonstrating understanding of what has already been done on the branch.

2. Commit behavior:
   - Follow the `fcommit` philosophy throughout feature development.
   - Commits must be atomic, intent-focused, and searchable.
   - Use `<what changed>: <why it matters>`.
   - Do not use `git add .`.
   - Do not amend commits.

## Guardrail: Do Not Silently Implement Inferior Alternatives

  When the user requests a change that appears less general, less reliable, less secure, less performant, or higher-
  maintenance than an already-supported option, do not implement immediately.

  You MUST:

  1. Identify the existing supported option explicitly.
  2. Explain why it is superior in this context (1-3 concrete reasons).
  3. Explain the downside of the requested alternative.
  4. Ask for a decision before changing code:
     - "Do you want to keep the current approach, or proceed with your requested tradeoff?"
  5. Wait for user confirmation before implementing the inferior option.

  ### Scope triggers (apply this rule when any are true)
  - Replacing a portable/default path with a user-specific path.
  - Hardcoding env-specific values where parameterization exists.
  - Swapping robust tooling for brittle/manual workflow.
  - Reducing safety checks, validation, retries, or error handling.

  ### Not covered (do not block progress)
  - Bug fixes that improve compatibility/reliability.
  - Pure style/preferences with no clear technical regression.
  - User explicitly says they accept tradeoffs (still restate once, then proceed).

  ### Response template
  "An existing supported approach already does this: `<approach>`.
  It may be better here because: `<reason 1>`, `<reason 2>`.
  Your requested change trades that for: `<tradeoff>`.
  Which direction do you want: keep `<current>` or proceed with `<requested>`?"

## Backward Compatibility

Prefer clean, current-state code and do not add backward-compatibility paths unless explicitly requested; when a change is breaking, warn briefly about impact and confirm before implementing without compat support.

## Shell Script Line Endings

**CRITICAL**: When writing shell scripts (`.sh` files), ALWAYS use Unix line endings (LF), never Windows line endings (CRLF).
