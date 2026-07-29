-- Meal logs for Celia Calorie Calculator.
-- Run this in Supabase SQL editor before enabling meal logging in production.

create table if not exists public.user_meals (
  id uuid primary key default gen_random_uuid(),
  user_id text not null,
  title text not null default 'Logged Meal',
  calories numeric not null default 0,
  protein_grams numeric not null default 0,
  carbs_grams numeric not null default 0,
  fat_grams numeric not null default 0,
  confidence numeric not null default 0,
  provider text not null default 'unknown',
  items jsonb not null default '[]'::jsonb,
  warnings jsonb not null default '[]'::jsonb,
  logged_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create index if not exists user_meals_user_logged_at_idx
  on public.user_meals (user_id, logged_at desc);

alter table public.user_meals enable row level security;

-- The Flutter app authenticates with Firebase, not Supabase Auth. Meal logs are
-- written through the Next.js /api/mobile/log-meal route using the Supabase
-- service-role key after verifying the user's Firebase ID token.
--
-- Intentionally do not add anon/authenticated client policies here. With RLS
-- enabled and no client policies, public clients cannot read or write meal logs.
-- The service-role backend bypasses RLS safely for authenticated requests.
