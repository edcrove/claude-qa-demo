#!/usr/bin/env node
/**
 * Report slides whose content overflows the 1280x720 frame.
 *
 * Marp will happily render a slide whose content runs past the bottom edge —
 * it just gets clipped on the projector, which you will not notice while
 * editing markdown. This measures each rendered slide in a real browser and
 * prints the ones that do not fit.
 *
 * Render the HTML *inside slides/* — the deck points at diagrams/*.svg with a
 * relative path, so exporting anywhere else leaves the images broken, and a
 * broken image measures 0px tall. That reads as "everything fits" when the
 * slide actually overflows, so this also fails on any image that did not load.
 *
 * Usage:
 *   ./scripts/build-deck.sh html
 *   node scripts/check-slide-overflow.js slides/slides-16x9.html
 *   node scripts/check-slide-overflow.js slides/slides-16x10.html
 *
 * Measurement is scale-invariant, so the same script checks either ratio.
 *
 * Needs playwright (`npm i -D playwright`). Exits non-zero if anything
 * overflows, so it can gate a rehearsal.
 */
const path = require('path');

let chromium;
try {
  ({ chromium } = require('playwright'));
} catch {
  console.error('playwright not installed — run: npm i -D playwright');
  process.exit(2);
}

const file = process.argv[2];
if (!file) {
  console.error('usage: node scripts/check-slide-overflow.js <rendered-slides.html>');
  process.exit(2);
}

(async () => {
  const launchOpts = {};
  if (process.env.CHROME_PATH) launchOpts.executablePath = process.env.CHROME_PATH;
  const browser = await chromium.launch(launchOpts);
  const page = await browser.newPage({ viewport: { width: 1280, height: 720 } });
  await page.goto('file://' + path.resolve(file));
  await page.waitForTimeout(1500);

  const brokenImages = await page.evaluate(() =>
    [...document.images].filter((img) => !img.complete || img.naturalWidth === 0).map((img) => img.getAttribute('src'))
  );

  const results = await page.evaluate(() => {
    const out = [];
    document.querySelectorAll('section').forEach((sec) => {
      if (!sec.querySelector('h1,h2,p,table,pre,ul')) return;
      const cs = getComputedStyle(sec);
      const rect = sec.getBoundingClientRect();
      const availH = rect.height - parseFloat(cs.paddingTop) - parseFloat(cs.paddingBottom);
      let maxBottom = 0;
      sec.querySelectorAll(':scope > *').forEach((el) => {
        const r = el.getBoundingClientRect();
        maxBottom = Math.max(maxBottom, r.bottom - rect.top - parseFloat(cs.paddingTop));
      });
      out.push({
        n: out.length + 1,
        title: (sec.querySelector('h1,h2')?.textContent || '(untitled)').trim().slice(0, 46),
        over: Math.round(maxBottom - availH),
      });
    });
    return out;
  });

  await browser.close();

  const isRemote = (src) => /^https?:/i.test(src);
  const brokenLocal = [...new Set(brokenImages.filter((s) => !isRemote(s)))];
  const brokenRemote = [...new Set(brokenImages.filter(isRemote))];

  // A broken <img> measures 0px tall, so the numbers below would happily call
  // an overflowing slide "fits". Local misses are always a bug worth failing on.
  if (brokenLocal.length) {
    console.error(`❌ ${brokenLocal.length} local image(s) did not load — the measurement below is not trustworthy:`);
    for (const src of brokenLocal) console.error(`   ${src}`);
    console.error('Export the HTML into slides/ so the relative diagram paths resolve.\n');
    process.exitCode = 1;
  }

  // Remote misses are usually Marp rewriting unicode emoji into twemoji CDN
  // <img>. Offline that is a live-demo risk, not a layout bug — warn, do not fail.
  if (brokenRemote.length) {
    console.warn(`⚠️  ${brokenRemote.length} remote image(s) did not load — the deck is not fully offline:`);
    for (const src of brokenRemote.slice(0, 3)) console.warn(`   ${src}`);
    if (brokenRemote.length > 3) console.warn(`   …and ${brokenRemote.length - 3} more`);
    console.warn('These are Marp emoji fetched from a CDN. To drop the dependency, set');
    console.warn("`options: { emoji: { unicode: false } }` in marp.config.js.\n");
  }

  const bad = results.filter((r) => r.over > 0).sort((a, b) => b.over - a.over);
  console.log(`measured ${results.length} slides — ${bad.length} overflowing`);
  if (!bad.length) {
    console.log('✅ every slide fits');
    return;
  }
  console.log('\nslide | overflow px | title');
  console.log('------+-------------+------');
  for (const r of bad) {
    console.log(`${String(r.n).padStart(5)} | ${String(r.over).padStart(11)} | ${r.title}`);
  }
  console.log('\nFix by trimming content or tagging the slide `<!-- _class: dense -->`.');
  process.exitCode = 1;
})();
