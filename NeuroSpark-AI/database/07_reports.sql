create table if not exists reports (

id uuid primary key default gen_random_uuid(),

user_id uuid not null references auth.users(id) on delete cascade,

overall_score numeric default 0,

confidence_score numeric default 0,

logic_score numeric default 0,

memory_score numeric default 0,

focus_score numeric default 0,

creativity_score numeric default 0,

leadership_score numeric default 0,

communication_score numeric default 0,

decision_score numeric default 0,

learning_score numeric default 0,

summary text,

recommendations jsonb,

version integer default 1,

created_at timestamptz default now()

);
