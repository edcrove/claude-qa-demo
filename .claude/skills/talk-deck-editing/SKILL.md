---
name: talk-deck-editing
description: Use when editing the talk's deck — slides/slides.md, slides/themes/*.css or slides/diagrams/*.mmd. Covers the render gate every change must pass, the failure modes that are silent (clipped slides, broken relative paths, blank lines in inline SVG, colour drift in one theme only), the callbacks that must be edited in pairs, and the rule that every claim gets checked against the repo. Use it before adding a slide too, because main-flow slides cost live time. Triggers: "editá la slide", "agregá una slide", "cambiá el diagrama", "arreglá el overflow", "rebuildeá el deck".
---

# Editing the talk deck

This skill exists because the deck fails **silently**. Marp will happily render a
slide whose content runs past the bottom edge, an image that never loaded, or an
inline SVG it closed early — no error, no warning, and you only find out on the
projector.

Every rule below is here because it already went wrong once. `docs/decision-log.md`
has the incident for each.

## Checklist for any deck change

```
- [ ] 1. Make the edit in slides/slides.md (or themes/, or diagrams/*.mmd)
- [ ] 2. If it touches a diagram source: ./scripts/build-diagrams.sh
- [ ] 3. ./scripts/build-deck.sh          (all four variants, HTML + PDF)
- [ ] 4. node scripts/check-slide-overflow.js on each variant → 0 overflowing
- [ ] 5. ./scripts/check-leaks.sh          → clean
- [ ] 6. Commit the PDFs when the SOURCE changed (build-deck.sh tells you which)
- [ ] 7. Update docs/STATUS.md + docs/decision-log.md; regenerate HANDOFF.md if
         STATUS changed
```

The build needs a browser. It does **not** need a Playwright download — the
overflow checker honours `CHROME_PATH` and passes it as `executablePath`:

```bash
export CHROME_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
export PATH="$HOME/node_modules/.bin:$PATH" NODE_PATH="$HOME/node_modules"
```

**If the build hangs, it is stdin.** Marp waits for stdin when it inherits one
nobody will close — a background task, a CI runner, `nohup`. It prints
*"Currently waiting data from stdin stream"* once and then sits there forever:
no error, no timeout. `build-deck.sh` now redirects `< /dev/null` for exactly
this reason. With stdin closed the four variants take about 90 seconds; the same
build hung for twenty minutes before the fix.

## The gate is not optional

Marp clips overflow instead of complaining. `check-slide-overflow.js` measures
each rendered slide in a real browser and exits non-zero if anything runs past
the frame. It caught 13 clipped slides the first time it ran.

It also **fails on any image that did not load** — deliberately. A broken image
measures 0 px tall, which would otherwise read as "everything fits" on a slide
that overflows.

Check every variant you might present with, not just one: the same content
overflows at 16:9 and fits at 16:10.

## Counting slides

Count the `<section>` elements in the rendered HTML. **Never** count the `---`
rules in the markdown — the frontmatter delimiters and the slide separators are
the same token, so the arithmetic is off by one and hand-counting gets it wrong:

```bash
grep -o '<section' slides/slides-dark-16x9.html | wc -l
```

## Export into `slides/`, never a subdirectory

The deck points at `diagrams/*.svg` and `img/*` with **relative** paths. One
level down they stop resolving. The PDFs survive it (Chromium resolves at build
time) but the HTML ships broken images with no error. `build-deck.sh` writes
everything into `slides/` for exactly this reason, including its temp file.

## Silent failures, by kind

**Blank lines inside inline `<svg>`.** A blank line ends the markdown HTML block.
Marp closes the tag there and renders the rest of the diagram as loose text. No
error. Keep inline SVG free of blank lines.

**A new CSS class without its light-theme override.** `themes/qa-deck.css` is
the dark deck; `themes/qa-light.css` overrides what the light one needs. Add a
class to one and not the other and the colour drifts in a single theme — which
you will not notice unless you build both.

