# Showable inventory — what the private toolkit has that the deck could use

The demo repo ships a deliberately small setup: 5 skills, 3 rules, 1 hook. The
author's real toolkit — a separate, private repo, the one the "lo genérico puede
vivir en un repo aparte" slide refers to — has considerably more, and some of it
is better talk material than what is on stage today.

This is the inventory, **already sanitized**. Every entry says what it is, why it
would earn stage time, and whether the demo repo already has it. Nothing below
names the employer, a real repo, a real job, a real ticket key or a real host.

## Sanitization contract

`scripts/check-leaks.sh` is the enforcement, not this section. It greps the whole
repo (tracked + untracked) for banned strings and fails the build. When you lift
anything from this file into a slide, run it.

Substitutions used throughout:

| Real thing | Written here as |
|---|---|
| the employer, the product, sibling products | Acme Streaming / "the product" / "the sibling team" |
| the functional-test monorepo | `api-tests` |
| the deployable service repo | `platform-service` |
| the CI regression job | `api-regression` |
| the one suite that must not overlap | `catalogRegression` |
| the two API gateways | `web-gateway` / `app-gateway` |
| ticket keys | `PROJ-1234`, release tickets `REL-4321` |
| hosts | `ci.example.com`, `jira.example.com`, `testrail.example.com` |
| the shared team channel | `#platform-contributors` |
| framework classes | `ApiTestBase`, `ApiContext`, `ProductTestData` |
| the toolkit repo itself | "the shared toolkit repo" — deliberately unnamed |

**The toolkit's name stays out of the deck.** It is a real repo in the
employer's GitHub org; printing the name is a one-search path from the talk to
the org. Say "un repo aparte, compartible" and show the *shape*, not the name.

---

## Rules

The demo repo has 3. These are the ones worth adding or upgrading, grouped by
what kind of rule they are — which is itself a slide, because "rule" gets read
as "prohibition" and only two of these are prohibitions.

### Already in the demo repo, but thinner than the real one

**`no-parallel-ci`** — the real version has three things the demo's does not,
and each is a beat:

