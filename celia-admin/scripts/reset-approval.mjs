// Diagnostic: rewinds a stored tool approval back to 'approval-requested' so an
// approval-resume turn can be replayed against the same conversation.
//
// Usage: node scripts/reset-approval.mjs <conversationId>

import { readFileSync } from 'node:fs';

function loadEnv() {
  const text = readFileSync(new URL('../.env.local', import.meta.url), 'utf8');
  const env = {};
  for (const line of text.split(/\r?\n/)) {
    const match = /^([A-Z0-9_]+)=(.*)$/.exec(line.trim());
    if (match) env[match[1]] = match[2].replace(/^["']|["']$/g, '');
  }
  return env;
}

const env = loadEnv();
const url = env.NEXT_PUBLIC_SUPABASE_URL;
const key = env.SUPABASE_SERVICE_ROLE_KEY;
const conversationId = process.argv[2];

if (!conversationId) {
  console.error('usage: node scripts/reset-approval.mjs <conversationId>');
  process.exit(1);
}

const headers = { apikey: key, Authorization: `Bearer ${key}`, 'Content-Type': 'application/json' };

const rows = await fetch(
  `${url}/rest/v1/chat_messages?conversation_id=eq.${conversationId}&role=eq.assistant&select=id,parts&order=created_at`,
  { headers }
).then((r) => r.json());

for (const row of rows) {
  let touched = false;
  const parts = row.parts.map((part) => {
    if (part.type !== 'tool-create_routine' || part.state !== 'approval-responded') return part;
    touched = true;
    const { approved, reason, ...approval } = part.approval ?? {};
    return { ...part, state: 'approval-requested', approval };
  });

  if (!touched) continue;

  const res = await fetch(`${url}/rest/v1/chat_messages?id=eq.${row.id}`, {
    method: 'PATCH',
    headers: { ...headers, Prefer: 'return=minimal' },
    body: JSON.stringify({ parts }),
  });

  console.log(`row ${row.id}: ${res.status === 204 ? 'rewound to approval-requested' : `failed ${res.status}`}`);
  const pending = parts.find((p) => p.state === 'approval-requested');
  if (pending) console.log(`  approvalId: ${pending.approval.id}`);
}
