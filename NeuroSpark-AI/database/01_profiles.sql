create table if not exists profiles (

id uuid primary key default gen_random_uuid(),

user_id uuid unique not null references auth.users(id) on delete cascade,

full_name text,

username text unique,

avatar text,

bio text,

country text,

city text,

language text default 'en',

birth_date date,

gender text,

education text,

experience text,

occupation text,

timezone text,

created_at timestamptz default now(),

updated_at timestamptz default now()

);
