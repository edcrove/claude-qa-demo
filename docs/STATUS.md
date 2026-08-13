# STATUS — start here to resume work

**Last updated:** 2026-08-13

This is the continuation anchor. A session with zero prior context should read,
in this order: this file → [`talk-design.md`](talk-design.md) (what the talk is)
→ [`decision-log.md`](decision-log.md) (why things are the way they are) →
[`runbook.md`](runbook.md) (how to drive the demos live).
Keep this file updated at the end of every working session.

**Continuing from a claude.ai chat (no filesystem):** attach or paste
[`HANDOFF.md`](HANDOFF.md) — a self-contained capsule of all of the above,
with a ready-made kickoff prompt. Regenerate it whenever the state changes.

## Where things stand

- **Repo + deck are rehearsal-ready.** All demo premises were audited and fixed
  on 2026-08-04 (see decision-log entry of that date). `./scripts/prep-demo.sh`
  passes all state assertions; `./scripts/check-leaks.sh` is clean; the deck
  renders (47 slides: 33 main / 9 appendix / 5 Q&A backup — count verified
  against Marp's own section count).
- **Title decided and announced:** "Tu setup de QA no se diseña: se cultiva"
  — de prompt suelto a skills, rules y hooks. Propagated across
  `slides/slides.md`, `CLAUDE.md`, `README.md`, `talk-design.md`, this file
  and `HANDOFF.md` (2026-08-13).
- **Everything is committed and pushed to origin**, working on branch
  `claude/estructura-revision-fwdb2c` (2026-08-13).
- **No rehearsal of the full 30-minute run has happened yet** with the current
  deck and fixed demos.

## Environment facts (non-derivable, will bite you)

| Fact | Detail |
|------|--------|
| Remote & push | `https://github.com/edcrove/claude-qa-demo.git` with two **repo-local** git configs (set 2026-08-04): a same-prefix `url.insteadOf` that defeats the global `~/.gitconfig` rule rewriting every GitHub HTTPS URL to SSH, and `credential.helper = !gh auth git-credential`. Pushing requires the personal account active in gh: `gh auth switch -u edcrove` |
| Why not SSH | Three stacked traps: (1) the global gitconfig rewrites HTTPS→SSH, (2) `~/.ssh/config` has `Host *` **before** the `github.com-personal` alias, so the work key is always offered first and GitHub authenticates as the work account, (3) the personal key on this machine is **not registered** on the GitHub account — the account's "Mac m1" key is a different key. To use SSH: register `~/.ssh/id_ed25519.pub` on the account and move `Host *` below the specific hosts |
| gh CLI | Two accounts configured. Run `gh auth switch -u edcrove` before any `gh` operation on this repo |
| iCloud eviction | The repo lives under `~/Documents` (iCloud-managed). `node_modules` files get evicted to `compressed,dataless` placeholders → typecheck/tests hang for minutes at 0% CPU. `prep-demo.sh` auto-detects and reinstalls. Details + measurements: decision-log §7 |
| Stage isolation | Never present from the day-to-day config. Launch via `./scripts/demo-profile.sh` (isolated `CLAUDE_CONFIG_DIR`, no global memory, no work MCPs). `check-leaks.sh` cannot see the global config — the profile is the only protection |
| jq | Required on PATH — the PostToolUse typecheck hook parses its stdin JSON with it |

## Pending decisions (the author's, not the agent's)

1. **The GitHub repo is still PRIVATE.** The slides print
   `github.com/edcrove/claude-qa-demo` and the pre-flight checklist assumes a
   public repo — flip visibility before the talk (`gh repo edit
   edcrove/claude-qa-demo --visibility public`, as edcrove).
2. **Timeline divergence** — deck slide "Mi línea de tiempo real" (months 1–6)
   vs `evolution-timeline.md` (weeks 1–7) tell different fictional stories.
   Acceptable or unify?
3. **`mocks/github/pr-7.diff`** is readable but not `git apply`-able. Fix or
   document as intentional?

## Suggested next steps

1. Full timed rehearsal: `./scripts/prep-demo.sh` → launch via
   `./scripts/demo-profile.sh` → run the six scenes from `runbook.md`.
2. Record the backup video during a good rehearsal run.
3. Decide the pending items above.
