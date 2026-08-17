#!/usr/bin/env bash
# Render the Mermaid sources in slides/diagrams/*.mmd to SVG.
#
# Each source produces TWO files: name.svg (dark deck) and name-light.svg
# (light deck). A pre-rendered SVG carries its colours baked in — it cannot
# read the deck's CSS variables the way the hand-written inline diagrams do —
# so the light theme swaps the <img> instead. See slides/themes/qa-light.css.
#
# The SVGs are committed, so building the deck never requires Mermaid — only
# editing a diagram does. That also keeps the deck offline-safe: nothing is
# fetched from a CDN at present time.
#
# Needs @mermaid-js/mermaid-cli. There is no root package.json here on purpose
# (this repo is markdown, not a project), so the default path is npx — same as
# how the deck itself is built. Install it globally if you edit diagrams often.
#
# On a machine where Puppeteer cannot download its own Chromium, point at one:
#   CHROME_PATH=/path/to/chrome ./scripts/build-diagrams.sh

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

DIA="slides/diagrams"
DARK="$DIA/mermaid.dark.json"
LIGHT="$DIA/mermaid.light.json"

if [[ -x "node_modules/.bin/mmdc" ]]; then
  MMDC=(node_modules/.bin/mmdc)
elif command -v mmdc >/dev/null 2>&1; then
  MMDC=(mmdc)
elif command -v npx >/dev/null 2>&1; then
  MMDC=(npx --yes @mermaid-js/mermaid-cli)
else
  echo "❌ mmdc not found and no npx — install @mermaid-js/mermaid-cli" >&2
  exit 1
fi

# mermaid-cli drives a headless browser; reuse an existing one when provided.
PUPPETEER_CFG=""
if [[ -n "${CHROME_PATH:-}" ]]; then
  PUPPETEER_CFG="$(mktemp)"
  printf '{"executablePath":"%s","args":["--no-sandbox"]}' "$CHROME_PATH" > "$PUPPETEER_CFG"
fi

render() {  # src out themefile
  if [[ -n "$PUPPETEER_CFG" ]]; then
    "${MMDC[@]}" -i "$1" -o "$2" -c "$3" -p "$PUPPETEER_CFG" -b transparent
  else
    "${MMDC[@]}" -i "$1" -o "$2" -c "$3" -b transparent
  fi
}

shopt -s nullglob
built=0
for src in "$DIA"/*.mmd; do
  base="${src%.mmd}"
  echo "→ $(basename "$src") → $(basename "$base").svg + $(basename "$base")-light.svg"
  render "$src" "$base.svg"       "$DARK"
  render "$src" "$base-light.svg" "$LIGHT"
  built=$((built + 1))
done

[[ -n "$PUPPETEER_CFG" ]] && rm -f "$PUPPETEER_CFG"

if [[ "$built" -eq 0 ]]; then
  echo "no .mmd sources in $DIA"
else
  echo "✅ $built diagram(s) × 2 temas — commit los .svg junto al .mmd"
fi
