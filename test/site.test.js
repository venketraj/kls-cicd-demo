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

test('call-to-action text and link live in content.json', () => {
  const { ctaText, ctaUrl } = JSON.parse(read('content.json'));
  assert.ok(typeof ctaText === 'string' && ctaText.trim(), 'ctaText is missing');
  // Count characters, not UTF-16 units, so an emoji counts as one.
  assert.ok([...ctaText].length <= 25, `ctaText is ${[...ctaText].length} chars, max is 25`);
  assert.match(ctaUrl, /^https:\/\//, 'ctaUrl must be an https link');
});

test('call-to-action opens in a new tab and is tall enough to tap', () => {
  const html = read('index.html');
  assert.match(html, /<a id="cta"[^>]*target="_blank"[^>]*rel="noopener"/);
  const minHeight = Number(html.match(/#cta \{[^}]*min-height: (\d+)px/)?.[1]);
  assert.ok(minHeight >= 44, `#cta min-height is ${minHeight}px, min is 44`);
});

test('index.html has a title', () => {
  assert.match(read('index.html'), /<title>[^<]+<\/title>/);
});
