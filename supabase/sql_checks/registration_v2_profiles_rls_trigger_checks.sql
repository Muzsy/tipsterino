\echo 'registration_v2 profiles privacy contract checks starting...'

BEGIN;

SET LOCAL search_path TO pg_catalog, public, auth;

DO $$
DECLARE
  expected_columns text[] := ARRAY['id', 'nickname', 'avatar_key'];
  actual_columns text[];
BEGIN
  IF to_regclass('public.profiles') IS NULL THEN
    RAISE EXCEPTION 'public.profiles table is missing';
  END IF;

  IF to_regclass('public.public_profiles') IS NULL THEN
    RAISE EXCEPTION 'public.public_profiles view is missing';
  END IF;

  IF to_regprocedure('public.check_nickname_available(text)') IS NULL THEN
    RAISE EXCEPTION 'public.check_nickname_available(text) function is missing';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'create_profile_on_signup_trigger') THEN
    RAISE EXCEPTION 'create_profile_on_signup_trigger is missing';
  END IF;

  IF NOT (SELECT relrowsecurity FROM pg_class WHERE oid = 'public.profiles'::regclass) THEN
    RAISE EXCEPTION 'RLS is not enabled on public.profiles';
  END IF;

  SELECT array_agg(c.column_name ORDER BY c.ordinal_position)
    INTO actual_columns
  FROM information_schema.columns c
  WHERE c.table_schema = 'public'
    AND c.table_name = 'public_profiles';

  IF actual_columns IS DISTINCT FROM expected_columns THEN
    RAISE EXCEPTION
      'public_profiles columns mismatch. expected=%, actual=%',
      expected_columns,
      coalesce(actual_columns, ARRAY[]::text[]);
  END IF;

  IF NOT has_table_privilege('anon', 'public.public_profiles', 'SELECT') THEN
    RAISE EXCEPTION 'anon is missing SELECT privilege on public.public_profiles';
  END IF;

  IF NOT has_table_privilege('authenticated', 'public.public_profiles', 'SELECT') THEN
    RAISE EXCEPTION 'authenticated is missing SELECT privilege on public.public_profiles';
  END IF;

  IF has_table_privilege('anon', 'public.public_profiles', 'INSERT')
     OR has_table_privilege('anon', 'public.public_profiles', 'UPDATE')
     OR has_table_privilege('anon', 'public.public_profiles', 'DELETE') THEN
    RAISE EXCEPTION 'anon has write privilege on public.public_profiles';
  END IF;

  IF has_table_privilege('authenticated', 'public.public_profiles', 'INSERT')
     OR has_table_privilege('authenticated', 'public.public_profiles', 'UPDATE')
     OR has_table_privilege('authenticated', 'public.public_profiles', 'DELETE') THEN
    RAISE EXCEPTION 'authenticated has write privilege on public.public_profiles';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM information_schema.role_table_grants
    WHERE grantee = 'PUBLIC'
      AND table_schema = 'public'
      AND table_name = 'public_profiles'
  ) THEN
    RAISE EXCEPTION 'PUBLIC must not have direct grants on public.public_profiles';
  END IF;
END;
$$;

ROLLBACK;

\echo 'registration_v2 profiles privacy contract checks passed'
