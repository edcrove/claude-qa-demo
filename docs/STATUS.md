# STATUS — start here to resume work

**Last updated:** 2026-08-04 (evening)

This is the continuation anchor. A session with zero prior context should read,
in this order: this file → [`talk-design.md`](talk-design.md) (what the talk is)
→ [`decision-log.md`](decision-log.md) (why things are the way they are) →
[`runbook.md`](runbook.md) (how to drive the demos live).
Keep this file updated at the end of every working session.

## Where things stand

- **Repo + deck are rehearsal-ready.** All demo premises were audited and fixed
  on 2026-08-04 (see decision-log entry of that date). `./scripts/prep-demo.sh`
  passes all state assertions; `./scripts/check-leaks.sh` is clean; the deck
  renders (45 slides: 32 main / 9 appendix / 4 Q&A backup).
- **Everything is committed on local `main` and pushed to origin**
  (2026-08-04, approved by the author).
- **No rehearsal of the full 30-minute run has happened yet** with the current
  deck and fixed demos.

## Environment facts (non-derivable, will bite you)

| Fact | Detail |
|------|--------|
| Remote | `git@github.com-personal:edcrove/claude-qa-demo.git` — the `github.com-personal` SSH alias is **required**: the default SSH key authenticates as the work account, which has no access to this repo ("Repository not found") |
| gh CLI | Two accounts configured; the work one is usually active. Run `gh auth switch -u edcrove` before any `gh` operation on this repo |
| iCloud eviction | The repo lives under `~/Documents` (iCloud-managed). `node_modules` files get evicted to `compressed,dataless` placeholders → typecheck/tests hang for minutes at 0% CPU. `prep-demo.sh` auto-detects and reinstalls. Details + measurements: decision-log §7 |
| Stage isolation | Never present from the day-to-day config. Launch via `./scripts/demo-profile.sh` (isolated `CLAUDE_CONFIG_DIR`, no global memory, no work MCPs). `check-leaks.sh` cannot see the global config — the profile is the only protection |
| jq | Required on PATH — the PostToolUse typecheck hook parses its stdin JSON with it |

## Pending decisions (the author's, not the agent's)

1. **The GitHub repo is still PRIVATE.** The slides print
   `github.com/edcrove/claude-qa-demo` and the pre-flight checklist assumes a
   public repo — flip visibility before the talk (`gh repo edit
   edcrove/claude-qa-demo --visibility public`, as edcrove).
2. **Final talk title** — candidates and constraints in `talk-design.md`.
3. **Timeline divergence** — deck slide "Mi línea de tiempo real" (months 1–6)
   vs `evolution-timeline.md` (weeks 1–7) tell different fictional stories.
   Acceptable or unify?
4. **`mocks/github/pr-7.diff`** is readable but not `git apply`-able. Fix or
   document as intentional?

## Suggested next steps

1. Full timed rehearsal: `./scripts/prep-demo.sh` → launch via
   `./scripts/demo-profile.sh` → run the six scenes from `runbook.md`.
2. Record the backup video during a good rehearsal run.
3. Decide the pending items above.
