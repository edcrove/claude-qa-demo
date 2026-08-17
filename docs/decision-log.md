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

## 2026-08-13 — Critical-review blockers: the repo contradicted the deck

A third reviewer pass (subagent, maximally-critical brief) found three claims
the deck makes that **the repo itself refuted** — the sharpest possible
failure mode, since the talk invites the audience to clone it four times.

1. **`CLAUDE.md` `@`-imported all 5 `SKILL.md` files**, so every skill was
   always in context — exactly what the pyramid slide defines as the property
   that separates a *rule* from a *skill*. Worse, `runbook.md` tells the
   speaker to run `/context` on stage, which would have displayed the
   contradiction live. All 5 have `description` frontmatter, so Claude Code
   discovers them on demand with no import needed: removed the imports,
   replaced with a prose list plus an explicit note on *why* they are not
   imported. `/context` is now an asset that demonstrates the distinction —
   the runbook says so.
2. **The `memory/` escalón was decorative.** Nothing imported it: the
   feedback memory was loaded by nobody, while the appendix slide claimed
   "Persiste entre sesiones. Sobrevive al `/clear`." Now `CLAUDE.md` imports
   `memory/MEMORY.md`, which in turn `@`-imports the feedback memory.
   `known-issues.md` stays deliberately on-demand (it grows per flake; the
   triage skill reads it) and `MEMORY.md` explains that split. Also renamed
   `feedback_local_build_before_ci.md` → `feedback-local-build-before-ci.md`
   to match its own `name:` field and the slide that cites it.
3. **The demo day was chronologically impossible.** Demo 3 (11:30) showed
   "build 43 RUNNING" from a mock that said it started at 14:22; Demo 5
   (15:00) then triaged build **42** — numbered *before* the build that was
   still running, and timestamped 19:47, after everything. The slide claims
   "es la misma branch de hoy" while the mock's failures pointed at
   `src/main/java/com/acme/**`, not the TypeScript the audience just watched
   change. Fixed: build 43 now starts 11:20 (RUNNING at 11:30, as Demo 3
   needs); `build-42.json` → `build-44.json`, running 11:35→12:18 on today's
   branch — after 43, before the 15:00 triage. Failures and commits now point
   at `demo-app/`, and the first failure is
   `GET /api/v1/channels/:slug > returns the channel for a known slug` at
   `demo-app/tests/api.test.ts:7` — a **real** test at a **real** line, the
   genre assertion, so the "misma branch de hoy" claim survives a clone and a
   grep. `memory/known-issues.md` renamed its entries to the matching vitest
   names/signatures; verified mechanically that 2 registry entries match the
   build and the third does not, so the discrimination Demo 5 depends on is
   real. `status-format.mdc`'s examples used builds 42/43, colliding with the
   demo's live numbers — moved to 51/52.

Also fixed from the same review: the Q&A slide claimed the registry "lo
actualiza una persona", contradicting `ci-failure-triage` step 4, which
invokes `known-issues-registry-update`. Reworded to "lo propone el agente y lo
confirmás vos antes de commitear" — true, and it closes on the ownership
thread instead of against it.

Still open from that review and **not** addressed here: the talk is ~18
minutes over budget (see STATUS.md), the deck carries two competing
conceptual axes (pyramid vs. subagents), the linter/SonarQube table
strawmans static analysis on the `catch` row, and the 3 "widening" slides
are candidates to move to the appendix.

## 2026-08-13 — Conceptual fixes: one axis, and a pyramid that admits it isn't a ladder

Second round from the critical review, addressing the structural findings
rather than the factual ones. Deliberately done **before** the timing cut, so
the cut is decided against a structure that already holds together.

