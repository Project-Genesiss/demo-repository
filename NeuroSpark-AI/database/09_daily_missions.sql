create table if not exists daily_missions (

id uuid primary key default gen_random_uuid(),

title text not null,

description text,

mission_type text,

difficulty integer default 1,

xp_reward integer default 10,

coin_reward integer default 5,

is_active boolean default true,

created_at timestamptz default now()

);
