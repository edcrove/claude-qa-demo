# claude-qa-demo

Public demo repo for the meetup talk
**"Tu setup de QA no se diseña: se cultiva"** — de prompt suelto a skills,
rules y hooks.

Every artifact here is plain text on disk. Read, fork, copy what works.

## Continuity

Working on the talk itself (not just the demo app)? Read `docs/STATUS.md`
first — it is the continuation anchor: current state, environment gotchas
(iCloud eviction, gh accounts, stage isolation), pending decisions, next
steps. Then `docs/talk-design.md` (design + narrative devices),
`docs/decision-log.md` (real history), `docs/runbook.md` (live demo script).
Update `docs/STATUS.md` at the end of every working session.

Continuing from a claude.ai **chat** (no filesystem access): `docs/HANDOFF.md`
is the self-contained capsule to attach or paste, with a kickoff prompt.
Regenerate it whenever STATUS changes.

## Workspace rules

Rules are always loaded — that is what makes them rules. They are imported
here on purpose:

@.claude/rules/english-only.mdc
@.claude/rules/no-parallel-ci.mdc
@.claude/rules/status-format.mdc

## Memory

Facts that must survive between sessions. Also always loaded:

@memory/MEMORY.md

## Skills

Skills live in `.claude/skills/` and are **deliberately not imported here.**
Claude discovers them by their `description` frontmatter and loads a skill's
body only when the situation calls for it. That on-demand loading is the
whole difference between a skill and a rule — importing them would erase it.

- `ticket-coverage-gap-analysis` — ticket → coverage map, gaps, proposed tests
- `local-build-gate` — typecheck + tests before any remote CI build
- `multi-agent-pr-review` — 5 specialized subagents in parallel, one summary
- `ci-failure-triage` — classify CI failures against the known-issues registry
- `known-issues-registry-update` — record a confirmed flake in the registry
- `talk-deck-editing` — the rules for editing this talk's deck: the render gate,
  the failures that are silent, the callbacks that must be edited in pairs.
  **This one is the repo eating its own cooking** — it was cultivated the same
  way the deck says to cultivate anything: the same corrections, repeated, until
  they were worth writing down.

## Demo app

The `demo-app/` directory contains a minimal TypeScript API used during the
TDD and PR-review scenes. It is intentionally small so it fits on screen.

## Mocks

The `mocks/` directory simulates external systems (Jira, Jenkins, GitHub) so
the demo can run fully offline.

## Conventions

- Test framework: vitest
- TDD: failing test first, then minimal implementation, then refactor
- Commit messages: conventional commits (feat:, fix:, test:, chore:, docs:)
- Before triggering CI: run local build via the `local-build-gate` skill
