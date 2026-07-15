create table if not exists assessments(

id uuid primary key default gen_random_uuid(),

title text,

description text,

category text,

difficulty integer,

estimated_minutes integer,

is_active boolean default true,

created_at timestamptz default now()

);
