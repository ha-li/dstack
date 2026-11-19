---
name: architect
description: "Use when asked to analyze, audit, design or redesign how a codebase or subsystem is structured. State ownership, duplicated ways of doing a task, coupling between modules, or 'workarounds keep piling up'"
disable-model-invocation: true
---

# Architect

Trace a system, audit it against three rules and redesign it where patching would only add workarounds.

The target is whatever the user names (a package, a directory, a feature). If none is named, ask which system to look at before reading anything.

## The thre rules
1. **One owner per piece of state.** Every piece of state is written and decided in exactly one place. Copies elsewere are derived, not stored.
2. **One way to do each task.** A task is implemented once and called from elsewhere.
3. **Callers know least.** A caller says what it wants and learns what happens. It does not sequence phases, read another module's storage, or branch on internal status values.


## Process

1. **Trace.** Read the code; do not infer it. Map each system: entry points, types, signatures, module boundaries, who imports whom, where state lives (memory, disk, preferences, caches). Say plainly which parts you did not read.
2. **Audit.** For each rule, list what does not conform, with `file:line` evidence and the concrete failure it allows. Group findings by rule, not by file.
3. **Look for workaround smells.** These show a missing owner or a missing abstraction:
   - a collaborator rebuilt on every call "because options or tests may replace it"
   - lazy initialization added because tests build struct literals
   - a fallback that restores an earlier state after failure
   - suppression logic that hides transitions from a derived value
   - a retry loop around an ordering race
   - the same comparison or parse written in several places with different failure policies
   - a value re-derived by guessing (for example, a channel recovered from a URL prefix)
   - two copies of one constant, or one key read by several packages
4. **Redesign instead of patching when the smells repeat.** If three or more appear around the same state, patching each one is the wrong move.
5. **Sketch two genuinely different shapes.** Give types, signatures and module boundaries for each, not prose. The second shape must differ in structure, not in naming.
6. **Pick one, against the three rules.** Use a short table, state the cost (files, tests, behavior changes), and recommend. Do not survey options you will not pursue.
7. **Plan the migration** as small, shippable steps where each step leaves the code building and passing. Name which steps change behavior.

## When implementing

- If the user asked to see a design first, describe it and wait. Do not generate code until they say go.
- Ask before deciding behavior: when two code paths disagree on an edge case, state each behavior and recommend one. Do not pick silently.
- Preserve behavior in refactor steps. Report every intentional behavior change, however small.
- Check claims instead of asserting them. If you say a linter does or does not flag something, run it with a control that you know should be flagged. If a test cannot fail on the bug, say so and do not keep it.
- Run the project's own checks after each step (build, tests with the race detector if the language has one, lint, other-platform builds). Report what you could only compile, not run.
- Search for leftovers after a rename or move: old names in code, comments, docs, config and generated files. Regenerate generated files with the project's pinned tool.
- Never commit unless asked. Leave the diff for the user to review.

## Report

End each phase with what changed, what it cost, what behavior changed, what you could not verify, and what is left. Keep it short and concrete; prefer a table to a paragraph when comparing.