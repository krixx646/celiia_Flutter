-- Equipment preference on the onboarding profile.
--
-- uses_equipment null  = never answered.
-- uses_equipment false = bodyweight only (available_equipment ignored / empty).
-- uses_equipment true  = kit listed in available_equipment.

alter table public.user_profiles
  add column if not exists uses_equipment boolean;

alter table public.user_profiles
  add column if not exists available_equipment text[] not null default '{}';

comment on column public.user_profiles.uses_equipment is
  'null = unanswered; false = bodyweight only; true = has kit in available_equipment';

comment on column public.user_profiles.available_equipment is
  'Equipment tags the user owns when uses_equipment is true';
