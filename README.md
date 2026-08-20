# claude-qa-demo

Companion repo for the meetup talk **"Tu setup de QA no se diseña: se
cultiva"** — de prompt suelto a skills, rules y hooks.

Everything here is plain text on disk. Clone it, read it, copy what works.

## Start here

**The deck** — [slides-light-16x9.pdf](slides/slides-light-16x9.pdf) · 48 slides,
in Spanish. Also in [16:10](slides/slides-light-16x10.pdf), and in a dark theme:
[16:9](slides/slides-dark-16x9.pdf) · [16:10](slides/slides-dark-16x10.pdf).
Versioned on purpose, so you can read it without installing Marp.

**The catalogue** — [`docs/showable-inventory.md`](docs/showable-inventory.md).
The pieces of a real QA setup, sanitized: rules, skills, agents, hooks and
permissions. Every row says what the piece does and **why it exists** — usually
the concrete pain that produced it. If you recognise the pain, copy the piece.
Start from its *"si copiás sólo tres cosas"* table.

## What's inside

| Path | Purpose |
|------|---------|
| `CLAUDE.md` | Project conventions Claude loads at session start |
| `.claude/skills/` | 6 invocable workflows — five for the QA day, plus the one that came out of building this talk |
| `.claude/rules/` | 3 always-on guardrails |
| `.claude/settings.json` | 1 PostToolUse hook |
| `memory/` | Cross-session memory: one feedback entry + the known-issues registry |
| `mocks/` | Offline Jira / Jenkins / GitHub fixtures |
| `skill-templates/` | Pegable templates for your own skills/rules/hooks |
| `demo-app/` | Minimal TypeScript API used in TDD and PR scenes |
| `docs/` | STATUS (continuation anchor), talk design, decision log, live runbook, HANDOFF (chat capsule), showable inventory (a catalogue of the author's real work setup, sanitized and written for you to copy from) |
| `evolution-timeline.md` | How this repo grew week by week (the demo fiction) |
| `SOURCES.md` | Where to download the pre-existing pieces |
| `scripts/` | Stage safety (`prep-demo.sh`, `check-leaks.sh`, `demo-profile.sh`) and deck build (`build-deck.sh`, `build-diagrams.sh`, `build-logos.js`, `check-slide-overflow.js`) |
| `slides/` | Marp deck, 48 slides (32 main flow + 9 anatomy appendix + 6 Q&A backup + 1 repo map). The rendered PDFs are versioned — `slides-{dark,light}-{16x9,16x10}.pdf`, readable without installing anything. See [`slides/README.md`](slides/README.md) |

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
| Demo 5 | `memory/known-issues.md` present, and `build-44.json` carries **no** category hints | `prep-demo.sh` |
| Hook | `jq` on PATH (the hook reads its stdin JSON with it) | `prep-demo.sh` |

## The pattern

```
Prompt → Memory → Skill → Rule → Hook
```

Cultivate, don't design. See `evolution-timeline.md`.

## License

MIT — see `LICENSE`.
