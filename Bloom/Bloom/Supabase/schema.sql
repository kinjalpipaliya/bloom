create extension if not exists pgcrypto;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  full_name text,
  created_at timestamptz not null default now()
);

create table public.onboarding_responses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,

  moods text[] not null default '{}',
  intentions text[] not null default '{}',
  blockers text[] not null default '{}',
  patterns text[] not null default '{}',

  energy text,
  reaction text,
  support_style text,

  completed boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.sessions (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  subtitle text,
  category text not null,
  session_type text not null default 'affirmation',
  duration_seconds integer not null default 300,

  cover_emoji text,
  audio_url text,
  script_text text,

  is_featured boolean not null default false,
  is_premium boolean not null default false,
  is_active boolean not null default true,

  created_at timestamptz not null default now()
);

create table public.user_saved_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  session_id uuid not null references public.sessions(id) on delete cascade,
  created_at timestamptz not null default now(),

  unique(user_id, session_id)
);

create table public.user_preferences (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.profiles(id) on delete cascade,

  reminder_enabled boolean not null default false,
  reminder_time text,
  preferred_session_length integer,
  preferred_tone text,
  music_enabled boolean not null default true,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger set_onboarding_responses_updated_at
before update on public.onboarding_responses
for each row
execute function public.set_updated_at();

create trigger set_user_preferences_updated_at
before update on public.user_preferences
for each row
execute function public.set_updated_at();

alter table public.profiles enable row level security;
alter table public.onboarding_responses enable row level security;
alter table public.sessions enable row level security;
alter table public.user_saved_sessions enable row level security;
alter table public.user_preferences enable row level security;

create policy "users can view own profile"
on public.profiles
for select
using (auth.uid() = id);

create policy "users can insert own profile"
on public.profiles
for insert
with check (auth.uid() = id);

create policy "users can update own profile"
on public.profiles
for update
using (auth.uid() = id);

create policy "users can view own onboarding"
on public.onboarding_responses
for select
using (auth.uid() = user_id);

create policy "users can insert own onboarding"
on public.onboarding_responses
for insert
with check (auth.uid() = user_id);

create policy "users can update own onboarding"
on public.onboarding_responses
for update
using (auth.uid() = user_id);

create policy "users can delete own onboarding"
on public.onboarding_responses
for delete
using (auth.uid() = user_id);

create policy "authenticated users can read sessions"
on public.sessions
for select
using (auth.role() = 'authenticated');

create policy "users can view own saved sessions"
on public.user_saved_sessions
for select
using (auth.uid() = user_id);

create policy "users can insert own saved sessions"
on public.user_saved_sessions
for insert
with check (auth.uid() = user_id);

create policy "users can delete own saved sessions"
on public.user_saved_sessions
for delete
using (auth.uid() = user_id);

create policy "users can view own preferences"
on public.user_preferences
for select
using (auth.uid() = user_id);

create policy "users can insert own preferences"
on public.user_preferences
for insert
with check (auth.uid() = user_id);

create policy "users can update own preferences"
on public.user_preferences
for update
using (auth.uid() = user_id);

insert into public.sessions
(title, subtitle, category, session_type, duration_seconds, cover_emoji, is_featured)
values
('Morning Reset', 'Start soft and steady', 'peace', 'affirmation', 300, '🌅', true),
('Calm Mind', 'Quiet mental noise', 'clarity', 'affirmation', 420, '🌙', true),
('Confidence Boost', 'Return to self-trust', 'confidence', 'affirmation', 360, '✨', false),
('Sleep Wind Down', 'Slow down for rest', 'sleep', 'affirmation', 600, '🛌', true);
