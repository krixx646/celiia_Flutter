-- Body scan: no free scans by default. Access is purchase or redeem code only.
-- Safe to run more than once.

alter table public.user_entitlements
  alter column scans_limit set default 0;

-- Existing free period allowance → 0. Paid/promo balances stay in bonus_scans.
update public.user_entitlements
   set scans_limit = 0,
       updated_at = now()
 where scans_limit > 0;

-- Dev / coach test code (Valentin). Redeem in the app paywall.
insert into public.scanner_codes (code, scans_grant, max_redemptions, note)
values ('VAL-TEST', 20, 10, 'Dev testing — Valentin')
on conflict (code) do update
  set scans_grant = excluded.scans_grant,
      max_redemptions = excluded.max_redemptions,
      note = excluded.note;
