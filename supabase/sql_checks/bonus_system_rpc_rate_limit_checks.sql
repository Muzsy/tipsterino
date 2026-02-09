\echo 'bonus_system RPC rate-limit checks starting...'

DO $$
DECLARE
  v_signup_def text;
  v_daily_def text;
BEGIN
  IF to_regclass('public.rpc_rate_limit_state') IS NULL THEN
    RAISE EXCEPTION 'public.rpc_rate_limit_state is missing';
  END IF;

  IF to_regprocedure('public.consume_bonus_rpc_token(uuid,text,integer,integer)') IS NULL THEN
    RAISE EXCEPTION 'consume_bonus_rpc_token(uuid,text,integer,integer) missing';
  END IF;

  IF NOT (SELECT relrowsecurity FROM pg_class WHERE oid = 'public.rpc_rate_limit_state'::regclass) THEN
    RAISE EXCEPTION 'RLS is not enabled on public.rpc_rate_limit_state';
  END IF;

  IF has_table_privilege('anon', 'public.rpc_rate_limit_state', 'SELECT')
     OR has_table_privilege('anon', 'public.rpc_rate_limit_state', 'INSERT')
     OR has_table_privilege('anon', 'public.rpc_rate_limit_state', 'UPDATE') THEN
    RAISE EXCEPTION 'anon must not have table privileges on rpc_rate_limit_state';
  END IF;

  IF has_table_privilege('authenticated', 'public.rpc_rate_limit_state', 'SELECT')
     OR has_table_privilege('authenticated', 'public.rpc_rate_limit_state', 'INSERT')
     OR has_table_privilege('authenticated', 'public.rpc_rate_limit_state', 'UPDATE') THEN
    RAISE EXCEPTION 'authenticated must not have table privileges on rpc_rate_limit_state';
  END IF;

  IF to_regprocedure('public.grant_signup_bonus_if_eligible()') IS NULL THEN
    RAISE EXCEPTION 'grant_signup_bonus_if_eligible() missing';
  END IF;

  IF to_regprocedure('public.grant_daily_bonus_if_eligible()') IS NULL THEN
    RAISE EXCEPTION 'grant_daily_bonus_if_eligible() missing';
  END IF;

  IF NOT has_function_privilege('authenticated', 'public.grant_signup_bonus_if_eligible()', 'EXECUTE') THEN
    RAISE EXCEPTION 'authenticated lacks EXECUTE on grant_signup_bonus_if_eligible';
  END IF;

  IF NOT has_function_privilege('authenticated', 'public.grant_daily_bonus_if_eligible()', 'EXECUTE') THEN
    RAISE EXCEPTION 'authenticated lacks EXECUTE on grant_daily_bonus_if_eligible';
  END IF;

  SELECT pg_get_functiondef('public.grant_signup_bonus_if_eligible()'::regprocedure)
    INTO v_signup_def;

  SELECT pg_get_functiondef('public.grant_daily_bonus_if_eligible()'::regprocedure)
    INTO v_daily_def;

  IF position('consume_bonus_rpc_token' in v_signup_def) = 0 THEN
    RAISE EXCEPTION 'signup RPC does not call consume_bonus_rpc_token';
  END IF;

  IF position('pg_try_advisory_xact_lock' in v_signup_def) = 0 THEN
    RAISE EXCEPTION 'signup RPC missing advisory lock';
  END IF;

  IF position('rate_limited' in v_signup_def) = 0 THEN
    RAISE EXCEPTION 'signup RPC missing rate_limited branch';
  END IF;

  IF position('consume_bonus_rpc_token' in v_daily_def) = 0 THEN
    RAISE EXCEPTION 'daily RPC does not call consume_bonus_rpc_token';
  END IF;

  IF position('pg_try_advisory_xact_lock' in v_daily_def) = 0 THEN
    RAISE EXCEPTION 'daily RPC missing advisory lock';
  END IF;

  IF position('rate_limited' in v_daily_def) = 0 THEN
    RAISE EXCEPTION 'daily RPC missing rate_limited branch';
  END IF;
END;
$$;

\echo 'bonus_system RPC rate-limit checks passed'
