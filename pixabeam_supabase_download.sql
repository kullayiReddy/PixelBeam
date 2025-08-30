
-- PixaBeam Assessment: Supabase/PostgreSQL schema and seed
-- Safe to run on a fresh Supabase project

-- Enable UUID generation (Supabase usually has this already)
create extension if not exists "pgcrypto";

-- Drop old objects (idempotent for quick re-runs)
drop table if exists rsvps cascade;
drop table if exists events cascade;
drop table if exists users cascade;
drop type  if exists rsvp_status cascade;

-- Enum for RSVP statuses
create type rsvp_status as enum ('yes', 'no', 'maybe');

-- Users table
create table users (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) >= 1),
  email text not null unique,
  created_at timestamptz not null default now()
);

-- Events table
create table events (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) >= 3),
  description text,
  date timestamptz not null,
  city text not null,
  created_by uuid null references users(id) on delete set null,
  created_at timestamptz not null default now()
);

-- RSVPs table
create table rsvps (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id) on delete cascade,
  event_id uuid not null references events(id) on delete cascade,
  status rsvp_status not null,
  created_at timestamptz not null default now(),
  unique (user_id, event_id) -- one RSVP per user per event
);

-- Helpful indexes
create index if not exists idx_events_date        on events(date);
create index if not exists idx_events_city        on events(city);
create index if not exists idx_rsvps_user         on rsvps(user_id);
create index if not exists idx_rsvps_event        on rsvps(event_id);

-- ------------------------
-- Seed data (deterministic UUIDs for demo)
-- ------------------------

