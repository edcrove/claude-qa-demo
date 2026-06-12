# claude-qa-demo

Public demo repo for the meetup talk
**"De prompt a skill: cultivando workflows de QA con agentes de Claude"**.

Every artifact here is plain text on disk. Read, fork, copy what works.

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