1. **The two competing axes are gone.** The reviewer's sharpest finding: the
   deck presented the pyramid (artifacts that persist in files) *and*
   subagents (in-session parallelism) as two co-equal "big ideas", with the
   star demo belonging to the axis that was **not** the thesis. The root was
   the thesis statement itself — "Skills + Rules + Memory + **Subagentes** =
   workflow reproducible" — which listed subagents as a peer of the pyramid's
   levels (and, oddly, omitted hooks). Fixes: the closing equation is now
   "Memory + Skills + Rules + Hooks", exactly the pyramid's artifacts; the
   slide "Subagentes — qué son" became **"Un skill no siempre ejecuta: a
   veces delega"**, framing subagents as what `multi-agent-pr-review` (a
   plain `SKILL.md` in this repo) does *inside itself*; "Subagentes en
   paralelo" became **"El skill por dentro"**. This is not a rhetorical
   dodge — it is what the repo actually does, and it puts Demo 4 back on the
   thesis's axis. It also removes the seam the old slide papered over with an
   explicit "hasta acá vimos el setup, ahora el motor" transition.
2. **The pyramid stops pretending to be a ladder.** The typecheck story goes
   prompt → memory → skill → hook and **skips RULE**, which the deck
   previously left as an unexplained gap. Now stated outright, and turned
   into the argument instead of a hole: a rule would have *reminded* him, and
   the whole problem was that being reminded wasn't enough — so it had to
   become deterministic. "No es una escalera que subís entera: es un menú, y
   cada dolor entra por donde le corresponde."
3. **Fixed a three-way contradiction about that same rule.** The appendix
   Hook slides claimed the hook was born "teniendo la memory y la rule" —
   but no typecheck rule exists in `.claude/rules/` (only `english-only`,
   `no-parallel-ci`, `status-format`), *and* the main "Las 4 piezas" table
   shows the story skipping rule. Corrected to "memory y skill", which is
   what actually happened and what the repo shows.
4. **The linter/SonarQube table no longer strawmans static analysis.** The
   `catch (e) { return [] }` row claimed a linter "puede no marcarlo" — the
   one example where static analysis is strongest. Rewritten to *cite the
   real rule* (`S2486`) and move the distinction to consequence vs. shape:
   the linter flags the pattern, the subagent says why that `[]` is
   indistinguishable from "no hay canales". Also dropped the claim that
   SonarQube is "gratis" (Developer/Enterprise are paid) in favour of "costo
   fijo, sin costo por corrida", and added the `toBeDefined()` row, where
   static analysis genuinely cannot judge test strength. Citing the tool
   accurately buys more credibility with this audience than overclaiming.

## 2026-08-13 — Cut "Fuentes" and "El patrón"

First two cuts of the timing pass, both pure redundancy removal rather than
sacrifice — chosen by the author from the reviewer's ranked list.

- **"Fuentes"** was a reference list the audience cannot act on while sitting
  in a meetup, and every item on it already lives in `SOURCES.md`, which the
  closing slide's repo URL points at. Its one element that existed nowhere
  else — the disclaimer about public plugins/MCPs being used only when
  trusted and org-approved — moved into **step 4 of "4 pasos para el lunes"**,
  which is the slide that actually tells people to install them, and into
  `SOURCES.md` as a blockquote at the top.
- **"El patrón"** was the deck's *third* statement of the same five levels,
  after "La pirámide de promoción" (which states them with the funnel nuance)
  and "Las 4 piezas" (which states them as a story). The closing slide still
  carries the pattern as an equation — "Memory + Skills + Rules + Hooks" —
  so nothing is lost but the repetition.

Deck: 49 → 47 slides (33 main flow, was 35). ~95 s recovered. The timing gap
is still the top open item; the remaining prescription is tracked as a
checklist in `STATUS.md`.

## 2026-08-13 — The 3 widening slides became passing notes

The reviewer wanted all three moved out of the main flow; the author kept
them but had them rewritten as **notas al pasar** — short enough to say while
moving, instead of full arguments. That addresses the reviewer's actual
complaint (a register change to brochure right after six evidence-heavy
scenes) without losing the content.

- **"¿Y esto no lo hacía ya un linter?"** — lost its 5-row comparison table.
  Now three sentences that still cite `S2486` by name and still land "el
  linter matchea patrones, el subagente lee. Van juntos." Roughly 60 s → 20 s.
