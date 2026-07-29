// Diagnostic: replays a stored conversation through convertToModelMessages to
// check what the agent actually receives on an approval-resume turn.
//
// Usage: node scripts/inspect-approval-resume.mjs <path-to-messages.json>
// where the JSON is the chat_messages rows (role, parts) for one conversation.

import { readFileSync } from 'node:fs';
import { convertToModelMessages } from 'ai';

const path = process.argv[2];
if (!path) {
  console.error('usage: node scripts/inspect-approval-resume.mjs <messages.json>');
  process.exit(1);
}

const rows = JSON.parse(readFileSync(path, 'utf8'));

const history = rows.map((row, i) => ({
  id: `msg-${i}`,
  role: row.role,
  parts: Array.isArray(row.parts) ? row.parts : [],
}));

console.log('--- stored UI messages ---');
for (const message of history) {
  console.log(
    `${message.role}: ` +
      message.parts
        .map((p) => (p.type?.startsWith('tool-') ? `${p.type}(${p.state})` : p.type))
        .join(', ')
  );
}

const messages = await convertToModelMessages(history);

console.log('\n--- converted model messages ---');
messages.forEach((message, i) => {
  const types = Array.isArray(message.content)
    ? message.content.map((p) => p.type).join(', ')
    : 'string';
  console.log(`[${i}] ${message.role}: ${types}`);
});

const last = messages.at(-1);
console.log('\nlast message role :', last?.role);
console.log(
  'approvals in last :',
  Array.isArray(last?.content)
    ? last.content.filter((p) => p.type === 'tool-approval-response').length
    : 0
);
console.log(
  '=> agent will resume the approved tool:',
  last?.role === 'tool' &&
    Array.isArray(last.content) &&
    last.content.some((p) => p.type === 'tool-approval-response')
);
