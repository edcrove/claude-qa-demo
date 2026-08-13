# Decision log

The real (non-fictional) history of this repo, so future sessions — human or
agent — don't have to rediscover why things are the way they are.
`evolution-timeline.md` tells the *demo fiction* (the cultivated-setup story the
talk narrates); this file records the actual decisions.

## 2026-08-13 — Demo day shortened to an honest 8-hour workday

"6 escenas · 9:00 → 18:00" is a 9-hour span, not 8, and the slide claimed an
8-hour workday. First pass moved Demo 5 to 16:00 and Demo 6 to 17:00 — still
wrong, since the workday *ends* at 17:00, so nothing can *start* then.
Final: Demo 5 at 15:00, Demo 6 at 16:00, leaving a wrap-up hour before the
stated 17:00 end. Demo 1–4 times unchanged. Propagated to
`slides/slides.md` (Demo 5/6 slide headers + the "Ahora, en vivo" intro),
`docs/runbook.md`, `docs/talk-design.md`'s one-day arc table, and
`docs/HANDOFF.md`.

## 2026-05-14 — Repo scaffolded

Built in a single Claude Code session from a written design + implementation
plan (20 commits between 21:29 and 22:03): demo app (`getChannelBySlug` via
TDD), 5 skills, 3 rules, 1 PostToolUse hook, mocks (Jira ticket, Jenkins build,
PR diff), memory seed, skill templates, evolution timeline, scripts, and a
3-slide Marp deck. The originating conversation transcripts were later pruned
by Claude Code's ~30-day retention; the design/plan documents survive in the
author's private notes. This log is the durable record.

## 2026-06-11/12 — Deck expansion

3 → 35 slides across several storytelling passes: real-journey framing, pain ↔
demo traceability (`↩ Resuelve:` lines), origin parity between downloaded and
distilled pieces, "QA automation" scoping in the title. Rules moved from
`.cursor/` to `.claude/`.

## 2026-08-04 — Pre-rehearsal audit and overhaul

A full audit of repo + deck found several broken demo premises. Fixes, in
order of impact:

1. **Demo 2 had nothing to implement.** `getChannelBySlug` already existed with
   green tests, and `prep-demo.sh` *restored* it. Retargeted the scene to the
   gap Demo 1 discovers: DEMO-100 requires malformed slugs to be **rejected**,
   and today they return `null`. Verified the red is genuine (a rejection test
   fails against current code).
