create table if not exists brain_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  summary jsonb default '{}'::jsonb, -- { skill_id: {current, potential, confidence, trend, evidence_count} }
  genome jsonb default '{}'::jsonb, -- 3D/graph representation metadata
  timeline jsonb default '[]'::jsonb, -- condensed timeline points
  last_updated timestamptz default now()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_brain_profiles_last_updated ON brain_profiles(last_updated);
