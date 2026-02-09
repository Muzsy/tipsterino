-- Migration 20260214000000: user_events unread partial index
create index if not exists user_events_user_unread_created_at_idx
  on public.user_events (user_id, created_at desc)
  where read_at is null;
