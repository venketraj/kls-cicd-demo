const { test } = require('node:test');
const assert = require('node:assert');
const fs = require('node:fs');
const path = require('node:path');

const site = path.join(__dirname, '..', 'site');
// Strip a BOM like browsers do; Windows editors sometimes add one.
const read = (file) => fs.readFileSync(path.join(site, file), 'utf8').replace(/^﻿/, '');

test('content.json is valid JSON', () => {
  assert.doesNotThrow(() => JSON.parse(read('content.json')), 'content.json has a syntax error');
});

test('headline is present and fits on a phone screen', () => {
  const { headline } = JSON.parse(read('content.json'));
  assert.ok(typeof headline === 'string' && headline.trim(), 'headline is missing');
  assert.ok(headline.length <= 40, `headline is ${headline.length} chars, max is 40`);
});

test('call-to-action text and link are set and fit on a phone', () => {
  const { ctaText, ctaUrl } = JSON.parse(read('content.json'));
  assert.strictEqual(ctaText, '⭐ Get the starter repo');
  assert.ok([...ctaText].length <= 25, `ctaText is ${[...ctaText].length} chars, max is 25`);
  assert.strictEqual(ctaUrl, 'https://github.com/venketraj/kls-cicd-demo');
});

test('call-to-action opens in a new tab, is filled from content.json and is tappable', () => {
  const html = read('index.html');
  assert.match(html, /<a id="cta"[^>]*target="_blank"[^>]*rel="noopener"/);
  assert.match(html, /\$\('cta'\)\.textContent = content\.ctaText/);
  assert.match(html, /\$\('cta'\)\.href = content\.ctaUrl/);
  const height = Number(html.match(/#cta\s*{[^}]*min-height:\s*(\d+)px/)?.[1]);
  assert.ok(height >= 44, `#cta min-height is ${height}px, min is 44`);
});

test('index.html has a title', () => {
  assert.match(read('index.html'), /<title>[^<]+<\/title>/);
});
