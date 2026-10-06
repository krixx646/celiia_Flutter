-- Fix ambiguous bonus_scans in grant_body_scan_scans (RETURNS TABLE name clash).
-- Run this in the Supabase SQL editor after 20261006_body_scan_billing.sql.

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
