create table if not exists evidence (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  evidence_type text not null, -- answer|game|mission|goal|journal|achievement|other
  source_id uuid, -- id of source table (answer id, game_session id, etc.)
  skill_id uuid references skills(id),
  weight numeric default 1.0, -- relative importance of this evidence
  quality numeric default 1.0, -- quality score (0..1)
  metadata jsonb,
  created_at timestamptz default now()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_evidence_user_id ON evidence(user_id);
CREATE INDEX IF NOT EXISTS idx_evidence_skill_id ON evidence(skill_id);
CREATE INDEX IF NOT EXISTS idx_evidence_type ON evidence(evidence_type);
