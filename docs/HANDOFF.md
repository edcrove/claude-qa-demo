# HANDOFF — continue this work from a Claude chat

**Generated:** 2026-08-19 · regenerate whenever the state changes.
**Source of truth:** the repo. If this file disagrees with
[`STATUS.md`](STATUS.md), STATUS.md wins.

A claude.ai chat has no filesystem, so it cannot read this repo on its own.
This file is a **self-contained capsule**: everything needed to keep working on
the talk from a plain chat, in one attachable document.

## How to load the context into a chat

1. **Minimum:** attach or paste this file alone.
2. **To edit the deck:** also attach `slides/slides.md` (the artifact most
   sessions work on).
3. **Best:** connect the repo to a claude.ai Project via the GitHub integration
   (works while the repo is private) — then every doc is searchable and this
   file is just the entry point.

## Kickoff prompt (copy, adjust the goal, paste)

```text
Estoy preparando una charla de meetup: "Tu setup de QA no se diseña: se
cultiva" — de prompt suelto a skills, rules y hooks (30 min, audiencia técnica
mixta dev/QA). Te adjunto el documento de handoff con todo el estado; el repo
es github.com/edcrove/claude-qa-demo. Leé el handoff antes de responder.
Hoy quiero trabajar en: [OBJETIVO — p.ej. "cortar el deck para que entre en 30
minutos", "pulir la slide X", "preparar respuestas de Q&A"].
```

## What this is

A 30-minute meetup talk (~25 talk + demos, ~5 Q&A) whose thesis is: **a QA
automation setup is not designed up front — it is cultivated.** The mechanism
is the promotion pyramid: `prompt suelto → memory → skill → rule → hook`; a
correction repeated 3 times is a promotion waiting to happen. The companion
repo (this one) is public-ready, fully offline, and contains everything shown
on stage: a minimal TypeScript API, 6 skills, 3 rules, 1 hook, JSON mocks for
Jira/Jenkins/GitHub, a known-issues registry, the Marp deck, and the scripts
that reset and protect the live demo.

Subagents are deliberately **not** in the thesis equation. They are not a peer
of the pyramid's levels — they are what one particular skill
(`multi-agent-pr-review`) does inside itself. Listing them alongside
skills/rules/memory set up a second conceptual axis competing with the thesis,
which is what a critical review flagged as the deck's main structural weakness.

## Current state (2026-08-19)

- **Deck: 48 slides** — 32 main flow, 9 appendix (anatomy + real example of
  memory/skill/rule/hook), 6 Q&A backup (token costs and how they are actually
  measured, model churn, offline/stack portability, who audits the CI-triage
  classifier, and "lo que no entró en la charla"). Count verified against
  Marp's own section count, not eyeballed.
- **One source, four builds.** `./scripts/build-deck.sh` renders dark/light ×
  16:9/16:10, HTML + PDF, from `slides/slides.md` alone. **The four PDFs are
  versioned** so anyone cloning the repo can read the deck without Marp. All
  four verified at **0/48 slides overflowing** (Marp clips overflow silently;
  `scripts/check-slide-overflow.js` measures it in a real browser).
- **Visual pass done (2026-08-16/17):** 9 visuals, Ink Black palette,
  hand-written inline SVG where layout carries meaning and Mermaid
  pre-rendered to committed SVG where it does not. The demo slides stay
  imageless on purpose — that is where the terminal is shown.
- **Presentation-feedback pass done (2026-08-19).** Eleven items from the
  author's read-through. The two that change the text a chat might edit:
  the pain slide is now **first person** (its title is
  "Mi día como QA, antes de todo esto" since 2026-08-20, and its bullets moved
  to first person with it), and Demo 4's report slide now names
  **what each specialist found**
  instead of showing a per-axis tally — which let the following
  linter/SonarQube slide anchor its argument in something visible on screen
  (honest split: **2 of 5** findings are pattern-matchable, 3 have to be read).
- **Title decided and announced:** "Tu setup de QA no se diseña: se cultiva"
  — de prompt suelto a skills, rules y hooks. No longer a pending decision.
- **Accountability thread** planted at 4 points in the deck after author
  feedback that automation was being shown without ever stating what stays a
  human call. Delegation of *execution*, never of *accountability*.
