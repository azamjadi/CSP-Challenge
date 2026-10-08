-- CSP Challenge: extended player profile (run once in Supabase SQL Editor)
-- Does not modify existing scores, auth accounts or game tables.
create table if not exists public.player_professional_info (
 user_id uuid primary key references auth.users(id) on delete cascade,
 employment_type text check (employment_type in ('abbott','distributor')),
 distributor_name text,
 job_category text check (job_category in ('sales','fte','sales_fte','education','marketing','management','other')),
 job_title text,
 crm_experience text check (crm_experience in ('under_1','1_3','3_5','over_5')),
 updated_at timestamptz not null default now(),
 constraint distributor_name_required check (employment_type is distinct from 'distributor' or nullif(btrim(distributor_name),'') is not null)
);
create table if not exists public.player_competencies (
 user_id uuid not null references auth.users(id) on delete cascade,
 area text not null check (area in ('LV-Trad','HV-Trad','CRT','CSP')),
 experience_level text not null default 'unknown' check (experience_level in ('unknown','none','intermediate','advanced')),
 certification_status text not null default 'unknown' check (certification_status in ('unknown','no','yes')),
 updated_at timestamptz not null default now(),
 primary key(user_id,area)
);
create table if not exists public.player_product_training (
 user_id uuid not null references auth.users(id) on delete cascade,
 product text not null,
 training_status text not null default 'unknown' check (training_status in ('unknown','not_trained','in_progress','completed')),
 experience_level text not null default 'unknown' check (experience_level in ('unknown','none','intermediate','advanced')),
 certification_status text not null default 'unknown' check (certification_status in ('unknown','no','yes')),
 product_champion boolean not null default false,
 updated_at timestamptz not null default now(),
 primary key(user_id,product)
);
alter table public.player_professional_info enable row level security;
alter table public.player_competencies enable row level security;
alter table public.player_product_training enable row level security;
drop policy if exists "own professional read" on public.player_professional_info;
drop policy if exists "own professional insert" on public.player_professional_info;
drop policy if exists "own professional update" on public.player_professional_info;
create policy "own professional read" on public.player_professional_info for select to authenticated using (user_id=auth.uid());
create policy "own professional insert" on public.player_professional_info for insert to authenticated with check (user_id=auth.uid());
create policy "own professional update" on public.player_professional_info for update to authenticated using (user_id=auth.uid()) with check (user_id=auth.uid());
drop policy if exists "own competency read" on public.player_competencies;
drop policy if exists "own competency insert" on public.player_competencies;
drop policy if exists "own competency update" on public.player_competencies;
create policy "own competency read" on public.player_competencies for select to authenticated using (user_id=auth.uid());
create policy "own competency insert" on public.player_competencies for insert to authenticated with check (user_id=auth.uid());
create policy "own competency update" on public.player_competencies for update to authenticated using (user_id=auth.uid()) with check (user_id=auth.uid());
drop policy if exists "own product read" on public.player_product_training;
drop policy if exists "own product insert" on public.player_product_training;
drop policy if exists "own product update" on public.player_product_training;
create policy "own product read" on public.player_product_training for select to authenticated using (user_id=auth.uid());
create policy "own product insert" on public.player_product_training for insert to authenticated with check (user_id=auth.uid());
create policy "own product update" on public.player_product_training for update to authenticated using (user_id=auth.uid()) with check (user_id=auth.uid());
grant select,insert,update on public.player_professional_info,public.player_competencies,public.player_product_training to authenticated;
