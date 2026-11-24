-- OS FIT — PREPARED CLOUD SCHEMA (NOT USED BY V1)
-- For a NEW, DEDICATED Supabase project. DO NOT run against the Mizan Finance database
-- until you explicitly decide to share a project and have reviewed existing objects.
-- No destructive DROP statements, no SECURITY DEFINER functions.
-- This is a future integration starting point. A cloud adapter is not yet shipped.

create table if not exists public.fit_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'Athlete',
  settings jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.fit_exercises (
  user_id uuid not null references auth.users(id) on delete cascade,
  id text not null,
  name text not null,
  muscle text not null,
  equipment text not null,
  is_custom boolean not null default false,
  primary key (user_id,id)
);
create table if not exists public.fit_plans (
  user_id uuid not null references auth.users(id) on delete cascade,
  id text not null,
  name text not null,
  description text not null default '',
  is_active boolean not null default false,
  primary key (user_id,id)
);
create table if not exists public.fit_plan_days (
  user_id uuid not null references auth.users(id) on delete cascade,
  id text not null,
  plan_id text not null,
  title text not null,
  weekday integer not null check (weekday between 0 and 6),
  ordinal integer not null default 0,
  primary key (user_id,id),
  foreign key (user_id,plan_id) references public.fit_plans(user_id,id) on delete cascade
);
create table if not exists public.fit_plan_exercises (
  user_id uuid not null references auth.users(id) on delete cascade,
  id text not null,
  day_id text not null,
  exercise_id text not null,
  target_sets integer not null check (target_sets between 1 and 20),
  target_reps integer not null check (target_reps between 1 and 500),
  rest_seconds integer not null default 90 check (rest_seconds between 0 and 900),
  ordinal integer not null default 0,
  primary key (user_id,id),
  foreign key (user_id,day_id) references public.fit_plan_days(user_id,id) on delete cascade
);
create table if not exists public.fit_workouts (
  user_id uuid not null references auth.users(id) on delete cascade,
  id text not null,
  title text not null,
  date date not null,
  started_at timestamptz not null,
  ended_at timestamptz not null,
  duration_minutes integer not null check (duration_minutes >= 0),
  notes text not null default '',
  primary key (user_id,id)
);
create table if not exists public.fit_workout_exercises (
  user_id uuid not null references auth.users(id) on delete cascade,
  id text not null,
  workout_id text not null,
  exercise_id text not null,
  ordinal integer not null default 0,
  primary key (user_id,id),
  foreign key (user_id,workout_id) references public.fit_workouts(user_id,id) on delete cascade
);
create table if not exists public.fit_workout_sets (
  user_id uuid not null references auth.users(id) on delete cascade,
  id text not null,
  workout_exercise_id text not null,
  ordinal integer not null default 0,
  weight numeric(9,3) not null default 0 check (weight >= 0),
  reps integer not null check (reps >= 0),
  rpe numeric(3,1) check (rpe between 0 and 10),
  is_completed boolean not null default true,
  primary key (user_id,id),
  foreign key (user_id,workout_exercise_id) references public.fit_workout_exercises(user_id,id) on delete cascade
);
create table if not exists public.fit_food_library (
  user_id uuid not null references auth.users(id) on delete cascade,
  id text not null,
  name text not null,
  serving text not null,
  calories numeric(9,2) not null default 0 check (calories >= 0),
  protein numeric(9,2) not null default 0 check (protein >= 0),
  carbs numeric(9,2) not null default 0 check (carbs >= 0),
  fats numeric(9,2) not null default 0 check (fats >= 0),
  primary key (user_id,id)
);
create table if not exists public.fit_nutrition_entries (
  user_id uuid not null references auth.users(id) on delete cascade,
  id text not null,
  date date not null,
  meal text not null check (meal in ('Breakfast','Lunch','Dinner','Snacks')),
  name text not null,
  serving text not null default '',
  calories numeric(9,2) not null default 0 check (calories >= 0),
  protein numeric(9,2) not null default 0 check (protein >= 0),
  carbs numeric(9,2) not null default 0 check (carbs >= 0),
  fats numeric(9,2) not null default 0 check (fats >= 0),
  primary key (user_id,id)
);
create table if not exists public.fit_body_checkins (
  user_id uuid not null references auth.users(id) on delete cascade,
  id text not null,
  date date not null,
  weight numeric(9,3),
  body_fat numeric(6,2),
  chest numeric(9,2),
  waist numeric(9,2),
  hips numeric(9,2),
  arm numeric(9,2),
  thigh numeric(9,2),
  notes text not null default '',
  primary key (user_id,id)
);
create table if not exists public.fit_progress_photos (
  user_id uuid not null references auth.users(id) on delete cascade,
  id text not null,
  date date not null,
  caption text not null default '',
  storage_path text not null,
  primary key (user_id,id)
);
create table if not exists public.fit_live_drafts (
  user_id uuid primary key references auth.users(id) on delete cascade,
  snapshot jsonb not null,
  revision bigint not null default 0 check (revision >= 0),
  updated_at timestamptz not null default now()
);

-- Enable row-level security on every exposed table.
alter table public.fit_profiles enable row level security;
alter table public.fit_exercises enable row level security;
alter table public.fit_plans enable row level security;
alter table public.fit_plan_days enable row level security;
alter table public.fit_plan_exercises enable row level security;
alter table public.fit_workouts enable row level security;
alter table public.fit_workout_exercises enable row level security;
alter table public.fit_workout_sets enable row level security;
alter table public.fit_food_library enable row level security;
alter table public.fit_nutrition_entries enable row level security;
alter table public.fit_body_checkins enable row level security;
alter table public.fit_progress_photos enable row level security;
alter table public.fit_live_drafts enable row level security;

-- Use authenticated users only. No anonymous access granted.
-- All SELECT/INSERT/UPDATE/DELETE operations must also match auth.uid().
do $$
declare tbl text;
begin
  foreach tbl in array array[
    'fit_profiles','fit_exercises','fit_plans','fit_plan_days','fit_plan_exercises',
    'fit_workouts','fit_workout_exercises','fit_workout_sets',
    'fit_food_library','fit_nutrition_entries','fit_body_checkins',
    'fit_progress_photos','fit_live_drafts'
  ] loop
    execute format('revoke all on table public.%I from anon',tbl);
    execute format('grant select,insert,update,delete on table public.%I to authenticated',tbl);
    if not exists(select 1 from pg_policies where schemaname='public' and tablename=tbl and policyname='fit_owner_only') then
      execute format('create policy fit_owner_only on public.%I for all to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id)',tbl);
    end if;
  end loop;
end $$;

create index if not exists fit_workouts_user_date_idx on public.fit_workouts(user_id,date desc);
create index if not exists fit_nutrition_user_date_idx on public.fit_nutrition_entries(user_id,date desc);
create index if not exists fit_checkins_user_date_idx on public.fit_body_checkins(user_id,date desc);

-- Future cloud photo uploads need a PRIVATE Storage bucket and additional
-- storage.objects policies matching auth.uid() against user-specific paths.
-- Do not create a public photo bucket.
-- The static V1 website does not use these tables yet.
