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
| `memory/` | Sample cross-session memory |
| `mocks/` | Offline Jira / Jenkins / GitHub fixtures |
| `skill-templates/` | Pegable templates for your own skills/rules/hooks |
| `demo-app/` | Minimal TypeScript API used in TDD and PR scenes |
| `evolution-timeline.md` | How this repo grew week by week |
| `SOURCES.md` | Where to download the pre-existing pieces |
| `scripts/` | `check-leaks.sh` and `prep-demo.sh` |
| `slides/` | Marp deck (~30 slides, ~30 min talk) |

## Running the demo app

```bash
cd demo-app
npm install
npm test
npm run typecheck
```

## Running the demo from scratch

```bash
./scripts/prep-demo.sh   # reset state between rehearsals
./scripts/check-leaks.sh # verify no confidential strings before pushing
```

## The pattern

```
Prompt → Memory → Skill → Rule → Hook
```

Cultivate, don't design. See `evolution-timeline.md`.

## License

MIT — see `LICENSE` (add one if missing before pushing publicly).
