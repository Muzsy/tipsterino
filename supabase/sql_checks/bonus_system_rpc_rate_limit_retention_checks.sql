\echo 'bonus_system RPC rate-limit retention checks starting...'

DO $$
DECLARE
  v_cleanup_def text;
  v_deleted integer;
BEGIN
  IF to_regclass('public.rpc_rate_limit_state') IS NULL THEN
    RAISE EXCEPTION 'public.rpc_rate_limit_state is missing';
  END IF;

  IF to_regprocedure('public.cleanup_bonus_rpc_rate_limit_state(interval,integer)') IS NULL THEN
    RAISE EXCEPTION 'cleanup_bonus_rpc_rate_limit_state(interval,integer) missing';
  END IF;

  IF NOT EXISTS (
    SELECT 1
      FROM pg_indexes
     WHERE schemaname = 'public'
       AND tablename = 'rpc_rate_limit_state'
       AND indexname = 'rpc_rate_limit_state_last_attempt_idx'
  ) THEN
    RAISE EXCEPTION 'rpc_rate_limit_state_last_attempt_idx is missing';
  END IF;

  IF has_function_privilege('anon', 'public.cleanup_bonus_rpc_rate_limit_state(interval,integer)', 'EXECUTE') THEN
    RAISE EXCEPTION 'anon must not have EXECUTE on cleanup_bonus_rpc_rate_limit_state';
  END IF;

  IF has_function_privilege('authenticated', 'public.cleanup_bonus_rpc_rate_limit_state(interval,integer)', 'EXECUTE') THEN
    RAISE EXCEPTION 'authenticated must not have EXECUTE on cleanup_bonus_rpc_rate_limit_state';
  END IF;

  IF NOT (
    SELECT prosecdef
      FROM pg_proc
     WHERE oid = 'public.cleanup_bonus_rpc_rate_limit_state(interval,integer)'::regprocedure
  ) THEN
    RAISE EXCEPTION 'cleanup_bonus_rpc_rate_limit_state must be SECURITY DEFINER';
  END IF;

  SELECT pg_get_functiondef('public.cleanup_bonus_rpc_rate_limit_state(interval,integer)'::regprocedure)
    INTO v_cleanup_def;

  IF position('set_config(''search_path'', ''pg_catalog, public, auth'', true)' in v_cleanup_def) = 0 THEN
    RAISE EXCEPTION 'cleanup function missing search_path hardening';
  END IF;

  IF position('last_attempt_at < now() - p_retention' in v_cleanup_def) = 0 THEN
    RAISE EXCEPTION 'cleanup function missing last_attempt_at retention predicate';
  END IF;

  SELECT public.cleanup_bonus_rpc_rate_limit_state(interval '100 years', 1)
    INTO v_deleted;

  IF v_deleted IS NULL THEN
    RAISE EXCEPTION 'cleanup function returned null';
  END IF;
END;
$$;

\echo 'bonus_system RPC rate-limit retention checks passed'
