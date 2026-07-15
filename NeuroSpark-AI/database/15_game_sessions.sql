create table if not exists game_sessions (

id uuid primary key default gen_random_uuid(),

user_id uuid references auth.users(id),

game_id uuid references games(id),

score numeric,

duration integer,

created_at timestamptz default now()

);
