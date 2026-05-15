---
name: multi-agent-pr-review
description: Use when reviewing a pull request. Dispatches multiple specialized subagents in parallel (code-reviewer, silent-failure-hunter, type-design-analyzer, comment-analyzer, pr-test-analyzer) and aggregates their findings into a single structured comment.
---

# Multi-agent PR review

Use parallel specialized subagents for each axis of review, then aggregate.

## When to use

When the user asks to review a PR, audit a diff, or evaluate code quality on a
branch.

## How to dispatch

In a **single message**, send 5 Agent tool calls in parallel:

1. `pr-review-toolkit:code-reviewer` — style, conventions, structure
2. `pr-review-toolkit:silent-failure-hunter` — error handling, swallowed exceptions
3. `pr-review-toolkit:type-design-analyzer` — type design and invariants
4. `pr-review-toolkit:comment-analyzer` — comments that lie or rot
5. `pr-review-toolkit:pr-test-analyzer` — test coverage and edge cases

Brief each one with:
- The PR identifier or diff file path
- A 1-sentence summary of the change

## Aggregation

After all subagents return, produce a single comment with sections:

```markdown
## Review summary

**Blockers:** ...
**Suggestions:** ...
**Nitpicks:** ...

<details><summary>Per-axis details</summary>

### Code review
...
### Silent failures
...
### Type design
...
### Comments
...
### Tests
...
</details>
```

## Why this beats sequential

- Each subagent gets a fresh context window — no contamination
- 5x parallelism on wall clock
- Each specialist can be improved independently
- Main agent only sees summaries, not 5x token cost in its own context
