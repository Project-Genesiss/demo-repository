create table if not exists games (

id uuid primary key default gen_random_uuid(),

title text,

category text,

difficulty integer,

estimated_minutes integer,

active boolean default true

);
