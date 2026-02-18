---
name: rename-symbol
description: Systematically rename a symbol across the entire codebase, ensuring no orphaned references remain. Use when renaming any symbol or changing a shared name root/prefix/suffix.
---

# Rename Symbol

Perform a codebase-wide rename guaranteeing that all references — direct and semantic — are updated consistently.

Standard renames miss semantic siblings (e.g., renaming `EmitOverallDecisionReason` but leaving `OverallDecisionReasonMapper` untouched), interface/implementation pairs, test names, file names, and non-code references. `rg "OldName"` surfaces all of these — this skill makes that search mandatory.

`rg` won't catch generated code, serialized names, or string-interpolated references — flag these to the user if the codebase uses them.

## Workflow

### 1. Clarify Scope

- Identify the OLD name (or name fragment) and the NEW name.
- Confirm: exact symbol rename vs. conceptual root rename (e.g., `OverallDecisionReason` → `DecisionReason` affects classes, methods, files, etc.).
- When ambiguous, ask the user before proceeding.

### 2. Search the Full Blast Radius

Before any edits:

```bash
rg "OldName"
```

If the root is a common substring, scope more narrowly to avoid false positives.

Use `Glob` to find files whose **names** contain the old symbol.

Categorize results:

- **Declarations**: class/method/interface/variable definitions
- **Call sites**: imports, using statements, invocations
- **File names**: files named after the old symbol
- **Semantic siblings**: related symbols sharing the conceptual root
- **Non-code**: comments, documentation, YAML, configs, test names

### 3. Present Change Plan

Before executing, show the user:

- Every file and symbol that will change, grouped by category
- Any ambiguous matches flagged for confirmation

### 4. Execute and Verify

Edit everything the plan identified. Then verify:

```bash
rg "OldName"
```

Must return zero results (or only user-confirmed exceptions). Check linter on changed files. If matches remain, keep going.

## Guardrails

- **Substring caution**: do not rename symbols that merely *contain* the old name unless the user confirms (e.g., renaming `User` should not automatically rename `UserService`).
- **Prefer `rg` over IDE refactoring** — `rg` catches references in non-code files that IDE tools miss.
