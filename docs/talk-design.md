# Talk design

**Title:** "Tu setup de QA no se diseña: se cultiva" — *de prompt suelto a
skills, rules y hooks* (final — this is how the talk was announced,
2026-08-13)
**Format:** 30 minutes — ~25 talk + demos, ~5 Q&A · one shared screen (slides + terminal)
**Audience:** mixed dev/QA technical meetup
**Repo:** `github.com/edcrove/claude-qa-demo` (this repo — fully offline, clonable)

## Objective

Show how a QA automation engineer can orchestrate their working day with Claude +
subagents, and leave the audience with a concrete feeling of **"I can start doing
this on Monday"**. The differentiator versus other "AI for testing" talks is the
**organic angle**: the setup is not designed in a meeting — it is cultivated by
combining what already exists (plugins, MCPs) with what gets distilled from the
team's own process.

## Central message

> Skills + Rules + Memory + Subagents = a reproducible QA workflow.
> It is not designed up front: it is cultivated.

The promotion pyramid is the mechanism:

```
Prompt suelto → Memory → Skill → Rule → Hook
   (today)     (tomorrow) (week)  (month) (quarter)
```

Each level up: more structure, less future ceremony. A correction repeated
3 times is a promotion waiting to happen.

## Narrative structure

The deck (see `slides/slides.md`) applies these deliberate storytelling devices:

1. **Cold open with a scar** (slide 2). The talk opens with the 90-minute
   phantom-flakes incident — before the bio. The scar pays off twice later:
   it is the origin of the `no-parallel-ci` rule, and Demo 3 shows the rule
   preventing exactly that incident, live.
2. **One pain as the spine.** The pyramid is told as a single story: the same
   forgotten typecheck climbing the levels (prompt → memory → skill → hook).
   Each level exists because the previous one was not enough. The rule keeps
   its own scar (the cold open) so both origin stories stay traceable.
3. **The demos are one clocked day** (9:00 → 18:00). Each demo ends with an
   italic handoff into the next. Demo 5 triages the very branch the day
   produced (`feature/DEMO-100-channels-coverage`), so the fiction is
   self-consistent end to end.
4. **The "Mañana" mirror.** The pain slide ends with *"Mañana — sesión nueva.
   Re-explicás el ticket, el plan, las convenciones."* Demo 6 closes by quoting
   that line and negating it word for word. That is the emotional arc of the
   talk in two sentences.
5. **The agent loses on stage.** In Demo 3 Claude *tries* to trigger CI and the
   rule blocks it (build 43 is RUNNING on stage in the mock). Guardrails are
   shown catching the agent, not just the human — this inoculates against
   "perfect demo" skepticism.
6. **The question gets answered.** Slide 4 asks *"¿Puedo automatizar mi proceso
   de QA con IA?"*; a callback slide answers it explicitly before the closing.
7. **Cultivating goes beyond the agent's config.** The "El agente también
   construye" slide widens the thesis: the agent also builds *for the project* —
   CI tuned to your rules, linters, SonarQube quality gates, coverage and
   reporting, notifications. Things that used to require dedicated research and
   deep tooling skill are now a conversation. Learning tools is part of
   cultivating; don't fear the unknown — the cost of learning collapsed.
