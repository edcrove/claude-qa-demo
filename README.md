# claude-qa-demo

Companion repo for the meetup talk **"De prompt a skill: cultivando workflows
de QA automation con agentes de Claude"**.

Everything here is plain text on disk. Clone it, read it, copy what works.

## What's inside

| Path | Purpose |
|------|---------|
| `CLAUDE.md` | Project conventions Claude loads at session start |
| `.claude/skills/` | 5 invocable workflows |
| `.claude/rules/` | 3 always-on guardrails |
| `.claude/settings.json` | 1 PostToolUse hook |
| `memory/` | Cross-session memory: one feedback entry + the known-issues registry |
| `mocks/` | Offline Jira / Jenkins / GitHub fixtures |
| `skill-templates/` | Pegable templates for your own skills/rules/hooks |
| `demo-app/` | Minimal TypeScript API used in TDD and PR scenes |
| `docs/` | STATUS (continuation anchor), talk design, decision log, live runbook |
| `evolution-timeline.md` | How this repo grew week by week (the demo fiction) |
| `SOURCES.md` | Where to download the pre-existing pieces |
| `scripts/` | `check-leaks.sh`, `prep-demo.sh`, `demo-profile.sh` |
| `slides/` | Marp deck (32-slide main flow + anatomy appendix + Q&A backup) |

## Running the demo app

```bash
cd demo-app
npm install
npm test
npm run typecheck
```

## Running the demo from scratch

```bash
./scripts/prep-demo.sh     # reset state + assert every scene still has work to do
./scripts/check-leaks.sh   # verify no confidential strings before pushing
./scripts/demo-profile.sh  # launch Claude with an isolated config (no work context)
```

`demo-profile.sh` is the one that matters on stage: it starts Claude Code with
`CLAUDE_CONFIG_DIR` pointing at a throwaway profile, so no global `CLAUDE.md`, no
work MCP servers and no tokens reach the projector. `check-leaks.sh` only greps
this repo — it cannot protect you from your own global config.

## Initial state the demos depend on

The repo intentionally ships **incomplete** so each scene has real work left:

| Scene | What must be missing / present | Checked by |
|-------|-------------------------------|------------|
| Demo 1 | `DEMO-100` lists 4 acceptance criteria, only 2 are covered by tests | — |
| Demo 2 | `getChannelBySlug` exists but does **not** validate the slug format — that is the red test | `prep-demo.sh` |
| Demo 3 | `build-43-running.json` shows a build RUNNING on stage, so `no-parallel-ci` blocks the trigger live | `prep-demo.sh` |
| Demo 5 | `memory/known-issues.md` present, and `build-42.json` carries **no** category hints | `prep-demo.sh` |
| Hook | `jq` on PATH (the hook reads its stdin JSON with it) | `prep-demo.sh` |

## The pattern

```
Prompt → Memory → Skill → Rule → Hook
```

Cultivate, don't design. See `evolution-timeline.md`.

## License

MIT — see `LICENSE`.
