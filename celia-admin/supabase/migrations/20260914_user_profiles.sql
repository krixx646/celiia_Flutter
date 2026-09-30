-- Onboarding profile: everything the 9-step signup collects.
--
-- This lives server-side rather than in Firestore because the answers have to
-- reach the routine generator and the Celia agent, neither of which can read
-- Firestore. Safe to run more than once.

create table if not exists public.user_profiles (
  user_id text primary key,

  -- Step 1 — registration and consent.
  -- The disclaimer is a legal record, so we keep when it was accepted and
  -- which wording was shown, not just a boolean.
  terms_accepted_at timestamptz,
  terms_version     text,

  -- Step 2 — physical data. BMR is stored alongside the inputs so a later
  -- change to the formula is visible as a change, rather than silently
  -- rewriting history.
  sex        text,      -- male | female | other
  age        int,
  weight_kg  numeric,
  height_cm  numeric,
  bmr_kcal   numeric,

  -- Step 3 — what the user is here for.
  primary_goal text,    -- lose_weight | gain_weight | build_muscle

  -- Step 4 — nutrition.
  diet_pattern              text,                            -- omnivore | vegetarian | vegan | pescatarian
  dietary_conditions        text[] not null default '{}',    -- celiac, lactose_intolerant, ...
  food_allergies            text[] not null default '{}',    -- free text: nuts, shellfish, ...
  -- Flagged so plans never push an aggressive deficit at someone with a
  -- history of disordered eating. Sensitive: read by the agent, never shown
  -- back to the user as a label.
  disordered_eating_history boolean not null default false,
  nutrition_mode            text not null default 'automatic', -- automatic | manual
  daily_water_ml            int,

  -- Computed targets. Duplicated from the client's Firestore profile on
  -- purpose: this is the copy the backend is allowed to read.
  daily_calories      numeric,
  daily_protein_grams numeric,
  daily_carbs_grams   numeric,
  daily_fat_grams     numeric,

  -- Step 5 — training.
  training_location       text,                          -- home | gym | both
  injuries                text[] not null default '{}',  -- knee, lower_back, ...
  medical_conditions      text[] not null default '{}',  -- hypertension, diabetes, ...
  fitness_goal            text,                          -- lose_fat | strength | tone | health | tactical | custom
  desired_outcomes        text[] not null default '{}',  -- stress, sleep, energy, habits, biohacking, confidence
  training_intensity      text,                          -- easy | moderate | intense
  experience_level        text,                          -- beginner | regular
  planning_mode           text not null default 'automatic', -- automatic | manual
  minutes_per_day         int,
  preferred_training_time text,                          -- local HH:MM, the daily "what time today?" default

  -- Step 6 — life coaching.
  current_mood    text,
  coaching_focus  text,

  -- Step 7 — notification preferences. Stored as a map so adding a new
  -- notification type later does not need a migration. Delivery itself is a
  -- separate piece of work; this only records what the user agreed to.
  notification_prefs jsonb not null default '{}'::jsonb,

  -- Step 8 — wearables. Recorded only; no integration reads this yet.
  wearable_provider text,   -- google_fit | health_connect | apple_health | fitbit | garmin

  -- Meta. onboarding_version drives who gets asked the new questions: when the
  -- flow grows, bump the constant in the app and everyone below it is routed
  -- back through the steps they have not answered. This replaces the old
  -- per-device SharedPreferences flag, which was lost on reinstall.
  onboarding_version      int not null default 0,
  onboarding_completed_at timestamptz,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.user_profiles enable row level security;

-- No anon policy on purpose: every read and write goes through the backend
-- with the service role, matching user_meals and body_scans.
