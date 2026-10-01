create table if not exists public.registrations (
  reg_no text primary key,
  class_name text,
  url text
);

alter table public.registrations
  add column if not exists class_name text;

alter table public.registrations
  add column if not exists url text;

alter table public.registrations enable row level security;

drop function if exists public.lookup_registration(text);

create function public.lookup_registration(reg_no_input text)
returns table (reg_no text, class_name text, url text)
language sql
security definer
set search_path = ''
as $$
  select r.reg_no::text, r.class_name::text, r.url::text
  from public.registrations as r
  where r.reg_no::text = $1
    and r.class_name = 'XII/E'
  limit 1;
$$;

revoke all on function public.lookup_registration(text) from public;
grant usage on schema public to anon, authenticated;
grant execute on function public.lookup_registration(text) to anon, authenticated;

create table if not exists public.partner_users (
  user_id uuid primary key references auth.users(id) on delete cascade
);

alter table public.partner_users enable row level security;
revoke all on table public.partner_users from anon, authenticated, public;
grant select on table public.partner_users to authenticated;

drop policy if exists "Partners can read their own allowlist entry" on public.partner_users;
create policy "Partners can read their own allowlist entry"
  on public.partner_users for select to authenticated
  using (user_id = auth.uid());

revoke all on table public.registrations from anon, authenticated, public;
grant select on table public.registrations to authenticated;
grant update (url) on table public.registrations to authenticated;

drop policy if exists "Partners can read registrations" on public.registrations;
create policy "Partners can read registrations"
  on public.registrations for select to authenticated
  using (exists (
    select 1 from public.partner_users as p where p.user_id = auth.uid()
  ));

drop policy if exists "Partners can update registration documents" on public.registrations;
create policy "Partners can update registration documents"
  on public.registrations for update to authenticated
  using (exists (
    select 1 from public.partner_users as p where p.user_id = auth.uid()
  ))
  with check (exists (
    select 1 from public.partner_users as p where p.user_id = auth.uid()
  ));

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('student-documents', 'student-documents', true, 1572864, array['application/pdf'])
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Authenticated partners can upload student PDFs" on storage.objects;
create policy "Authenticated partners can upload student PDFs"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'student-documents'
    and exists (select 1 from public.partner_users as p where p.user_id = auth.uid())
  );

drop policy if exists "Authenticated partners can delete student PDFs" on storage.objects;
create policy "Authenticated partners can delete student PDFs"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'student-documents'
    and exists (select 1 from public.partner_users as p where p.user_id = auth.uid())
  );