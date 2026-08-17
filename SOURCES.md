# Sources

Where to find the pre-existing pieces used in this demo.

> **These are public plugins and MCP servers.** Install the ones you trust and
> the ones your organization has already approved — the same due diligence you
> would apply to any third-party dependency.

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

All under `.claude/rules/`, and loaded because `CLAUDE.md` imports them with `@`:

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
