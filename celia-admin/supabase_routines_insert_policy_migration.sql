-- Only the server may add routines.
--
-- The routines table accepted inserts from anyone: the policy checked `true`
-- for PUBLIC, so the anon key that ships inside the app was enough to write a
-- row with is_published = true and place arbitrary content in every user's
-- library. This was confirmed by doing exactly that with the app's own key.
--
-- Nothing legitimate depended on it. Users still create routines the way they
-- always have, through the backend: /api/mobile/generate-routine and Celia's
-- create_routine tool both verify the caller's Firebase ID token and then write
-- with the service key, as does the admin dashboard. The app itself never
-- inserts routines directly.
--
-- The service key bypasses row-level security, so the policy below grants
-- nothing it would not already have; it states the intent in the schema and
-- follows the convention already used on the videos table.

drop policy if exists "Service can insert routines" on public.routines;
drop policy if exists "Allow service role insert on routines" on public.routines;

create policy "Allow service role insert on routines"
  on public.routines
  for insert
  to service_role
  with check (true);
