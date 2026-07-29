/**
 * Checks the near-miss slug matching against the real exercise library:
 * does it recover the slug Celia actually got wrong, and does it stay
 * unambiguous across the whole catalog?
 */
const SUPABASE_URL = 'https://zgwxdpxhddcswdmectsm.supabase.co';
const KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

const SLUG_FILLER_WORDS = new Set([
  'of', 'the', 'with', 'a', 'an', 'and', 'for', 'to', 'on', 'in', 'at', 'by', 'your',
]);

function slugFingerprint(slug) {
  return slug
    .toLowerCase()
    .split(/[-_\s]+/)
    .filter((word) => word && !SLUG_FILLER_WORDS.has(word))
    .sort()
    .join('-');
}

const res = await fetch(
  `${SUPABASE_URL}/rest/v1/exercise_media?select=slug,display_name&limit=5000`,
  { headers: { apikey: KEY, Authorization: `Bearer ${KEY}` } }
);
const catalog = (await res.json()).map((r) => ({ slug: r.slug, displayName: r.display_name }));
console.log('catalog size:', catalog.length);

const byFingerprint = new Map();
for (const entry of catalog) {
  const key = slugFingerprint(entry.slug);
  const list = byFingerprint.get(key);
  if (list) list.push(entry);
  else byFingerprint.set(key, [entry]);
}

// How often does dropping filler words make two different exercises collide?
const collisions = [...byFingerprint.entries()].filter(([, v]) => v.length > 1);
console.log('ambiguous fingerprints:', collisions.length);
for (const [key, entries] of collisions.slice(0, 8)) {
  console.log('  ', key, '->', entries.map((e) => e.slug).join(' | '));
}

const cases = [
  'stretch-reverse-shoulder-standing', // what Celia wrote
  'stretch-of-the-upper-back',
  'circles-with-arms',
  'pendulum-shoulder',
  'totally-made-up-exercise',
];

console.log('--- resolution ---');
for (const slug of cases) {
  const exact = catalog.find((e) => e.slug === slug);
  if (exact) {
    console.log(`  ${slug} -> exact`);
    continue;
  }
  const candidates = byFingerprint.get(slugFingerprint(slug)) || [];
  console.log(
    `  ${slug} -> ${candidates.length === 1 ? candidates[0].slug : `${candidates.length} candidates (no auto-fix)`}`
  );
}
