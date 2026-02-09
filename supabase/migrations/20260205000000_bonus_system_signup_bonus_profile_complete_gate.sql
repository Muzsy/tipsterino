-- Migration 20260205000000: profile completeness helper for signup bonus RPC

create or replace function public.is_profile_complete(p_user_id uuid)
  returns boolean
  security definer
  language plpgsql
as $$
declare
  v_nickname text;
  v_avatar_key text;
begin
  perform set_config('search_path', 'pg_catalog, public, auth', true);

  if p_user_id is null then
    return false;
  end if;

  select nickname, avatar_key
    into v_nickname, v_avatar_key
    from public.profiles
   where id = p_user_id;

  return v_nickname is not null
     and btrim(v_nickname) <> ''
     and v_avatar_key is not null
     and btrim(v_avatar_key) <> '';
end;
$$;
