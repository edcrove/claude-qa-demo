#!/usr/bin/env node
/**
 * Generate slides/img/logos/*.svg from the `simple-icons` package.
 *
 * The deck shows the logos of the tools the MCPs connect to. Rather than
 * committing opaque blobs pulled off the internet, this regenerates them from
 * a pinned dependency, so it is auditable and reproducible — and the committed
 * SVGs keep the deck offline.
 *
 * Colours are not always the brand hex. simple-icons ships each brand's
 * canonical colour, but a few are unreadable on this deck's #011627
 * background — Atlassian's #172B4D is nearly invisible on it. Where that
 * happens we use the brand's own light-background variant instead of
 * inventing a colour.
 *
 * Usage:
 *   npm i simple-icons        # or npx, see below
 *   node scripts/build-logos.js
 */
const fs = require('fs');
const path = require('path');

let si;
try {
  si = require('simple-icons');
} catch {
  console.error('simple-icons not installed — run: npm i simple-icons');
  process.exit(2);
}

// slug → fill colour actually used in the deck.
const LOGOS = {
  jira:       { color: '#2684FF', note: "Atlassian blue B200 — brand #0052CC is too dark on #011627" },
  testrail:   { color: null,      note: 'brand colour' },
  jenkins:    { color: '#E8604F', note: 'brand #D24939 lightened — its line art goes muddy on #011627' },
  confluence: { color: '#2684FF', note: "Atlassian blue B200 — brand #172B4D is invisible on #011627" },
};

const outDir = path.join(__dirname, '..', 'slides', 'img', 'logos');
fs.mkdirSync(outDir, { recursive: true });

const byTitle = new Map(
  Object.values(si)
    .filter((i) => i && i.title && i.path)
    .map((i) => [i.title.toLowerCase().replace(/[^a-z]/g, ''), i])
);

let n = 0;
for (const [slug, { color, note }] of Object.entries(LOGOS)) {
  const icon = byTitle.get(slug);
  if (!icon) {
    console.error(`✗ ${slug} not found in simple-icons`);
    process.exitCode = 1;
    continue;
  }
  const fill = color || `#${icon.hex}`;
  const svg =
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" role="img" aria-label="${icon.title}">` +
    `<title>${icon.title}</title>` +
    `<path fill="${fill}" d="${icon.path}"/>` +
    `</svg>\n`;
  fs.writeFileSync(path.join(outDir, `${slug}.svg`), svg);
  console.log(`→ ${slug}.svg  ${fill}  (${note})`);
  n++;
}

console.log(`\n✅ ${n} logo(s) written to slides/img/logos/ — commit them alongside this script`);
