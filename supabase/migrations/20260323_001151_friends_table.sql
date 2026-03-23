-- Friends table for bilateral relationships in Tipsterino.
-- Final-state migration: no legacy followers/friend_requests replay.

create table if not exists public.friends (
  user_id uuid not null references public.profiles(id) on delete cascade,
  friend_id uuid not null references public.profiles(id) on delete cascade,
  status text not null check (status in ('pending', 'accepted', 'rejected')),
  created_at timestamptz not null default now(),
  constraint friends_no_self check (user_id <> friend_id),
  constraint friends_user_friend_unique unique (user_id, friend_id)
);

comment on table public.friends is 'Stores bilateral friend relationships and invitations between profiles.';

create index if not exists friends_user_idx on public.friends (user_id);
create index if not exists friends_friend_idx on public.friends (friend_id);
create index if not exists friends_status_idx on public.friends (status);

alter table public.friends enable row level security;

drop policy if exists "Friends select own relationships" on public.friends;
create policy "Friends select own relationships"
  on public.friends
  for select
  using (auth.uid() = user_id or auth.uid() = friend_id);

drop policy if exists "Friends insert requester only" on public.friends;
create policy "Friends insert requester only"
  on public.friends
  for insert
  with check (auth.uid() = user_id);

drop policy if exists "Friends update participants" on public.friends;
create policy "Friends update participants"
  on public.friends
  for update
  using (auth.uid() = user_id or auth.uid() = friend_id)
  with check (auth.uid() = user_id or auth.uid() = friend_id);

drop policy if exists "Friends delete participants" on public.friends;
create policy "Friends delete participants"
  on public.friends
  for delete
  using (auth.uid() = user_id or auth.uid() = friend_id);
