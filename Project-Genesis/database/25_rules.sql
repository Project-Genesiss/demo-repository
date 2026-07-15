create table if not exists rules (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  conditions jsonb not null, -- e.g. {"all": [{"skill":"logic","operator":">","value":80}, ...]}
  actions jsonb not null, -- e.g. [{"type":"recommendation","payload":{...}}]
  priority integer default 100,
  enabled boolean default true,
  created_at timestamptz default now()
);

CREATE INDEX IF NOT EXISTS idx_rules_priority ON rules(priority);
