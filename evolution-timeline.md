# Evolution timeline

How this repo grew. Each entry is dated with what triggered the change so the
audience can see that the setup wasn't designed — it was cultivated.

## Week 1 — Empty CLAUDE.md

> 5 lines: project name, Node version, test command.

Nothing else. Every prompt is freeform.

## Week 1 — First skill: `local-build-gate`

Trigger: triggered a CI build twice in a row with a TypeScript error that
typecheck would have caught in 2 seconds. After the second time, distilled the
3-step routine into a skill.

## Week 3 — Rule: `no-parallel-ci`

Trigger: parallel CI run against `stage` produced cascading flakes that looked
like real regressions. Spent 90 minutes triaging non-issues. Promoted the
"don't do this" learning from a prompt to a rule so Claude refuses on my behalf.

## Week 3 — Rule: `english-only`

Trigger: a teammate from another region couldn't review a commit message
written in Spanish. Promoted to a rule for consistency.

## Week 6 — Skill: `ci-failure-triage`

Trigger: same 3 categorization questions every Monday morning. Distilled the
heuristic table into a skill.

## Week 6 — Skill: `known-issues-registry-update`

Trigger: kept losing track of which flakes had been seen before. Created the
registry, then the skill to keep it updated.

## Week 9 — Plugin install: `pr-review-toolkit`

Trigger: found the marketplace plugin while looking for a code-reviewer agent.
Downloaded, used as-is. Did not need to write my own.

## Week 9 — Skill: `multi-agent-pr-review`

Trigger: was running the 5 plugin subagents sequentially and waiting too long.
Wrote a thin wrapper skill to dispatch them in parallel.

## Week 11 — Hook: typecheck-after-edit

Trigger: kept forgetting to run typecheck after Claude edited a TS file.
Promoted from feedback memory → skill → hook. Now it's automatic. Note there is
no typecheck *rule*: this pain skipped that level, which is the point the deck's
pyramid makes.

## Week 13 — Skill: `ticket-coverage-gap-analysis`

Trigger: ran the same coverage-mapping conversation 4 weeks in a row during
sprint planning. Time to write it down.

## Week 16 — Memory: `known-issues` registry

Trigger: the flake registry kept growing with every confirmed flaky test.
Deliberately **not** imported from `CLAUDE.md` — `ci-failure-triage` reads it
when a build fails, instead of carrying it in every session.
