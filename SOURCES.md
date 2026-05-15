# Sources

Where to find the pre-existing pieces used in this demo.

## Plugins

- **superpowers** — TDD, debugging, brainstorming, verification-before-completion,
  using-git-worktrees, and many more. Install via `/plugin` in Claude Code.
- **pr-review-toolkit** — 5 specialized PR reviewers (code, comments, types,
  silent failures, tests). Install via `/plugin`.

## Skills authored for this demo

All under `.claude/skills/`. Adapt freely:

- `ticket-coverage-gap-analysis`
- `local-build-gate`
- `multi-agent-pr-review`
- `ci-failure-triage`
- `known-issues-registry-update`

## Rules authored for this demo

All under `.cursor/rules/`. These are read by both Cursor and Claude Code:

- `english-only.mdc`
- `no-parallel-ci.mdc`
- `status-format.mdc`

## MCP servers (not used in this offline demo)

The real-world setup connects to:
- Atlassian (Jira, Confluence)
- GitHub
- Slack
- context7 (library docs)

In this demo all external systems are replaced by mocks under `mocks/`.

## Inspiration

- Anthropic Claude Code documentation
- Claude Code plugin marketplace
- Personal observation of the team's own workflow
