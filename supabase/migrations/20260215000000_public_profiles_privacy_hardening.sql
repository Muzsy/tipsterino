-- Audit P0-1 privacy hardening.
-- Contract decision: keep public read on public.public_profiles for anon/authenticated,
-- but freeze minimal field set and explicit grants.

create or replace view public.public_profiles as
  select p.id, p.nickname, p.avatar_key
  from public.profiles p;

revoke all on table public.public_profiles from public;
revoke all on table public.public_profiles from anon;
revoke all on table public.public_profiles from authenticated;

grant select on table public.public_profiles to anon;
grant select on table public.public_profiles to authenticated;
