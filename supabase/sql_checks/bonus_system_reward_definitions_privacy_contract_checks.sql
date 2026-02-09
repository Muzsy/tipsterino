\echo 'bonus_system reward_definitions privacy contract checks starting...'

BEGIN;

SET LOCAL search_path TO pg_catalog, public, auth;

DO $$
DECLARE
  policy_count int;
BEGIN
  IF to_regclass('public.reward_definitions') IS NULL THEN
    RAISE EXCEPTION 'public.reward_definitions is missing';
  END IF;

  IF NOT (SELECT relrowsecurity FROM pg_class WHERE oid = 'public.reward_definitions'::regclass) THEN
    RAISE EXCEPTION 'RLS is not enabled on public.reward_definitions';
  END IF;

  SELECT count(*) INTO policy_count
  FROM pg_policies
  WHERE schemaname = 'public' AND tablename = 'reward_definitions';

  -- Canonical privacy contract: no client-facing policy on reward_definitions.
  IF policy_count <> 0 THEN
    RAISE EXCEPTION 'reward_definitions must have zero policies (found %)', policy_count;
  END IF;

  -- No client/table privileges for PUBLIC/anon/authenticated.
  IF EXISTS (
    SELECT 1
    FROM information_schema.role_table_grants
    WHERE grantee = 'PUBLIC'
      AND table_schema = 'public'
      AND table_name = 'reward_definitions'
      AND privilege_type = 'SELECT'
  ) THEN
    RAISE EXCEPTION 'PUBLIC has SELECT on reward_definitions';
  END IF;
  IF EXISTS (
    SELECT 1
    FROM information_schema.role_table_grants
    WHERE grantee = 'PUBLIC'
      AND table_schema = 'public'
      AND table_name = 'reward_definitions'
      AND privilege_type = 'INSERT'
  ) THEN
    RAISE EXCEPTION 'PUBLIC has INSERT on reward_definitions';
  END IF;
  IF EXISTS (
    SELECT 1
    FROM information_schema.role_table_grants
    WHERE grantee = 'PUBLIC'
      AND table_schema = 'public'
      AND table_name = 'reward_definitions'
      AND privilege_type = 'UPDATE'
  ) THEN
    RAISE EXCEPTION 'PUBLIC has UPDATE on reward_definitions';
  END IF;
  IF EXISTS (
    SELECT 1
    FROM information_schema.role_table_grants
    WHERE grantee = 'PUBLIC'
      AND table_schema = 'public'
      AND table_name = 'reward_definitions'
      AND privilege_type = 'DELETE'
  ) THEN
    RAISE EXCEPTION 'PUBLIC has DELETE on reward_definitions';
  END IF;

  IF has_table_privilege('anon', 'public.reward_definitions', 'SELECT') THEN
    RAISE EXCEPTION 'anon has SELECT on reward_definitions';
  END IF;
  IF has_table_privilege('anon', 'public.reward_definitions', 'INSERT') THEN
    RAISE EXCEPTION 'anon has INSERT on reward_definitions';
  END IF;
  IF has_table_privilege('anon', 'public.reward_definitions', 'UPDATE') THEN
    RAISE EXCEPTION 'anon has UPDATE on reward_definitions';
  END IF;
  IF has_table_privilege('anon', 'public.reward_definitions', 'DELETE') THEN
    RAISE EXCEPTION 'anon has DELETE on reward_definitions';
  END IF;

  IF has_table_privilege('authenticated', 'public.reward_definitions', 'SELECT') THEN
    RAISE EXCEPTION 'authenticated has SELECT on reward_definitions';
  END IF;
  IF has_table_privilege('authenticated', 'public.reward_definitions', 'INSERT') THEN
    RAISE EXCEPTION 'authenticated has INSERT on reward_definitions';
  END IF;
  IF has_table_privilege('authenticated', 'public.reward_definitions', 'UPDATE') THEN
    RAISE EXCEPTION 'authenticated has UPDATE on reward_definitions';
  END IF;
  IF has_table_privilege('authenticated', 'public.reward_definitions', 'DELETE') THEN
    RAISE EXCEPTION 'authenticated has DELETE on reward_definitions';
  END IF;
END;
$$;

ROLLBACK;

\echo 'bonus_system reward_definitions privacy contract checks passed'
