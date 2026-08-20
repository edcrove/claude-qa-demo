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


## 2026-08-19 — Feedback de la presentación: once cambios del autor

Lectura completa del deck por parte del autor, con once observaciones. Lo que
salió de aplicarlas:

- **Slide 6 pasó a primera persona** (*"Tu día como QA"* → *"Mi día como QA"*).
  No alcanzaba con el título: los bullets estaban en segunda persona
  (*comparás*, *copiás*, *armás*) y quedaban peleados con el encabezado, así que
  se movieron con él. Y hay una trampa: la slide 24 **cita esa línea textual**
  (*"La slide del principio terminaba: ..."*), así que el callback se movió
  también. Cambiar una sola de las dos rompe la cita en silencio.
- **La slide 10 tenía las líneas encimadas de verdad, no por percepción.** El
  spine vertical del árbol estaba en `x=668` mientras la caja
  `proyecto/CLAUDE.md` termina en `x=670` — y los `path` se pintan *después* de
  los `rect`, así que la línea se dibujaba **adentro** de la caja, a 2px de su
  borde derecho, a lo largo de todo su alto. Movido a `x=680`, con los stubs
  acompañando. Verificado exportando la slide a PNG, no razonando la geometría.
- **El tick de la slide 14 tiene su propia clase.** *"corrección repetida 3×"*
  usaba `.dg-tick`, que también dibuja los horarios 9:00→17:00 de la slide 15:
  agrandarla ahí habría agrandado la tira. Se agregó `.dg-tick2` (13px → 15.5px)
  **más su override en `qa-light.css`** — sin eso el color se desviaba sólo en el
  tema claro, que es exactamente la falla silenciosa que documenta STATUS.
- **La slide 20 mostraba un marcador, no un reporte.** Era un conteo por eje
  (`silent-failure-hunter · 1`), del que no se entendía qué había encontrado
  nadie. Ahora cada fila dice el hallazgo concreto, con las cinco cadenas
  **verificadas contra `mocks/github/pr-7.diff`** una por una.
- **Y eso destrabó la slide 21.** El pedido era que la aclaración se apoyara en
  algo visible en el reporte; ahora se apoya. De paso se corrigió el argumento:
  decía que SonarQube agarra *el catch* y no ve el resto, pero un linter también
  marca el `// TODO` (`S1135`). El corte honesto es **2 de 5** matcheables por
  patrón y 3 que hay que leer — que sigue siendo el punto, sin exagerarlo.
- **La transición de la slide 23 rompía la voz.** *"Pero hoy, tres veces, me
  corregiste lo mismo"* le hablaba al agente, cuando las otras cuatro
  transiciones son el presentador narrando su día en primera persona.
- **Slides 42/43/44 y una slide nueva al final.** En costos: cómo se mide de
  verdad (`/context`, `/usage`, y `total_cost_usd` de `claude -p --output-format
  json`) y evals en vez de intuición. En cambio de modelo: revisar las
  estructuras es una conversación con el modelo nuevo, no una migración. En
  stack: lo genérico puede vivir en un repo aparte y compartible.

**Cuidado con lo que se afirma de las features.** La slide nueva lista `/loop`,
`/goal`, `/schedule`, background agents + worktrees y subagentes propios. Los
nombres se verificaron contra la lista real de `slash_commands` que devuelve la
sesión, y la definición de `/goal` se sacó del binario de Claude Code, no de
memoria: *"propone una condición de fin de sesión; una vez fijada, Claude sigue
trabajando hasta que **un evaluador aparte** confirma que se cumplió"*. También
se corrigió un reflejo: el comando es `/usage`, no `/cost`.

Deck: 45 → **46 slides** (31 main / 9 appendix / 6 Q&A backup), **0/46
overflowing** en los cuatro builds.


## 2026-08-19 (cierre) — Auditoría de los docs y vuelta a `main`

Revisión de todos los documentos del repo contra lo que el repo dice hoy. Lo
que estaba mal no era opinable: eran números y nombres de archivo.

- **El conteo de slides estaba viejo en tres lugares.** `talk-design.md` decía
  45 y "Q&A backup: 5"; el mapa de slides es lo que lee una sesión nueva para
  saber qué hay. `STATUS.md` decía 45 en el bloque de timing. Todo a **46**
  (31 main / 9 appendix / 6 Q&A backup), verificado contra los `<section>` del
  HTML renderizado, no contra los `---` del markdown — hay 47 separadores para
  46 slides y contar a mano da mal.
- **Dos docs mandaban a un archivo que no existe.** El checklist de
  `talk-design.md` y el docstring de `check-slide-overflow.js` decían
  `slides/slides-16x9.html`. `build-deck.sh` escribe cuatro variantes con
  tema en el nombre (`slides-dark-16x9.html`, …); ese archivo no se generó
  nunca. Un chequeo pre-charla que falla con "file not found" es un chequeo que
  no se corre.
