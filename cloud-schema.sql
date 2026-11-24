-- OS Fit V2 optional cloud sync. Run in a NEW Supabase project, not Mizan Finance.
-- One versioned JSON snapshot per authenticated user; photos are excluded by the client.
-- Must enable RLS because public schema is exposed by the Data API.
create table if not exists public.fit_snapshots (
  user_id uuid primary key references auth.users(id) on delete cascade,
  revision bigint not null default 0 check (revision >= 0),
  snapshot jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
alter table public.fit_snapshots enable row level security;
revoke all on table public.fit_snapshots from public, anon;
grant select, insert, update on table public.fit_snapshots to authenticated;

drop policy if exists fit_snapshot_owner on public.fit_snapshots;
create policy fit_snapshot_owner on public.fit_snapshots
 for all to authenticated
 using ((select auth.uid()) = user_id)
 with check ((select auth.uid()) = user_id);

create or replace function public.fit_pull() returns jsonb
language plpgsql security invoker set search_path = '' as $$
declare uid uuid := (select auth.uid()); result jsonb;
begin
  if uid is null then raise exception 'Sign-in required' using errcode='42501'; end if;
  select jsonb_build_object('revision',revision,'snapshot',snapshot) into result
    from public.fit_snapshots where user_id=uid;
  return coalesce(result,jsonb_build_object('revision',0,'snapshot',null));
end;
$$;

create or replace function public.fit_push(payload jsonb, expected_revision bigint) returns jsonb
language plpgsql security invoker set search_path = '' as $$
declare uid uuid := (select auth.uid()); current_revision bigint;
begin
  if uid is null then raise exception 'Sign-in required' using errcode='42501'; end if;
  if jsonb_typeof(payload) <> 'object'
     or payload->>'version' <> '1'
     or jsonb_typeof(payload->'sessions') <> 'array'
     or jsonb_typeof(payload->'nutrition') <> 'array'
     or jsonb_typeof(payload->'bodyLogs') <> 'array'
     or jsonb_typeof(payload->'photos') <> 'array'
     or jsonb_array_length(payload->'photos') <> 0
     or octet_length(payload::text) > 4000000
  then raise exception 'Invalid fitness snapshot (photos excluded, <=4 MB)' using errcode='22023'; end if;

  insert into public.fit_snapshots (user_id,revision,snapshot) values(uid,0,'{}'::jsonb)
    on conflict (user_id) do nothing;
  select revision into current_revision from public.fit_snapshots where user_id=uid for update;
  if current_revision is distinct from expected_revision then
    return jsonb_build_object('status','conflict','revision',current_revision);
  end if;
  update public.fit_snapshots set snapshot=payload,revision=current_revision+1,updated_at=now()
    where user_id=uid;
  return jsonb_build_object('status','ok','revision',current_revision+1);
end;
$$;

revoke all on function public.fit_pull() from public,anon;
revoke all on function public.fit_push(jsonb,bigint) from public,anon;
grant execute on function public.fit_pull() to authenticated;
grant execute on function public.fit_push(jsonb,bigint) to authenticated;