-- Users (10)
insert into users (id, name, email, created_at) values
('11111111-1111-1111-1111-111111111111','Aarav Kumar','aarav.kumar@example.com','2025-08-01T10:00:00Z'),
('22222222-2222-2222-2222-222222222222','Ananya Singh','ananya.singh@example.com','2025-08-01T10:05:00Z'),
('33333333-3333-3333-3333-333333333333','Rahul Verma','rahul.verma@example.com','2025-08-01T10:10:00Z'),
('44444444-4444-4444-4444-444444444444','Priya Nair','priya.nair@example.com','2025-08-01T10:15:00Z'),
('55555555-5555-5555-5555-555555555555','Vikram Shah','vikram.shah@example.com','2025-08-01T10:20:00Z'),
('66666666-6666-6666-6666-666666666666','Isha Gupta','isha.gupta@example.com','2025-08-01T10:25:00Z'),
('77777777-7777-7777-7777-777777777777','Neha Joshi','neha.joshi@example.com','2025-08-01T10:30:00Z'),
('88888888-8888-8888-8888-888888888888','Karan Mehta','karan.mehta@example.com','2025-08-01T10:35:00Z'),
('99999999-9999-9999-9999-999999999999','Sneha Rao','sneha.rao@example.com','2025-08-01T10:40:00Z'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','Rohan Das','rohan.das@example.com','2025-08-01T10:45:00Z');

-- Events (5), a mix of upcoming dates in IST (stored as UTC here)
insert into events (id, title, description, date, city, created_by, created_at) values
('e0000000-0000-0000-0000-000000000001','Bengaluru Tech Meetup','Monthly gathering of tech enthusiasts','2025-09-05T13:30:00Z','Bengaluru','11111111-1111-1111-1111-111111111111','2025-08-15T09:00:00Z'),
('e0000000-0000-0000-0000-000000000002','Hyderabad JS Conf','Talks on modern JS and tooling','2025-09-12T11:30:00Z','Hyderabad','33333333-3333-3333-3333-333333333333','2025-08-15T09:05:00Z'),
('e0000000-0000-0000-0000-000000000003','Chennai Data Night','Hands-on with Supabase & SQL','2025-09-18T12:00:00Z','Chennai','55555555-5555-5555-5555-555555555555','2025-08-15T09:10:00Z'),
('e0000000-0000-0000-0000-000000000004','Pune AI Summit','Applied ML in production','2025-09-25T10:30:00Z','Pune','77777777-7777-7777-7777-777777777777','2025-08-15T09:15:00Z'),
('e0000000-0000-0000-0000-000000000005','Mumbai Cloud Day','Serverless, edge, and DevOps','2025-10-02T10:30:00Z','Mumbai','99999999-9999-9999-9999-999999999999','2025-08-15T09:20:00Z');

-- RSVPs (20) - mix of yes/no/maybe
insert into rsvps (id, user_id, event_id, status, created_at) values
('r0000000-0000-0000-0000-000000000001','11111111-1111-1111-1111-111111111111','e0000000-0000-0000-0000-000000000001','yes','2025-08-20T08:00:00Z'),
('r0000000-0000-0000-0000-000000000002','22222222-2222-2222-2222-222222222222','e0000000-0000-0000-0000-000000000001','maybe','2025-08-20T08:05:00Z'),
('r0000000-0000-0000-0000-000000000003','33333333-3333-3333-3333-333333333333','e0000000-0000-0000-0000-000000000001','no','2025-08-20T08:10:00Z'),
('r0000000-0000-0000-0000-000000000004','44444444-4444-4444-4444-444444444444','e0000000-0000-0000-0000-000000000001','yes','2025-08-20T08:15:00Z'),

('r0000000-0000-0000-0000-000000000005','55555555-5555-5555-5555-555555555555','e0000000-0000-0000-0000-000000000002','yes','2025-08-20T08:20:00Z'),
('r0000000-0000-0000-0000-000000000006','66666666-6666-6666-6666-666666666666','e0000000-0000-0000-0000-000000000002','maybe','2025-08-20T08:25:00Z'),
('r0000000-0000-0000-0000-000000000007','77777777-7777-7777-7777-777777777777','e0000000-0000-0000-0000-000000000002','no','2025-08-20T08:30:00Z'),
('r0000000-0000-0000-0000-000000000008','88888888-8888-8888-8888-888888888888','e0000000-0000-0000-0000-000000000002','yes','2025-08-20T08:35:00Z'),

('r0000000-0000-0000-0000-000000000009','99999999-9999-9999-9999-999999999999','e0000000-0000-0000-0000-000000000003','maybe','2025-08-20T08:40:00Z'),
('r0000000-0000-0000-0000-00000000000a','aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','e0000000-0000-0000-0000-000000000003','yes','2025-08-20T08:45:00Z'),
('r0000000-0000-0000-0000-00000000000b','11111111-1111-1111-1111-111111111111','e0000000-0000-0000-0000-000000000003','no','2025-08-20T08:50:00Z'),
('r0000000-0000-0000-0000-00000000000c','22222222-2222-2222-2222-222222222222','e0000000-0000-0000-0000-000000000003','maybe','2025-08-20T08:55:00Z'),

('r0000000-0000-0000-0000-00000000000d','33333333-3333-3333-3333-333333333333','e0000000-0000-0000-0000-000000000004','yes','2025-08-20T09:00:00Z'),
('r0000000-0000-0000-0000-00000000000e','44444444-4444-4444-4444-444444444444','e0000000-0000-0000-0000-000000000004','yes','2025-08-20T09:05:00Z'),
('r0000000-0000-0000-0000-00000000000f','55555555-5555-5555-5555-555555555555','e0000000-0000-0000-0000-000000000004','maybe','2025-08-20T09:10:00Z'),
('r0000000-0000-0000-0000-000000000010','66666666-6666-6666-6666-666666666666','e0000000-0000-0000-0000-000000000004','no','2025-08-20T09:15:00Z'),

('r0000000-0000-0000-0000-000000000011','77777777-7777-7777-7777-777777777777','e0000000-0000-0000-0000-000000000005','yes','2025-08-20T09:20:00Z'),
('r0000000-0000-0000-0000-000000000012','88888888-8888-8888-8888-888888888888','e0000000-0000-0000-0000-000000000005','maybe','2025-08-20T09:25:00Z'),
('r0000000-0000-0000-0000-000000000013','99999999-9999-9999-9999-999999999999','e0000000-0000-0000-0000-000000000005','no','2025-08-20T09:30:00Z'),
('r0000000-0000-0000-0000-000000000014','aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','e0000000-0000-0000-0000-000000000005','yes','2025-08-20T09:35:00Z');

-- Views (optional helpers)
create or replace view v_event_rsvp_summary as
select
  e.id as event_id,
  e.title,
  e.date,
  e.city,
  count(*) filter (where r.status = 'yes')   as yes_count,
  count(*) filter (where r.status = 'no')    as no_count,
  count(*) filter (where r.status = 'maybe') as maybe_count
from events e
left join rsvps r on r.event_id = e.id
group by e.id, e.title, e.date, e.city
order by e.date;

-- Example queries for validation
-- select * from v_event_rsvp_summary;
-- delete from users where id = '11111111-1111-1111-1111-111111111111'; -- will cascade their RSVPs
-- delete from events where id = 'e0000000-0000-0000-0000-000000000001'; -- will cascade RSVPs for that event