8. **Ownership doesn't cultivate away.** Planted at 4 points: mechanics
   (subagent review slide — "quien aprueba sigue siendo responsable de lo que
   aprueba"), Demo 4's aggregated result ("no sé, lo hizo la IA" no es una
   respuesta"), a dedicated summary slide **"Qué le toca a la persona"**
   (agent/person table: execution vs. criterio/revisión/decisión/
   responsabilidad — right after "El patrón", right before the callback
   question), and the closing thesis slide ("el criterio, el dominio y la
   firma siguen siendo tuyos"). The recurring one-liners keep the idea alive
   scene by scene; the summary slide is where it gets stated plainly enough
   to survive a quick skim (added 2026-08-13 after the one-liners alone read
   as too easy to miss). The baseline the talk demonstrates is delegation of
   *execution*, never of *accountability* — the audience should leave knowing
   which is which, not just that more gets automated.

## The one-day arc

| Time | Scene | Skill / piece on stage | Pain it answers |
|------|-------|------------------------|-----------------|
| 9:00 | Demo 1 — ticket → coverage plan | `ticket-coverage-gap-analysis` | 4 tabs to understand context |
| 10:00 | Demo 2 — TDD on the gap Demo 1 left open | `superpowers:test-driven-development` | landing on code with no red test |
| 11:30 | Demo 3 — local gate + rule blocks the trigger | `local-build-gate` + `no-parallel-ci` | 10-minute CI runs that die on a typo |
| 14:00 | Demo 4 — multi-agent PR review (5 parallel subagents) | `multi-agent-pr-review` + pr-review-toolkit | repeating the same review comments |
| 17:00 | Demo 5 — CI triage against the known-issues registry | `ci-failure-triage` + `memory/known-issues.md` | triaging reds by hand |
| 18:00 | Demo 6 — repeated correction becomes a skill | `superpowers:writing-skills` | re-explaining everything tomorrow |

## Slide map

`slides/slides.md` — 46 slides total (counts verified against Marp's own
section count, not eyeballed):

- **Main flow: 32** (cold open → thesis → mechanics → 6 demos → timeline →
  "el agente también construye" → sources → pattern → "qué le toca a la
  persona" (human/agent split summary) → question answered → "3 pasos para
  el lunes" → close). Dropped "Los workflows que emergieron" (2026-08-13,
  QA-reviewer pass): redundant with "El flujo end-to-end", which already
  names the same skills as a pipeline diagram right before the demos start.
- **Appendix: 9** — anatomy + real example for memory / skill / rule / hook
  (moved out of the main flow to protect demo time)
- **Q&A backup: 5** — token costs, model churn (skills survive, prompts don't
  always), offline/stack portability, **who audits the CI-triage classifier**
  (added 2026-08-13 — the most QA-native skeptical question the deck didn't
  have a prepared answer for)

## Title — decided

**"Tu setup de QA no se diseña: se cultiva"** won. This is how the talk was
publicly announced (2026-08-13) — no longer a pending decision. Runner-up
and other candidates considered (2026-08-04), kept for record:

| Candidate | Angle | Outcome |
|---|---|---|
| **Tu setup de QA no se diseña: se cultiva** | thesis-first; bookends with the closing slide | **chosen — announced** |
| De prompt a skill: cultivando workflows de QA automation con agentes de Claude | original working title | retired |
| De prompt a skill: tu workflow de QA no se diseña, se cultiva | minimal evolution keeping the brand | not chosen |
| De 5 líneas a 5 subagentes | concrete arc (initial CLAUDE.md → PR review fleet) | not chosen |
| El QA que dejó de re-explicar su proyecto | pain-first | not chosen |

Final subtitle: *"De prompt suelto a skills, rules y hooks."* — this drops
the "Claude" mention the original constraint wanted in the subtitle. The
name still appears early ("Cuando empezó la IA: dos pasos" names Claude
explicitly, and it recurs through every demo), so the constraint's
underlying goal — don't let the tool disappear from the framing — still
holds even though the literal subtitle slot doesn't say it. Not treated as
a violation worth re-opening the title decision over.

## Sanitization (rule #1)

Everything on screen is fictional: "Acme Streaming", `DEMO-100`,
`jenkins.demo.local`, `demo@acme.example`. `scripts/check-leaks.sh` greps the
whole repo (tracked + untracked) for banned employer strings and fails on any
match. The bigger leak surface is the **global** Claude config (global
CLAUDE.md, MCP server names, tokens in autocomplete) — that is what
`scripts/demo-profile.sh` isolates.

## Risks and mitigations

| Risk | Mitigation |
|------|-----------|
| Network / VPN down | 100% local: JSON mocks on disk, no real MCP |
| Live demo derails | each scene has an expected-output screenshot fallback |
| Time overrun | anatomy slides in appendix; each demo has a skip-ahead point |
| Accidental leak | `check-leaks.sh` + `demo-profile.sh` (isolated config) |
| Token cost on stage | mid-tier model via demo profile; switch up only for Demo 4 |
| node_modules evicted by iCloud | `prep-demo.sh` detects dataless files and reinstalls |

## Pre-flight checklist (day of talk)

- [ ] `./scripts/prep-demo.sh` → all state assertions green
- [ ] `./scripts/check-leaks.sh` → 0 matches
- [ ] launch through `./scripts/demo-profile.sh`, run `/context`, confirm only
      the repo's `CLAUDE.md` is loaded
- [ ] terminal font ≥ 16pt, notifications off
- [ ] slides rendered locally (`slides/slides.html`), no Wi-Fi needed
- [ ] backup recording on the desktop

## Out of scope

- Tool comparisons (Cursor, Copilot, etc.)
- Model internals or detailed pricing
- Step-by-step plugin setup (link to docs instead)
- Real MCP with credentials — mocks only
