create table if not exists goals (

id uuid primary key default gen_random_uuid(),

user_id uuid not null references auth.users(id) on delete cascade,

title text not null,

description text,

goal_type text,

status text default 'active',

priority integer default 1,

progress numeric default 0,

target_date date,

completed_at timestamptz,

created_at timestamptz default now()

);
