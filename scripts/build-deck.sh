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

  # `< /dev/null` no es decorativo. Si marp hereda un stdin abierto que nadie va
  # a cerrar —una tarea en background, un runner de CI, un `nohup`— se queda
  # esperando: "Currently waiting data from stdin stream. Conversion will start
  # after finished reading." No falla, no imprime nada más, y cuelga para
  # siempre. Con stdin cerrado, los cuatro variantes tardan ~90 s.
  "${MARP[@]}" "$TMP" -o "$OUT/slides-$label.html" < /dev/null
  [[ "$ONLY" != "html" ]] && "${MARP[@]}" "$TMP" --pdf -o "$OUT/slides-$label.pdf" < /dev/null
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

build qa-deck  "16:9"  "dark-16x9"
build qa-deck  "16:10" "dark-16x10"
build qa-light "16:9"  "light-16x9"
build qa-light "16:10" "light-16x10"

echo
echo "✅ built:"
ls -1 "$OUT"/slides-dark-* "$OUT"/slides-light-* 2>/dev/null || true

# Los PDF están versionados, así que conviene avisar cuando el repo quedó con
# un render viejo. Pero Marp NO produce PDF reproducibles: con la misma fuente,
# ~2.5% de los bytes cambia (metadata dentro de streams comprimidos). Así que un
# rebuild solo, sin tocar nada, igual ensucia el árbol con 6.6 MB de ruido.
# Por eso el aviso mira la FUENTE, no los PDF.
if [[ "$ONLY" != "html" ]] && ! git diff --quiet -- "$OUT"/*.pdf 2>/dev/null; then
  SOURCES=(slides/slides.md slides/themes slides/diagrams slides/img marp.config.js)
  echo
  if git diff --quiet HEAD -- "${SOURCES[@]}" 2>/dev/null; then
    echo "ℹ️  Los PDF cambiaron pero la fuente no: es sólo metadata de Marp."
    echo "   Descartalos para no sumar 6.6 MB de ruido al historial:"
    echo "     git checkout -- slides/*.pdf"
  else
    echo "📌 Cambió la fuente: commiteá los PDF para que el repo quede con el"
    echo "   último render:  git add slides/*.pdf && git commit"
  fi
fi
