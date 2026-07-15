create table if not exists xp_logs (

id uuid primary key default gen_random_uuid(),

user_id uuid references auth.users(id),

amount integer,

reason text,

created_at timestamptz default now()

);