- **Scene-by-scene rehearsal done (2026-08-19)** — the six demos were driven
  individually. **The full timed 30-minute run has not happened.** Three
  unfixed findings from it are in STATUS: subagent dispatch was not reliably
  *visibly* parallel (that is Demo 4's money shot), PostToolUse hooks do not
  fire in headless `-p` mode (so Demo 2 cannot be smoke-tested that way), and
  `mocks/github/pr-7.diff` is not `git apply`-able.
- **Work happens on `main`.** The `claude/estructura-revision-fwdb2c` topic
  branch was merged and deleted on 2026-08-19.

## The blocker that matters most

**THE TALK DOES NOT FIT IN 30 MINUTES.** A critical review estimated the live
path at **~43 min against a 25-min budget**: main-flow slides alone ~26 min
before running a single demo, plus ~17 min of demo wall clock once the agent
actually responding is counted (Demo 4 ≈ 5 min, Demo 2 ≈ 4 min). Even an
all-optimistic run lands at ~34 min.

Done so far: cut "Fuentes" and "El patrón", rewrote the 3 widening slides as
*notas al pasar*, merged the two subagent slides, merged the pyramid with
"Las 4 piezas". Still open, in the reviewer's ranked order:

1. **pre-record Demos 2 and 6** — biggest single win, ~270 s
2. cut "El flujo end-to-end"
3. compress the two opening pain slides into one

Target: **4 demos live, 2 pre-recorded, ~27 slides.** This is a cut decision
to make *before* the rehearsal, not during it — and it is the most useful thing
a chat session can help with, because it is pure narrative surgery.

## The deck's storytelling devices

1. **Cold open with a scar** (slide 2): the 90-minute phantom-flakes incident,
   before the bio. Pays off twice: it is the origin of the `no-parallel-ci`
   rule, and Demo 3 shows that rule preventing the same incident live.
2. **One pain as the spine:** the pyramid is told as a single story — the same
   forgotten typecheck climbing prompt → memory → skill → hook. Each level
   exists because the previous one was not enough.
3. **The demos are one clocked day** (9:00 → 17:00) with italic handoffs
   between scenes; Demo 5 triages the very branch the day produced.
4. **The "Mañana" mirror:** the pain slide ends *"Mañana — sesión nueva.
   Re-explico el ticket, el plan, las convenciones."*; Demo 6 quotes it back
   negated word for word. **Edit those two lines together** — the second one
   quotes the first verbatim, so a one-sided change breaks the callback
   silently (it already happened once, when the slide went first person).
5. **The agent loses on stage:** in Demo 3, Claude tries to trigger CI and the
   rule blocks it (a mock build is RUNNING on stage). Guardrails are shown
   catching the agent, not just the human.
6. **The question gets answered:** slide 4 asks *"¿Puedo automatizar mi
   proceso de QA con IA?"*; a callback slide answers it before the closing
   ("Sí — lo acabás de ver. ¿Se diseña? No. Se cultiva.").
7. **Cultivating goes beyond the agent's config:** the "El agente también
   construye" slide — the agent also builds *for the project* (CI tuned to
   your rules, linters, SonarQube, coverage, notifications). Don't fear the
   unknown: the cost of learning collapsed.
8. **Ownership doesn't cultivate away:** planted at 4 points — the subagent
   mechanics slide ("quien aprueba sigue siendo responsable de lo que
   aprueba"), Demo 4's aggregated result ("no sé, lo hizo la IA" no es una
   respuesta), a dedicated summary slide "Qué le toca a la persona" (agent
   vs. person table), and the closing thesis slide.

## The one-day demo arc (with the exact stage prompts)

