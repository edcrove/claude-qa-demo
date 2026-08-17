#!/usr/bin/env bash
# Build the deck in both themes and both aspect ratios, from one source.
#
# slides/slides.md is the single source of truth. Its frontmatter pins one
# combination (dark, 16:9); the other three are produced by rewriting two lines
# into a temporary copy, because Marp CLI has no flag to override a global
# directive.
#
#   slides-dark-16x9    slides-dark-16x10
#   slides-light-16x9   slides-light-16x10
#
# Each as .html and .pdf, written next to slides.md in slides/ (gitignored).
# NOT into a dist/ subdirectory: the deck points at diagrams/*.svg and
# img/*.svg with relative paths, and one level down they stop resolving. The
# PDFs would survive it — Chromium resolves them at build time — but the HTML
# would ship broken images, silently. The temp copy lives in slides/ for the
# same reason.
#
# Which one to present with:
#   dark   → the original. Best in a dark room.
#   light  → White Smoke background, and the code panes are light too, so
#            switching to the terminal mid-demo is not a slap in the face.
#            Also the safer bet on a washed-out projector.
#   16:9   → most projectors and modern laptops (1920x1080, 1366x768)
#   16:10  → many conference beamers and MacBooks (1920x1200, 1280x800)
# Ask the venue about the ratio; the wrong one letterboxes.
#
# Usage:
#   ./scripts/build-deck.sh              # all four, html + pdf
#   ./scripts/build-deck.sh html         # skip the slower PDF export
#
# Needs @marp-team/marp-cli. Uses the local binary if present, else npx.
# On a machine where the browser is not auto-detected:
#   CHROME_PATH=/path/to/chrome ./scripts/build-deck.sh

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

ONLY="${1:-all}"

if [[ -x "node_modules/.bin/marp" ]]; then
  MARP=(node_modules/.bin/marp)
elif command -v marp >/dev/null 2>&1; then
  MARP=(marp)
elif command -v npx >/dev/null 2>&1; then
  # npx re-resolves the package on every call and can stall for minutes behind
  # a proxy. Install marp-cli locally if you build often.
  MARP=(npx --yes @marp-team/marp-cli)
else
  echo "❌ marp not found — run: npm i -D @marp-team/marp-cli" >&2
  exit 1
fi

SRC="slides/slides.md"
OUT="slides"
TMP="slides/.build-variant.md"
trap 'rm -f "$TMP"' EXIT

# Sanity check: the rewrites below are line-exact, so fail loudly rather than
# silently shipping four copies of the same variant.
for line in '^theme: qa-deck$' '^size: 16:9$' '^class: invert$'; do
  grep -qE "$line" "$SRC" || { echo "❌ '$line' no está en el frontmatter de $SRC" >&2; exit 1; }
done

build() {
  local theme="$1" ratio="$2" label="$3"
  echo "── $label ──────────────────────────────"

  # gaia's `invert` class is what makes it dark; the light variant drops it.
  if [[ "$theme" == "qa-light" ]]; then
    sed -e 's/^theme: qa-deck$/theme: qa-light/' -e '/^class: invert$/d' "$SRC" > "$TMP"
  else
    cp "$SRC" "$TMP"
  fi
  [[ "$ratio" == "16:10" ]] && sed -i.bak 's/^size: 16:9$/size: 16:10/' "$TMP" && rm -f "$TMP.bak"

  "${MARP[@]}" "$TMP" -o "$OUT/slides-$label.html"
  [[ "$ONLY" != "html" ]] && "${MARP[@]}" "$TMP" --pdf -o "$OUT/slides-$label.pdf"
  return 0
}

# El tema claro intercambia los SVG de Mermaid por variantes -light via
# `content: url(...)`. Si ese archivo no existe, el navegador no tira error:
# muestra el alt y sigue. Chequearlo acá es la única forma de enterarse.
missing=0
while read -r svg; do
  [[ -f "slides/$svg" ]] || { echo "❌ falta slides/$svg — corré ./scripts/build-diagrams.sh" >&2; missing=1; }
done < <(grep -o 'url("[^"]*-light\.svg")' slides/themes/qa-light.css | sed 's/url("//;s/")//')
[[ "$missing" -eq 0 ]] || exit 1

# Dos imágenes de la charla se armaron fuera del repo y todavía están con un
# stand-in gris. El deck compila igual, pero conviene enterarse antes de la
# sala, no en la sala. Cuando se reemplacen, el hash cambia y el aviso se va.
while IFS='  ' read -r hash file; do
  [[ -f "$file" ]] || continue
  if [[ "$(sha256sum "$file" | cut -c1-16)" == "$hash" ]]; then
    echo "⚠️  $file sigue siendo el stand-in — reemplazalo por la imagen real" >&2
  fi
done <<'PENDING'
2c762b222f3b30bb  slides/img/qa-hero.png
fc47c35f9f1d9d26  slides/img/logs-triage.png
PENDING

build qa-deck  "16:9"  "dark-16x9"
build qa-deck  "16:10" "dark-16x10"
build qa-light "16:9"  "light-16x9"
build qa-light "16:10" "light-16x10"

echo
echo "✅ built:"
ls -1 "$OUT"/slides-dark-* "$OUT"/slides-light-* 2>/dev/null || true
