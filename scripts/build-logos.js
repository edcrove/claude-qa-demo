#!/usr/bin/env node
/**
 * Generate slides/img/logos/*.svg from the `simple-icons` package.
 *
 * The deck shows the logos of the tools the MCPs connect to. Rather than
 * committing opaque blobs pulled off the internet, this regenerates them from
 * a pinned dependency, so it is auditable and reproducible — and the committed
 * SVGs keep the deck offline.
 *
 * Every logo keeps its real brand colour. An earlier version had to lighten
 * three of them to survive the #011627 background — Atlassian's #172B4D was
 * nearly invisible, and Jenkins' butler is line art that turned to mud. That
 * was solved in CSS instead (`img.logo` sits on a light chip, see slides.md),
 * which is both more accurate and more legible than tinting brand marks.
 *
 * Usage:
 *   npm i simple-icons
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

// simple-icons slugs, in the order the MCP table lists them.
const LOGOS = [
  // la tabla de MCPs, en el orden en que la slide 11 los lista
  'jira', 'testrail', 'jenkins', 'github', 'confluence',
  // el logo grande de la slide "Mis primeros pasos con Claude"
  'claude',
];

const outDir = path.join(__dirname, '..', 'slides', 'img', 'logos');
fs.mkdirSync(outDir, { recursive: true });

const byTitle = new Map(
  Object.values(si)
    .filter((i) => i && i.title && i.path)
    .map((i) => [i.title.toLowerCase().replace(/[^a-z]/g, ''), i])
);

let n = 0;
for (const slug of LOGOS) {
  const icon = byTitle.get(slug);
  if (!icon) {
    console.error(`✗ ${slug} not found in simple-icons`);
    process.exitCode = 1;
    continue;
  }
  const svg =
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" role="img" aria-label="${icon.title}">` +
    `<title>${icon.title}</title>` +
    `<path fill="#${icon.hex}" d="${icon.path}"/>` +
    `</svg>\n`;
  fs.writeFileSync(path.join(outDir, `${slug}.svg`), svg);
  console.log(`→ ${slug}.svg  #${icon.hex}  (${icon.title})`);
  n++;
}

console.log(`\n✅ ${n} logo(s) written to slides/img/logos/ — commit them alongside this script`);
