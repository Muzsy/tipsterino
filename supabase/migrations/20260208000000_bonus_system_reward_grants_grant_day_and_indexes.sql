-- Migration 20260208000000: reward_grants grant_day + partial unique index fix

ALTER TABLE public.reward_grants
  ADD COLUMN IF NOT EXISTS grant_day date;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'reward_grants_daily_bonus_grant_day_not_null'
  ) THEN
    ALTER TABLE public.reward_grants
      ADD CONSTRAINT reward_grants_daily_bonus_grant_day_not_null
        CHECK (code <> 'daily_bonus' OR grant_day IS NOT NULL);
  END IF;
END;
$$;

DROP INDEX IF EXISTS reward_grants_user_id_code_unique;

CREATE UNIQUE INDEX IF NOT EXISTS reward_grants_user_signup_bonus_unique
  ON public.reward_grants (user_id, code)
  WHERE code = 'signup_bonus';

CREATE UNIQUE INDEX IF NOT EXISTS reward_grants_user_daily_bonus_day_unique
  ON public.reward_grants (user_id, code, grant_day)
  WHERE code = 'daily_bonus'
    AND grant_day IS NOT NULL;

CREATE INDEX IF NOT EXISTS reward_grants_user_created_at_idx
  ON public.reward_grants (user_id, created_at desc);

-- Canonical signup bonus RPC definition (single source of truth).
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
BEGIN
  PERFORM set_config('search_path', 'pg_catalog, public, auth', true);

  IF v_user_id IS NULL THEN
    RETURN jsonb_build_object('granted', false, 'amount', 0, 'reason', 'not_authenticated');
  END IF;

  IF NOT public.is_email_verified(v_user_id) THEN
    RETURN jsonb_build_object('granted', false, 'amount', 0, 'reason', 'not_verified');
  END IF;

  IF NOT public.is_profile_complete(v_user_id) THEN
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

GRANT EXECUTE ON FUNCTION public.grant_signup_bonus_if_eligible() TO authenticated;
