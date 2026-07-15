create table if not exists activity_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id),
  event_type text,
  event_data jsonb,
  ip inet,
  user_agent text,
  created_at timestamptz default now()
);
