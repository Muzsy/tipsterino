-- Migration 20260206000000: privilege contract fix for bonus system

REVOKE ALL ON FUNCTION public.grant_signup_bonus_if_eligible() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.grant_signup_bonus_if_eligible() TO authenticated;

REVOKE ALL ON TABLE public.user_events FROM PUBLIC;
REVOKE ALL ON TABLE public.user_events FROM anon;
REVOKE ALL ON TABLE public.user_events FROM authenticated;
GRANT SELECT ON TABLE public.user_events TO authenticated;
GRANT UPDATE (read_at) ON TABLE public.user_events TO authenticated;

REVOKE ALL ON TABLE public.reward_grants FROM PUBLIC, anon, authenticated;
GRANT SELECT ON TABLE public.reward_grants TO authenticated;

REVOKE ALL ON TABLE public.user_stats FROM PUBLIC, anon, authenticated;
GRANT SELECT ON TABLE public.user_stats TO authenticated;
