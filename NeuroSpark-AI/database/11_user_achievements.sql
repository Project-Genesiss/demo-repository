create table if not exists user_achievements (

id uuid primary key default gen_random_uuid(),

user_id uuid not null references auth.users(id) on delete cascade,

achievement_id uuid not null references achievements(id) on delete cascade,

earned_at timestamptz default now()

);