| Time | Scene | Stage prompt | Skill / piece | Expected beat |
|------|-------|--------------|---------------|---------------|
| 9:00 | Demo 1 — coverage plan | `Planificá el trabajo para DEMO-100.` | `ticket-coverage-gap-analysis` | coverage map + gaps; leaves ❌ "malformed slug" open |
| 10:00 | Demo 2 — TDD on the gap | `Cerrá el gap del slug malformado con TDD.` | `superpowers:test-driven-development` | genuine red first, then green; typecheck hook fires on each edit |
| 11:30 | Demo 3 — rule blocks trigger | `Triggeá un build de Jenkins para esta branch.` | `local-build-gate` + `no-parallel-ci` | local gate green, then Claude finds build 43 RUNNING and **refuses** |
| 14:00 | Demo 4 — multi-agent review ⭐ | `Revisá el PR #7 — el diff está en mocks/github/pr-7.diff.` | `multi-agent-pr-review` + pr-review-toolkit | 5 subagents in parallel, one aggregated comment, 5 seeded bugs (one per specialist) |
| 15:00 | Demo 5 — CI triage | `Triajeá el build 44.` | `ci-failure-triage` + `memory/known-issues.md` | derives 2 flakes / 1 infra / 2 regressions from evidence (no hints in the JSON) |
| 16:00 | Demo 6 — correction → skill | `Esto ya te lo repetí 3 veces. ¿Lo convertimos en skill?` | `superpowers:writing-skills` | new SKILL.md; close with the "Mañana" mirror line |

Demo 6 needs setup: correct Claude with the same reminder ≥3 times during
Demos 1–5 — its stage prompt claims the repetition happened, so it has to have
happened, and it has to have come from the presenter. Every scene has a
screenshot/clip fallback (see `runbook.md`).

The 5 seeded bugs in `pr-7.diff`, one per specialist: swallowed catch
(`return []`), lying `as Channel` cast, a comment claiming "sorted by
relevance" over code that does not sort, a `toBeDefined()`-only test, and a
`// TODO` left in production code.

## Pending decisions (the author's)

1. **The timing cut** — see "the blocker that matters most" above.
2. **Repo is still PRIVATE on GitHub** — the slides print the URL and the
   pre-flight checklist assumes public. Flip before the talk
   (`gh repo edit edcrove/claude-qa-demo --visibility public`, as `edcrove`).
3. **`mocks/github/pr-7.diff`** is readable but not `git apply`-able (the
   test-file diff is nested inside the first hunk). More urgent than it looks:
   the talk invites cloning and this is the star demo's artifact.

## Next steps

1. Decide the timing cut, then a **full timed rehearsal** (reset with
   `prep-demo.sh`, launch with `demo-profile.sh`, drive the scenes from
   `runbook.md`).
2. Record the backup video during a good run.
3. Fix `pr-7.diff` and flip the repo public.

## What a chat can and cannot do

- **Can:** everything narrative — deck edits (produce replacement slide blocks
  the author pastes into `slides/slides.md`), the timing cut, Q&A prep, speaker
  notes, restructuring arguments.
- **Cannot:** run scripts, verify repo state, rehearse demos, render slides,
  or push. Those need a Claude Code session on the author's Mac — where the
  environment traps documented in `STATUS.md` apply (iCloud-evicted
  `node_modules`, dual git/gh identities requiring
  `gh auth switch -u edcrove`, isolated demo profile for stage).

## Repo map (when the repo is synced into a Project)

- `docs/` — `STATUS.md` (anchor, environment traps, pending decisions),
  `talk-design.md` (full design + slide map), `decision-log.md` (real
  history, newest entries in Spanish), `runbook.md` (per-scene stage script),
  `showable-inventory.md` (sanitized catalogue of the author's real work setup —
  **written to the audience, not to the presenter**: each row answers what pain
  the piece solves, and it closes on what to copy first), this file
- `slides/slides.md` — the whole deck (Marp, Spanish); `slides/themes/`,
  `slides/diagrams/`, `slides/img/` are its inputs; the four
  `slides-{dark,light}-{16x9,16x10}.pdf` are its versioned outputs
- `.claude/skills|rules/`, `.claude/settings.json` — the 6 skills, 3 rules,
  typecheck hook
- `memory/` — `MEMORY.md` index + known-issues registry + seed feedback memory
- `mocks/` — DEMO-100 ticket, builds 42/43/44, PR #7 diff
- `demo-app/` — the TypeScript API under test
- `scripts/` — stage safety (`prep-demo.sh`, `check-leaks.sh`,
  `demo-profile.sh`) and deck build (`build-deck.sh`, `build-diagrams.sh`,
  `build-logos.js`, `check-slide-overflow.js`)
- `evolution-timeline.md` — how the setup grew, week by week (the demo fiction
  the timeline slide must stay consistent with)
