create table if not exists notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  type text,
  title text,
  message text,
  data jsonb,
  read boolean default false,
  delivered boolean default false,
  scheduled_at timestamptz,
  created_at timestamptz default now()
);
