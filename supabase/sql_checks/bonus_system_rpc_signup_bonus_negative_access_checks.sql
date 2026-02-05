\echo 'bonus_system RPC signup bonus negative access checks'

BEGIN;

SET LOCAL search_path TO pg_catalog, public, auth;

DO $$
BEGIN
  IF has_function_privilege('anon', 'public.grant_signup_bonus_if_eligible()', 'EXECUTE') THEN
    RAISE EXCEPTION 'anon has EXECUTE privilege on grant_signup_bonus_if_eligible()';
  END IF;

  IF has_table_privilege('anon', 'public.reward_grants', 'INSERT') THEN
    RAISE EXCEPTION 'anon has INSERT privilege on reward_grants';
  END IF;
  IF has_table_privilege('anon', 'public.reward_grants', 'UPDATE') THEN
    RAISE EXCEPTION 'anon has UPDATE privilege on reward_grants';
  END IF;
  IF has_table_privilege('anon', 'public.reward_grants', 'DELETE') THEN
    RAISE EXCEPTION 'anon has DELETE privilege on reward_grants';
  END IF;

  IF has_table_privilege('anon', 'public.user_stats', 'INSERT') THEN
    RAISE EXCEPTION 'anon has INSERT privilege on user_stats';
  END IF;
  IF has_table_privilege('anon', 'public.user_stats', 'UPDATE') THEN
    RAISE EXCEPTION 'anon has UPDATE privilege on user_stats';
  END IF;
  IF has_table_privilege('anon', 'public.user_stats', 'DELETE') THEN
    RAISE EXCEPTION 'anon has DELETE privilege on user_stats';
  END IF;

  IF has_table_privilege('anon', 'public.user_events', 'INSERT') THEN
    RAISE EXCEPTION 'anon has INSERT privilege on user_events';
  END IF;
  IF has_table_privilege('anon', 'public.user_events', 'UPDATE') THEN
    RAISE EXCEPTION 'anon has UPDATE privilege on user_events';
  END IF;
  IF has_table_privilege('anon', 'public.user_events', 'DELETE') THEN
    RAISE EXCEPTION 'anon has DELETE privilege on user_events';
  END IF;
END;
$$;

DO $$
BEGIN
  IF NOT has_table_privilege('authenticated', 'public.user_events', 'SELECT') THEN
    RAISE EXCEPTION 'authenticated lacks SELECT privilege on user_events';
  END IF;
  IF has_table_privilege('authenticated', 'public.user_events', 'INSERT') THEN
    RAISE EXCEPTION 'authenticated has INSERT privilege on user_events';
  END IF;
  IF has_table_privilege('authenticated', 'public.user_events', 'DELETE') THEN
    RAISE EXCEPTION 'authenticated has DELETE privilege on user_events';
  END IF;

  IF NOT has_column_privilege('authenticated', 'public.user_events', 'read_at', 'UPDATE') THEN
    RAISE EXCEPTION 'authenticated lacks UPDATE privilege on user_events.read_at';
  END IF;
  IF has_column_privilege('authenticated', 'public.user_events', 'type', 'UPDATE') THEN
    RAISE EXCEPTION 'authenticated has UPDATE privilege on user_events.type';
  END IF;
  IF has_column_privilege('authenticated', 'public.user_events', 'code', 'UPDATE') THEN
    RAISE EXCEPTION 'authenticated has UPDATE privilege on user_events.code';
  END IF;
  IF has_column_privilege('authenticated', 'public.user_events', 'amount', 'UPDATE') THEN
    RAISE EXCEPTION 'authenticated has UPDATE privilege on user_events.amount';
  END IF;
  IF has_column_privilege('authenticated', 'public.user_events', 'payload', 'UPDATE') THEN
    RAISE EXCEPTION 'authenticated has UPDATE privilege on user_events.payload';
  END IF;
END;
$$;

ROLLBACK;

\echo 'bonus_system RPC signup bonus negative access checks completed'
