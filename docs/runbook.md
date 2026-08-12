# Live demo runbook

The exact prompts to type on stage, what should happen, what to watch for, and
the fallback if the model derails. One scene per demo slide; times match the
one-day arc in the deck.

## Before going on stage

```bash
./scripts/prep-demo.sh     # resets state, asserts every scene has work left
./scripts/demo-profile.sh  # launches Claude with the isolated config
```

Inside the session, run `/context` once and confirm **only the repo's
`CLAUDE.md`** is loaded (no global memory, no work MCPs). The profile starts on
a mid-tier model; switch up with `/model` before Demo 4 if desired.

During the session, deliberately correct Claude with variations of the same
reminder (e.g. *"acordate de chequear el registry antes de llamar a algo
regresión"*) at least **3 times** across Demos 1–5 — Demo 6 needs that setup.

## Demo 1 · 9:00 — Ticket → coverage plan

**Type:** `Planificá el trabajo para DEMO-100.`

**Expected:** invokes `ticket-coverage-gap-analysis` → reads
`mocks/jira/DEMO-100.json` → greps `demo-app/tests/` → replies with coverage
map (table), gaps (✅/⚠️/❌), TodoWrite + estimates.

**Watch for:** the ticket lists 4 acceptance criteria; only 2 are covered by
existing tests. The two ❌ must include **malformed slug rejection** — Demo 2
depends on it.

**Fallback:** screenshot of expected output; worst case, open the ticket JSON
and the test file side by side and narrate the gap.

## Demo 2 · 10:00 — TDD on the open gap

**Type:** `Cerrá el gap del slug malformado con TDD.`

**Expected:** invokes `superpowers:test-driven-development` → writes a failing
test first (malformed slug must be rejected — today `getChannelBySlug` returns
`null` for it) → shows the red → minimal implementation → green → optional
refactor.

**Watch for:** the PostToolUse hook firing typecheck after each `.ts` edit —
call it out ("nadie lo invocó, es el runtime"). The red must be genuine: if
Claude claims the test already passes, something restored state — abort to
fallback.

**Fallback:** pre-recorded clip of the red→green cycle.

## Demo 3 · 11:30 — The rule blocks the trigger

**Type:** `Triggeá un build de Jenkins para esta branch.`

**Expected:** `local-build-gate` runs typecheck + tests locally (fast, green) →
then `no-parallel-ci` makes Claude check `mocks/jenkins/` → finds
`build-43-running.json` with `"status": "RUNNING"` on stage → **refuses to
trigger**, offers to wait (~12 min estimate in the mock) or switch env.

**Watch for:** this is the "agent loses on stage" beat. The message is that
the rule catches *the agent*, not the human.

**Fallback:** open the mock and the rule side by side; narrate.

## Demo 4 · 14:00 — Multi-agent PR review ⭐

**Type:** `Revisá la PR #7 — el diff está en mocks/github/pr-7.diff.`

**Expected:** invokes `multi-agent-pr-review` → dispatches the 5
`pr-review-toolkit` subagents **in parallel in a single message** → aggregates
into one comment (Blockers / Suggestions / Nitpicks + per-axis details).

**Watch for:** the 5 seeded bugs, one per specialist: swallowed catch
(`return []`), lying `as Channel` cast, comment claiming "sorted" over unsorted
code, `toBeDefined()`-only test, `// TODO` left in production code. Parallel
dispatch must be visible in the UI — that is the money shot.

**Say out loud, don't just let the slide say it:** before posting the
aggregated comment, actually scroll through the per-axis details on stage —
this is the "lo leo entero antes de postearlo" beat. Land the line: *"si
alguien pregunta por qué se bloqueó el PR, la respuesta soy yo."* Skipping
this turns the scene into "the AI reviewed it," which is exactly the framing
the deck spends its close arguing against.

**Fallback:** pre-rendered aggregated review (this is the most
model-variable scene; have the screenshot ready) — narrate the same reading
beat over the screenshot instead of skipping it.

## Demo 5 · 17:00 — CI triage against the registry

**Type:** `Triajeá el build 42.`

**Expected:** invokes `ci-failure-triage` → reads `mocks/jenkins/build-42.json`
(5 unlabeled failures + the day's commits) and `memory/known-issues.md` →
classifies: 2 known flakes (timeout signatures match the registry), 1 infra
(connection refused to auth), 2 real regressions (not in registry, commits
touch related code) → one-line status per `status-format.mdc`
(`❌ build 42 — 280 passed / 5 failed (2 flakes)`) → offers registry update
via `known-issues-registry-update` (bump last-seen to build 42).

**Watch for:** the categories must be *derived* — the JSON carries no hints.
If asked to re-trigger, the `no-parallel-ci` rule still applies.

**Fallback:** walk the registry and the failures manually — the match is
visible to the naked eye (same signature strings).

## Demo 6 · 18:00 — Repeated correction becomes a skill

**Type:** `Esto ya me lo recordaste 3 veces. ¿Lo convertimos en skill?`

**Expected:** invokes `superpowers:writing-skills` (marketplace alternative:
`skill-creator`) → drafts a short `SKILL.md` from the repeated correction →
saves under `.claude/skills/<name>/SKILL.md`.

**Watch for:** requires the 3 staged corrections from earlier scenes. Close
with the mirror line: *"Mañana — sesión nueva. No se re-explica ni el ticket,
ni el plan, ni las convenciones."*

**Fallback:** show the diff of a pre-written skill file and narrate the
promotion.

## After (or between rehearsals)

```bash
git status              # rehearsal artifacts show up here
./scripts/prep-demo.sh  # WARNING: git-cleans untracked files — commit anything you want to keep FIRST
```
