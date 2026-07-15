create table if not exists skills(

id uuid primary key default gen_random_uuid(),

name text not null,

category text,

description text,

icon text,

difficulty integer default 1,

created_at timestamptz default now()

);
