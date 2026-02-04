-- Migration 20260203000000: bonus system tables + RLS + grants
create extension if not exists "pgcrypto";

create table if not exists public.reward_definitions (
  code text primary key,
  amount integer not null check (amount >= 0),
  enabled boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint reward_definitions_code_format check (code ~ '^[a-z0-9_]{3,40}$')
);

create table if not exists public.reward_grants (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  code text not null references public.reward_definitions(code),
  amount integer not null check (amount >= 0),
  reason text,
  created_at timestamptz not null default now()
);

create unique index if not exists reward_grants_user_id_code_unique
  on public.reward_grants (user_id, code);
create index if not exists reward_grants_user_created_at_idx
  on public.reward_grants (user_id, created_at desc);

create table if not exists public.user_stats (
  user_id uuid primary key references auth.users(id) on delete cascade,
  tippcoins integer not null default 0 check (tippcoins >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.user_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  type text not null,
  code text,
  amount integer,
  payload jsonb,
  created_at timestamptz not null default now(),
  read_at timestamptz,
  constraint user_events_type_format check (type ~ '^[a-z0-9_]{3,40}$'),
  constraint user_events_code_format check (code is null or code ~ '^[a-z0-9_]{3,40}$'),
  constraint user_events_amount_positive check (amount is null or amount >= 0)
);
create index if not exists user_events_user_created_at_idx
  on public.user_events (user_id, created_at desc);

create or replace function public.set_updated_at()
  returns trigger
  language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists reward_definitions_set_updated_at on public.reward_definitions;
create trigger reward_definitions_set_updated_at
  before update on public.reward_definitions
  for each row execute function public.set_updated_at();

drop trigger if exists user_stats_set_updated_at on public.user_stats;
create trigger user_stats_set_updated_at
  before update on public.user_stats
  for each row execute function public.set_updated_at();

alter table public.reward_definitions enable row level security;
alter table public.reward_grants enable row level security;
alter table public.user_stats enable row level security;
alter table public.user_events enable row level security;

drop policy if exists reward_grants_select on public.reward_grants;
create policy reward_grants_select on public.reward_grants
  for select using (user_id = auth.uid());

drop policy if exists user_stats_select on public.user_stats;
create policy user_stats_select on public.user_stats
  for select using (user_id = auth.uid());

drop policy if exists user_events_select on public.user_events;
create policy user_events_select on public.user_events
  for select using (user_id = auth.uid());

drop policy if exists user_events_update on public.user_events;
create policy user_events_update on public.user_events
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());

grant select on public.reward_grants to authenticated;
grant select on public.user_stats to authenticated;
grant select on public.user_events to authenticated;
grant update (read_at) on public.user_events to authenticated;

insert into public.reward_definitions (code, amount, enabled)
  values ('signup_bonus', 0, true)
  on conflict (code) do nothing;
