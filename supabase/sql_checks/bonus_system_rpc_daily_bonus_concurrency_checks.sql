\echo 'bonus_system RPC daily bonus concurrency checks starting...'

DO $$
DECLARE
  v_def text;
BEGIN
  IF to_regprocedure('public.grant_daily_bonus_if_eligible()') IS NULL THEN
    RAISE EXCEPTION 'grant_daily_bonus_if_eligible() missing';
  END IF;

  IF to_regclass('public.reward_grants_user_daily_bonus_day_unique') IS NULL THEN
    RAISE EXCEPTION 'reward_grants_user_daily_bonus_day_unique index missing';
  END IF;

  SELECT pg_get_functiondef('public.grant_daily_bonus_if_eligible()'::regprocedure)
    INTO v_def;

  IF position('pg_try_advisory_xact_lock' in v_def) = 0 THEN
    RAISE EXCEPTION 'daily bonus RPC missing advisory lock guard';
  END IF;

  IF position('already_claimed_today' in v_def) = 0 THEN
    RAISE EXCEPTION 'daily bonus RPC missing deterministic second-response reason';
  END IF;

  IF position('ON CONFLICT (user_id, code, grant_day)' in v_def) = 0 THEN
    RAISE EXCEPTION 'daily bonus RPC missing grant conflict protection';
  END IF;
END;
$$;

\echo 'bonus_system RPC daily bonus concurrency checks passed'
