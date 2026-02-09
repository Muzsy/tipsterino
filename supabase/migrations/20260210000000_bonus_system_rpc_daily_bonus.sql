-- Migration 20260210000000: daily bonus RPC + privilege contract

CREATE OR REPLACE FUNCTION public.grant_daily_bonus_if_eligible()
  RETURNS jsonb
  SECURITY DEFINER
  LANGUAGE plpgsql
AS $$
DECLARE
  v_user_id uuid := auth.uid();
  v_nickname text;
  v_avatar_key text;
  v_amount integer;
  v_enabled boolean;
  v_grant_id uuid;
  v_grant_day date := (now() AT TIME ZONE 'UTC')::date;
  v_next_eligible_at timestamptz := (date_trunc('day', now() AT TIME ZONE 'UTC') + interval '1 day') AT TIME ZONE 'UTC';
BEGIN
  PERFORM set_config('search_path', 'pg_catalog, public, auth', true);

  IF v_user_id IS NULL THEN
    RETURN jsonb_build_object(
      'granted', false,
      'amount', 0,
      'reason', 'not_authenticated',
      'next_eligible_at', v_next_eligible_at
    );
  END IF;

  -- Serialise per-user daily bonus claim attempts inside one transaction window.
  IF NOT pg_try_advisory_xact_lock(hashtext('daily_bonus_claim'), hashtext(v_user_id::text)) THEN
    RETURN jsonb_build_object(
      'granted', false,
      'amount', 0,
      'reason', 'already_claimed_today',
      'next_eligible_at', v_next_eligible_at
    );
  END IF;

  IF NOT public.is_email_verified(v_user_id) THEN
    RETURN jsonb_build_object(
      'granted', false,
      'amount', 0,
      'reason', 'not_verified',
      'next_eligible_at', v_next_eligible_at
    );
  END IF;

  SELECT nickname, avatar_key
    INTO v_nickname, v_avatar_key
    FROM public.profiles
   WHERE id = v_user_id;

  IF v_nickname IS NULL OR btrim(v_nickname) = ''
     OR v_avatar_key IS NULL OR btrim(v_avatar_key) = '' THEN
    RETURN jsonb_build_object(
      'granted', false,
      'amount', 0,
      'reason', 'profile_incomplete',
      'next_eligible_at', v_next_eligible_at
    );
  END IF;

  SELECT amount, enabled INTO v_amount, v_enabled
    FROM public.reward_definitions
   WHERE code = 'daily_bonus';

  IF v_amount IS NULL THEN
    RETURN jsonb_build_object(
      'granted', false,
      'amount', 0,
      'reason', 'disabled',
      'next_eligible_at', v_next_eligible_at
    );
  END IF;

  IF NOT v_enabled OR v_amount <= 0 THEN
    RETURN jsonb_build_object(
      'granted', false,
      'amount', 0,
      'reason', 'disabled',
      'next_eligible_at', v_next_eligible_at
    );
  END IF;

  INSERT INTO public.reward_grants (user_id, code, amount, reason, grant_day)
    VALUES (v_user_id, 'daily_bonus', v_amount, 'daily_bonus_rpc', v_grant_day)
    ON CONFLICT (user_id, code, grant_day)
      WHERE code = 'daily_bonus' AND grant_day IS NOT NULL
      DO NOTHING
    RETURNING id INTO v_grant_id;

  IF v_grant_id IS NULL THEN
    RETURN jsonb_build_object(
      'granted', false,
      'amount', 0,
      'reason', 'already_claimed_today',
      'next_eligible_at', v_next_eligible_at
    );
  END IF;

  INSERT INTO public.user_stats (user_id)
    VALUES (v_user_id)
    ON CONFLICT (user_id) DO NOTHING;

  UPDATE public.user_stats
     SET tippcoins = tippcoins + v_amount,
         updated_at = now()
   WHERE user_id = v_user_id;

  INSERT INTO public.user_events (user_id, type, code, amount, payload)
    VALUES (
      v_user_id,
      'tippcoin_credit',
      'daily_bonus',
      v_amount,
      jsonb_build_object('source', 'rpc', 'grant_code', 'daily_bonus')
    );

  RETURN jsonb_build_object(
    'granted', true,
    'amount', v_amount,
    'reason', 'granted',
    'next_eligible_at', v_next_eligible_at
  );
END;
$$;

REVOKE ALL ON FUNCTION public.grant_daily_bonus_if_eligible() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.grant_daily_bonus_if_eligible() TO authenticated;
