-- Body scan billing: purchased/promo scans (bonus_scans), purchase audit,
-- and redeemable coach/trial codes. Safe to run more than once.

-- Purchased and promo scans live here so the free monthly allowance can still
-- reset without wiping what the user paid for.
alter table public.user_entitlements
  add column if not exists bonus_scans int not null default 0;

alter table public.user_entitlements
  add column if not exists last_consume_bonus boolean not null default false;

-- Receipt-backed grants. Unique on (platform, transaction_id) so a replay
-- cannot double-credit.
create table if not exists public.purchases (
  id              uuid primary key default gen_random_uuid(),
  user_id         text not null,
  platform        text not null check (platform in ('ios', 'android')),
  product_id      text not null,
  transaction_id  text not null,
  purchase_token  text,
  status          text not null default 'verified'
                  check (status in ('pending', 'verified', 'failed', 'refunded')),
  scans_granted   int not null default 0,
  raw_payload     jsonb,
  verified_at     timestamptz,
  created_at      timestamptz not null default now(),
  unique (platform, transaction_id)
);

create index if not exists purchases_user_created_idx
  on public.purchases (user_id, created_at desc);

alter table public.purchases enable row level security;

create table if not exists public.scanner_codes (
  code              text primary key,
  scans_grant       int not null check (scans_grant > 0),
  max_redemptions   int,
  redemption_count  int not null default 0,
  note              text,
  valid_from        timestamptz not null default now(),
  valid_until       timestamptz,
  created_at        timestamptz not null default now(),
  check (max_redemptions is null or max_redemptions > 0)
);

alter table public.scanner_codes enable row level security;

create table if not exists public.scanner_code_redemptions (
  id          uuid primary key default gen_random_uuid(),
  code        text not null references public.scanner_codes(code),
  user_id     text not null,
  redeemed_at timestamptz not null default now(),
  unique (code, user_id)
);

create index if not exists scanner_code_redemptions_user_idx
  on public.scanner_code_redemptions (user_id, redeemed_at desc);

alter table public.scanner_code_redemptions enable row level security;

-- Atomic consume: spend a bonus scan first, then the free period allowance.
create or replace function public.consume_body_scan_quota(
  p_user_id text,
  p_period_days int default 30
)
returns table (allowed boolean, remaining int, resets_at timestamptz)
language plpgsql
as $$
declare
  v_row public.user_entitlements%rowtype;
  v_period_remaining int;
  v_remaining int;
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

  v_period_remaining := greatest(v_row.scans_limit - v_row.scans_used, 0);

  if v_row.bonus_scans > 0 then
    update public.user_entitlements
       set bonus_scans = v_row.bonus_scans - 1,
           last_consume_bonus = true,
           scans_used = v_row.scans_used,
           period_start = v_row.period_start,
           updated_at = now()
     where user_id = p_user_id;

    v_remaining := (v_row.bonus_scans - 1) + v_period_remaining;
    return query
      select true,
             v_remaining,
             v_row.period_start + make_interval(days => p_period_days);
    return;
  end if;

  if v_row.scans_used >= v_row.scans_limit then
    update public.user_entitlements
       set scans_used = v_row.scans_used,
           period_start = v_row.period_start,
           last_consume_bonus = false,
           updated_at = now()
     where user_id = p_user_id;

    return query
      select false, 0, v_row.period_start + make_interval(days => p_period_days);
    return;
  end if;

  update public.user_entitlements
     set scans_used = v_row.scans_used + 1,
         period_start = v_row.period_start,
         last_consume_bonus = false,
         updated_at = now()
   where user_id = p_user_id;

  v_remaining := greatest(v_row.scans_limit - (v_row.scans_used + 1), 0)
                 + v_row.bonus_scans;

  return query
    select true,
           v_remaining,
           v_row.period_start + make_interval(days => p_period_days);
end;
$$;

-- Undo the most recent consume for this user (vendor rejection path).
create or replace function public.refund_body_scan_quota(p_user_id text)
returns void
language plpgsql
as $$
declare
  v_row public.user_entitlements%rowtype;
begin
  select * into v_row
    from public.user_entitlements
   where user_id = p_user_id
     for update;

  if not found then
    return;
  end if;

  if v_row.last_consume_bonus then
    update public.user_entitlements
       set bonus_scans = bonus_scans + 1,
           last_consume_bonus = false,
           updated_at = now()
     where user_id = p_user_id;
  else
    update public.user_entitlements
       set scans_used = greatest(scans_used - 1, 0),
           last_consume_bonus = false,
           updated_at = now()
     where user_id = p_user_id;
  end if;
end;
$$;

create or replace function public.grant_body_scan_scans(
  p_user_id text,
  p_scans int
)
returns table (
  bonus_scans int,
  scans_limit int,
  scans_used int,
  remaining int
)
language plpgsql
as $$
declare
  v_row public.user_entitlements%rowtype;
begin
  if p_scans is null or p_scans <= 0 then
    raise exception 'p_scans must be positive';
  end if;

  insert into public.user_entitlements (user_id)
  values (p_user_id)
  on conflict (user_id) do nothing;

  -- Qualify the table alias: RETURNS TABLE exposes bonus_scans as a PL/pgSQL
  -- variable, so an unqualified "bonus_scans = bonus_scans + …" is ambiguous.
  update public.user_entitlements as ue
     set bonus_scans = ue.bonus_scans + p_scans,
         updated_at = now()
   where ue.user_id = p_user_id
  returning ue.* into v_row;

  return query
    select v_row.bonus_scans,
           v_row.scans_limit,
           v_row.scans_used,
           greatest(v_row.scans_limit - v_row.scans_used, 0) + v_row.bonus_scans;
end;
$$;

-- Redeem a coach/trial code. One redemption per user per code.
create or replace function public.redeem_scanner_code(
  p_user_id text,
  p_code text
)
returns table (
  ok boolean,
  reason text,
  scans_granted int,
  remaining int
)
language plpgsql
as $$
declare
  v_code text;
  v_row public.scanner_codes%rowtype;
  v_grant int;
  v_remaining int;
begin
  v_code := upper(trim(both from coalesce(p_code, '')));
  if v_code = '' then
    return query select false, 'invalid'::text, 0, 0;
    return;
  end if;

  select * into v_row
    from public.scanner_codes
   where code = v_code
     for update;

  if not found then
    return query select false, 'not_found'::text, 0, 0;
    return;
  end if;

  if v_row.valid_from > now()
     or (v_row.valid_until is not null and v_row.valid_until < now()) then
    return query select false, 'expired'::text, 0, 0;
    return;
  end if;

  if v_row.max_redemptions is not null
     and v_row.redemption_count >= v_row.max_redemptions then
    return query select false, 'exhausted'::text, 0, 0;
    return;
  end if;

  if exists (
    select 1 from public.scanner_code_redemptions
     where code = v_code and user_id = p_user_id
  ) then
    return query select false, 'already_redeemed'::text, 0, 0;
    return;
  end if;

  insert into public.scanner_code_redemptions (code, user_id)
  values (v_code, p_user_id);

  update public.scanner_codes
     set redemption_count = redemption_count + 1
   where code = v_code;

  select g.remaining into v_remaining
    from public.grant_body_scan_scans(p_user_id, v_row.scans_grant) as g;

  v_grant := v_row.scans_grant;
  return query select true, 'ok'::text, v_grant, coalesce(v_remaining, 0);
end;
$$;
