const assert = require('node:assert/strict');
const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');
const { chromium } = require('playwright');

const root = path.resolve(__dirname, '..');
const types = { '.html': 'text/html', '.js': 'text/javascript', '.css': 'text/css', '.svg': 'image/svg+xml' };
const server = http.createServer((req, res) => {
  const pathname = decodeURIComponent(new URL(req.url, 'http://localhost').pathname);
  const file = path.resolve(root, '.' + pathname);
  if (!file.startsWith(root + path.sep) && file !== root) { res.writeHead(403).end(); return; }
  const target = file === root ? path.join(root, 'index.html') : file;
  fs.readFile(target, (err, data) => {
    if (err) { res.writeHead(404).end('Not found'); return; }
    res.writeHead(200, { 'Content-Type': types[path.extname(target)] || 'application/octet-stream' });
    res.end(data);
  });
});

(async () => {
  await new Promise(resolve => server.listen(4173, '127.0.0.1', resolve));
  const browser = await chromium.launch({ headless: true });
  try {
    const page = await browser.newPage({ viewport: { width: 390, height: 844 } });
    const pageErrors = [];
    page.on('pageerror', error => pageErrors.push(error.message));
    await page.goto('http://127.0.0.1:4173', { waitUntil: 'domcontentloaded' });
    assert.match(await page.title(), /Dragless Rivalry/);
    await page.locator('[data-go="create"]').click();
    await page.locator('#driver-name').fill('Browser Tester');
    await page.locator('#begin-career').click();
    await page.locator('[data-story-choice="street"]').click();
    await page.locator('[data-go="dashboard"]').click();
    await page.locator('[data-go="garage"]').click();
    assert.match(await page.locator('#screen').innerText(), /VEHICLE DEALERSHIP/);
    await page.locator('[data-go="racing"]').click();
    await page.locator('#stage-race').click();
    await page.waitForFunction(() => document.querySelector('#launch-car')?.textContent === 'LAUNCH NOW', { timeout: 5000 });
    await page.locator('#launch-car').click();
    for (let i = 0; i < 3; i++) await page.locator('#launch-car').click();
    await page.waitForFunction(() => /WIN|RUNNER-UP|RED LIGHT/.test(document.querySelector('#race-result')?.innerText || ''));
    await page.locator('[data-go="dashboard"]').click();
    await page.locator('[data-go="management"]').click();
    assert.match(await page.locator('#screen').innerText(), /CHAMPIONSHIP CALENDAR/);
    await page.reload();
    assert.match(await page.locator('#screen').innerText(), /CONTINUE CAREER/);
    const overflow = await page.evaluate(() => document.documentElement.scrollWidth > window.innerWidth + 1);
    assert.equal(overflow, false, 'mobile layout must not overflow horizontally');
    assert.deepEqual(pageErrors, [], 'browser should not emit uncaught page errors');
    console.log('PASS: mobile browser loads, starts a career, navigates screens, runs a race, saves progress and fits viewport.');
  } finally {
    await browser.close();
    server.close();
  }
})().catch(error => { console.error(error); process.exitCode = 1; server.close(); });
