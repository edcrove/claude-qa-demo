# HANDOFF — continue this work from a Claude chat

**Generated:** 2026-08-13 · regenerate whenever the state changes.
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
Hoy quiero trabajar en: [OBJETIVO — p.ej. "ensayar el timing", "pulir la
slide X", "preparar respuestas de Q&A"].
```

## What this is

A 30-minute meetup talk (~25 talk + demos, ~5 Q&A) whose thesis is: **a QA
automation setup is not designed up front — it is cultivated.** The mechanism
is the promotion pyramid: `prompt suelto → memory → skill → rule → hook`; a
correction repeated 3 times is a promotion waiting to happen. The companion
repo (this one) is public-ready, fully offline, and contains everything shown
on stage: a minimal TypeScript API, 5 skills, 3 rules, 1 hook, JSON mocks for
Jira/Jenkins/GitHub, a known-issues registry, the Marp deck, and the scripts
that reset and protect the live demo.

## Current state (2026-08-13)

- **Repo + deck are rehearsal-ready and pushed to origin.** All demo premises
  audited and fixed 2026-08-04; state assertions (`scripts/prep-demo.sh`) and
  leak check (`scripts/check-leaks.sh`) pass; deck renders.
- **Title decided and announced:** "Tu setup de QA no se diseña: se cultiva"
  — de prompt suelto a skills, rules y hooks. No longer a pending decision.
- **Deck: 46 slides** — 32 main flow, 9 appendix (anatomy + real example of
  memory/skill/rule/hook), 5 Q&A backup (token costs, model churn, offline,
  who audits the CI-triage classifier). Count verified against Marp's own
  section count, not eyeballed.
- **A human-vs-agent accountability thread was added** across 4 points in the
  deck (see storytelling device #8 below) after author feedback that
  automation was shown without ever stating what stays a human call.
- **A QA-conference-expert review pass** (dispatched as a subagent, twice —
  once general, once role-playing a Montevideo-based reviewer for register/
  tone fit) found and fixed: a Demo 2 line that contradicted the deck's own
  hook-vs-skill distinction, a redundant slide, an unanchored claims-heavy
  slide, a missing Q&A backup answer, and a near-duplicate MCP explanation
  across two consecutive slides.
- **No full timed rehearsal has happened yet** with the current deck.

## The deck's storytelling devices

1. **Cold open with a scar** (slide 2): the 90-minute phantom-flakes incident,
   before the bio. Pays off twice: it is the origin of the `no-parallel-ci`
   rule, and Demo 3 shows that rule preventing the same incident live.
2. **One pain as the spine:** the pyramid is told as a single story — the same
   forgotten typecheck climbing prompt → memory → skill → hook.
3. **The demos are one clocked day** (9:00 → 17:00, an 8-hour workday) with italic handoffs
   between scenes; Demo 5 triages the very branch the day produced.
4. **The "Mañana" mirror:** the pain slide ends *"Mañana — sesión nueva.
   Re-explicás el ticket, el plan, las convenciones."*; Demo 6 quotes it back
   negated word for word.
5. **The agent loses on stage:** in Demo 3, Claude tries to trigger CI and the
   rule blocks it (a mock build is RUNNING on stage).
6. **The question gets answered:** slide 4 asks *"¿Puedo automatizar mi
   proceso de QA con IA?"*; a callback slide answers it before the closing
   ("Sí — lo acabás de ver. ¿Se diseñó? No. Se cultivó.").
7. **Cultivating goes beyond the agent's config:** the "El agente también
   construye" slide — the agent also builds *for the project* (CI tuned to
   your rules, linters, SonarQube, coverage, notifications). Don't fear the
   unknown: the cost of learning collapsed.
8. **Ownership doesn't cultivate away:** planted at 4 points — the subagent
   mechanics slide ("quien aprueba sigue siendo responsable de lo que
   aprueba"), Demo 4's aggregated result ("no sé, lo hizo la IA" no es una
   respuesta"), a dedicated summary slide "Qué le toca a la persona" (agent
   vs. person table), and the closing thesis slide. Delegation of execution,
   never of accountability.

## The one-day demo arc (with the exact stage prompts)

| Time | Scene | Stage prompt | Skill / piece | Expected beat |
|------|-------|--------------|---------------|---------------|
| 9:00 | Demo 1 — coverage plan | `Planificá el trabajo para DEMO-100.` | `ticket-coverage-gap-analysis` | coverage map + gaps; leaves ❌ "malformed slug" open |
| 10:00 | Demo 2 — TDD on the gap | `Cerrá el gap del slug malformado con TDD.` | `superpowers:test-driven-development` | genuine red first (today the API returns `null`), then green; typecheck hook fires on each edit |
| 11:30 | Demo 3 — rule blocks trigger | `Triggeá un build de Jenkins para esta branch.` | `local-build-gate` + `no-parallel-ci` | local gate green, then Claude finds build 43 RUNNING and **refuses** |
| 14:00 | Demo 4 — multi-agent review ⭐ | `Revisá la PR #7 — el diff está en mocks/github/pr-7.diff.` | `multi-agent-pr-review` + pr-review-toolkit | 5 subagents in parallel, one aggregated comment, 5 seeded bugs (one per specialist) |
| 16:00 | Demo 5 — CI triage | `Triajeá el build 42.` | `ci-failure-triage` + `memory/known-issues.md` | derives 2 flakes / 1 infra / 2 regressions from evidence (no hints in the JSON) |
| 17:00 | Demo 6 — correction → skill | `Esto ya me lo recordaste 3 veces. ¿Lo convertimos en skill?` | `superpowers:writing-skills` | new SKILL.md; close with the "Mañana" mirror line |

Demo 6 needs setup: correct Claude with the same reminder ≥3 times during
Demos 1–5. Every scene has a screenshot/clip fallback (see `runbook.md`).

## Title — decided

**"Tu setup de QA no se diseña: se cultiva"** — de prompt suelto a skills,
rules y hooks. This is how the talk was publicly announced (2026-08-13); no
longer pending. It was the thesis-first candidate from the original
shortlist (2026-08-04); the working title
("De prompt a skill: cultivando workflows de QA automation con agentes de
Claude") is retired. The final subtitle drops the literal "Claude" mention
the original constraint wanted there — accepted, since the name still
appears within the first few main-flow slides and every demo.

## Pending decisions (the author's)

1. **Repo is still PRIVATE on GitHub** — slides print the URL and the
   pre-flight checklist assumes public. Flip before the talk.
2. **Timeline divergence:** deck's "Mi línea de tiempo real" (months 1–6) vs
   `evolution-timeline.md` (weeks 1–7) tell different fictional stories.
3. **`mocks/github/pr-7.diff`** is readable but not `git apply`-able.

## Next steps

1. Full timed rehearsal (reset with `prep-demo.sh`, launch with
   `demo-profile.sh`, drive the scenes from `runbook.md`).
2. Record the backup video during a good run.
3. Decide the pending items.

## What a chat can and cannot do

- **Can:** everything narrative — deck edits (produce replacement slide blocks
  the author pastes into `slides/slides.md`), title decision, Q&A prep, timing
  plans, speaker notes, restructuring arguments.
- **Cannot:** run scripts, verify repo state, rehearse demos, render slides,
  or push. Those need a Claude Code session on the author's Mac — where the
  environment traps documented in `STATUS.md` apply (iCloud-evicted
  `node_modules`, dual git/gh identities, isolated demo profile for stage).

## Repo map (when the repo is synced into a Project)

- `docs/` — `STATUS.md` (anchor, environment traps), `talk-design.md` (full
  design), `decision-log.md` (real history), `runbook.md` (per-scene script),
  this file
- `slides/slides.md` — the whole deck (Marp)
- `.claude/skills|rules/`, `.claude/settings.json` — the 5 skills, 3 rules,
  typecheck hook
- `mocks/` — DEMO-100 ticket, builds 42/43, PR #7 diff
- `memory/` — known-issues registry + seed feedback memory
- `demo-app/` — the TypeScript API under test
- `scripts/` — `prep-demo.sh`, `check-leaks.sh`, `demo-profile.sh`