2. **Demo 5 was circular.** `build-42.json` shipped a `category_hint` per
   failure (the triage could just read the label) and the known-issues registry
   the skill referenced did not exist under any of its three names. Created
   `memory/known-issues.md` (two timeout flakes that match build 42, one entry
   that doesn't — so discrimination is real), removed the hints, added
   `branch` + `commits` as evidence, and gave `ci-failure-triage` an explicit
   precedence order (registry match beats the timeout-is-infra heuristic).
3. **The typecheck hook never fired.** It tested `$CLAUDE_TOOL_FILE_PATH`,
   which Claude Code does not set — the condition was always false, a silent
   no-op (the worst failure mode for a slide claiming hooks "always run").
   Rewritten to parse the file path from the stdin event JSON with `jq`,
   matcher widened to `Edit|Write|MultiEdit`. Verified with 5 simulated
   events, including one that must surface a type error and does.
4. **Demo 6 referenced a disabled plugin.** Switched to
   `superpowers:writing-skills`; `skill-creator` stays as the marketplace
   alternative.
5. **The real leak surface is the global config, not the repo.**
   `check-leaks.sh` can only grep this repo; the projector also shows the
   global CLAUDE.md, work MCP server names, and other projects' paths. Added
   `scripts/demo-profile.sh` (launches Claude Code with `CLAUDE_CONFIG_DIR`
   pointing at a throwaway profile: no global memory, no work MCPs, plugins
   symlinked in). `check-leaks.sh` now also greps untracked files.
6. **Rehearsal state is now asserted, not assumed.** `prep-demo.sh` checks the
   initial-state contract each scene depends on (Demo 2 gap open, build 43
   RUNNING for Demo 3, registry present, mock unhinted, `jq` on PATH) and
   fails loudly if the repo isn't rehearsal-ready. The contract is documented
   in the README.
7. **iCloud Drive silently breaks the demo.** `~/Documents` is iCloud-managed;
   it evicts `node_modules` files into `compressed,dataless` placeholders.
   Measured cost: 4–15 s per cold read (1234 files) — `tsc` appears to hang at
   0% CPU; a vitest run took 440 s and died. `npm install` over an existing
   tree does **not** rematerialize; `brctl download` was unreliable
   (789/1234 still dataless after ~20 min). Fix: fresh reinstall (2 s).
   `prep-demo.sh` now detects dataless files and reinstalls automatically.
   Long-term recommendation: keep working clones outside `~/Documents`.
8. **Deck restructured for time and story** (35 → 45 slides, but the main flow
   *before the first demo* dropped from 23 to 17): anatomy slides moved to an
   appendix; cold-open scar; the pyramid retold as the single typecheck story;
   demos clocked as one day with handoffs; the "Mañana" mirror; the agent
   blocked by a rule on stage (new mock `build-43-running.json`); the question
   slide answered before closing; new slide "El agente también construye"
   (cultivating includes what the agent builds *for the project*: CI tuning,
   linters, quality gates, coverage, notifications — don't fear the unknown);
   "3 pasos para el lunes" closing; 3 Q&A backup slides.
9. **MIT LICENSE added** (the README already declared it).

## 2026-08-13 — Human ownership made explicit in the deck

Author feedback while reviewing slides: the deck showed the automation
baseline (pattern, 6 demos, subagent review) but never closed the loop on
what stays human vs what the agent executes — no final statement on decision
authority. Chose to elevate an existing buried line (`El peer review queda
libre para arquitectura...`) into a recurring 3-point thread instead of a
dedicated slide: (1) mechanics slide "Subagentes en paralelo" — approval
still means responsibility; (2) Demo 4 (2/2) aggregated result — reading the
output critically before posting, "no sé, lo hizo la IA" is not a valid
answer; (3) closing thesis slide — criterio, dominio and firma stay the
speaker's. Documented as narrative device #8 in `talk-design.md`. Runbook's
Demo 4 section updated so the beat is actually performed live (reading the
aggregated review on stage before posting), not just projected as slide text.

**2026-08-13 (later same day):** author reported the recurring one-liners
were too easy to miss skimming the deck on a phone, and asked for an
explicit summary. Added a dedicated slide "Qué le toca a la persona" (agent
vs. person table — execution/criterio/revisión/decisión/responsabilidad)
right after "El patrón" and before the closing callback question. Deck is
now 46 slides (33 main flow, was 32). `talk-design.md` slide map and device
#8 updated to match.

## 2026-08-13 (later still) — QA-reviewer pass applied

Dispatched a subagent role-playing an expert QA-conference reviewer against
the full deck + runbook + decision log. Applied its findings, plus one item
the author caught independently (MCPs explained near-identically on two
consecutive slides):

- **Demo 2 wording fixed.** "El skill **fuerza** el orden. No te deja saltar
  el red" contradicted the deck's own hook-vs-skill distinction (a skill is
  model-followed, not enforced — only the hook is deterministic). Changed to
  "El skill guía el orden — y hoy lo respetó." `runbook.md`'s Demo 2 watch-for
  now tells the speaker to narrate an implementation-before-test moment as
  "followed, not enforced" if it happens live, instead of treating it as an
  abort condition.
- **MCP duplication removed.** "Cuando empezó la IA: dos pasos" repeated the
  same 4 MCPs with the same one-line descriptions as the very next "MCPs" table
  slide. Step 2 now names the 4 MCPs in one line and defers detail to the
  next slide.
- **Pacing: cut "Los workflows que emergieron."** Redundant with "El flujo
  end-to-end" (same skills, already shown as a pipeline diagram right before
  the demos). Pre-Demo-1 slide count drops from 18 to 17. Deeper pacing
  restructuring (subagent mechanics run two slides before any subagent demo)
  is still open if a future pass wants to go further.
- **"El agente también construye" trimmed from 5 bullets to 3** and anchored
  to something the audience already saw live (the typecheck hook), per the
  reviewer's read that an unanchored claims-only slide right after 6 verified
  demos risks reading as hype.
- **New Q&A backup slide: "¿Quién audita al clasificador de CI?"** — the
  reviewer flagged this as the one skeptical question a QA audience would
  ask that had no prepared answer. Ties back to the ownership thread (agent
  proposes, person confirms).
- **Callback made explicit.** "Qué le toca a la persona"'s closing line now
  says "mismo criterio que en la Demo 4" instead of silently repeating the
  Demo-4 wording near-verbatim.
- **De-duplicated "todo el contexto en tu cabeza"**, which appeared on two
  consecutive slides ("Mi setup antes de IA" → "Tu día como QA, hoy").

Deck stays at 46 slides (32 main / 9 appendix / 5 Q&A backup) — counts
verified against Marp's own section count, not eyeballed, after the last two
sessions' numbers turned out to be off.

## 2026-08-13 — Final title decided and announced

