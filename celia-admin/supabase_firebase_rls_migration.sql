-- Give the app access to its own user's rows.
--
-- Users sign in with Firebase, so Supabase never issued them a session and
-- auth.uid() was always null. The policies written against it therefore matched
-- nothing: the saved-routine library came back empty, workout completions were
-- rejected with 42501 (so the streak and level could never advance), and
-- routines Celia creates were unreadable because they are saved unpublished.
--
-- With Firebase registered as a third-party auth provider, requests now arrive
-- carrying the user's Firebase ID token and its claims are readable through
-- auth.jwt(). The `sub` claim is the Firebase uid, which is exactly what the
-- user_id and created_by columns already hold.
--
-- The old auth.uid() policies must be dropped rather than left in place.
-- auth.uid() casts `sub` to uuid, and a Firebase uid is not one, so once real
-- tokens start arriving those policies raise
--   22P02 invalid input syntax for type uuid
-- which fails the whole query instead of merely denying a row.
--
-- Firebase tokens carry no `role` claim, so Supabase runs these requests as
-- `anon`. The policies are left at PUBLIC rather than pinned to
-- `authenticated`, so they work now and keep working if a `role: authenticated`
-- claim is added later. This exposes nothing: a request holding only the app's
-- anon key has no `sub`, so firebase_uid() is null and matches no row.

-- The Firebase uid of the caller, or null when the request is anonymous.
-- Returns text, so there is no uuid cast to blow up on.
create or replace function public.firebase_uid()
  returns text
  language sql
  stable
  as $$ select auth.jwt() ->> 'sub' $$;

-- ── routines ────────────────────────────────────────────────────────────────
-- Personalised routines are saved unpublished so they stay out of the global
-- library, but their owner still has to be able to read them or the app cannot
-- open what Celia just made. This sits alongside the existing
-- "Anyone can view published routines" policy; permissive policies combine
-- with OR, so the public catalogue is unaffected.
drop policy if exists "Owners can read their own routines" on public.routines;
create policy "Owners can read their own routines"
  on public.routines
  for select
  using (created_by is not null and created_by = public.firebase_uid());

-- ── user_routines (saved library, completions, favourites) ──────────────────
drop policy if exists "Users can view their own saved routines" on public.user_routines;
drop policy if exists "Users can save routines" on public.user_routines;
drop policy if exists "Users can update their saved routines" on public.user_routines;
drop policy if exists "Users can delete their saved routines" on public.user_routines;

create policy "Users can view their own saved routines"
  on public.user_routines
  for select
  using (user_id = public.firebase_uid());

create policy "Users can save routines"
  on public.user_routines
  for insert
  with check (user_id = public.firebase_uid());

-- Completions, last-played and favourite toggles are all updates to this row,
-- and the streak is derived from them.
create policy "Users can update their saved routines"
  on public.user_routines
  for update
  using (user_id = public.firebase_uid())
  with check (user_id = public.firebase_uid());

create policy "Users can delete their saved routines"
  on public.user_routines
  for delete
  using (user_id = public.firebase_uid());

-- ── user_meals (calorie scanner log) ───────────────────────────────────────
-- This table had row-level security enabled and no policies at all, so every
-- request that was not the service key was denied.
drop policy if exists "Users can view their own meals" on public.user_meals;
drop policy if exists "Users can log their own meals" on public.user_meals;
drop policy if exists "Users can update their own meals" on public.user_meals;
drop policy if exists "Users can delete their own meals" on public.user_meals;

create policy "Users can view their own meals"
  on public.user_meals
  for select
  using (user_id = public.firebase_uid());

create policy "Users can log their own meals"
  on public.user_meals
  for insert
  with check (user_id = public.firebase_uid());

create policy "Users can update their own meals"
  on public.user_meals
  for update
  using (user_id = public.firebase_uid())
  with check (user_id = public.firebase_uid());

create policy "Users can delete their own meals"
  on public.user_meals
  for delete
  using (user_id = public.firebase_uid());

-- ── routine_requests ───────────────────────────────────────────────────────
-- Same stale auth.uid() pattern, and the same uuid cast waiting to fail.
drop policy if exists "Users can view their own requests" on public.routine_requests;
drop policy if exists "Users can create requests" on public.routine_requests;

create policy "Users can view their own requests"
  on public.routine_requests
  for select
  using (user_id = public.firebase_uid());

create policy "Users can create requests"
  on public.routine_requests
  for insert
  with check (user_id = public.firebase_uid());