- **La cita de la slide 24 estaba desincronizada en los docs.** El deck ya
  quedó en primera persona el 2026-08-19, pero `talk-design.md` y `HANDOFF.md`
  seguían citando *"Re-explicás el ticket…"* como el texto del espejo. Ahora los
  dos dicen que las dos líneas se editan juntas — es exactamente el error que
  se cometió una vez.
- **`HANDOFF.md` estaba generado el 2026-08-13 y no mencionaba el blocker
  principal.** La cápsula que existe para arrancar una sesión desde un chat no
  decía que la charla no entra en 30 minutos — que es justo lo que un chat
  *sí* puede ayudar a resolver (cirugía narrativa, sin filesystem).
  Regenerado completo, con el recorte pendiente arriba.
- **El runbook prometía algo que el ensayo no confirmó.** Decía que el fan-out
  de los 5 subagentes "must be visible in the UI — that is the money shot". El
  ensayo del 2026-08-19 no lo consiguió de forma confiable. Queda escrito como
  supuesto a verificar, con un plan B narrando la *agregación* en vez del
  paralelismo. Y el beat del hook de la Demo 2 aclara que necesita sesión
  interactiva: bajo `claude -p` los PostToolUse no disparan.
- **Los hallazgos del ensayo entraron a STATUS.** Estaban sólo en el buffer de
  la sesión: dispatch no visiblemente paralelo, hooks ausentes en headless, y
  `pr-7.diff` que no aplica. Tres cosas que se pierden con el `/clear` si no se
  escriben.
