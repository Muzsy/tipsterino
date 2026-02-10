-- Migration 20260217000000: rpc_rate_limit_state retention cleanup helper

CREATE INDEX IF NOT EXISTS rpc_rate_limit_state_last_attempt_idx
  ON public.rpc_rate_limit_state (last_attempt_at);

CREATE OR REPLACE FUNCTION public.cleanup_bonus_rpc_rate_limit_state(
  p_retention interval DEFAULT interval '7 days',
  p_batch_size integer DEFAULT 10000
)
RETURNS integer
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
DECLARE
  v_deleted integer := 0;
BEGIN
  PERFORM set_config('search_path', 'pg_catalog, public, auth', true);

  IF p_retention < interval '1 hour' THEN
    RAISE EXCEPTION 'retention interval too small';
  END IF;

  IF p_batch_size < 1 THEN
    RAISE EXCEPTION 'batch_size must be positive';
  END IF;

  WITH stale AS (
    SELECT ctid
      FROM public.rpc_rate_limit_state
     WHERE last_attempt_at < now() - p_retention
     ORDER BY last_attempt_at ASC
     LIMIT p_batch_size
  ), deleted AS (
    DELETE FROM public.rpc_rate_limit_state
     WHERE ctid IN (SELECT ctid FROM stale)
     RETURNING 1
  )
  SELECT count(*) INTO v_deleted FROM deleted;

  RETURN v_deleted;
END;
$$;

REVOKE ALL ON FUNCTION public.cleanup_bonus_rpc_rate_limit_state(interval, integer)
  FROM PUBLIC, anon, authenticated;
