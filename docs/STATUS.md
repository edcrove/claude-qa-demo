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
- **Everything is committed on local `main`.** Nothing is stashed or untracked.
- **Local `main` is ahead of `origin/main` and has NOT been pushed.** The push
  is pending the author's explicit approval (public repo). Origin last has the
  2026-06-12 deck.
- **No rehearsal of the full 30-minute run has happened yet** with the current
  deck and fixed demos.

## Environment facts (non-derivable, will bite you)

| Fact | Detail |
|------|--------|
| Remote | `ssh://git@github.com/edcrove/claude-qa-demo.git` — the author's **personal** account; commits as `edcrove@gmail.com` |
| gh CLI | The *active* `gh` account is the work account. `git push` is unaffected (SSH), but run `gh auth switch -u edcrove` before any `gh` operation on this repo |
| iCloud eviction | The repo lives under `~/Documents` (iCloud-managed). `node_modules` files get evicted to `compressed,dataless` placeholders → typecheck/tests hang for minutes at 0% CPU. `prep-demo.sh` auto-detects and reinstalls. Details + measurements: decision-log §7 |
| Stage isolation | Never present from the day-to-day config. Launch via `./scripts/demo-profile.sh` (isolated `CLAUDE_CONFIG_DIR`, no global memory, no work MCPs). `check-leaks.sh` cannot see the global config — the profile is the only protection |
| jq | Required on PATH — the PostToolUse typecheck hook parses its stdin JSON with it |

## Pending decisions (the author's, not the agent's)

1. **Push the local commits to origin** — approved? Not yet.
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
3. Decide the pending items above; push when approved.
