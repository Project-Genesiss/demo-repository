create table if not exists skill_scores(

id uuid primary key default gen_random_uuid(),

user_id uuid references auth.users(id) on delete cascade,

skill_id uuid references skills(id),

score numeric default 0,

confidence numeric default 0,

trend numeric default 0,

updated_at timestamptz default now()

);
