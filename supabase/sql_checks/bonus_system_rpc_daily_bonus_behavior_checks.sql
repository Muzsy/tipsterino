\echo 'bonus_system RPC daily bonus behavior checks'

BEGIN;

DO $$
DECLARE
  v_user_id uuid := gen_random_uuid();
  v_email text := v_user_id::text || '@example.com';
  v_result jsonb;
  v_reward_grants_count int;
  v_user_stats_tippcoins int;
  v_user_events_count int;
  v_amount integer;
  v_enabled boolean;
  v_has_email_confirmed boolean;
  v_has_confirmed boolean;
  v_confirmed_generated boolean := false;
  v_expected_grant_day date := (now() AT TIME ZONE 'UTC')::date;
  v_expected_next_eligible timestamptz := (date_trunc('day', now() AT TIME ZONE 'UTC') + interval '1 day') AT TIME ZONE 'UTC';
  v_observed_grant_day date;
BEGIN
  PERFORM set_config('search_path', 'pg_catalog, public, auth', true);

  v_result := public.grant_daily_bonus_if_eligible();
  IF COALESCE(v_result->>'granted', 'false')::boolean THEN
    RAISE EXCEPTION 'not_authenticated should not grant: %', v_result;
  END IF;
  IF v_result->>'reason' IS DISTINCT FROM 'not_authenticated' THEN
    RAISE EXCEPTION 'not_authenticated returned wrong reason: %', v_result;
  END IF;

  INSERT INTO auth.users (
    id, aud, role, email,
    encrypted_password, instance_id,
    created_at, updated_at, raw_user_meta_data
  )
  VALUES (
    v_user_id, 'authenticated', 'authenticated', v_email,
    'fake-password', v_user_id,
    now(), now(),
    jsonb_build_object(
      'nickname',
      lower(substr(translate(v_user_id::text, '-', ''), 1, 10)),
      'avatar_key',
      'default'
    )
  );

  v_has_email_confirmed := EXISTS(
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'auth'
      AND table_name = 'users'
      AND column_name = 'email_confirmed_at'
  );
  v_has_confirmed := EXISTS(
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'auth'
      AND table_name = 'users'
      AND column_name = 'confirmed_at'
  );
  IF v_has_confirmed THEN
    SELECT attgenerated <> '' INTO v_confirmed_generated
    FROM pg_attribute
    WHERE attrelid = 'auth.users'::regclass
      AND attname = 'confirmed_at';
  END IF;

  IF v_has_email_confirmed THEN
    EXECUTE format('UPDATE auth.users SET email_confirmed_at = NULL, updated_at = now() WHERE id = %L', v_user_id);
  END IF;
  IF v_has_confirmed AND NOT v_confirmed_generated THEN
    EXECUTE format('UPDATE auth.users SET confirmed_at = NULL, updated_at = now() WHERE id = %L', v_user_id);
  END IF;

  PERFORM set_config('request.jwt.claim.sub', v_user_id::text, true);
  v_result := public.grant_daily_bonus_if_eligible();
  IF COALESCE(v_result->>'granted', 'false')::boolean THEN
    RAISE EXCEPTION 'not_verified should not grant: %', v_result;
  END IF;
  IF v_result->>'reason' IS DISTINCT FROM 'not_verified' THEN
    RAISE EXCEPTION 'not_verified returned wrong reason: %', v_result;
  END IF;

  SELECT count(*) INTO v_reward_grants_count FROM public.reward_grants WHERE user_id = v_user_id;
  IF v_reward_grants_count != 0 THEN
    RAISE EXCEPTION 'not_verified inserted reward_grants: %', v_reward_grants_count;
  END IF;

  SELECT count(*) INTO v_user_stats_tippcoins FROM public.user_stats WHERE user_id = v_user_id;
  IF v_user_stats_tippcoins != 0 THEN
    RAISE EXCEPTION 'not_verified inserted user_stats: %', v_user_stats_tippcoins;
  END IF;

  SELECT count(*) INTO v_user_events_count FROM public.user_events WHERE user_id = v_user_id;
  IF v_user_events_count != 0 THEN
    RAISE EXCEPTION 'not_verified inserted user_events: %', v_user_events_count;
  END IF;

  SELECT amount, enabled INTO v_amount, v_enabled
  FROM public.reward_definitions
  WHERE code = 'daily_bonus';

  UPDATE public.reward_definitions
    SET amount = 0, enabled = v_enabled
  WHERE code = 'daily_bonus';

  IF v_has_email_confirmed THEN
    EXECUTE format('UPDATE auth.users SET email_confirmed_at = now(), updated_at = now() WHERE id = %L', v_user_id);
  END IF;
  IF v_has_confirmed AND NOT v_confirmed_generated THEN
    EXECUTE format('UPDATE auth.users SET confirmed_at = now(), updated_at = now() WHERE id = %L', v_user_id);
  END IF;

  PERFORM set_config('request.jwt.claim.sub', v_user_id::text, true);
  v_result := public.grant_daily_bonus_if_eligible();
  IF COALESCE(v_result->>'granted', 'false')::boolean THEN
    RAISE EXCEPTION 'disabled (amount=0) should not grant: %', v_result;
  END IF;
  IF v_result->>'reason' IS DISTINCT FROM 'disabled' THEN
    RAISE EXCEPTION 'disabled returned wrong reason: %', v_result;
  END IF;

  UPDATE public.reward_definitions
    SET amount = 50, enabled = true
  WHERE code = 'daily_bonus';

  IF v_has_email_confirmed THEN
    EXECUTE format('UPDATE auth.users SET email_confirmed_at = now(), updated_at = now() WHERE id = %L', v_user_id);
  ELSIF v_has_confirmed AND NOT v_confirmed_generated THEN
    EXECUTE format('UPDATE auth.users SET confirmed_at = now(), updated_at = now() WHERE id = %L', v_user_id);
  ELSE
    RAISE EXCEPTION 'no editable verification column found on auth.users';
  END IF;

  UPDATE public.profiles
    SET avatar_key = ''
  WHERE id = v_user_id;

  PERFORM set_config('request.jwt.claim.sub', v_user_id::text, true);
  v_result := public.grant_daily_bonus_if_eligible();
  IF COALESCE(v_result->>'granted', 'false')::boolean THEN
    RAISE EXCEPTION 'profile_incomplete should not grant: %', v_result;
  END IF;
  IF v_result->>'reason' IS DISTINCT FROM 'profile_incomplete' THEN
    RAISE EXCEPTION 'profile_incomplete returned wrong reason: %', v_result;
  END IF;

  SELECT count(*) INTO v_reward_grants_count FROM public.reward_grants WHERE user_id = v_user_id;
  IF v_reward_grants_count != 0 THEN
    RAISE EXCEPTION 'profile_incomplete inserted reward_grants: %', v_reward_grants_count;
  END IF;

  SELECT count(*) INTO v_user_stats_tippcoins FROM public.user_stats WHERE user_id = v_user_id;
  IF v_user_stats_tippcoins != 0 THEN
    RAISE EXCEPTION 'profile_incomplete inserted user_stats: %', v_user_stats_tippcoins;
  END IF;

  SELECT count(*) INTO v_user_events_count FROM public.user_events WHERE user_id = v_user_id;
  IF v_user_events_count != 0 THEN
    RAISE EXCEPTION 'profile_incomplete inserted user_events: %', v_user_events_count;
  END IF;

  UPDATE public.profiles
    SET avatar_key = 'complete-avatar'
  WHERE id = v_user_id;

  PERFORM set_config('request.jwt.claim.sub', v_user_id::text, true);
  v_result := public.grant_daily_bonus_if_eligible();
  IF NOT COALESCE(v_result->>'granted', 'false')::boolean THEN
    RAISE EXCEPTION 'grant phase failed: %', v_result;
  END IF;
  IF v_result->>'reason' IS DISTINCT FROM 'granted' THEN
    RAISE EXCEPTION 'grant phase returned wrong reason: %', v_result;
  END IF;
  IF (v_result->>'amount')::int != 50 THEN
    RAISE EXCEPTION 'grant phase returned wrong amount: %', v_result->>'amount';
  END IF;

  SELECT count(*) INTO v_reward_grants_count
  FROM public.reward_grants
  WHERE user_id = v_user_id AND code = 'daily_bonus';
  IF v_reward_grants_count != 1 THEN
    RAISE EXCEPTION 'expected one reward_grant, got %', v_reward_grants_count;
  END IF;

  SELECT grant_day INTO v_observed_grant_day
  FROM public.reward_grants
  WHERE user_id = v_user_id AND code = 'daily_bonus';
  IF v_observed_grant_day IS DISTINCT FROM v_expected_grant_day THEN
    RAISE EXCEPTION 'grant_day mismatch: % vs %', v_observed_grant_day, v_expected_grant_day;
  END IF;

  SELECT tippcoins INTO v_user_stats_tippcoins FROM public.user_stats WHERE user_id = v_user_id;
  IF v_user_stats_tippcoins != 50 THEN
    RAISE EXCEPTION 'user_stats tippcoins mismatch: %', v_user_stats_tippcoins;
  END IF;

  SELECT count(*) INTO v_user_events_count
  FROM public.user_events
  WHERE user_id = v_user_id
    AND type = 'tippcoin_credit'
    AND code = 'daily_bonus';
  IF v_user_events_count != 1 THEN
    RAISE EXCEPTION 'expected one user_event, got %', v_user_events_count;
  END IF;

  PERFORM set_config('request.jwt.claim.sub', v_user_id::text, true);
  v_result := public.grant_daily_bonus_if_eligible();
  IF COALESCE(v_result->>'granted', 'false')::boolean THEN
    RAISE EXCEPTION 'idempotent call wrongly granted: %', v_result;
  END IF;
  IF v_result->>'reason' IS DISTINCT FROM 'already_claimed_today' THEN
    RAISE EXCEPTION 'idempotent call wrong reason: %', v_result;
  END IF;
  IF (v_result->>'next_eligible_at')::timestamptz <> v_expected_next_eligible THEN
    RAISE EXCEPTION 'next_eligible_at mismatch: % vs %', (v_result->>'next_eligible_at')::timestamptz, v_expected_next_eligible;
  END IF;

  SELECT count(*) INTO v_reward_grants_count
  FROM public.reward_grants
  WHERE user_id = v_user_id AND code = 'daily_bonus';
  IF v_reward_grants_count != 1 THEN
    RAISE EXCEPTION 'idempotent call added reward_grants: %', v_reward_grants_count;
  END IF;

  SELECT count(*) INTO v_user_events_count
  FROM public.user_events
  WHERE user_id = v_user_id
    AND type = 'tippcoin_credit'
    AND code = 'daily_bonus';
  IF v_user_events_count != 1 THEN
    RAISE EXCEPTION 'idempotent call added user_events: %', v_user_events_count;
  END IF;

  SELECT tippcoins INTO v_user_stats_tippcoins FROM public.user_stats WHERE user_id = v_user_id;
  IF v_user_stats_tippcoins != 50 THEN
    RAISE EXCEPTION 'idempotent call changed tippcoins: %', v_user_stats_tippcoins;
  END IF;

  UPDATE public.reward_definitions
    SET amount = v_amount, enabled = v_enabled
  WHERE code = 'daily_bonus';
END;
$$;

ROLLBACK;