1. It names the *scope* of serialization precisely ("only `catalogRegression` is
   serialized per environment; other suites are not"). A rule that over-reaches
   gets ignored.
2. It points at a **guard script** the trigger scripts already call, so the rule
   is not the only line of defence — the rule tells the agent, the script tells
   everything else.
3. It ships an **emergency bypass**: `CI_GUARD_SKIP=1`. Beat: *"una regla sin
   válvula de escape no se respeta, se saltea a mano y en silencio."*

**`english-only`** — the real one enumerates the surfaces (PR titles and bodies,
review comments, issue comments, inline replies, commit messages, release notes)
and then lists **exceptions that must not be translated**: ticket ids, build
numbers, branch names, code identifiers, log excerpts, quoted third-party text.
The exceptions are what makes it survive contact with reality.

### New — format rules (mechanical, cheap, near-perfect compliance)

**`pr-description-ticket-first-line`**
> Line 1 of a PR description is the ticket key. Line 2 blank. Then the body.
> A PR that changes test code must include a `## Test evidence` block with the
> direct build link, a before/after-vs-`main` comparison **on the same matrix**,
> and a net-new-failures statement. Evidence must reflect the current head — if
> commits land after the build, the evidence is stale.

Why it shows well: it is boring, it is verifiable, and it is the kind of thing
every reviewer nags about forever. The staleness clause is the interesting half —
it encodes *when evidence stops counting*.

**`response-context-header`**
> Every reply starts with three lines: branch, workspace, time. `Time:` is never
> optional; run `date` to fill it.

The odd one out, and worth 20 seconds precisely because of that: this rule
governs **how the agent talks to you**, not what it does to the code. It exists
because an answer that does not say which branch it was about caused a wrong-branch
mistake once. Beat: *"podés gobernar el formato de la respuesta, no sólo la
acción."*

### New — decision-procedure rules (the QA-native category)

**`regression-evidence-scope`** — the single best rule in the toolkit for this
audience. It does not forbid anything; it tells the agent **how much evidence a
change needs, derived from the changed file paths, not from the ticket**:

> - Every changed file under `tests/catalog/` → attach a `catalogRegression` run.
> - Anything outside it — shared framework, base classes, common services → attach
>   **both** a full `regression` **and** a `catalogRegression` run, because common
>   code is shared with the sibling team and the narrow suite does not prove
>   no-regression.
> - When unsure whether a path counts as common, treat it as common.
>
> Fast gate first: run the narrow validation group before the full suites. A full
> regression costs ~an hour; the gate catches an obviously broken fix in minutes.
> Never attach the gate run *instead of* the full evidence.

Three things in one slide: risk-scaled effort, a stated default for ambiguity,
and a cheap-check-before-expensive-check ordering. This is what a senior QA does
in their head, written down.

**`scratchpad-for-working-docs`** — where the agent's generated documents go.

> Every document you generate while working a ticket goes in
> `<repo-root>/scratchpad/`, gitignored. Plans, coverage matrices, failure
> analyses, triage notes, proposals. Never a `.md` at the repo root. Never in the
> tool-config directory — that is config, not a document store.

And the table that makes it click:

| Location | Lifetime | For |
|---|---|---|
| `<repo>/scratchpad/` | survives the session | documents you will reopen: plans, analyses, evidence |
| the harness's own session scratchpad | session-only | throwaway scripts, JSON dumps, intermediate output |

Beat: an agent that writes files needs a **filing rule**, or six months later the
repo root is a landfill of `analysis-final-v2.md`. Nobody thinks of this until it
has already happened.

**`branch-management`** — rebase onto the default branch, never merge, when
updating a ticket branch; `--force-with-lease` after. Stash or commit before
switching. Generic, one screen, immediately copyable.

### New — vocabulary rules (the category nobody expects)

**`second-checkout-definition`** — "R1" is the main checkout, "R2" is a second
local checkout of the same remote used in parallel; both paths come from config;
if R2 is not configured on this machine, say so instead of guessing a path.

This rule teaches the agent **your team's jargon**. It has no procedure and
forbids nothing. Great 15-second aside: *"una rule también puede ser un
glosario."*

### New — the distilled-review-feedback rule

**`test-antipatterns`** — the biggest rule in the toolkit, and the one that
proves the deck's thesis best, because every bullet is a defect that was caught
in a real code review and then written down so it would never be caught again.
Show three or four items, never the whole thing:

- **Fail fast in suite setup.** Don't `catch → log → return null` for required
  setup: a null cached token makes every request 401 and produces a confusing
  mass-failure run instead of one clear setup error.
- **Smoke tests must assert the value the production path consumes**, not a fresh
  fetch — otherwise a cache-injection regression passes the smoke test.
- **Soft-assert the leaves, hard-assert the gates.** Route independent field
  checks through a soft assert so one run surfaces every wrong field; keep hard
  any check that gates a later dereference, or the soft path NPEs before the
  final assertion runs.
- **Reuse the test-data constants instead of hardcoding strings.**
- **No ticket id in any source comment.** A comment explains what and why; the
  ticket that added it goes stale and is already reachable via `git blame`.
- **No AI commentary anywhere** — no verbose reasoning prose in Javadoc, no
  generated-by footer in PR descriptions or commit messages. Write comments a
  human engineer would leave.

That last one is the sleeper. It is a rule whose entire job is to keep the agent's
fingerprints off the artifact, and it lands hard with an audience that is quietly
worried about exactly that. Beat: *"la regla existe porque el output se tiene que
poder defender como tuyo."*

Also worth saying out loud: this rule cites the **PR number** each item came
from, never the reviewer's name. Provenance without naming a person.

### Rule placement — a slide in itself

Two directories, one discipline:

- `rules/user/` — loads in **every** project. Keep this set small.
- `rules/workspaces/<repo>/` — loads for one repository only.

> Filing a project-specific rule under `user/` makes it load everywhere, which is
> almost always wrong. If the rule names a repo, a job or a package, it belongs
> under `workspaces/`.

This is the concrete, mechanical version of the deck's cost slide: *lo
siempre-cargado es lo único con costo recurrente.* The real toolkit has 4 global
rules and 8 repo-scoped ones — a ratio you can put on screen.

---

## Skills

The demo repo has 5. These are the additions that carry a distinct idea rather
than another instance of the same one.

**`feature-knowledge-base`** — the strongest new skill, and the only one that
changes what the audience thinks a skill *is*. Two modes:

- **RECALL**, at the start of ticket work: grep the knowledge base for the
  endpoint / domain / region / ticket keywords, read every match, follow
  `[[cross-links]]`, and surface what is already known **before** proposing work.
- **CAPTURE**, after analysis: copy the template, fill the frontmatter, write
  Summary / What we learned / Evidence / How to apply, cross-link, index it.

The payoff line is in its quality bar: *"an entry that only records what happened
is a changelog, not knowledge — every entry needs a **How to apply to future
tickets** section."* This is durable memory that is **not** the harness's memory
feature: plain files, grep-addressable, shared across two different agent tools.

**`ci-regression-review`** — reviews a whole CI regression run and produces a
**verdict, not a list**:

1. **Reconciled counts, not the dashboard's.** Cross-check the totals for
   internal inconsistency before quoting them — totals against the sum of the
   suites, the suite list against the matrix that was supposed to run — and
   adjust, stating both the raw and the reconciled number. Flag partial
   coverage when part of the matrix is missing from the report.
2. Clusters by **root cause**, not by test class.
3. A **per-team split** derived from the test package, flagging failures one
   team's tests surfaced in another team's code.
4. Skip classification.
5. Whether the release under test is **actually at fault** — reproduced against
   production.

Best beat available anywhere in the toolkit: point 1. Every reporting pipeline
grows quirks — a run counted twice somewhere, a fork missing from the summary,
a retry inflating a total — and the number on the dashboard is the one that ends
up in a status update. The skill is where that reconciliation lives, so nobody
re-derives it at 9am on a Monday, and nobody quotes the raw number by accident.
Beat: *"un skill también es donde guardás cómo se leen de verdad los números de
tu propio reporte."*

**`session-status-panel`** — one panel: what every other open agent session in
this project is doing (branch, last turn, what it is blocked on), what CI is
doing, and what came in on the team channels. Fires on the single word "status".

Pairs with the deck's background-agents / parallel-work slide: once you run more
than one session, you need a **view over your agents**, and that view is itself a
skill. Its implementation reads the harness's own transcript files — see
`session-mining` below.

**`release-ticket-structure`** — reads release-management tickets, where the
validation evidence lives in **custom fields**, not in comments or attachments.

Include this one specifically to make a point the deck currently misses: this
skill has **no checklist and no procedure**. It is a *reference* — it tells the
agent where the information actually is in a system whose UI hides it. Roughly
half the toolkit's skills are references, not procedures. Beat: *"un skill no es
sólo un procedimiento; a veces es sólo saber dónde está la data."*

**`local-ci-compile`** — replicates the CI compile step locally, offline, in a
clean `git worktree` so untracked files cannot cause duplicate-class errors.
Generic pattern, and the worktree detail is a genuinely non-obvious trick.

**`ticket-to-tests-workflow`** — the composite: ticket → plan → coverage matrix →
implement → create the test-management cases → map ids → PR. Worth one line as
the "skills compose into a pipeline" example; too big to demo.

---

## Hooks and permissions

The demo repo has one `PostToolUse` typecheck hook. Two additions, and they are
different *kinds* of automatic.

### The permissions block — the biggest gap in the demo repo

`settings.json` is not only hooks. The real one carries an allow / ask / deny
split that a QA-and-security audience will react to more than any skill:

```json
{
  "permissions": {
    "allow": [
      "Bash(git status:*)", "Bash(git diff:*)", "Bash(git log:*)",
      "Bash(git show:*)", "Bash(gh pr view:*)", "Bash(gh pr checks:*)",
      "Bash(jq:*)"
    ],
    "ask": [
      "Bash(git push:*)", "Bash(gh pr edit:*)",
      "Bash(gh pr review:*)", "Bash(gh pr merge:*)"
    ],
    "deny": [
      "Read(**/secrets.env)", "Read(**/.env)",
      "Read(**/id_rsa)", "Read(**/id_ed25519)"
    ]
  }
}
```

Three tiers, three intents: **allow** the read-only things so you stop clicking
approve fifty times a day; **ask** on anything that leaves your machine or
changes someone else's view of the work; **deny** the files the agent should not
be able to read at all, so a prompt cannot talk it into it.

Beat, and it lands: *"`ask` es donde vive la firma. Todo lo que sale de tu
máquina pasa por ahí."* This is the accountability thread made mechanical, and
it is one JSON block.

### `check-leaks` as a **git** pre-commit hook

```bash
ln -s ../../scripts/check-leaks.sh .git/hooks/pre-commit
```

Useful for drawing the line the deck never draws explicitly: a **harness hook**
fires on the agent's tool calls; a **git hook** fires on the repository, whoever
or whatever is committing. The agent cannot route around the second one. Beat:
*"el hook del agente protege tu sesión; el hook de git protege el repo — del
agente incluido."*

---

## Otros elementos — the section the deck does not have

This is where the real toolkit is furthest ahead of the demo repo, and where a
QA audience will lean in, because it is all the same move: **treat your agent
setup as software, and apply the practices you already sell.**

### 1. Static validation of your own skills — `test-skills.sh`

One script, nine checks, per skill:

```
1. SKILL.md exists
2. frontmatter parses, and `name` matches the directory name
3. `description` exists, is non-trivial, and states when to invoke
4. relative markdown links resolve to real files
5. [[wikilinks]] resolve to a rule or knowledge-base entry
6. config variables referenced are declared in a *.env.example
7. helper functions referenced exist in the helpers script
8. shipped scripts pass `bash -n`
9. no references to files retired from the repo
```

And its own honest disclaimer, which is the best line in the toolkit:

> This is static analysis. It cannot prove a skill produces good output — it
> proves a skill will not fail on a broken reference, a missing variable or a
> function that does not exist.

Check 2 is the one to say out loud: if `name` does not match the directory, **the
harness never finds the skill** — it fails silently, forever, and looks like the
model ignoring you. Check 5 catches the real rot in a markdown repo: a rule got
renamed and four skills now point at nothing.

**This is the single strongest addition available.** A QA talk that shows tests
for the test setup closes its own loop.

### 2. Read-only live smoke tests — `test-skills-live.sh`

Exercises the read-only path of every integration each skill depends on, against
the real systems, with the operator's own credentials, and three outcomes with
explicit meanings:

- **PASS** — the dependency answered as expected
- **SKIP** — a precondition is absent (VPN down, value not configured). Not a bug.
- **FAIL** — the dependency is reachable but behaved wrong. Investigate.

Plus a safety contract stated in the header: it **never writes** — no build
triggered, no deploy, no ticket labelled, no case created, no reviewer requested.
Skills whose purpose *is* to write are covered only up to their pre-flight gates,
and those are marked `WRITE-GATED` in the source.

The SKIP-is-not-FAIL distinction is a small, real piece of test-design craft, and
it is the same distinction the demo's `ci-failure-triage` skill makes about
flakes. Same instinct, one level up.

### 3. The secrets architecture

- Credentials live in `~/.config/<toolkit>/secrets.env`, mode `0600`, **outside
  the repo**. Nothing in the tree may contain a token.
- Non-secret but machine- or team-specific values (org, repo, URLs, board and
  project ids) live in a separate `site.env`, also outside the repo.
- The repo ships only `*.env.example` templates.
- One helpers script sources both and exposes functions, so skills never
  hand-roll `curl` with inline credentials.

And the rule that is worth the whole section:

> **Never pass a token as a literal on a command line** — it is recorded in shell
> history *and in agent transcripts.*

That second clause is new information for most of the room. The transcript is a
leak surface people have not thought about yet, and it is exactly the kind of
thing this talk should be handing out.

### 4. The config/site split — the mechanism that makes sharing possible

> If a number, id, URL or path differs between teams or machines, it goes in
> `site.env` and the skill reads the variable. Add the variable to
> `site.env.example` in the same change.

And `test-skills.sh` check 6 **enforces it**: a skill referencing an undeclared
variable fails validation.

This is the concrete answer to the deck's "lo genérico puede vivir en un repo
aparte y compartible" slide. Right now that slide asserts shareability; this is
the machinery that earns it. Without it, "shareable" means "everyone forks it and
edits twelve hardcoded strings".

### 5. The knowledge base as a structured artifact

Not a notes file — a directory with a shape:

- `INDEX.md` — a table of every entry: domain, **status**, tickets, one-line
  summary
- `TEMPLATE.md` — the entry skeleton, with typed frontmatter (`domain`,
  `endpoints`, `platforms`, `regions`, `tickets`, `tags`, `status`,
  `last_updated`, `related`)
- a **status lifecycle**: `hypothesis` → `open` → `confirmed`, flipped forward
  only when proven
- `[[slug]]` cross-links between entries
- fixed sections: Summary / What we learned / Evidence / How to apply to future
  tickets / Open questions

The status field is the beat: *"el agente puede escribir acá, pero tiene que
marcar si lo confirmó o lo supone."* An agent-writable knowledge store that
distinguishes verified from guessed is a QA artifact, not a wiki page.

### 6. `Last verified: YYYY-MM-DD`

Any claim about how an external system **currently** behaves carries a
verified-on date in the body. One line per claim, and staleness becomes visible
instead of silently rotting into a wrong instruction the agent follows
confidently.

Cheapest idea in the whole inventory. Steal it in five seconds.

### 7. Distribution: the setup as an installable plugin

`.claude-plugin/plugin.json` + `marketplace.json` + an `install.sh` that merges
the settings fragment and symlinks the skills. Your cultivated setup stops being
"my dotfiles" and becomes something a teammate installs.

Ties the "repo aparte y compartible" slide to something concrete: not "copy these
files", but `/plugin` and done. Also the honest counterweight — the deck already
tells people to vet third-party plugins; here you are the third party.

### 8. Slash commands wrapping skills

`commands/review-regression.md`, with frontmatter `description` and
`argument-hint`, `$1` for the build number, and this instruction in the body:

> Invoke the `ci-regression-review` skill and follow its stages in order — **do
> not improvise a shortcut analysis.** If no build number was given, list recent
> runs, pick the most recent finished one matching the group, and say which one
> you chose before analysing it. If more than one plausibly matches, ask rather
> than guessing.

Two things worth 30 seconds: a **command** is a typed entry point (`/review-regression 44`)
while a **skill** is model-discovered — and the command's job here is to stop the
agent from taking the cheap path through the skill it just invoked.

### 9. Session mining — `scan_sessions.py`

Reads the harness's own transcript files (JSONL, on disk, per project) and prints
per recent session: branch, working directory, first task, last user turn, last
assistant turn.

Directly under two slides the deck already has: the conversation-mining note
after Demo 6, and the background-agents item on the final slide. It is the proof
that "pedile que escanee tus conversaciones pasadas" is not hand-waving — the
transcripts are **files**, and files can be grepped, counted and summarized.

### 10. Governance conventions worth quoting verbatim

From the toolkit's own CONTRIBUTING, the four rules for contributing to the
setup: **English only** · **no secrets, not even in an example** · **no personal
data** (write "the operator", cite a PR number rather than a reviewer's name) ·
**no site values hardcoded**.

Then two agent-specific insights that are not obvious and are not about code:

- **Example vs data.** A ticket id introduced by "e.g." is an example and must be
  a placeholder — a real one reads as live state and rots. A ticket id that *is*
  the content (the known-issues registry, a genuine dependency, the review a
  convention came from) stays real; replacing it destroys the information the
  artifact exists to carry. Test: *could a reader still act on the line with the
  id removed?* If yes, it was an example.
- **Deprecating something means deleting it.** Git history is the archive. A
  `removed-*` or `old-*` directory is dead weight **an agent may still read and
  act on.** This one is genuinely new for most people: dead code is a human
  smell; dead *instructions* are an active hazard.

---

## If you only add three things

Ranked by (stage value ÷ time to explain), for a deck that is already ~18 minutes
over budget:

1. **The permissions allow/ask/deny block.** One JSON screen, ~40 seconds, and it
   makes the whole accountability thread mechanical instead of rhetorical.
   Belongs in the appendix next to the hook anatomy.
2. **`test-skills.sh`.** ~60 seconds. Tests for the test setup, in a QA talk. It
   closes the loop the talk opens, and no other AI-for-testing talk is showing
   this.
3. **`regression-evidence-scope`.** ~45 seconds as a *nota al pasar* after Demo 3
   or in the Q&A backup. It is the most QA-native artifact in the inventory: a
   rule that encodes how much proof a change owes.

Runners-up, cheap and quotable in one line each: `Last verified:` dates, the
transcripts-are-a-leak-surface warning, and the `rules/user/` vs
`rules/workspaces/` ratio as the concrete version of the context-cost argument.

## Deliberately not showable

- **The knowledge-base entries themselves.** The structure is showable, the
  content is pure product internals — endpoint shapes, gateway behaviour
  differences, region enforcement, account provisioning. Show `TEMPLATE.md` and
  a redacted `INDEX.md` row shape, never a real entry.
- **`check-repo-policy.sh`.** Validates a repo name against the org's naming
  policy: approved suffixes, a redundant-word blocklist that is literally a list
  of the employer's brands, discouraged internal abbreviations. The *pattern* is
  great — encode your org's written policy as a script the agent runs before
  creating a repo — but every data table in it is identifying. Describe the
  pattern in one sentence; do not put the file on screen.
- **The repo-scoped rules that are all product knowledge**
  (test-management conventions with real project and suite ids, the shared-code
  ownership map, the CI parameter reference). Their *shape* is the reusable part
  and it is already covered above.
- **The specific reporting defect behind the reconciled-counts step.** The
  toolkit names the exact mechanism and the exact multiplier, because the skill
  needs it to do arithmetic. That is a live bug in a team's own tooling and it
  is not the author's to put on a projector. Keep the step generic — *check the
  totals for internal inconsistency and adjust* — and do not lift the mechanism
  back out of the toolkit on a future pass.
- **The toolkit's name and the sibling repo's name.** See the sanitization
  contract at the top.
