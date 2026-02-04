\echo 'bonus_system RPC checks starting...'

DO $$
BEGIN
  IF to_regprocedure('public.is_email_verified(uuid)') IS NULL THEN
    RAISE EXCEPTION 'is_email_verified(uuid) missing';
  END IF;
  IF to_regprocedure('public.grant_signup_bonus_if_eligible()') IS NULL THEN
    RAISE EXCEPTION 'grant_signup_bonus_if_eligible() missing';
  END IF;
END;
$$;

DO $$
BEGIN
  IF NOT (SELECT prosecdef FROM pg_proc WHERE proname = 'grant_signup_bonus_if_eligible') THEN
    RAISE EXCEPTION 'grant_signup_bonus_if_eligible is not security definer';
  END IF;
END;
$$;

DO $$
BEGIN
  IF NOT has_function_privilege('authenticated', 'public.grant_signup_bonus_if_eligible()', 'EXECUTE') THEN
    RAISE EXCEPTION 'authenticated lacks EXECUTE on grant_signup_bonus_if_eligible';
  END IF;
END;
$$;

\echo 'bonus_system RPC checks passed'
