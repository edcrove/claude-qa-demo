#!/usr/bin/env bash
# Build the deck in both aspect ratios, from one source.
#
# slides/slides.md is the single source of truth; its frontmatter says
# `size: 16:9`. Marp CLI has no flag to override a global directive, so for the
# 16:10 build this rewrites that one line into a temporary copy placed *inside
# slides/* — the copy has to live there or the relative diagrams/*.svg and
# img/*.svg paths stop resolving and the images silently vanish.
#
# Output goes next to slides.md, in slides/ (gitignored):
#   slides-16x9.html   slides-16x9.pdf
#   slides-16x10.html  slides-16x10.pdf
#
# Not into a dist/ subdirectory, deliberately: the deck points at
# diagrams/*.svg and img/*.svg with relative paths, and one level down they
# stop resolving. The PDFs would survive it (Chromium resolves them at build
# time) but the HTML would ship 8 broken images, silently.
#
# Which one to present with:
#   16:9  → most projectors and modern laptops (1920x1080, 1366x768)
#   16:10 → many conference beamers and MacBooks (1920x1200, 1280x800)
# If unsure, ask the venue; showing 16:9 on a 16:10 screen letterboxes the
# deck, which is what prompted having both.
#
# Usage:
#   ./scripts/build-deck.sh            # both ratios, html + pdf
#   ./scripts/build-deck.sh html       # skip the (slower) PDF export
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
DIST="slides"

TMP=""
cleanup() { [[ -n "$TMP" && -f "$TMP" ]] && rm -f "$TMP"; }
trap cleanup EXIT

build() {
  local ratio="$1" label="$2" input="$3"
  echo "── $ratio ──────────────────────────────"
  "${MARP[@]}" "$input" -o "$DIST/slides-$label.html"
  if [[ "$ONLY" != "html" ]]; then
    "${MARP[@]}" "$input" --pdf -o "$DIST/slides-$label.pdf"
  fi
}

build "16:9" "16x9" "$SRC"

# The 16:10 copy sits next to the original so relative asset paths still work.
TMP="slides/.build-16x10.md"
sed 's/^size: 16:9$/size: 16:10/' "$SRC" > "$TMP"
if ! grep -q '^size: 16:10$' "$TMP"; then
  echo "❌ could not switch the size directive — is 'size: 16:9' still in the frontmatter?" >&2
  exit 1
fi
build "16:10" "16x10" "$TMP"

echo
echo "✅ built:"
ls -1 "$DIST"/slides-16x*.html "$DIST"/slides-16x*.pdf 2>/dev/null || true
