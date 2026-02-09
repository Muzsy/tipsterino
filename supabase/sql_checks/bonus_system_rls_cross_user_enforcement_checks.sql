\echo 'bonus_system RLS cross-user enforcement checks starting...'

BEGIN;

SET LOCAL search_path TO pg_catalog, public, auth;

DO $$
DECLARE
  v_user1 uuid := '11111111-1111-1111-1111-111111111111';
  v_user2 uuid := '22222222-2222-2222-2222-222222222222';
  v_count integer;
BEGIN
  -- Arrange deterministic fixtures for cross-user checks.
  INSERT INTO auth.users (id, raw_user_meta_data)
  VALUES (v_user1, '{"nickname":"rls_test_u1","avatar_key":"avatar_u1"}'::jsonb)
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO auth.users (id, raw_user_meta_data)
  VALUES (v_user2, '{"nickname":"rls_test_u2","avatar_key":"avatar_u2"}'::jsonb)
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO public.profiles (id, nickname, avatar_key)
  VALUES (v_user1, 'rls_test_u1', 'avatar_u1')
  ON CONFLICT (id) DO UPDATE
    SET nickname = EXCLUDED.nickname,
        avatar_key = EXCLUDED.avatar_key;

  INSERT INTO public.profiles (id, nickname, avatar_key)
  VALUES (v_user2, 'rls_test_u2', 'avatar_u2')
  ON CONFLICT (id) DO UPDATE
    SET nickname = EXCLUDED.nickname,
        avatar_key = EXCLUDED.avatar_key;

  INSERT INTO public.reward_grants (user_id, code, amount, reason)
  VALUES (v_user2, 'signup_bonus', 1, 'rls_cross_user_test')
  ON CONFLICT (user_id, code) WHERE code = 'signup_bonus' DO NOTHING;

  INSERT INTO public.user_stats (user_id, tippcoins)
  VALUES (v_user2, 123)
  ON CONFLICT (user_id) DO UPDATE
    SET tippcoins = EXCLUDED.tippcoins,
        updated_at = now();

  INSERT INTO public.user_events (user_id, type, code, amount, payload)
  VALUES (v_user2, 'tippcoin_credit', 'signup_bonus', 1, '{"source":"rls_cross_user_test"}'::jsonb)
  ON CONFLICT DO NOTHING;

  -- Act as authenticated user1 and try to read/write user2 rows.
  PERFORM set_config('request.jwt.claim.role', 'authenticated', true);
  PERFORM set_config('request.jwt.claim.sub', v_user1::text, true);
  SET LOCAL ROLE authenticated;

  SELECT count(*) INTO v_count FROM public.profiles WHERE id = v_user2;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'cross-user leak: profiles user1 can see user2 row(s)';
  END IF;

  SELECT count(*) INTO v_count FROM public.reward_grants WHERE user_id = v_user2;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'cross-user leak: reward_grants user1 can see user2 row(s)';
  END IF;

  SELECT count(*) INTO v_count FROM public.user_stats WHERE user_id = v_user2;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'cross-user leak: user_stats user1 can see user2 row(s)';
  END IF;

  SELECT count(*) INTO v_count FROM public.user_events WHERE user_id = v_user2;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'cross-user leak: user_events user1 can see user2 row(s)';
  END IF;

  UPDATE public.profiles
     SET avatar_key = 'avatar_u2_mutated'
   WHERE id = v_user2;
  GET DIAGNOSTICS v_count = ROW_COUNT;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'cross-user write leak: profiles user1 updated user2 row';
  END IF;

  UPDATE public.user_events
     SET read_at = now()
   WHERE user_id = v_user2;
  GET DIAGNOSTICS v_count = ROW_COUNT;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'cross-user write leak: user_events user1 updated user2 row';
  END IF;

  RESET ROLE;
END;
$$;

ROLLBACK;

\echo 'bonus_system RLS cross-user enforcement checks passed'
