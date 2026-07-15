create table if not exists answers (

id uuid primary key default gen_random_uuid(),

user_id uuid not null references auth.users(id) on delete cascade,

question_id uuid not null references questions(id) on delete cascade,

assessment_id uuid not null references assessments(id) on delete cascade,

answer jsonb,

score numeric default 0,

time_taken_seconds integer,

created_at timestamptz default now()

);
