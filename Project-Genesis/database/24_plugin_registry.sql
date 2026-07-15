create table if not exists plugin_registry (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  plugin_type text not null, -- assessment|career|game|mission|language|learning
  version text default '1.0.0',
  manifest jsonb, -- plugin manifest and metadata
  entrypoint text, -- URL or path to plugin bundle
  permissions jsonb default '[]'::jsonb,
  enabled boolean default false,
  owner_id uuid references auth.users(id),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

CREATE INDEX IF NOT EXISTS idx_plugin_registry_type ON plugin_registry(plugin_type);
