create table if not exists payments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  amount numeric not null,
  currency text default 'USD',
  status text default 'pending', -- pending, succeeded, failed, refunded
  provider text,
  provider_payment_id text,
  metadata jsonb,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Optional: check on status values
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_payments_status') THEN
    ALTER TABLE payments ADD CONSTRAINT chk_payments_status CHECK (status IN ('pending','succeeded','failed','refunded'));
  END IF;
END$$;