- **Borrado `slides/gamma-version.md`.** Era una copia en prosa del deck para
  importar en Gamma, congelada en 41 slides y con el texto viejo (*"Tu día como
  QA"*). No la referenciaba ningún doc ni el decision-log. Un deck paralelo que
  nadie sincroniza no es un entregable, es una trampa: queda en el historial
  de git si alguna vez hace falta.
- **`README.md`** listaba 3 de los 7 scripts y tenía una fila mitad en
  castellano; `slides/README.md` seguía diciendo que el deck se buildea con un
  `npx marp-cli` a mano, sin mencionar `build-deck.sh`, las cuatro variantes,
  los PDF versionados ni el chequeo de overflow.

**Y se cerró la branch.** `claude/estructura-revision-fwdb2c` nunca tuvo
commits propios — main y la branch apuntaban al mismo sha durante tres días, y
lo único que vivía ahí era el árbol de trabajo. Todo se commiteó, se llevó a
`main` y la branch se borró (local y remota). El trabajo del deck sigue en
`main`: una branch que no aísla nada sólo agrega un lugar más donde
desincronizarse.


## 2026-08-20 — Inventario de lo mostrable del toolkit privado

El deck asegura, en la slide de stack, que lo genérico puede vivir en un repo
aparte y compartible. Ese repo existe y es privado. Se revisó completo para
sacar qué tiene que al deck le sirva, y quedó en
[`showable-inventory.md`](showable-inventory.md) ya sanitizado.

**Lo que apareció y el deck no tiene:**

- **El bloque de permissions `allow`/`ask`/`deny`.** `settings.json` no es sólo
  hooks. Tres niveles con tres intenciones: `allow` para lo read-only (dejás de
  clickear aprobar cincuenta veces por día), `ask` para todo lo que sale de tu
  máquina, `deny` sobre los archivos que el agente no tiene que poder leer
  siquiera — `secrets.env`, `.env`, claves SSH. Es el hilo de accountability
  hecho mecánico, en un solo JSON. La mejor relación valor/tiempo de todo el
  inventario.
- **Tests para los propios skills.** Un script con nueve chequeos estáticos por
  skill: que el frontmatter parsee, que `name` coincida con el directorio (si no,
  **el harness nunca encuentra el skill** — falla en silencio y parece que el
  modelo te ignora), que los links relativos resuelvan, que los `[[wikilinks]]`
  apunten a algo que existe, que las variables de config estén declaradas en el
  `.env.example`, que los scripts pasen `bash -n`. Más su propio disclaimer
  honesto: es análisis estático, no prueba que el skill produzca buen output.
  En una charla de QA, esto cierra el loop que la charla misma abre.
- **La regla de alcance de evidencia.** No prohíbe nada: dice *cuánta* evidencia
  debe una PR según los paths que toca, con default explícito para la
  ambigüedad y un gate rápido antes de las suites caras. Es lo que un QA senior
  hace en la cabeza, escrito.
- **`Last verified: YYYY-MM-DD`** en cualquier afirmación sobre cómo se comporta
  hoy un sistema externo. La idea más barata del inventario.
- **Los transcripts son superficie de leak.** El toolkit lo dice de una forma
  que a la audiencia le va a caer nueva: nunca pases un token como literal en la
  línea de comandos, queda en el historial de shell *y en el transcript del
  agente*.

**Y una categoría de rule que el deck no nombra.** Sale de mirar las doce que
tiene el toolkit: sólo dos son prohibiciones. Las otras son reglas de formato
(la primera línea de la PR es el ticket), procedimientos de decisión (cuánta
evidencia), de archivo (dónde van los docs que genera el agente) y de
vocabulario (qué significa "R2" en este equipo). Una rule también puede ser un
glosario.

**Sanitización: se endureció el guard, no se prometió.** El doc tiene tabla de
sustituciones, pero una tabla es una promesa. `check-leaks.sh` ahora matchea
case-insensitive —una sola entrada cubre todas las capitalizaciones de una
marca, donde antes hacían falta tres— y banea los
identificadores internos que no son obviamente confidenciales pero están a una
búsqueda de la organización: nombres de repo, de job, de suite, de servicio, y
los dos repos del toolkit privado. Dos detalles que costaron un ciclo:

- **`gqe` quedó afuera.** Aparece dentro de un hash base64 de
  `package-lock.json`. Una palabra baneada que salta con ruido termina en que
  alguien desactiva el chequeo entero. Regla nueva: nada de tres letras o menos.
- **El punto del patrón del mail hay que escaparlo.** Al pasar a
  case-insensitive, el `.` dejó de ser un punto y matcheó el espacio del nombre
  propio del autor — que está a propósito en la slide de título y en el LICENSE.
  Lo baneado es el local part del mail de trabajo, con punto literal.

Nota al margen que vale como anécdota: el guard cazó el propio entry de este
decision-log. Escribir *sobre* la lista de palabras prohibidas usando las
palabras prohibidas falla, y está bien que falle — se reescribió el texto en vez
de agregarle una excepción al chequeo.

**Qué no se muestra:** las entradas del knowledge base (la estructura sí, el
contenido es interno puro), el validador de nombres de repo contra la política
de la organización (el patrón es bueno, pero cada tabla de datos que tiene es
identificatoria) y los nombres de los dos repos del toolkit.


## 2026-08-20 — Dos slides: que el modelo falla, y qué abrir al clonar

### "El modelo se equivoca"

El deck mostraba veinticinco minutos de un agente funcionando y nunca decía en
voz alta lo obvio: un LLM es probabilístico y falla. Sin eso, toda la pirámide
se lee como productividad, cuando la mitad de su razón de ser es contención.

Va **inmediatamente antes de "Qué le toca a la persona"**, y esa posición es el
argumento entero. Esa tabla venía afirmando el reparto humano/agente como
principio; ahora llega con su causa: el criterio se queda del lado humano
**porque el modelo es probabilístico**, no por política de la empresa.

Los tres ejemplos son autorreferenciales a propósito, y eso es lo que hace que
no suene a disclaimer:

- **La Demo 3**, que la sala acaba de ver. El agente iba a triggear un build que
  no debía y no lo frenó el modelo: lo frenó una rule.
- **Las tres afirmaciones que este deck hacía y su propio repo desmentía**
  (revisión del 2026-08-13). Las encontró alguien que fue a leer el repo, no
  que le volvió a preguntar al modelo. Esa distinción es el método.
- **La slide del linter, que estaba mal.** Decía que SonarQube no ve el
  `// TODO`; lo ve (`S1135`). Se arregló leyendo la regla del linter, no
  confiando en la memoria — el mismo error que la slide describe, cometido por
  el deck que lo describe.

Cierra en que el trabajo no es que el agente no se equivoque, sino que se
equivoque **donde se nota** y que el error no vuelva — que es literalmente el
mecanismo de promoción, ahora con su motivo explícito. *"El error es la materia
prima del setup."*

**No es gratis:** es la primera slide de flujo principal que se agrega desde los
recortes de timing, y suma ~40 s a un camino que ya está ~18 min pasado. Queda
anotado en la decisión pendiente 1 de STATUS en vez de disimulado.

### "Qué abrir cuando clones el repo"

Última slide, y la que la audiencia fotografía. Tabla path→para qué de
`CLAUDE.md`, `.claude/rules|skills`, `settings.json`, `memory/`,
`skill-templates/`, `mocks/` y `evolution-timeline.md`, y después el bloque que
explica `docs/showable-inventory.md`: qué es —catálogo sanitizado de piezas del
setup de trabajo real, las que no entraron en 30 minutos— y **cómo usarlo**:
buscá tu dolor en la columna *"por qué mostrarla"*, copiá la pieza, reemplazá
los nombres genéricos por los tuyos, y arrancá por la tabla de las tres
primeras.

No se cuenta como Q&A backup: no responde una pregunta, es una referencia que
existe para leerse *después* de la charla. El conteo ahora es 32 main / 9
appendix / 6 Q&A backup / 1 mapa del repo.

Deck: 46 → **48 slides**, **0/48 overflowing** en los cuatro builds, PDFs
re-renderizados.

**Nota de entorno que cuesta cada vez:** el gate de overflow venía fallando con
`Executable doesn't exist` de Playwright. No hace falta bajar el Chromium: el
script ya honra `CHROME_PATH` y lo pasa como `executablePath`. Con el Chrome del
sistema, más `PATH`/`NODE_PATH` apuntando a donde quedaron instalados `marp` y
`playwright`, buildea y verifica sin instalar nada nuevo.


## 2026-08-20 (más tarde) — El repo hermano entra al inventario, y la slide se reescribe

### Lo mostrable del pipeline multi-agente

El inventario cubría un solo repo privado. Falta el hermano, que es material de
otra naturaleza: no es una biblioteca de skills y rules, es un **pipeline de tres
agentes con orquestación determinística** — planifica cobertura desde los AC,
escribe los tests, los corre contra el ambiente efímero del ticket, y los
**verifica con un agente independiente**.

Lo que se llevó al inventario, sanitizado:

- **El `verifier` es el mejor artefacto de los dos repos para esta audiencia.**
  Es literalmente la respuesta a *"¿y quién revisa al agente que escribió los
  tests?"*: otro agente, con menos tools, modelo más chico, sin el contexto del
  primero, y con instrucción explícita de tratar el resultado del Runner como un
  claim a verificar. Un pass sin assertion que cubra el AC no es un pass —
  `hollow_pass_suspected`. Nunca hace default a pass.
- **El `backlog-verifier` trae el argumento asimétrico**, que es diseño de tests
  puro: un ticket marcado listo por error se construye mal y nadie lo vuelve a
  leer; uno frenado por error cuesta una pregunta. Entonces la barra para
  confirmar "listo" es alta. Y una prohibición que casi ningún reviewer humano se
  autoimpone: *"no fabriques un gap para parecer riguroso."*
- **El contraste entre los dos bloques de permissions.** El toolkit usa
  `allow`/`ask`/`deny` y manda `git push` a `ask`; el pipeline no tiene `ask` y
  **deniega** `git push`. La diferencia es la presencia de un humano: sesión
  interactiva hay a quién preguntarle, corrida larga semi-desatendida no.
- **`WebFetch`/`WebSearch` denegados** — el agente no puede importar una
  convención de un blog mientras escribe tests. Sale del AC y de las convenciones
  declaradas, o no sale.
- **Las lecciones del POC**, que son el mejor material honesto de los dos repos:
  *"el razonamiento es la parte fácil; la disciplina es la difícil"*, *"la
  escalación honesta es una feature, no una falla — un sistema que nunca escala o
  está inventando o está escondiendo"*, *"los guardrails se imponen, no se
  piden"*, y *"cada fix manual es un upgrade del sistema"* — que es el mecanismo
  de promoción del deck, encontrado de forma independiente por otro proyecto.

### Y la slide se reescribió entera

**"El modelo se equivoca" no se entendía.** El diagnóstico, que vale más que el
arreglo: sus tres ejemplos no compartían forma. Uno era *el agente hizo algo mal*
(la Demo 3) y los otros dos eran *el deck decía algo mal* (tres afirmaciones que
el repo desmentía, y la slide del linter). Mezclar "falla el agente" con "fallé
yo" difumina el punto, y los dos últimos pedían contexto que la sala no tiene:
nadie estuvo en el desarrollo del deck. Encima la conclusión —*"que se equivoque
donde se nota"*— no decía **dónde** se nota ni **qué** lo nota.

Ahora es una **taxonomía de cuatro filas: forma de fallar → qué la agarra.**

| Se equivoca así | Qué lo agarra |
|---|---|
| Inventa un flag, un endpoint, un método | que el resultado sea verificable: hook + test |
| Toma un atajo razonable: escribe los tests mirando el código del dev | rule que lo prohíbe + skill que fija el orden |
| Se pasa de límite: triggea el build corriendo, va al keychain | la rule (Demo 3) y los permisos |
| Se olvida: sesión nueva, cero contexto | memory |

Las cuatro piezas de la pirámide aparecen **como respuesta a una forma concreta
de fallar**, así que la pirámide se gana su existencia en vez de afirmarla. Y los
dos ejemplos nuevos salen de las lecciones del repo hermano: son reales, son de
QA, y ninguno necesita explicación previa. El del código del dev es el que hiela
la sangre — cobertura que pasa por construcción, con el bug adentro.

Cierra en las dos mitades que faltaban: *"que cuando pase, se vea — y que el
mismo error no vuelva dos veces"*, y después *"cuando aparece uno nuevo no lo
corrijo en el chat y sigo de largo: lo escribo."*

### Y el título de la slide del dolor decía lo contrario de lo que mostraba

*"Mi día como QA, **hoy**"* se leía como el día actual —con IA— cuando el
contenido es el día enteramente manual: copiar los AC a mano, comparar docs
contra branch a ojo, pingear peers y volver a pingear. La slide contradecía su
propio encabezado.

Queda **"Mi día como QA, antes de todo esto"**. No *"antes de IA"*, porque la
slide inmediatamente anterior ya se llama así y habla del stack: ésta es lo que
ese pipeline **costaba**. La marca temporal es relativa a la charla, no al
calendario, así que no vuelve a envejecer.

El callback de la Demo 6 no se toca: cita el último *bullet* (*"Mañana — sesión
nueva. Re-explico el ticket, el plan, las convenciones."*), no el título.

### El inventario se reorganizó por tipo de pieza, no por repo

Venía partido en dos bloques según de qué repo privado salía cada cosa, con una
sección aparte para "el repo hermano". A una audiencia general eso no le dice
nada: es contabilidad interna. Ahora está por **tipo de artefacto**, con todo
mezclado como si viviera en un solo lugar.

Lo que el merge destrabó, que es más que cosmética:

- **Apareció una sección de `## Agentes`** que antes no existía. Es la categoría
  que el deck más roza y menos muestra: los 5 subagentes de la Demo 4 vienen de
  un plugin, y la última slide dice *"los tuyos los escribís vos"* sin mostrar
  uno. Ahora hay cinco propios con rol, tools, criterio y modelo en una tabla.
- **Tres prohibiciones nuevas entraron a `## Rules`** en vez de quedar como
  "principios" de un pipeline: *green is never the goal*, *no leer el código para
  diseñar los tests* y *AC congelados*. Como rules se leen mejor y compiten
  derecho con las que ya estaban — la primera es probablemente la prohibición más
  importante del inventario.
- **Los dos bloques de permisos quedaron uno al lado del otro** y el contraste se
  volvió el contenido: no es "el repo A vs el repo B", es **sesión interactiva vs
  corrida semi-desatendida**. Con `ask` cuando hay alguien a quien preguntarle y
  `deny` cuando no. Ese reencuadre sólo aparece cuando se borra la frontera de
  repos.
- **Las lecciones del POC quedaron en su propia sección** (`## Lo que se aprendió
  midiendo`) porque no son artefactos: son hallazgos. Mezclarlas con las piezas
  las hacía parecer features.
- **El top 3 cambió.** El `verifier` desplazó a `regression-evidence-scope` al
  cuarto puesto: es la respuesta directa a *"¿y quién revisa al agente que
  escribió los tests?"*, que es la pregunta que esta audiencia va a hacer.

Y en el deck, la última slide ahora nombra las cinco categorías —rules, skills,
**agentes**, hooks, permisos— en vez de "skills, rules, hooks y otras piezas".
"Agentes" es a propósito: cierra el loop que abre la slide anterior.

### Faltaba el skill de PR review, y el motivo por el que faltaba era el error

Lo descarté en la primera pasada con "ya está en el demo". Falso: el demo
despacha los cinco reviewers **genéricos del plugin** (código, fallas
silenciosas, tipos, comentarios, tests), y el real tiene cinco escritos para el
dominio del equipo. Es justo la mitad que el deck afirma y no muestra —la última
slide dice *"los tuyos los escribís vos"* sin mostrar ninguno.

Lo que entró:

- **Los cinco reviewers propios**, en `## Agentes`, que ahora tiene dos
  subsecciones: los reviewers de PR y el pipeline. El dev-code reviewer es la
  rule `test-antipatterns` convertida en prompt, lo cual cierra un loop que el
  deck no cierra: **la rule le dice al agente cómo escribir, el reviewer chequea
  que lo hizo.** El mismo conocimiento en los dos extremos del ciclo, salido del
  mismo review repetido.
- **La respuesta a "¿y para qué escribo un agente si el plugin ya trae cinco?"**
  Ninguno de los genéricos puede saber que el id de tu caso de test es un prefijo
  del nombre del método, ni qué anotación aplica en un repo del monorepo y no en
  el otro, ni qué AC tenía el ticket. Eso no es code smell: es tu convención.
- **Los dos gates bloqueantes del orquestador**, que son lo mejor del skill y no
  son opiniones: se calculan desde la lista de archivos tocados. Si algo cae
  fuera del árbol de tu equipo, no es un merge solo tuyo. Y el orquestador tiene
  instrucción de **liderar con ese gate** — un cambio en código compartido es un
  bloqueante de merge, no un nit.
- **La política de auto-fix partida en dos:** un solo reviewer arregla solo
  metadata que no cambia el comportamiento de ningún test; todo lo demás se
  reporta y espera aprobación. Es una línea defendible de qué toca un agente sin
  que lo miren.
- **El analista de comentarios tiene prohibido postear.** Analiza y devuelve; el
  orquestador postea después de que el humano elige.
- **El chequeo de salud de datos del SME**, que separa *"falta cobertura"* de
  *"los datos del ambiente no soportan ese escenario"*. Un reviewer que exige un
  test imposible quema su credibilidad.

Y quedó anotada una mejora de la Demo 4 que no cuesta una slide: mencionar en una
frase que los reviewers propios llevan las convenciones de tu equipo.

### El inventario completo, y los cinco reviewers propios entran al deck

**El inventario ahora lista todo, incluido lo que ya está en el demo.** Venía
funcionando como "el delta contra el deck", y eso escondía piezas que el autor
usa todos los días: el planificador de una corrida no aparecía por ningún lado.
Las skills quedaron agrupadas por lo que hacen —planificar, correr en local, CI,
review, conocimiento, panel y deploy— con las que ya están en el demo marcadas.
Dieciocho en total, contra siete de antes.

Lo que apareció al listar en serio:

- **`ticket-execution-plan`, el planificador.** Identifica clases y grupos de
  test, arma el comando local por plataforma, escribe el plan en el scratchpad y
  genera el script de trigger. El detalle que lo hace un plan y no una lista:
  **resuelve el ambiente desde el estado del ticket de desarrollo.**
- **`multi-ticket-work-plan`**, y su decisión de diseño: el template del doc
  incluye a propósito un ticket cuyo dev **no** está Done, como segundo ejemplo.
  Enseña la forma de la excepción, no sólo la del caso feliz.
- **`local-functional-tests`**, que tiene los mejores títulos del inventario:
  *"BUILD SUCCESS no significa nada"* (el pom trae `testFailureIgnore=true`, así
  que Maven reporta éxito con fallas y con cero tests) y *"¿la falla es mía o del
  ambiente?"* (un `5xx` upstream es el ambiente; compará contra un build reciente
  del mismo env antes de debuggear).
- **`test-case-manager-workflow`**, cuya primera línea es el hallazgo: **el MCP
  conectado no expone ninguna tool**, así que todo va por la API REST. Un skill
  que documenta que una integración conectada es inservible y cuál es el camino
  que sí funciona.
- **`preprod-deploy`**, el ejemplo más puro de "un skill es donde vive el
  gotcha": los parámetros del job son dinámicos, y si el job no fue consultado
  por API en esta sesión el trigger **descarta todos los parámetros en silencio**
  y el build muere mucho después con un NullPointerException. Y el primado no es
  un no-op: corre el pipeline completo con los defaults y *los deploya*.

### Y el deck: lo real en el diagrama, lo simplificado en la demo

El deck venía afirmando agentes propios mientras el escenario despacha los de un
plugin. La solución no fue elegir uno de los dos, fue **ponerlos en su lugar**:

- **El diagrama de fan-out** —el que aparece antes de las demos, cuando se
  explica que un skill puede delegar— ahora muestra **los cinco reales**: código,
  framework de tests, sync de casos, cobertura de AC, comentarios. Etiquetas más
  cortas que los slugs del plugin que había antes, así que el diagrama quedó más
  chico, no más grande.
- **La Demo 4 sigue corriendo los genéricos**, y ahora la slide lo dice: *"acá
  corren los genéricos de un plugin: la versión simplificada del demo, para que
  ande en cualquier repo"*. El escenario y la slide dejan de contradecirse.
- **El reporte agregado cambió las atribuciones** de slugs del plugin
  (`silent-failure-hunter`) a roles legibles (`fallas silenciosas`). Un reporte lo
  lee una persona: los nombres de máquina van en el dispatch, los humanos en el
  reporte.
- **La slide del linter se acortó.** Re-listaba los cinco hallazgos que la slide
  anterior acababa de mostrar; ahora dice *"el comentario que miente, el cast que
  miente, el test que no prueba nada"* y listo. Dos líneas menos, que pagan las
  que se agregaron en el diagrama.
- **Y la última slide de backup soltó su cláusula**, porque el mensaje se mudó al
  flujo principal donde sí se ve.

Neto: **cero slides nuevas, cero tiempo agregado**, y de paso la tesis de
cultivar aplicada a los agentes mismos — el plugin es la rampa de entrada, los
propios son donde terminás.

**Nota de build:** regenerar los diagramas movió también
`pipeline-antes.svg`/`-light.svg` sin que su `.mmd` cambiara — la versión de
Mermaid instalada recalcula la geometría (anchos de nodo, coordenadas de los
paths). Se commitean igual **a propósito**: si se revirtiera uno, el deck
quedaría con dos diagramas renderizados por versiones distintas, y las
diferencias de padding y métricas de fuente entre slides son exactamente lo que
esta semana se estuvo corrigiendo a mano.

### Una skill nueva: las reglas de cómo se edita este deck

`.claude/skills/talk-deck-editing/SKILL.md`. Es el repo comiendo de su propia
cocina: se cultivó exactamente como el deck dice que se cultiva cualquier cosa —
las mismas correcciones, repetidas, hasta que valieron la pena escribirlas. Cada
regla que tiene está porque ya salió mal una vez, y el decision-log tiene el
incidente de cada una.

Qué recoge, agrupado por cómo falla:

- **El gate, que no es opcional.** Marp recorta en vez de quejarse. Y el checker
  **falla a propósito ante una imagen que no cargó**, porque una imagen rota mide
  0 px y eso se leería como "entra todo" en una slide que se desborda.
- **Contar `<section>` del HTML, nunca los `---` del markdown.** Los
  delimitadores del frontmatter y los separadores de slide son el mismo token: la
  cuenta a mano da mal.
- **Exportar dentro de `slides/`.** Los paths a `diagrams/` e `img/` son
  relativos; un nivel más abajo dejan de resolver, los PDF sobreviven y el HTML
  publica imágenes rotas sin decir nada.
- **Las fallas silenciosas, por tipo**: línea en blanco adentro de un `<svg>`
  inline (Marp cierra el tag ahí y el resto se renderiza como texto suelto), una
  clase de CSS nueva sin su override en el tema claro, agrandar una clase
  compartida entre dos slides, un `-light.svg` que falta, los emoji que Marp
  reescribe a `<img>` de CDN, y la última fila de una tabla que no tiene borde.
- **Los callbacks se editan de a pares**, con la tabla de qué línea cita a cuál.
  Un cambio de un solo lado no rompe el render: rompe el sentido, en silencio.
- **Las afirmaciones se verifican, no se recuerdan.** Sobre el repo → leé el
  repo. Sobre una herramienta → leé la herramienta. Sobre lo que hace la demo en
  vivo → la slide y el escenario tienen que coincidir.
- **Agregar una slide al flujo principal cuesta tiempo**: decí cuántos segundos,
  preferí reemplazar antes que agregar, y pagalo comprimiendo algo.
- **Y tres "nunca"**: nunca `@`-importar las skills desde `CLAUDE.md`, nunca
  agregarle una excepción a `check-leaks.sh` para que pase un texto, y nunca
  declarar un build verificado sin la salida del gate a la vista.

El repo pasa de 5 a **6 skills**. La sexta no es un workflow de QA y se dice así
en `CLAUDE.md`, en `SOURCES.md` y en la slide del mapa del repo: *"una es cómo se
edita este deck"*. Que es, probablemente, la mejor prueba de la tesis que el repo
puede ofrecer sin decir una palabra más.

### El inventario cambió de destinatario

Estaba escrito para el autor: *"por qué mostrarlo"*, *"si agregás sólo tres
cosas"*, *"deliberadamente no mostrable"*, estimaciones en segundos de escenario,
referencias a en qué slide iría cada pieza. Un doc de preparación de charla.

Pero el que lo va a abrir es otra persona: alguien que salió de la charla y clonó
el repo para robarse ideas. Reescrito entero para ese lector.

Los cambios que importan, más allá del tono:

- **La tercera columna pasó de "por qué mostrarlo" a "por qué existe".** No es
  cosmético: obliga a nombrar el **dolor concreto** que hizo aparecer cada pieza,
  que es la única información con la que el lector puede decidir si le sirve. Y
  es la tesis del deck aplicada al doc — si reconocés el dolor, copiá la pieza; si
  no, salteala.
- **"Si agregás sólo tres cosas" → "si copiás sólo tres cosas"**, con esfuerzo de
  adopción ("veinte minutos, una vez" · "media tarde") en vez de segundos de
  escenario, y una columna de qué te da.
- **"Deliberadamente no mostrable" → "lo que no publiqué, y por qué".** La misma
  lista, pero deja de ser mi checklist de sanitización y pasa a ser consejo para
  alguien que va a publicar su propio setup: qué hay que decidir *antes* de subir
  el repo.
- **La sección de sanitización dejó la tabla de sustituciones** —que era para mí—
  y quedó en la lección: una promesa de sanear no alcanza, necesitás enforcement.
  Con los dos errores que me costó escribirlo (nada de tres letras o menos en la
  blocklist; escapá los puntos de los patrones de mail).
- **Se fue la sección "ya aplicado al deck"**, que era pura historia de
  construcción del deck y al lector no le dice nada.
- **Los "beats" de escenario pasaron a takeaways.** La misma frase, sin el
  andamiaje de *"vale 20 segundos"* o *"decilo al pasar"* alrededor.
- Y el catálogo cierra con lo único que sirve si no copiás nada: **la próxima
  corrección que repitas por tercera vez, escribila.**

**Y rompió dos referencias del deck**, que es exactamente lo que la skill
`talk-deck-editing` avisa que pasa: la slide del mapa del repo mandaba a la
columna *"por qué mostrarla"* y a la tabla *"si agregás sólo tres cosas"*, y
ninguna de las dos se llama más así. Arregladas.

Queda un wart: el archivo se sigue llamando `showable-inventory.md`, y
"showable" es el encuadre viejo —lo que yo puedo mostrar en pantalla—. Renombrarlo
toca la slide que imprime el path, así que se decide aparte.

## 2026-08-20 — Revisión cruzada charla ↔ catálogo, `/doctor`, y por qué se colgaban los builds

### Cuatro cosas que la revisión encontró

Pasar el deck contra el catálogo, buscando que no se contradigan. Tres de las
cuatro eran del tipo que más duele: **afirmaciones sobre este repo, falsas.**

- **`status-format` no estaba en el catálogo.** Es la tercera rule del repo y la
  más chica que tengo —cuatro líneas— y el catálogo listaba dos. Su *por qué* es
  lo que la hace valer: **el estado se escanea, no se lee.** Agregada al grupo de
  formato.
- **"Es lo que no entró en 30 minutos"**, en la slide del mapa del repo, dejó de
  ser cierto cuando el catálogo pasó a listar *todo* —incluidas las piezas que sí
  están en el repo y sí se demuestran—. Ahora la slide dice qué es el catálogo y
  que lo que ya está acá va marcado, que es la información que el lector
  necesita.
- **El catálogo afirmaba que `check-leaks.sh` "está enganchado como hook de
  git".** No lo estaba: `.git/hooks/` tenía sólo los samples. Y hay algo peor que
  el error, que es la razón por la que nunca podría ser cierto: **`.git/hooks/` no
  se versiona**, así que clonar el repo te trae el script y no la protección. La
  redacción pasó a imperativo —*enganchalo así*— con esa trampa dicha en voz alta,
  y de paso el hook quedó instalado localmente.
- **Faltaba el hook de typecheck**, que es el remate de toda la pirámide del deck.
  El catálogo tenía permisos y el hook de git, y no la pieza que un lector va a
  querer copiar primero. Ahora está, con su historia (corrección → memoria →
  skill → hook) y con su límite honesto: **un hook no razona.** Matchea una tool y
  corre un comando; todo lo que necesite criterio sigue siendo skill o rule, y por
  eso son pocas las piezas que llegan hasta arriba.

### `/doctor` entró, y no gratis

Verificado antes de escribirlo, que es la regla: el binario tiene
`doctorHandler`, un `DISABLE_DOCTOR_COMMAND`, y strings que lo usan para
diagnosticar acceso al keychain, entitlements y TLS detrás de un proxy
corporativo. No se puso de memoria.

Con la fila nueva, la slide se pasaba **75px**. Se pagó recortando cuatro bullets
donde había redundancia real: `/loop` tenía dos ejemplos que decían lo mismo,
*unattended* repetía "en cron" que ya estaba en `/schedule` dos bullets antes, y
*agentes como piezas* venía diciendo lo que ahora dice el diagrama de fan-out.
Neto: cuatro líneas menos para una fila de dos.

Y encaja mejor de lo que parece: los otros ítems de esa slide son más capacidad,
`/doctor` es la contracara honesta —**cuando no anda, hay un comando que te dice
por qué**—. Para alguien que el lunes va a probar esto en la laptop del trabajo,
detrás de un proxy, es probablemente el ítem más útil de la slide.

### Y la causa de los builds que se colgaban

Los builds venían tardando veinte minutos o muriendo sin renderizar nada. No era
iCloud ni Chrome: **marp espera stdin.** Cuando hereda un stdin abierto que nadie
va a cerrar —una tarea en background, un runner de CI, un `nohup`— imprime
*"Currently waiting data from stdin stream"* una vez y se queda ahí. No falla, no
tiene timeout, no dice nada más.

`build-deck.sh` ahora redirige `< /dev/null` en las dos invocaciones de marp, con
el comentario de por qué. Verificado en las dos direcciones: los cuatro HTML
tardan **2 segundos** —el export a HTML no necesita browser, sólo el PDF— y los
cuatro PDF unos 90 segundos. Contra veinte minutos colgado.

Está también en la skill `talk-deck-editing`, en la sección del build: si se
cuelga, es stdin. Es exactamente la clase de cosa por la que esa skill existe.

### Corrección: `/doctor` hacía algo bastante más interesante que lo que decía la slide

La slide decía *"diagnostica instalación, keychain y el proxy corporativo que te
rompe el TLS"*. No era falso, pero describía la cosa chica: eso es
`claude doctor`, el modo read-only de terminal. La documentación oficial del
comando en sesión dice otra cosa, y es mucho mejor para este deck:

> audita el setup — encuentra **skills, MCP servers y plugins que no usás contra
> su costo de contexto**, marca **hooks lentos**, deduplica los `CLAUDE.md`
> locales contra los versionados, recorta de los versionados lo que Claude podría
> deducir del código, y **migra la guía siempre-cargada que queda a skills y
> `CLAUDE.md` anidados que cargan on-demand.** Reporta primero y pide
> confirmación antes de cambiar nada.

Eso es **la pirámide del deck, auditada por una herramienta.** Encuentra lo que
está siempre-cargado y no debería, y te ofrece bajarlo a on-demand — que es
exactamente la distinción que la charla dedica una slide entera a explicar. La
línea nueva dice eso, en una respiración.

Y por eso se agregó también a la slide de costos, donde conceptualmente vive: al
lado de `/context` (qué está cargado y cuánto ocupa) y `/usage` (el consumo),
`/doctor` es **qué de eso no estás usando**. Una cláusula en una línea que ya
existía, cero tiempo.

**La lección, que fue a la skill.** Grepear el binario probó que el comando
existe y me mostró strings sobre keychain y proxy — así que escribí un
diagnosticador de red. La mitad interesante era invisible desde ahí.
**Verificar que algo existe no es verificar qué hace.** La regla en
`talk-deck-editing` decía "una afirmación sobre una herramienta → chequeá la
herramienta"; ahora aclara que hay que leer la documentación *de la afirmación que
estás haciendo*, no del nombre.
