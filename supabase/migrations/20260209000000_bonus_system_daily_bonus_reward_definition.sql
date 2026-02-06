-- Migration 20260209000000: daily_bonus reward definition seed

INSERT INTO public.reward_definitions (code, amount, enabled)
VALUES ('daily_bonus', 0, true)
ON CONFLICT (code) DO UPDATE
  SET amount = EXCLUDED.amount,
      enabled = EXCLUDED.enabled;
