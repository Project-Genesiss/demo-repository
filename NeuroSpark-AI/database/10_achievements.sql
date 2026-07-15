create table if not exists achievements (

id uuid primary key default gen_random_uuid(),

name text not null,

description text,

icon text,

category text,

xp_reward integer default 100,

badge_color text,

created_at timestamptz default now()

);
