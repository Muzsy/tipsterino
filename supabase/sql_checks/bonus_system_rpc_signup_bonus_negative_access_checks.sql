\echo 'bonus_system RPC signup bonus negative access checks'

BEGIN;

PERFORM set_config('search_path', 'pg_catalog, public, auth', true);

DO $$
BEGIN
  SET LOCAL ROLE anon;
  BEGIN
    PERFORM public.grant_signup_bonus_if_eligible();
    RAISE EXCEPTION 'anon role executed grant_signup_bonus_if_eligible() without insufficient_privilege';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;
  PERFORM set_config('search_path', 'pg_catalog, public, auth', true);
  IF has_table_privilege('anon', 'public.reward_grants', 'INSERT') THEN
    RAISE EXCEPTION 'anon has INSERT privilege on reward_grants';
  END IF;
  IF has_table_privilege('anon', 'public.user_stats', 'INSERT') THEN
    RAISE EXCEPTION 'anon has INSERT privilege on user_stats';
  END IF;
  IF has_table_privilege('anon', 'public.user_events', 'INSERT') THEN
    RAISE EXCEPTION 'anon has INSERT privilege on user_events';
  END IF;
END;
$$;

DO $$
BEGIN
  SET LOCAL ROLE authenticated;
  IF NOT has_column_privilege('authenticated', 'public.user_events', 'read_at', 'UPDATE') THEN
    RAISE EXCEPTION 'authenticated lacks UPDATE privilege on user_events.read_at';
  END IF;
  IF has_column_privilege('authenticated', 'public.user_events', 'amount', 'UPDATE') THEN
    RAISE EXCEPTION 'authenticated should not have UPDATE privilege on user_events.amount';
  END IF;
  IF has_column_privilege('authenticated', 'public.user_events', 'type', 'UPDATE') THEN
    RAISE EXCEPTION 'authenticated should not have UPDATE privilege on user_events.type';
  END IF;
  IF has_column_privilege('authenticated', 'public.user_events', 'code', 'UPDATE') THEN
    RAISE EXCEPTION 'authenticated should not have UPDATE privilege on user_events.code';
  END IF;
END;
$$;

ROLLBACK;

\echo 'bonus_system RPC signup bonus negative access checks completed'
