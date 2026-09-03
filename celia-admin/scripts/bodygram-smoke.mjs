/**
 * Bodygram credential + mesh smoke test.
 *
 *   node scripts/bodygram-smoke.mjs
 *
 * Runs a stats-only scan, which needs no photos but still returns a real
 * avatar mesh — the cheapest way to prove the credentials work and to get
 * genuine vendor geometry to test the OBJ -> GLB converter against.
 *
 * Consumes one scan from the organisation quota. Never prints the API key.
 */
import { readFileSync, mkdirSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const root = resolve(here, '..');

// Minimal .env.local reader so the script has no dependencies.
for (const line of readFileSync(resolve(root, '.env.local'), 'utf8').split('\n')) {
  const match = line.match(/^\s*([A-Z0-9_]+)\s*=\s*(.*)$/);
  if (match && !process.env[match[1]]) {
    process.env[match[1]] = match[2].trim().replace(/^["']|["']$/g, '');
  }
}

const orgId = process.env.BODYGRAM_ORG_ID;
const apiKey = process.env.BODYGRAM_API_KEY;
const baseUrl = process.env.BODYGRAM_BASE_URL || 'https://platform.bodygram.com';

if (!orgId || !apiKey) {
  console.error('Missing BODYGRAM_ORG_ID or BODYGRAM_API_KEY in .env.local');
  process.exit(1);
}
console.log(`org id length ${orgId.length}, api key length ${apiKey.length}`);

const response = await fetch(`${baseUrl}/api/orgs/${orgId}/scans`, {
  method: 'POST',
  headers: { Authorization: apiKey, 'Content-Type': 'application/json' },
  body: JSON.stringify({
    customScanId: 'celia-smoke-test',
    statsEstimations: { age: 30, gender: 'male', height: 1800, weight: 80000 },
  }),
});

console.log(`HTTP ${response.status} ${response.statusText}`);
const text = await response.text();
if (!response.ok) {
  console.error(text.slice(0, 800));
  process.exit(1);
}

const { entry } = JSON.parse(text);
console.log(`scan id: ${entry.id}`);
console.log(`status:  ${entry.status}`);
if (entry.status === 'failure') {
  console.error(`error code: ${entry.error?.code}`);
  process.exit(1);
}

const measurements = entry.measurements ?? [];
console.log(`measurements: ${measurements.length}`);
for (const m of measurements.slice(0, 8)) {
  console.log(`  ${m.name} = ${m.value} ${m.unit}`);
}
console.log(`bodyComposition: ${entry.bodyComposition ? 'present' : 'null (expected: photos only)'}`);

if (!entry.avatar?.data) {
  console.error('No avatar returned; nothing to convert.');
  process.exit(1);
}

const obj = Buffer.from(entry.avatar.data, 'base64');
console.log(`avatar: format=${entry.avatar.format} type=${entry.avatar.type} bytes=${obj.length}`);

mkdirSync(resolve(root, '.tmp'), { recursive: true });
const objPath = resolve(root, '.tmp/bodygram-avatar.obj');
writeFileSync(objPath, obj);
console.log(`wrote ${objPath}`);

const head = obj.toString('utf8', 0, 200).split('\n').slice(0, 4).join(' | ');
console.log(`first lines: ${head}`);
