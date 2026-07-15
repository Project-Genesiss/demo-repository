-- Migration 003: Core Engine tables (evidence, skill_history, brain_profiles, plugin_registry, rules)

-- 1) Ensure pgcrypto for gen_random_uuid
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 2) Evidence
CREATE TABLE IF NOT EXISTS evidence (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  evidence_type text not null,
  source_id uuid,
  skill_id uuid references skills(id),
  weight numeric default 1.0,
  quality numeric default 1.0,
  metadata jsonb,
  created_at timestamptz default now()
);
CREATE INDEX IF NOT EXISTS idx_evidence_user_id ON evidence(user_id);
CREATE INDEX IF NOT EXISTS idx_evidence_skill_id ON evidence(skill_id);
CREATE INDEX IF NOT EXISTS idx_evidence_type ON evidence(evidence_type);

-- 3) Skill history
CREATE TABLE IF NOT EXISTS skill_history (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  skill_id uuid not null references skills(id) on delete cascade,
  score numeric not null,
  confidence numeric not null,
  xp integer default 0,
  evidence_count integer default 0,
  created_at timestamptz default now()
);
CREATE INDEX IF NOT EXISTS idx_skill_history_user_id ON skill_history(user_id);
CREATE INDEX IF NOT EXISTS idx_skill_history_skill_id ON skill_history(skill_id);

-- 4) Brain profiles
CREATE TABLE IF NOT EXISTS brain_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  summary jsonb default '{}'::jsonb,
  genome jsonb default '{}'::jsonb,
  timeline jsonb default '[]'::jsonb,
  last_updated timestamptz default now()
);
CREATE INDEX IF NOT EXISTS idx_brain_profiles_last_updated ON brain_profiles(last_updated);

-- 5) Plugin registry
CREATE TABLE IF NOT EXISTS plugin_registry (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  plugin_type text not null,
  version text default '1.0.0',
  manifest jsonb,
  entrypoint text,
  permissions jsonb default '[]'::jsonb,
  enabled boolean default false,
  owner_id uuid references auth.users(id),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
CREATE INDEX IF NOT EXISTS idx_plugin_registry_type ON plugin_registry(plugin_type);

-- 6) Rules
CREATE TABLE IF NOT EXISTS rules (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  conditions jsonb not null,
  actions jsonb not null,
  priority integer default 100,
  enabled boolean default true,
  created_at timestamptz default now()
);
CREATE INDEX IF NOT EXISTS idx_rules_priority ON rules(priority);

-- 7) Seeds (small examples for testing)
-- Example rule: Recommend "Data Analysis" when Logic > 80 and Focus > 70
INSERT INTO rules (id, name, description, conditions, actions, priority) VALUES (
  gen_random_uuid(),
  'Recommend Data Analysis',
  'Simple rule to recommend Data Analysis based on skill thresholds',
  jsonb_build_object('all', jsonb_build_array(
    jsonb_build_object('skill','Logical Thinking','operator','>','value',80),
    jsonb_build_object('skill','Focus','operator','>','value',70)
  )),
  jsonb_build_array(jsonb_build_object('type','recommendation','payload',jsonb_build_object('career','Data Analyst'))),
  100
) ON CONFLICT DO NOTHING;

-- 8) RLS templates (do not enable automatically) - examples
-- Example: profiles owner policy
-- ENABLE ROW LEVEL SECURITY on tables in staging when ready, then add policies like:
-- CREATE POLICY "brain_profiles_owner" ON brain_profiles FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- End Migration 003