**Resizing a shared class.** Two slides sharing `.dg-tick` means growing it on
one grows it on the other. Add a sibling class (`.dg-tick2`) instead, *and* its
light-theme override.

**A missing `-light.svg`.** The light theme swaps pre-rendered diagrams via
`content: url(...)`, because a pre-rendered SVG cannot read the deck's CSS
variables. If the file is absent the browser shows the alt text and moves on, so
`build-deck.sh` asserts they all exist.

**Emoji.** `marp.config.js` sets `options: { emoji: { unicode: false } }`.
Without it Marp rewrites unicode emoji into twemoji CDN `<img>` tags and the deck
stops being offline — while still looking fine on a machine with Wi-Fi.

**Tables.** The last row has no bottom border, so a paragraph right after a table
reads as another row. The fix is the table's bottom margin, not blank lines in
the markdown — Markdown collapses those.

## Diagrams: Mermaid or hand-written?

- **Mermaid** (`diagrams/*.mmd` → committed `.svg` via `build-diagrams.sh`) for
  graphs, where the layout engine's choices are fine.
- **Hand-written inline SVG** when the layout carries meaning — **and alignment
  is meaning.** The `~/.claude/` tree left Mermaid because dagre would not align
  sibling boxes.

**Verify geometry by exporting the slide, not by reasoning about it.** A wire
sitting at `x=668` next to a box that ends at `x=670` draws *inside* the box,
because paths paint after rects. That was invisible in the source and obvious in
a PNG.

Regenerating one diagram re-renders **all** of them, and the installed Mermaid
version may recompute node widths and path coordinates. Commit them all rather
than leaving the deck with two diagrams from two renderer versions.

## Edit callbacks in pairs

The deck's power comes from lines that pay off later, and each one is a pair that
must move together. A one-sided edit breaks the callback **silently** — the deck
still renders, it just stops making sense:

| This line | Is quoted by |
|---|---|
| The pain slide's last bullet (*"Mañana — sesión nueva…"*) | Demo 6's closing mirror |
| The opening question (*"¿Puedo automatizar…?"*) | The callback slide before the close |
| The cold-open scar (90 minutes of phantom flakes) | The `no-parallel-ci` rule's origin, and Demo 3 |

Before changing any line that reads like a slogan, `grep` the deck for a fragment
of it.

## Claims get verified, not recalled

Three of the deck's own claims about this repo were false until a review went and
read the repo. The rule that came out of it:

- **A claim about the repo** → check the repo. Not the model's memory of it.
- **A claim about a tool** → check the tool. A linter rule id, a CLI command
  name, a flag. The deck once said a linter misses a `// TODO` (it does not,
  `S1135`) and once said `/cost` when the command is `/usage`.
- **A claim about what the live demo does** → the slide and the stage must agree.
  If a slide says "my own agents" while the demo dispatches a plugin's, say which
  version is running.

## Adding a slide costs live time

The talk is already over budget. Before adding to the **main flow**:

1. Say what it costs in seconds, in the commit message and in STATUS.
2. Prefer **replacing** a line over adding one.
3. Pay for it: find a paragraph that restates something the previous slide just
   showed, and compress it.
4. Appendix and Q&A-backup slides cost no live time — that is what they are for.

## The PDFs are versioned, and not reproducible

`slides-{dark,light}-{16x9,16x10}.pdf` are committed so anyone cloning the repo
can read the deck. But Marp's PDF export is not byte-reproducible: the same
source re-renders with ~2.5 % of bytes different, so a rebuild alone dirties the
tree with ~6.6 MB of noise.

`build-deck.sh` therefore compares the **source**, not the PDFs, and tells you
which case you are in — commit them, or `git checkout -- slides/*.pdf`.

## Never

- Never `@`-import the skills from `CLAUDE.md`. It makes `/context` show every
  skill as always-loaded, which contradicts the pyramid live, on stage.
- Never add an exception to `check-leaks.sh` to let text through. Rewrite the
  text. Writing *about* the banned words trips the guard, and that is correct.
- Never claim a build is verified without the gate's output in front of you.
