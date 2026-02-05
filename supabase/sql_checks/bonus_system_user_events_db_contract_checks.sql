\echo 'bonus_system user_events DB contract checks'

BEGIN;

SET LOCAL search_path = pg_catalog, public, auth;

DO $$
DECLARE
  expected_columns text[] := ARRAY[
    'id:uuid',
    'user_id:uuid',
    'type:text',
    'code:text',
    'amount:integer',
    'payload:jsonb',
    'created_at:timestamp with time zone',
    'read_at:timestamp with time zone'
  ];
  row record;
  found_columns int := 0;
  index_record record;
  col text;
BEGIN
  IF to_regclass('public.user_events') IS NULL THEN
    RAISE EXCEPTION 'public.user_events table is missing';
  END IF;

  FOR row IN
    SELECT column_name, udt_name, data_type
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'user_events'
  LOOP
    FOREACH col IN ARRAY expected_columns LOOP
      IF row.column_name || ':' || row.data_type = col
         OR (row.column_name = 'amount' AND row.data_type = 'integer' AND col LIKE 'amount:%')
         OR (row.column_name = 'code' AND row.data_type = 'text' AND col LIKE 'code:%')
         OR (row.column_name = 'payload' AND row.data_type = 'jsonb' AND col LIKE 'payload:%') THEN
        found_columns := found_columns + 1;
        EXIT;
      END IF;
    END LOOP;
  END LOOP;

  IF found_columns < array_length(expected_columns, 1) THEN
    RAISE EXCEPTION 'user_events columns do not match contract (found % of %)', found_columns, array_length(expected_columns, 1);
  END IF;

  IF NOT (SELECT relrowsecurity FROM pg_class WHERE oid = 'public.user_events'::regclass) THEN
    RAISE EXCEPTION 'RLS is not enabled on public.user_events';
  END IF;

  IF NOT has_table_privilege('authenticated', 'public.user_events', 'SELECT') THEN
    RAISE EXCEPTION 'authenticated lacks SELECT on user_events';
  END IF;

  IF NOT has_column_privilege('authenticated', 'public.user_events', 'read_at', 'UPDATE') THEN
    RAISE EXCEPTION 'authenticated lacks UPDATE on user_events.read_at';
  END IF;
  SELECT *
  INTO index_record
  FROM pg_indexes
  WHERE tablename = 'user_events'
    AND indexdef ILIKE '%user_id%'
    AND indexdef ILIKE '%created_at%'
  LIMIT 1;

  IF index_record IS NULL THEN
    RAISE EXCEPTION 'No index found covering user_id and created_at on user_events';
  END IF;
END;
$$;

ROLLBACK;

\echo 'bonus_system user_events DB contract checks completed'
