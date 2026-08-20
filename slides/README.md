# Slides

`slides.md` is the single source of truth — 46 slides, Marp, in Spanish (it is
the talk). Everything else in here is either an input to it (`themes/`,
`diagrams/`, `img/`) or an output of it (the PDFs).

## Reading the deck without installing anything

The four rendered PDFs are versioned:

```
slides-dark-16x9.pdf    slides-dark-16x10.pdf
slides-light-16x9.pdf   slides-light-16x10.pdf
```

That is the point of committing them — clone the repo and read the deck. They
are the only build outputs tracked; the `.html` exports are gitignored.

## Building

```bash
./scripts/build-deck.sh          # all four variants, HTML + PDF
./scripts/build-deck.sh html     # skip the slower PDF export
```

One source, four variants: `slides.md`'s frontmatter pins dark + 16:9, and the
script rewrites two lines into a temporary copy for the other three (Marp CLI
has no flag to override a global directive). Which one to present with:

| Variant | When |
|---------|------|
| `dark` | the original — best in a dark room |
| `light` | bright room or washed-out projector, and the demos run in a light editor theme |
| `16x9` | most projectors and modern laptops |
| `16x10` | many conference beamers and MacBooks |

**Ask the venue which ratio the projector is** — the wrong one letterboxes.

Everything renders locally, no network needed. Needs `@marp-team/marp-cli`
(the script uses the local binary if present, else `npx`).

Do not export anywhere but `slides/`: the deck points at `diagrams/*.svg` and
`img/*` with relative paths, and one level down they stop resolving — the PDFs
survive it, the HTML ships broken images silently.

## Checking it fits

Marp renders a slide whose content runs past the bottom edge without
complaining; it just gets clipped on the projector.

```bash
./scripts/build-deck.sh html
node scripts/check-slide-overflow.js slides/slides-dark-16x9.html
```

Needs playwright (`npm i -D playwright` plus
`npx playwright install chromium`). Exits non-zero if anything overflows, so it
can gate a rehearsal. It also fails on any image that did not load — a broken
image measures 0px tall, which would otherwise read as "everything fits".

## Diagrams

`diagrams/*.mmd` are Mermaid sources pre-rendered to committed `.svg` by
`./scripts/build-diagrams.sh`, in a dark and a light variant. The pyramid, the
end-to-end flow and the `~/.claude/` tree are hand-written inline SVG inside
`slides.md` instead — the rule is Mermaid for graphs, hand-written SVG when
layout carries meaning, and alignment is meaning.