The talk was publicly announced as **"Tu setup de QA no se diseña: se
cultiva"** — de prompt suelto a skills, rules y hooks (the author shared the
actual meetup listing). This was one of the candidates already sitting in
`talk-design.md` since 2026-08-04. Resolves pending decision #2 from
`STATUS.md`. Propagated everywhere the old working title
("De prompt a skill: cultivando workflows de QA automation con agentes de
Claude") appeared: `slides/slides.md` title slide, `CLAUDE.md`, `README.md`,
`docs/talk-design.md` (title field + candidates table, now marked with an
outcome column), `docs/STATUS.md`, `docs/HANDOFF.md`.

One tradeoff accepted knowingly: the final subtitle ("De prompt suelto a
skills, rules y hooks") drops the literal "Claude" mention the original
title constraint wanted in the subtitle slot. Not re-opening the decision
over it — the name still appears within the first few main-flow slides and
throughout every demo.

Also fixed while touching these files: three decision-log entries from this
same working session were mis-dated 2026-08-12 instead of 2026-08-13 —
corrected, since this file's whole purpose is being the accurate history.

## 2026-08-13 — Added the linter/SonarQube comparison slide

Author, mid slide-by-slide pass: wanted Demo 4's aggregated-review slide
followed by an explicit comparison against non-agentic static analysis
(SonarQube, linters) — the technical differentiator question a QA/dev
audience would naturally ask right at that moment, and the deck didn't
answer it anywhere. New slide "¿Y esto no lo hacía ya un linter?" inserted
right after Demo 4 (2/2), before Demo 5: a table contrasting what static
tools catch (fixed patterns) against what a subagent catches (semantic
mismatches — a comment lying about sorting, a `catch` block silencing an
error), closing on "no compiten" — SonarQube keeps running deterministically
in CI, the subagent covers what requires reading, not matching. The
existing handoff line to Demo 5 moved from the end of Demo 4 (2/2) to the
end of this new slide. Deck: 46 → 47 slides (33 main flow, was 32).

## 2026-08-13 — Added the triage-capability slide

Same request, continuing the slide-by-slide pass: the live Demo 5 only
shows 3-category classification against the known-issues registry, but the
real `ci-failure-triage` pattern does more — reads full logs (not just the
build summary), groups related failures, and gives a first-pass root-cause
read. Too much to fold into the dense Demo 5 slide, so it became its own
slide, "El triage no termina en la categoría", right after Demo 5, with the
existing handoff line to Demo 6 moved to its end. Deck: 47 → 48 slides (34
main flow, was 33).

## 2026-08-13 — Added the conversation-mining slide

Same slide-by-slide pass: Demo 6 only promotes a repeated correction to a
skill because the human explicitly counted 3 occurrences and asked. Author
wanted it clarified that this doesn't require a human to keep count — you
can ask Claude to scan past conversations directly ("Revisá las
conversaciones últimas y decime qué skills hay que crear o actualizar").
Added as its own slide, "No hace falta que te acuerdes vos", right after
Demo 6 — folding it into Demo 6 itself would have blunted that slide's
closing beat (the "Mañana" mirror payoff). Deck: 48 → 49 slides (35 main
flow, was 34).

## 2026-08-13 — Timeline divergence resolved: slide now matches evolution-timeline.md

The deck's "Mi línea de tiempo real" and `evolution-timeline.md` told two
different fictional histories — different time scale (months 1–6 vs. weeks
1–7) and, worse, **different artifacts**. The slide invented two skills that
don't exist anywhere in the repo ("AC-vs-branch-diff", "pre-peer-review")
and never mentioned three that do (`local-build-gate`,
`known-issues-registry-update`, the `english-only` rule) — a real
credibility risk given the talk repeatedly invites the audience to clone
and read this repo. Rewrote the slide to tell exactly
`evolution-timeline.md`'s week-by-week story (same 7 weeks, same triggers,
same artifact names), condensed to one line per entry. `evolution-timeline.md`
itself wasn't touched — it's the source of truth now; the slide was the one
that had drifted.

## 2026-08-13 — Stretched the timeline to ~4 months

Author felt weeks 1–7 read too compressed. Spread the same 11 milestones
further apart — same weeks-as-unit (kept, per author's choice), same
triggers, same artifacts — now weeks 1, 1, 3, 3, 6, 6, 9, 11, 13, 16
(~4 months). Updated both `evolution-timeline.md` (the source of truth,
week headers only) and the slide, keeping them in lockstep so the
divergence fixed earlier doesn't reopen.

### Known open items

- `mocks/github/pr-7.diff` is readable but not `git apply`-able (the test-file
  diff is nested inside the first hunk). Fine for the demo, broken for anyone
  who tries to apply it.
