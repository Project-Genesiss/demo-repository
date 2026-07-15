create table if not exists skill_history (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  skill_id uuid not null references skills(id) on delete cascade,
  score numeric not null,
  confidence numeric not null,
  xp integer default 0,
  evidence_count integer default 0,
  created_at timestamptz default now()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_skill_history_user_id ON skill_history(user_id);
CREATE INDEX IF NOT EXISTS idx_skill_history_skill_id ON skill_history(skill_id);
