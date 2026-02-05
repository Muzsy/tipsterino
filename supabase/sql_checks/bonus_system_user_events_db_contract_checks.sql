\echo 'bonus_system user_events DB contract checks'

BEGIN;

SET LOCAL search_path TO pg_catalog, public, auth;

DO $$
DECLARE
  amt_type text;
  idx_exists boolean;
BEGIN
  IF to_regclass('public.user_events') IS NULL THEN
    RAISE EXCEPTION 'public.user_events table is missing';
  END IF;

  PERFORM 1
  FROM information_schema.columns
  WHERE table_schema = 'public' AND table_name = 'user_events'
    AND column_name = 'id' AND udt_name = 'uuid';
  IF NOT FOUND THEN
    RAISE EXCEPTION 'user_events.id column missing or wrong type';
  END IF;

  PERFORM 1
  FROM information_schema.columns
  WHERE table_schema = 'public' AND table_name = 'user_events'
    AND column_name = 'user_id' AND udt_name = 'uuid';
  IF NOT FOUND THEN
    RAISE EXCEPTION 'user_events.user_id column missing or wrong type';
  END IF;

  PERFORM 1
  FROM information_schema.columns
  WHERE table_schema = 'public' AND table_name = 'user_events'
    AND column_name = 'type' AND data_type = 'text';
  IF NOT FOUND THEN
    RAISE EXCEPTION 'user_events.type missing or wrong type';
  END IF;

  PERFORM 1
  FROM information_schema.columns
  WHERE table_schema = 'public' AND table_name = 'user_events'
    AND column_name = 'code' AND data_type = 'text';
  IF NOT FOUND THEN
    RAISE EXCEPTION 'user_events.code missing or wrong type';
  END IF;

  SELECT data_type INTO amt_type
  FROM information_schema.columns
  WHERE table_schema = 'public' AND table_name = 'user_events'
    AND column_name = 'amount';
  IF amt_type IS NULL OR NOT (amt_type IN ('integer', 'bigint')) THEN
    RAISE EXCEPTION 'user_events.amount wrong or missing type (found %)', amt_type;
  END IF;

  PERFORM 1
  FROM information_schema.columns
  WHERE table_schema = 'public' AND table_name = 'user_events'
    AND column_name = 'payload' AND data_type = 'jsonb';
  IF NOT FOUND THEN
    RAISE EXCEPTION 'user_events.payload missing or wrong type';
  END IF;

  PERFORM 1
  FROM information_schema.columns
  WHERE table_schema = 'public' AND table_name = 'user_events'
    AND column_name = 'created_at' AND data_type = 'timestamp with time zone';
  IF NOT FOUND THEN
    RAISE EXCEPTION 'user_events.created_at missing or wrong type';
  END IF;

  PERFORM 1
  FROM information_schema.columns
  WHERE table_schema = 'public' AND table_name = 'user_events'
    AND column_name = 'read_at' AND data_type = 'timestamp with time zone';
  IF NOT FOUND THEN
    RAISE EXCEPTION 'user_events.read_at missing or wrong type';
  END IF;

  IF NOT (SELECT relrowsecurity FROM pg_class WHERE oid = 'public.user_events'::regclass) THEN
    RAISE EXCEPTION 'RLS is not enabled on public.user_events';
  END IF;

  IF NOT has_table_privilege('authenticated', 'public.user_events', 'SELECT') THEN
    RAISE EXCEPTION 'authenticated lacks SELECT on user_events';
  END IF;
  IF has_table_privilege('authenticated', 'public.user_events', 'INSERT') THEN
    RAISE EXCEPTION 'authenticated has INSERT on user_events';
  END IF;
  IF has_table_privilege('authenticated', 'public.user_events', 'DELETE') THEN
    RAISE EXCEPTION 'authenticated has DELETE on user_events';
  END IF;

  IF NOT has_column_privilege('authenticated', 'public.user_events', 'read_at', 'UPDATE') THEN
    RAISE EXCEPTION 'authenticated lacks UPDATE on user_events.read_at';
  END IF;
  IF has_column_privilege('authenticated', 'public.user_events', 'type', 'UPDATE') THEN
    RAISE EXCEPTION 'authenticated has UPDATE on user_events.type';
  END IF;
  IF has_column_privilege('authenticated', 'public.user_events', 'code', 'UPDATE') THEN
    RAISE EXCEPTION 'authenticated has UPDATE on user_events.code';
  END IF;
  IF has_column_privilege('authenticated', 'public.user_events', 'amount', 'UPDATE') THEN
    RAISE EXCEPTION 'authenticated has UPDATE on user_events.amount';
  END IF;
  IF has_column_privilege('authenticated', 'public.user_events', 'payload', 'UPDATE') THEN
    RAISE EXCEPTION 'authenticated has UPDATE on user_events.payload';
  END IF;

  SELECT EXISTS (
    SELECT 1
    FROM pg_index idx
    JOIN pg_class tab ON tab.oid = idx.indrelid
    JOIN pg_class idx_rel ON idx_rel.oid = idx.indexrelid
    WHERE tab.relname = 'user_events'
      AND tab.relnamespace = 'public'::regnamespace
      AND idx.indisvalid
      AND idx.indisready
      AND (
        SELECT COUNT(DISTINCT attr.attname)
        FROM pg_attribute attr
        WHERE attr.attrelid = tab.oid
          AND attr.attnum = ANY(idx.indkey)
          AND attr.attname IN ('user_id', 'created_at')
      ) = 2
  ) INTO idx_exists;

  IF NOT idx_exists THEN
    RAISE EXCEPTION 'No index covers user_id and created_at on user_events';
  END IF;
END;
$$;

ROLLBACK;

\echo 'bonus_system user_events DB contract checks completed'
