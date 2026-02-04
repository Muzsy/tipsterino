-- Migration 20260204000000: helper + RPC to grant the signup bonus post-verification

create or replace function public.is_email_verified(p_user_id uuid)
  returns boolean
  security definer
  language plpgsql
as $$
declare
  verified boolean;
begin
  perform set_config('search_path', 'pg_catalog, public, auth', true);

  if p_user_id is null then
    return false;
  end if;

  select coalesce(email_confirmed_at, confirmed_at) is not null
    into verified
    from auth.users
   where id = p_user_id;

  return coalesce(verified, false);
end;
$$;

create or replace function public.grant_signup_bonus_if_eligible()
  returns jsonb
  security definer
  language plpgsql
as $$
declare
  v_user_id uuid := auth.uid();
  v_amount integer;
  v_enabled boolean;
  v_grant_id uuid;
begin
  perform set_config('search_path', 'pg_catalog, public, auth', true);

  if v_user_id is null then
    return jsonb_build_object('granted', false, 'amount', 0, 'reason', 'not_authenticated');
  end if;

  if not public.is_email_verified(v_user_id) then
    return jsonb_build_object('granted', false, 'amount', 0, 'reason', 'not_verified');
  end if;

  select amount, enabled into v_amount, v_enabled
    from public.reward_definitions
   where code = 'signup_bonus';

  if v_amount is null then
    return jsonb_build_object('granted', false, 'amount', 0, 'reason', 'disabled');
  end if;

  if not v_enabled then
    return jsonb_build_object('granted', false, 'amount', v_amount, 'reason', 'disabled');
  end if;

  insert into public.reward_grants (user_id, code, amount, reason)
    values (v_user_id, 'signup_bonus', v_amount, 'signup_bonus_rpc')
    on conflict (user_id, code) do nothing
    returning id into v_grant_id;

  if v_grant_id is null then
    return jsonb_build_object('granted', false, 'amount', v_amount, 'reason', 'already_granted');
  end if;

  insert into public.user_stats (user_id)
    values (v_user_id)
    on conflict (user_id) do nothing;

  update public.user_stats
     set tippcoins = tippcoins + v_amount,
         updated_at = now()
   where user_id = v_user_id;

  insert into public.user_events (user_id, type, code, amount, payload)
    values (v_user_id, 'tippcoin_credit', 'signup_bonus', v_amount,
            jsonb_build_object('source', 'rpc', 'grant_code', 'signup_bonus'));

  return jsonb_build_object('granted', true, 'amount', v_amount, 'reason', 'granted');
end;
$$;

grant execute on function public.grant_signup_bonus_if_eligible() to authenticated;
