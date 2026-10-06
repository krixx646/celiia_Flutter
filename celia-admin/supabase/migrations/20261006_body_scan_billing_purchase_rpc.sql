-- Atomic purchase recording + scan grant.
-- Inserting the purchase row and crediting the scans happen in ONE transaction,
-- so a crash or retry can never leave a purchase recorded without its scans
-- (or credit the same store transaction twice).
-- Run in the Supabase SQL editor after 20261006_body_scan_billing_grant_fix.sql.

create or replace function public.record_purchase_and_grant(
  p_user_id text,
  p_platform text,
  p_product_id text,
  p_transaction_id text,
  p_purchase_token text,
  p_scans int,
  p_raw jsonb
)
returns table (granted boolean, remaining int)
language plpgsql
as $$
declare
  v_inserted int;
  v_remaining int;
begin
  insert into public.purchases (
    user_id, platform, product_id, transaction_id, purchase_token,
    status, scans_granted, raw_payload, verified_at
  )
  values (
    p_user_id, p_platform, p_product_id, p_transaction_id, p_purchase_token,
    'verified', p_scans, p_raw, now()
  )
  on conflict (platform, transaction_id) do nothing;

  get diagnostics v_inserted = row_count;

  if v_inserted = 0 then
    select greatest(ue.scans_limit - ue.scans_used, 0) + ue.bonus_scans
      into v_remaining
      from public.user_entitlements ue
     where ue.user_id = p_user_id;
    return query select false, coalesce(v_remaining, 0);
    return;
  end if;

  select g.remaining into v_remaining
    from public.grant_body_scan_scans(p_user_id, p_scans) as g;

  return query select true, coalesce(v_remaining, 0);
end;
$$;
