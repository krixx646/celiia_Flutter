-- Separate Avatar Mode conversations from the manual chat tab.
-- Safe to run more than once: ADD COLUMN IF NOT EXISTS.
alter table public.chat_conversations
  add column if not exists mode text not null default 'chat';

create index if not exists chat_conversations_user_mode_updated_idx
  on public.chat_conversations (user_id, mode, updated_at desc);
