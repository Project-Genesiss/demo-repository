create table if not exists subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  tier text not null, -- free, pro, team, enterprise
  status text default 'active', -- active, canceled, past_due, trialing
  started_at timestamptz default now(),
  trial_end timestamptz,
  current_period_start timestamptz,
  current_period_end timestamptz,
  provider_subscription_id text,
  billing_cycle text,
  metadata jsonb,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_subscriptions_status') THEN
    ALTER TABLE subscriptions ADD CONSTRAINT chk_subscriptions_status CHECK (status IN ('active','canceled','past_due','trialing'));
  END IF;
END$$;
