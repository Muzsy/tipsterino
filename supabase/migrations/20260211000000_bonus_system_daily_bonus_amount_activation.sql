-- Migration 20260211000000: activate daily bonus amount

INSERT INTO public.reward_definitions (code, amount, enabled)
VALUES ('daily_bonus', 50, true)
ON CONFLICT (code) DO UPDATE
  SET amount = EXCLUDED.amount,
      enabled = EXCLUDED.enabled;
