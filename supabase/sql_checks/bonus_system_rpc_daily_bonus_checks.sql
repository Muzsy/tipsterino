\echo 'bonus_system RPC daily bonus checks'

DO $$
BEGIN
  IF to_regprocedure('public.grant_daily_bonus_if_eligible()') IS NULL THEN
    RAISE EXCEPTION 'grant_daily_bonus_if_eligible() missing';
  END IF;
END;
$$;

DO $$
BEGIN
  IF NOT (SELECT prosecdef FROM pg_proc WHERE proname = 'grant_daily_bonus_if_eligible') THEN
    RAISE EXCEPTION 'grant_daily_bonus_if_eligible is not security definer';
  END IF;
END;
$$;

DO $$
BEGIN
  IF NOT has_function_privilege('authenticated', 'public.grant_daily_bonus_if_eligible()', 'EXECUTE') THEN
    RAISE EXCEPTION 'authenticated lacks EXECUTE on grant_daily_bonus_if_eligible';
  END IF;
END;
$$;

\echo 'bonus_system RPC daily bonus checks passed'
