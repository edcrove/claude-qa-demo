#!/usr/bin/env node
/**
 * Report slides whose content overflows the 1280x720 frame.
 *
 * Marp will happily render a slide whose content runs past the bottom edge —
 * it just gets clipped on the projector, which you will not notice while
 * editing markdown. This measures each rendered slide in a real browser and
 * prints the ones that do not fit.
 *
 * Usage:
 *   npx @marp-team/marp-cli slides/slides.md -o /tmp/slides.html --html
 *   node scripts/check-slide-overflow.js /tmp/slides.html
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
