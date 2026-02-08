-- Migration 20260212000000: enforce reward_definitions privacy privilege contract

REVOKE ALL ON TABLE public.reward_definitions FROM PUBLIC;
REVOKE ALL ON TABLE public.reward_definitions FROM anon;
REVOKE ALL ON TABLE public.reward_definitions FROM authenticated;
