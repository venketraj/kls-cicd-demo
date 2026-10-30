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

test('starter repo CTA content is configurable and fits on one line', () => {
  const content = JSON.parse(read('content.json'));
  assert.equal(content.ctaText, '⭐ Get the starter repo');
  assert.equal(content.ctaUrl, 'https://github.com/venketraj/kls-cicd-demo');
  assert.ok(content.ctaText.length <= 25, 'CTA text must be 25 characters or fewer');
});

test('starter repo CTA appears under the subtitle as an accessible tap target', () => {
  const html = read('index.html');
  assert.match(html, /<p id="subtitle"><\/p>\s*<a id="cta"[^>]*target="_blank"[^>]*rel="noopener noreferrer"/);
  assert.match(html, /min-height:\s*44px/);
  assert.match(html, /\$\('cta'\)\.textContent\s*=\s*content\.ctaText/);
  assert.match(html, /\$\('cta'\)\.href\s*=\s*content\.ctaUrl/);
});

test('index.html has a title', () => {
  assert.match(read('index.html'), /<title>[^<]+<\/title>/);
});
