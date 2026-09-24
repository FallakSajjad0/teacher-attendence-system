create extension if not exists pgcrypto;
create table if not exists users (
 id uuid primary key default gen_random_uuid(), name text not null, email text unique not null,
 password_hash text not null, role text not null default 'teacher' check(role in ('admin','management','faculty','teacher')),
 phone text, fcm_token text, is_active boolean not null default true, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists classes (
 id uuid primary key default gen_random_uuid(), subject text not null, code text, teacher_id uuid not null references users(id) on delete cascade,
 room text, start_time timestamptz not null, end_time timestamptz not null,
 classroom_latitude double precision, classroom_longitude double precision, radius_meters integer not null default 100,
 is_active boolean not null default true, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists attendance (
 id uuid primary key default gen_random_uuid(), class_id uuid not null references classes(id) on delete cascade,
 user_id uuid not null references users(id) on delete cascade, status text not null default 'pending',
 availability_response_at timestamptz, arrival_confirmed_at timestamptz, latitude double precision, longitude double precision,
 accuracy double precision, distance_from_classroom double precision, is_within_radius boolean,
 photo_id uuid, verification_status text default 'pending', verification_notes text,
 verified_by uuid references users(id) on delete set null, verified_at timestamptz, is_absent boolean default false, absent_marked_at timestamptz,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now(), unique(class_id,user_id)
);
create table if not exists notifications (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references users(id) on delete cascade,
 class_id uuid references classes(id) on delete cascade, type text not null, title text not null, body text not null,
 status text not null default 'pending', scheduled_at timestamptz, sent_at timestamptz, read_at timestamptz,
 data jsonb not null default '{}'::jsonb, created_at timestamptz not null default now()
);
create table if not exists photos (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references users(id) on delete cascade,
 class_id uuid not null references classes(id) on delete cascade, attendance_id uuid references attendance(id) on delete cascade,
 url text not null, filename text, mime_type text, size_bytes bigint default 0, captured_at timestamptz,
 latitude double precision, longitude double precision, verification_status text default 'pending', notes text,
 created_at timestamptz not null default now()
);
alter table attendance add constraint attendance_photo_fk foreign key(photo_id) references photos(id) on delete set null;
create index if not exists idx_classes_teacher_start on classes(teacher_id,start_time);
create index if not exists idx_attendance_user on attendance(user_id);
create index if not exists idx_notifications_user on notifications(user_id,status);
create index if not exists idx_photos_status on photos(verification_status);
-- Create the first admin from the backend registration endpoint after the schema is installed.
