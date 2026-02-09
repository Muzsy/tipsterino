-- Migration 20260213000000: bonus RPC rate-limit helper + guard wiring

CREATE TABLE IF NOT EXISTS public.rpc_rate_limit_state (
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  rpc_code text NOT NULL CHECK (rpc_code ~ '^[a-z0-9_]{3,60}$'),
  attempt_count integer NOT NULL DEFAULT 0 CHECK (attempt_count >= 0),
  window_started_at timestamptz NOT NULL DEFAULT now(),
  last_attempt_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, rpc_code)
);

ALTER TABLE public.rpc_rate_limit_state ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON TABLE public.rpc_rate_limit_state FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.consume_bonus_rpc_token(
  p_user_id uuid,
  p_rpc_code text,
  p_window_seconds integer DEFAULT 10,
  p_max_attempts integer DEFAULT 5
)
RETURNS boolean
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
DECLARE
  v_attempt_count integer;
BEGIN
  PERFORM set_config('search_path', 'pg_catalog, public, auth', true);

  IF p_user_id IS NULL THEN
    RETURN false;
  END IF;

  IF p_window_seconds < 1 OR p_max_attempts < 1 THEN
    RAISE EXCEPTION 'invalid limiter parameters';
  END IF;

  INSERT INTO public.rpc_rate_limit_state (
    user_id,
    rpc_code,
    attempt_count,
    window_started_at,
    last_attempt_at
  )
  VALUES (
    p_user_id,
    p_rpc_code,
    1,
    now(),
    now()
  )
  ON CONFLICT (user_id, rpc_code)
  DO UPDATE
    SET attempt_count = CASE
      WHEN public.rpc_rate_limit_state.window_started_at <= now() - make_interval(secs => p_window_seconds)
        THEN 1
      ELSE public.rpc_rate_limit_state.attempt_count + 1
    END,
    window_started_at = CASE
      WHEN public.rpc_rate_limit_state.window_started_at <= now() - make_interval(secs => p_window_seconds)
        THEN now()
      ELSE public.rpc_rate_limit_state.window_started_at
    END,
    last_attempt_at = now()
  RETURNING attempt_count INTO v_attempt_count;

  RETURN v_attempt_count <= p_max_attempts;
END;
$$;

REVOKE ALL ON FUNCTION public.consume_bonus_rpc_token(uuid, text, integer, integer)
  FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.grant_signup_bonus_if_eligible()
  RETURNS jsonb
  SECURITY DEFINER
  LANGUAGE plpgsql
AS $$
DECLARE
  v_user_id uuid := auth.uid();
  v_amount integer;
  v_enabled boolean;
  v_grant_id uuid;
  v_nickname text;
  v_avatar_key text;
  v_allowed boolean;
BEGIN
  PERFORM set_config('search_path', 'pg_catalog, public, auth', true);

  IF v_user_id IS NULL THEN
    RETURN jsonb_build_object('granted', false, 'amount', 0, 'reason', 'not_authenticated');
  END IF;

  IF NOT pg_try_advisory_xact_lock(hashtext('bonus_rpc_signup'), hashtext(v_user_id::text)) THEN
    RETURN jsonb_build_object('granted', false, 'amount', 0, 'reason', 'rate_limited');
  END IF;

  v_allowed := public.consume_bonus_rpc_token(v_user_id, 'signup_bonus_rpc', 10, 5);
  IF NOT v_allowed THEN
    RETURN jsonb_build_object('granted', false, 'amount', 0, 'reason', 'rate_limited');
  END IF;

  IF NOT public.is_email_verified(v_user_id) THEN
    RETURN jsonb_build_object('granted', false, 'amount', 0, 'reason', 'not_verified');
  END IF;

  SELECT nickname, avatar_key
    INTO v_nickname, v_avatar_key
    FROM public.profiles
   WHERE id = v_user_id;

  IF v_nickname IS NULL OR btrim(v_nickname) = '' OR
     v_avatar_key IS NULL OR btrim(v_avatar_key) = '' THEN
    RETURN jsonb_build_object('granted', false, 'amount', 0, 'reason', 'profile_incomplete');
  END IF;

  SELECT amount, enabled INTO v_amount, v_enabled
    FROM public.reward_definitions
   WHERE code = 'signup_bonus';

  IF v_amount IS NULL THEN
    RETURN jsonb_build_object('granted', false, 'amount', 0, 'reason', 'disabled');
  END IF;

  IF NOT v_enabled THEN
    RETURN jsonb_build_object('granted', false, 'amount', v_amount, 'reason', 'disabled');
  END IF;

  INSERT INTO public.reward_grants (user_id, code, amount, reason)
    VALUES (v_user_id, 'signup_bonus', v_amount, 'signup_bonus_rpc')
    ON CONFLICT (user_id, code) WHERE code = 'signup_bonus' DO NOTHING
    RETURNING id INTO v_grant_id;

  IF v_grant_id IS NULL THEN
    RETURN jsonb_build_object('granted', false, 'amount', v_amount, 'reason', 'already_granted');
  END IF;

  INSERT INTO public.user_stats (user_id)
    VALUES (v_user_id)
    ON CONFLICT (user_id) DO NOTHING;

  UPDATE public.user_stats
     SET tippcoins = tippcoins + v_amount,
         updated_at = now()
   WHERE user_id = v_user_id;

  INSERT INTO public.user_events (user_id, type, code, amount, payload)
    VALUES (v_user_id, 'tippcoin_credit', 'signup_bonus', v_amount,
            jsonb_build_object('source', 'rpc', 'grant_code', 'signup_bonus'));

  RETURN jsonb_build_object('granted', true, 'amount', v_amount, 'reason', 'granted');
END;
$$;

REVOKE ALL ON FUNCTION public.grant_signup_bonus_if_eligible() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.grant_signup_bonus_if_eligible() TO authenticated;

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
  v_allowed boolean;
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

  IF NOT pg_try_advisory_xact_lock(hashtext('bonus_rpc_daily'), hashtext(v_user_id::text)) THEN
    RETURN jsonb_build_object(
      'granted', false,
      'amount', 0,
      'reason', 'rate_limited',
      'next_eligible_at', v_next_eligible_at
    );
  END IF;

  v_allowed := public.consume_bonus_rpc_token(v_user_id, 'daily_bonus_rpc', 10, 5);
  IF NOT v_allowed THEN
    RETURN jsonb_build_object(
      'granted', false,
      'amount', 0,
      'reason', 'rate_limited',
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
