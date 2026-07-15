create table if not exists levels (

id serial primary key,

level_number integer unique,

xp_required integer,

title text,

reward text

);