- **"El triage no termina en la categoría"** — 3 bullets + closing collapsed
  into one sentence that keeps the honest framing ("son 5 fallas para que
  entren en pantalla") and the three capabilities.
- **"No hace falta que te acuerdes vos"** → **"Y no siempre tenés que contar
  vos".** This one needed more than trimming: the reviewer's sharpest point
  was that it *deactivated Demo 6 retroactively* — the audience had just felt
  the moment of counting to 3, and the next slide said counting wasn't
  necessary. Rewritten to extend instead of negate: "Hoy conté hasta 3 porque
  me acordaba. Cuando no te acordás, se lo preguntás… El patrón es el mismo —
  cambia quién lo detecta." Demo 6's mirror payoff survives intact.

## 2026-08-13 — Two merges: the pyramid absorbs its story, the subagents become one slide

Continuing the timing pass. Both merges turned out better than the originals,
not just shorter.

- **"La pirámide de promoción" + "Las 4 piezas — una sola historia" → one
  slide.** They were the same content at two altitudes: an abstract ladder,
  then a table telling the typecheck story through that ladder. Merged by
  filling each pyramid level with its own real example inline — `HOOK ◀
  typecheck en cada edit`, `SKILL ◀ local-build-gate`, `MEMORY ◀
  feedback-local-build-before-ci`, `PROMPT SUELTO ◀ "acordate del typecheck
  antes de CI"`. The deck's own "one pain as the spine" device now happens
  *inside the diagram* instead of being asserted next to it, and the
  skips-the-Rule insight and the `no-parallel-ci` scar both survive below it.
- **"Un skill no siempre ejecuta: a veces delega" + "El skill por dentro" →
  one slide.** Natural after the earlier reframe made them a single idea. The
  bullet list ("no ve tu historial", "se despachan en paralelo") was mostly
  redundant with what the ASCII diagram already shows — the diagram literally
  labels `◀ despacho paralelo` and `5 contextos aislados` — so it collapsed
  into two sentences above the diagram. The peer-review payoff and the
  ownership line are unchanged.

Deck: 47 → 45 slides (31 main flow, was 33). Remaining on the timing
checklist: pre-record Demos 2 and 6 (the biggest single win), cut "El flujo
end-to-end", compress the two opening pain slides.

## 2026-08-13 — Deck restyled, and 13 slides were being clipped

Author reported slides rendering "out of bounds". Measured rather than
eyeballed: rendered the deck and walked every `<section>` in a real browser
comparing content height against the frame. **13 of 45 slides overflowed**,
the worst by 341 px — "Qué le toca a la persona" was using 961 px of a 620 px
box, so roughly its bottom third was being clipped on the projector and
nobody would have noticed until the talk.

Fixed together with a restyle, since both live in the same `style:` block:

- **Visual identity.** The old look was stock gaia-inverted. New design leans
  on what the talk is actually about — plain text on disk: a left gutter rail
  with an accent tab (like an editor's line-number column), `#` prefixed
  headings in monospace (markdown flavour), code blocks styled as editor
  panes with a rounded border, and a teal secondary accent against the
  existing Claude orange.
- **Tables became rules instead of boxes** — uppercase letter-spaced headers
  on a hairline, no cell borders, no zebra striping. This is where most of
  the vertical space came back. Note gaia fights this: its own `th`/`tr`
  background and border rules needed `!important` overrides, which is why
  those declarations look heavy-handed.
- **Tighter vertical rhythm** — line-height, heading margins and code
  line-height all trimmed, without shrinking the base font (24px), which
  would have hurt readability from the back of a room.
- **`<!-- _class: dense -->`** as an opt-in escape hatch for the two slides
  that still did not fit; better than shrinking the whole deck for two
  outliers.

Result: **0 of 45 slides overflow.** Added `scripts/check-slide-overflow.js`
so this cannot regress silently, and put it in the pre-flight checklist. It
needs playwright and exits non-zero when something is clipped.

## 2026-08-16 — Diagrams: vector, and Mermaid only where it earns it

The three ASCII diagrams became vector. Two different mechanisms, on purpose:

- **Mermaid → static SVG at build time** for the `multi-agent-pr-review`
  fan-out. It is a plain node-and-edge graph, which is exactly what Mermaid
  is good at, and the source (`slides/diagrams/subagentes.mmd`) is eleven
  readable lines — adding a sixth subagent is one line, not a coordinate
  rewrite. Rendered by `scripts/build-diagrams.sh` (`@mermaid-js/mermaid-cli`)
  and **committed as `.svg`**, so building the deck never needs Mermaid and
  nothing is fetched at present time. Browser-side Mermaid was rejected for
  the same reason the emoji are a problem: a CDN the room's Wi-Fi can break.
- **Hand-written inline SVG** stays for the pyramid and the end-to-end flow.
  Mermaid has no pyramid chart, and the pyramid's argument *is* its visual
  grammar — the dashed, dimmed RULE tier is the point of the slide. The flow
  is a two-row stage/piece grid, not a graph. Forcing either into Mermaid
  would cost control and buy nothing.

Rule of thumb this leaves behind: Mermaid when the diagram is a graph,
hand-written SVG when the layout carries meaning.

Two things fell out of the change:

- The Mermaid default (`<br/>` inside every node label) made two-line boxes
  and pushed slide 13's closing line off the bottom. Fixed at the source —
  single-line labels, tighter `nodeSpacing`/`rankSpacing` — not by shrinking
  the image, which would have shrunk the text with it.
- **`check-slide-overflow.js` had been lying.** Exported to `/tmp`, the
  relative `diagrams/*.svg` path did not resolve; a broken `<img>` measures
  0px tall, so it reported "every slide fits" for a slide that was clipping.
  The script now fails on any local image that did not load, and separately
  *warns* on remote ones — which is how the twemoji CDN dependency shows up
  on every run instead of only when the room has no Wi-Fi.

## 2026-08-16 — Seis visuales más, y por qué no más que seis

El deck tenía 45 slides y 3 visuales, todos apiñados en el bloque de mecánica
(slides 12-14). Todo lo demás era tipografía. Lo que se agregó:

- **Cold open (2)** — dos builds en <span>rojo</span> colgando de un solo
  ambiente. Es la imagen que abre la charla y el incidente que la origina;
  ahora se ve antes de contarlo.
- **"Mi setup antes de IA" (5)** — el pipeline ASCII pasó a Mermaid, con la
  flecha punteada de vuelta al ticket. El ciclo era lo que la lista no decía.
- **"Cómo Claude conoce mi proyecto" (10)** — el árbol ASCII pasó a Mermaid.
  Es una jerarquía: global → repo → piezas.
- **"Ahora, en vivo" (15)** — una franja horaria de 9:00 a 17:00 con las 6
  escenas ubicadas. Orienta antes de seis demos seguidos, y el hueco del
  almuerzo hace que se lea como una jornada y no como una lista.
- **"Demo 4 (2/2)" (20)** — el bloque de código pasó a tener la forma de un
  comentario de GitHub. Es lo que la slide siempre estuvo mostrando.
- **"Mi línea de tiempo real" (26)** — 12 líneas de monospace a .58em (casi
  ilegibles desde el fondo) pasaron a una espina vertical con el color del
  punto codificando el nivel de la pirámide. El *dolor* de cada pieza se
  mantiene: era el contenido, no el adorno.

Dónde **no** se puso imagen, a propósito:

- **Las 6 slides de demo.** Durante la charla se sale del deck y se muestra la
  terminal. Una imagen ahí compite con lo que se está por mostrar. Si se
  pre-graban las Demos 2 y 6, el video reemplaza a la terminal, no a la slide.
- **"MCPs — los puentes"** — un hub-and-spoke sería la forma correcta, pero
  cae tres slides antes del fan-out de subagentes y las dos figuras se verían
  iguales. La tabla dice lo mismo sin repetir la imagen.
- **"Qué le toca a la persona"** — es una comparación de dos columnas. La
  tabla ya es la forma correcta.
- **El apéndice** — son anatomías de archivos; el bloque de código es el punto.

Se agregó un placeholder para la **foto del autor** en "Quién soy" (slide 3),
lo único que no se podía generar acá. **El autor decidió no poner foto**
(2026-08-16): el placeholder y su CSS se sacaron, y la slide queda tipográfica.

**Trampa encontrada:** una línea en blanco dentro de un `<svg>` en línea corta
el bloque HTML de markdown, y Marp cierra el `<svg>` ahí. Los `<text>` que
siguen se emiten como HTML suelto y el navegador los muestra como texto
corrido — el diagrama se desarma sin ningún error. Los SVG del deck no llevan
líneas en blanco por eso.

## 2026-08-16 — The deck is actually offline now

Marp rewrites every unicode emoji into an `<img>` against the twemoji CDN. A
contact sheet of all 45 slides made the cost obvious in a way that looking at
slides one at a time had not: with no network, that is **8 broken-image icons
scattered across 5 slides**, including the MCP table and three demo slides —
while the *Ahora, en vivo* slide promises "todo offline".

Fixed with `options: { emoji: { unicode: false } }` in `marp.config.js`. The
emoji now render as glyphs from the system emoji font: same look, zero network.
Verified by counting CDN URLs in the exported HTML — **12 before, 0 after** —
and `check-slide-overflow.js` now runs with no warnings at all.

### Note on tooling, not on the deck

`npx @marp-team/marp-cli@latest` re-resolves the package against the registry
on every invocation, and through this environment's proxy that intermittently
stalls for minutes — long enough to look like the render itself had hung. It
also briefly produced a false conclusion (that the emoji option was what hung
the build; it was not — the same command runs in 0.6 s). Installing marp-cli
once and calling the local binary takes the full 45-slide PNG export from
"times out" to **5.5 s**. Worth doing before a rehearsal.

## 2026-08-16 — Real logos in the MCP table

The four emoji standing in for Jira, TestRail, Jenkins and Confluence became
the actual logos, generated by `scripts/build-logos.js` from the `simple-icons`
package rather than downloaded by hand — auditable, regenerable, and committed
as SVG so the deck stays offline.

Two things needed judgement rather than just using the brand hex:

- **Two brand colours are unusable on this background.** Atlassian's `#0052CC`
  (Jira) is muddy on `#011627` and `#172B4D` (Confluence) is all but invisible.
  Both use Atlassian's own light-background blue `#2684FF` instead — the
  brand's variant, not an invented colour. Jenkins' `#D24939` was lightened to
  `#E8604F` for the same reason: its butler is line art and goes muddy at icon
  size on a dark field. TestRail's green needed nothing.
- **Size.** At `1.15em` the first three read fine but Jenkins was a blob —
  it carries far more detail than the other three. `1.5em` makes all four
  legible at the same visual weight.

Trademarks are noted in `slides/img/logos/README.md`: nominative use to
identify the tools the talk discusses, no affiliation implied.

## 2026-08-16 — Logo chips, GitHub as a fifth MCP, and an ambient layer

Three changes, one of them a reversal.

**The logo tinting was the wrong fix.** Yesterday's entry lightened three brand
colours so they would survive `#011627`. That was solving a background problem
by altering trademarks. The right fix is CSS: `img.logo` now sits on a light
rounded chip, so all five keep their real brand hex *and* read at the same
visual weight — which was the other half of the problem, since Jenkins' butler
carries far more detail than a flat glyph and was the logo that prompted this.
`build-logos.js` lost its colour-override table entirely.

**GitHub joins the MCP table.** It was already the odd one out: `mocks/github/`
exists, Demo 4 posts its aggregated review to a PR, and the table listed four
MCPs without the system that demo actually targets. Row added ("Leer el PR y su
diff, postear el review, ver los checks"), the count updated 4 → 5, and the
Q&A slide that enumerates which MCPs need network updated to match.

**Ambient layer, in place of decorative images.** The author asked for vanity
filler. Stock imagery would fight the deck's whole premise — plain text on
disk — so instead: two very faint radial washes extending the treatment the
lead slides already used, and a low-opacity monospace watermark with the repo
URL, which is filler that does a job since the talk invites cloning four times.

The bigger win was not decoration at all. Eight slides are short *by design*
(the framing question, the three notas al pasar, the Q&A backups) and were
sitting at the top of the frame with 400–500 px of void under them, which reads
as a mistake rather than a pause. A `mid` class centres them vertically. Two
implementation notes worth keeping: `justify-content` needs `display:flex`,
which gaia's `section` does not set; and the frontmatter `backgroundColor`
directive emits a `background` shorthand that silently wipes the gradients, so
the washes are applied as `background-image` with `!important`.

## 2026-08-16 — Two aspect ratios from one source

The deck was 16:9 only (Marp's default). On a 16:10 screen that letterboxes,
which is what the author was seeing. `./scripts/build-deck.sh` now produces
both, HTML and PDF, from the same `slides.md`.

How, and why not more simply: Marp derives the canvas from a `size:` directive,
but only accepts sizes the *theme* declares, and gaia declares 16:9 and 4:3 —
not 16:10. So `slides/themes/qa-deck.css` is gaia plus one `@size` line. The
deck's styling stays inline in `slides.md`, where the talk's own argument says
it should be readable; the theme file exists purely for that declaration.

Marp CLI has no flag to override a global directive, so the 16:10 build writes
a temp copy with the one line changed. The copy goes **inside `slides/`** on
purpose — relative `diagrams/*.svg` and `img/*.svg` paths break anywhere else.

**Two mistakes worth recording, both mine, both about verification:**

- The first build looked like a failure. I was grepping the output for
  `width:1280px;height:...` and always got 720 — but that string matches an
  earlier rule in the cascade, not the effective size. The real markers are the
  SVG `viewBox` and `@page`. The `size:` directive had worked the whole time;
  I nearly rewrote the approach because of a bad probe. Verify with `viewBox`.
- The first output location was `slides/dist/`, one level below the assets, so
  every diagram and logo in the built **HTML** was broken — the PDFs were fine,
  since Chromium resolves paths at build time, which is exactly the kind of
  half-broken that ships unnoticed. `check-slide-overflow.js` caught it, which
  is the broken-image guard added earlier this same day paying for itself.
  Output now sits next to `slides.md`.

Both ratios verified: 1280×720 and 1280×800, 0 of 45 slides overflowing in
each, no broken images in either.

## 2026-08-16 — Titles pinned, and the tree diagram leaves Mermaid

**The `mid` class is gone.** Centring the eight short slides filled their void
but moved their titles, so flipping through the deck made the heading jump
between the top of the frame and the middle. The author called it, and it is
the right call: a heading that lands in the same place on every slide is worth
more than filling space. Measured after removing it — all 36 content headings
sit at exactly 44 px.

That exposed a second, subtler jump: `dense` lowers the section font-size, and
the heading was sized in `em`, so it shrank along with the body on those two
slides. `section h1` is now sized in **px**, which makes it immune. The
positions were already identical; the *size* was not.

**The `~/.claude/` tree is hand-written SVG now.** Mermaid centres each node on
its own width, so the four leaf boxes had ragged left edges — `.claude/rules/`
sticking out past `memory/` for no reason a reader could interpret. There is no
Mermaid setting for "same width, same left edge"; dagre computes those
positions. Hand-writing it gives all four an identical `x` and width.

This refines the rule from the earlier diagram entry. It was "Mermaid when the
diagram is a graph, hand-written SVG when the layout carries meaning" — and
this *is* a graph, so by that rule Mermaid should have won. The missing half:
**alignment is meaning too.** When boxes are siblings, showing them as siblings
matters more than the convenience of generating the layout. Mermaid still owns
the subagent fan-out and the pre-AI pipeline, where nothing needs to line up.

`diagrams/arbol-claude.mmd` and its SVG were deleted rather than left orphaned.

## 2026-08-16 — A light variant, and the refactor it forced

The author asked for a second deck on a White Smoke background, so the demos —
which run in a light editor theme — stop being a slap in the face every time
the talk cuts to the terminal. Both variants are kept; `build-deck.sh` now
produces four builds (2 themes × 2 ratios).

**The refactor.** Two palettes cannot live in one `style:` block, so the block
was split: `slides.md` keeps every structural rule and consumes only
variables, and `slides/themes/qa-deck.css` (dark) and `qa-light.css` (light)
carry the palettes. Thirteen literal colours in the CSS became variables to
make that possible. The frontmatter's `backgroundColor`/`color` directives were
dropped — the theme sets them now, which also removed the reason the ambient
washes needed `!important` in the first place.

**Roles are not a straight swap.** Measured against `#f5f5f5`, the vivid
members of this palette land at 3.2–3.4:1 — fine for graphics and large text,
not for small text. So the vivid colours go to markers, borders and headlines,
and small text uses the palette's dark members. Every substitution is written
down in `qa-light.css` next to the rule it applies to. Burnt Tangerine is
deliberately unused: it is nearly indistinguishable from Blazing Flame, and two
oranges meaning different things get confused on a projector.

**Three things broke, none of them obvious:**

- **The syntax highlighting was still a dark theme.** Marp injects one
  highlight.js theme regardless of variant. On the white code pane its tokens
  measured **1.95:1 to 2.68:1** — illegible, and precisely the problem the
  light deck exists to avoid. Overridden with the palette's dark members; the
  worst token went from 1.95:1 to 3.66:1 (Verdigris strings, kept because it is
  the only green and a string that does not read as a string costs more).
- **The lead slides rendered black.** `section.lead` used the `background`
  shorthand, which resets `background-color`, while the ambient layer set
  `background-image` with `!important` — so the slide kept the washes and lost
  its colour entirely. Invisible on the dark deck because the container behind
  is also dark. Both now set `background-image` only.
- **The two Mermaid diagrams stayed dark.** A pre-rendered SVG carries its
  colours baked in and cannot read the deck's variables the way the
  hand-written inline diagrams do — the exact tradeoff the earlier "Mermaid vs
  hand-written" entry did not anticipate. `build-diagrams.sh` now emits a
  `-light.svg` beside each one and the light theme swaps the `<img>` via
  `content: url(...)`. Note that a missing swap target fails **silently** — the
  browser just shows the alt text — so `build-deck.sh` asserts the files exist.

Also worth knowing: `content: url()` paths resolve against the **output HTML**,
not the CSS file, because Marp inlines the theme. The first attempt used
`../diagrams/…` and quietly showed alt text.

All four builds verified at 0 of 45 slides overflowing.

## 2026-08-16 — Más aire para los diagramas, y dos imágenes de apoyo

Pedidos del autor sobre el espacio en blanco que quedaba bajo los diagramas.

- **Slide 10 (árbol) y 14 (flujo end-to-end)** se agrandaron: cajas más altas,
  tipografía de 12–15 px a 14–18 px. Eran legibles en pantalla y flojas
  proyectadas.
- **Slide 5 (pipeline pre-IA) salió de Mermaid.** Agrandar la fuente no
  alcanzaba: en un `flowchart LR` el alto lo fija la altura de un nodo, y el
  ancho crece con el texto, así que la relación de aspecto casi no cambia —
  pasó de 9.3:1 a 8.3:1 y siguió siendo una tira baja. Reescrito a mano en dos
  filas, que además muestra lo que la fila única no mostraba: **que es un
  ciclo**. La vuelta va por un carril a la izquierda de las cajas; la primera
  versión la cruzaba por adentro de Jenkins.

  Otro caso de la regla ya conocida: Mermaid cuando es un grafo, SVG a mano
  cuando el layout carga significado. Acá el significado era el ciclo.

- **Dos imágenes de apoyo** en las slides 4 y 23, con clase `hero` (centrada,
  máximo 352 px de alto, esquinas redondeadas; en el tema oscuro `qa-deck.css`
  les agrega borde y sombra para que se lean como tarjeta y no como agujero).
- **Logo de Claude** en el aire de la slide 9, generado por `build-logos.js`
  igual que los demás.

**Las dos imágenes están con un stand-in.** Se armaron fuera del repo y llegan
por chat, que no es un canal del que se pueda escribir a disco. El deck compila
—hay un PNG gris en su lugar— y `build-deck.sh` compara el hash y avisa en cada
corrida hasta que se reemplacen. Detalle y medidas en `slides/img/README.md`.

Nota de sintaxis que costó un render: `![w:640 hero](…)` **no** genera
`class="hero"`. Marp sólo interpreta sus propias palabras clave en el alt; el
resto queda como texto alternativo. Para que aplique una clase hay que escribir
el `<img class="…">` a mano.

## 2026-08-17 — Revisión conceptual: cinco cosas que el deck decía mal

Un subagente experto en workflows de Claude Code revisó deck + repo + runbook
buscando errores conceptuales y contradicciones repo↔deck. Encontró una cuarta
tanda de las mismas — la charla se demuestra en vivo sobre este repo, así que
cualquier afirmación que el repo desmienta se cae sola en escena. Arreglado:

- **La timeline inventaba dos cosas.** Decía que el hook nació porque
  *"memory + rule no alcanzaban"*, pero **no existe ninguna rule de typecheck**
  y la pirámide argumenta lo contrario: ese dolor *saltea* la Rule. Y listaba
  una memory (`heurística de flaky tests en stage`) que no existe, mientras
  omitía la única real. Ahora las 13 filas corresponden a artefactos que están
  en disco — verificado uno por uno. La fila de semana 16 pasó a ser el
  registry `known-issues`, que además enseña la distinción importado /
  on-demand en vez de sólo repetir "cada pieza nació de un dolor".
- **"memory + rules cargadas todo el tiempo"** (flujo end-to-end) era falso
  justo para la memory que esa misma slide muestra: `known-issues` es
  deliberadamente **no** importada. Y el runbook manda mostrar `/context` en
  vivo como prueba de la distinción, así que la contradicción era proyectable.
- **La slide de costos decía lo contrario de lo que pasa.** *"Memory, rules y
  hooks cuestan ~0"*: al revés, lo siempre-cargado es lo único con costo
  recurrente por mensaje. Reescrita, y de paso ahora contesta la pregunta que
  la charla nunca respondía: por qué no meter todo en el `CLAUDE.md`.
- **Las rules no son una primitiva.** Están siempre cargadas *sólo porque*
  `CLAUDE.md` las importa con `@`, y su `description` —a diferencia de la de un
  skill— no la lee nadie. Sin eso, quien copie la plantilla el lunes no obtiene
  nada y no se entera. Aclarado en el apéndice y en `SOURCES.md`, que además
  afirmaba que Cursor lee `.claude/rules/` (lee `.cursor/rules/`).
- **Riesgo de falla silenciosa en escena.** Demos 2, 4 y 6 invocan skills que
  vienen en plugins, y `prep-demo.sh` chequeaba todo menos que los plugins
  estuvieran habilitados: si no resuelven, la skill no existe y Claude
  improvisa. Assert agregado, con la advertencia de que sólo prueba que el
  perfil los *declara* — que resuelvan se ve en un lanzamiento real.

Menores, de la misma revisión: el mensaje de falla de `build-44.json` invertía
el test al que estaba anclado (vitest imprime *expected `<actual>` to be
`<esperado>`*), la slide de Q&A listaba 4 MCPs con la tabla en 5, el paso 4
omitía `/plugin marketplace add` antes de `install` —literalmente lo que el
público va a tipear— y el README decía 32 slides de main flow con 31.

**Una del reporte no se aplicó:** marcaba `defaultMode: "auto"` en
`demo-profile.sh` como valor no documentado. `auto` sí es válido, junto con
`default`, `plan`, `acceptEdits`, `dontAsk` y `bypassPermissions`. Verificar
antes de propagar, incluso lo que viene de una revisión buena.

### Known open items

- `mocks/github/pr-7.diff` is readable but not `git apply`-able (the test-file
  diff is nested inside the first hunk). Fine for the demo, broken for anyone
  who tries to apply it.
