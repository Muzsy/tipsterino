create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nickname text not null,
  avatar_key text not null,
  created_at timestamptz not null default now(),
  constraint profiles_nickname_format check (nickname ~ '^[a-z0-9_.]{3,20}$')
);

create unique index if not exists profiles_nickname_lower_ux on public.profiles (lower(nickname));

alter table public.profiles enable row level security;

create policy if not exists profiles_select_own_profile on public.profiles
  for select using (auth.uid() = id);
create policy if not exists profiles_update_own_profile on public.profiles
  for update using (auth.uid() = id) with check (auth.uid() = id);

create or replace view public.public_profiles as
  select id, nickname, avatar_key
  from public.profiles;

grant select on public.public_profiles to anon;
grant select on public.public_profiles to authenticated;

create or replace function public.check_nickname_available(p_nickname text)
  returns boolean
  language sql stable as $$
    select not exists (
      select 1
      from public.profiles
      where lower(nickname) = lower(p_nickname)
    );
  $$;

create or replace function public.create_profile_on_signup()
  returns trigger
  language plpgsql
  security definer
  as $$
begin
  if new.raw_user_meta_data is null then
    raise exception 'Missing nickname/avatar_key in user metadata';
  end if;

  perform 1 from new.raw_user_meta_data;

  if (new.raw_user_meta_data ->> 'nickname') is null
     or (new.raw_user_meta_data ->> 'avatar_key') is null then
    raise exception 'Missing nickname/avatar_key in user metadata';
  end if;

  insert into public.profiles(id, nickname, avatar_key)
  values (
    new.id,
    lower(new.raw_user_meta_data ->> 'nickname'),
    new.raw_user_meta_data ->> 'avatar_key'
  );

  return new;
end;
$$;

create trigger create_profile_on_signup_trigger
  after insert on auth.users
  for each row
  execute function public.create_profile_on_signup();
