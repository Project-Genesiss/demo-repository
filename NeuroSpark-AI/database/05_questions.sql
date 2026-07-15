create table if not exists questions(

id uuid primary key default gen_random_uuid(),

assessment_id uuid references assessments(id) on delete cascade,

question text,

question_type text,

options jsonb,

correct_answer text,

points integer default 1,

created_at timestamptz default now()

);
