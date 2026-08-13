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

@.claude/rules/english-only.mdc
@.claude/rules/no-parallel-ci.mdc
@.claude/rules/status-format.mdc

## Skills

@.claude/skills/ticket-coverage-gap-analysis/SKILL.md
@.claude/skills/local-build-gate/SKILL.md
@.claude/skills/multi-agent-pr-review/SKILL.md
@.claude/skills/ci-failure-triage/SKILL.md
@.claude/skills/known-issues-registry-update/SKILL.md

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
