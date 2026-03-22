-- Create direct messages table for 1:1 chat
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  sender_id uuid not null references public.profiles(id) on delete cascade,
  receiver_id uuid not null references public.profiles(id) on delete cascade,
  content text not null check (char_length(content) <= 2000),
  created_at timestamptz not null default now(),
  read_at timestamptz,
  constraint messages_no_self check (sender_id <> receiver_id)
);

comment on table public.messages is 'Stores private messages between two profiles.';

create index if not exists messages_sender_idx on public.messages (sender_id, created_at desc);
create index if not exists messages_receiver_idx on public.messages (receiver_id, created_at desc);
create index if not exists messages_conversation_idx on public.messages (sender_id, receiver_id, created_at desc);

alter table public.messages enable row level security;

drop policy if exists "Messages select participants" on public.messages;
create policy "Messages select participants"
  on public.messages
  for select
  using (auth.uid() = sender_id or auth.uid() = receiver_id);

drop policy if exists "Messages insert sender" on public.messages;
create policy "Messages insert sender"
  on public.messages
  for insert
  with check (auth.uid() = sender_id);

drop policy if exists "Messages update participants" on public.messages;
create policy "Messages update participants"
  on public.messages
  for update
  using (auth.uid() = sender_id or auth.uid() = receiver_id)
  with check (auth.uid() = sender_id or auth.uid() = receiver_id);

drop policy if exists "Messages delete participants" on public.messages;
create policy "Messages delete participants"
  on public.messages
  for delete
  using (auth.uid() = sender_id or auth.uid() = receiver_id);
