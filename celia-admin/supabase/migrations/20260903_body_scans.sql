-- Body Scan: photo-based body composition (Bodygram).
--
-- Photos are never stored. They pass through /api/mobile/body-scan in memory
-- on their way to the vendor; only the derived numbers and the 3D mesh land
-- here. Safe to run more than once.

create table if not exists public.body_scans (
  id             uuid primary key default gen_random_uuid(),
  user_id        text not null,
  vendor         text not null default 'bodygram',
  vendor_scan_id text,

  -- The inputs are echoed back because a result is only interpretable
  -- alongside the weight and height it was estimated from.
  age            int,
  gender         text,
  height_mm      int,
  weight_g       int,

  body_fat_pct        numeric,
  lean_mass_g         numeric,
  body_fat_mass_g     numeric,
  measurements   jsonb not null default '[]'::jsonb,  -- [{name, unit, value}]
  posture        jsonb,

  -- Object path inside the private body-meshes bucket. Null when the vendor
  -- returned no avatar or the conversion failed; the metrics are still useful.
  mesh_path      text,

  scanned_at     timestamptz not null default now(),
  created_at     timestamptz not null default now()
);

create index if not exists body_scans_user_scanned_idx
  on public.body_scans (user_id, scanned_at desc);

alter table public.body_scans enable row level security;

-- No anon policy on purpose: every read and write goes through the backend
-- with the service role, matching user_meals.

-- Scan quota. This is the seam where a real, receipt-backed entitlement will
-- eventually sit; until billing exists it enforces a per-period scan budget so
-- vendor cost cannot run away.
create table if not exists public.user_entitlements (
  user_id      text primary key,
  tier         text not null default 'free',   -- free | premium | comp
  scans_limit  int not null default 1,
  scans_used   int not null default 0,
  period_start timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

alter table public.user_entitlements enable row level security;

-- Reserving quota has to be atomic, or two scans fired at once both read
-- scans_used before either writes and both slip past the limit. The row lock
-- makes the check-and-increment a single step.
create or replace function public.consume_body_scan_quota(
  p_user_id text,
  p_period_days int default 30
)
returns table (allowed boolean, remaining int, resets_at timestamptz)
language plpgsql
as $$
declare
  v_row public.user_entitlements%rowtype;
begin
  insert into public.user_entitlements (user_id)
  values (p_user_id)
  on conflict (user_id) do nothing;

  select * into v_row
    from public.user_entitlements
   where user_id = p_user_id
     for update;

  if v_row.period_start < now() - make_interval(days => p_period_days) then
    v_row.scans_used := 0;
    v_row.period_start := now();
  end if;

  if v_row.scans_used >= v_row.scans_limit then
    update public.user_entitlements
       set scans_used = v_row.scans_used,
           period_start = v_row.period_start,
           updated_at = now()
     where user_id = p_user_id;

    return query
      select false, 0, v_row.period_start + make_interval(days => p_period_days);
    return;
  end if;

  update public.user_entitlements
     set scans_used = v_row.scans_used + 1,
         period_start = v_row.period_start,
         updated_at = now()
   where user_id = p_user_id;

  return query
    select true,
           greatest(v_row.scans_limit - (v_row.scans_used + 1), 0),
           v_row.period_start + make_interval(days => p_period_days);
end;
$$;

-- Quota is reserved before the vendor call, so a scan the vendor rejects for a
-- bad photo has to give it back. Charging someone a month's scan for standing
-- too close to the camera is not a product we want to ship.
create or replace function public.refund_body_scan_quota(p_user_id text)
returns void
language sql
as $$
  update public.user_entitlements
     set scans_used = greatest(scans_used - 1, 0),
         updated_at = now()
   where user_id = p_user_id;
$$;

-- Private bucket for the generated .glb meshes. Served to the app as
-- short-lived signed URLs, never public.
insert into storage.buckets (id, name, public)
values ('body-meshes', 'body-meshes', false)
on conflict (id) do nothing;
