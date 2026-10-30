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

test('index.html has a title', () => {
  assert.match(read('index.html'), /<title>[^<]+<\/title>/);
});
