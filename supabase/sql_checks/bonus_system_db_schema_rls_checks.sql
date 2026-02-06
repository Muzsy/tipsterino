\echo 'bonus_system schema/rls checks starting...'

DO $$
BEGIN
  IF to_regclass('public.reward_definitions') IS NULL THEN
    RAISE EXCEPTION 'public.reward_definitions is missing';
  END IF;
  IF to_regclass('public.reward_grants') IS NULL THEN
    RAISE EXCEPTION 'public.reward_grants is missing';
  END IF;
  IF to_regclass('public.user_stats') IS NULL THEN
    RAISE EXCEPTION 'public.user_stats is missing';
  END IF;
  IF to_regclass('public.user_events') IS NULL THEN
    RAISE EXCEPTION 'public.user_events is missing';
  END IF;
END;
$$;

DO $$
BEGIN
  IF NOT (SELECT relrowsecurity FROM pg_class WHERE oid = 'public.reward_definitions'::regclass) THEN
    RAISE EXCEPTION 'RLS is not enabled on public.reward_definitions';
  END IF;
  IF NOT (SELECT relrowsecurity FROM pg_class WHERE oid = 'public.reward_grants'::regclass) THEN
    RAISE EXCEPTION 'RLS is not enabled on public.reward_grants';
  END IF;
  IF NOT (SELECT relrowsecurity FROM pg_class WHERE oid = 'public.user_stats'::regclass) THEN
    RAISE EXCEPTION 'RLS is not enabled on public.user_stats';
  END IF;
  IF NOT (SELECT relrowsecurity FROM pg_class WHERE oid = 'public.user_events'::regclass) THEN
    RAISE EXCEPTION 'RLS is not enabled on public.user_events';
  END IF;
END;
$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'reward_grants' AND policyname = 'reward_grants_select') THEN
    RAISE EXCEPTION 'policy reward_grants_select missing';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'user_stats' AND policyname = 'user_stats_select') THEN
    RAISE EXCEPTION 'policy user_stats_select missing';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'user_events' AND policyname = 'user_events_select') THEN
    RAISE EXCEPTION 'policy user_events_select missing';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'user_events' AND policyname = 'user_events_update') THEN
    RAISE EXCEPTION 'policy user_events_update missing';
  END IF;
END;
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'reward_grants'
      AND column_name = 'grant_day'
      AND data_type = 'date'
  ) THEN
    RAISE EXCEPTION 'reward_grants.grant_day column missing';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'reward_grants_user_signup_bonus_unique') THEN
    RAISE EXCEPTION 'reward_grants user+code unique index missing';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'reward_grants_user_daily_bonus_day_unique') THEN
    RAISE EXCEPTION 'reward_grants user+code+grant_day unique index missing';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'reward_grants_user_created_at_idx') THEN
    RAISE EXCEPTION 'reward_grants list index missing';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'user_events_user_created_at_idx') THEN
    RAISE EXCEPTION 'user_events list index missing';
  END IF;
END;
$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.reward_definitions WHERE code = 'signup_bonus') THEN
    RAISE EXCEPTION 'signup_bonus definition missing';
  END IF;
END;
$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.reward_definitions WHERE code = 'daily_bonus') THEN
    RAISE EXCEPTION 'daily_bonus definition missing';
  END IF;
END;
$$;

\echo 'bonus_system schema/rls checks passed'
