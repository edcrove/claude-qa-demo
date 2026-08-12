# Decision log

The real (non-fictional) history of this repo, so future sessions — human or
agent — don't have to rediscover why things are the way they are.
`evolution-timeline.md` tells the *demo fiction* (the cultivated-setup story the
talk narrates); this file records the actual decisions.

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

## 2026-08-12 — Human ownership made explicit in the deck

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

**2026-08-12 (later same day):** author reported the recurring one-liners
were too easy to miss skimming the deck on a phone, and asked for an
explicit summary. Added a dedicated slide "Qué le toca a la persona" (agent
vs. person table — execution/criterio/revisión/decisión/responsabilidad)
right after "El patrón" and before the closing callback question. Deck is
now 46 slides (33 main flow, was 32). `talk-design.md` slide map and device
#8 updated to match.

## 2026-08-12 (later still) — QA-reviewer pass applied

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

### Known open items

- `mocks/github/pr-7.diff` is readable but not `git apply`-able (the test-file
  diff is nested inside the first hunk). Fine for the demo, broken for anyone
  who tries to apply it.
- The deck's "Mi línea de tiempo real" (months 1–6) and
  `evolution-timeline.md` (weeks 1–7) tell different fictional timelines with
  different artifact sets. Decide whether that divergence is acceptable.
- Title final choice pending — candidates in `docs/talk-design.md`.
