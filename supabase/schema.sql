-- IPADECC, espace membres. A coller une seule fois dans Supabase, menu SQL Editor, puis Run.

create sequence if not exists public.membre_numero_seq start 1;

create table if not exists public.membres (
  id uuid primary key references auth.users(id) on delete cascade,
  numero integer unique not null default nextval('public.membre_numero_seq'),
  email text not null,
  prenom text not null default '',
  nom text not null default '',
  naissance date,
  statut text not null default 'candidat' check (statut in ('candidat','laureat_pact','laureat_pcc','autre')),
  voie text check (voie in ('interne','externe')),
  specialite text,
  annee_evc integer check (annee_evc between 2000 and 2100),
  date_commission date,
  validation text not null default 'en_attente' check (validation in ('en_attente','valide','refuse')),
  cotisation_jusqu date,
  role text not null default 'membre' check (role in ('membre','admin')),
  consentement_le timestamptz,
  derniere_connexion timestamptz,
  cree_le timestamptz not null default now()
);

alter table public.membres enable row level security;
revoke all on public.membres from anon;

-- Outils internes
create or replace function public.est_admin() returns boolean
language sql security definer stable set search_path = public as $$
  select exists (select 1 from public.membres where id = auth.uid() and role = 'admin' and validation = 'valide');
$$;
revoke all on function public.est_admin() from public, anon;
grant execute on function public.est_admin() to authenticated;

create or replace function public.date_sure(t text) returns date
language plpgsql immutable as $$
begin return nullif(t,'')::date; exception when others then return null; end $$;

create or replace function public.entier_sur(t text) returns integer
language plpgsql immutable as $$
begin return nullif(t,'')::integer; exception when others then return null; end $$;

-- Creation automatique de la fiche a l'inscription
create or replace function public.nouveau_membre() returns trigger
language plpgsql security definer set search_path = public as $$
declare m jsonb := coalesce(new.raw_user_meta_data, '{}'::jsonb);
begin
  insert into public.membres (id, email, prenom, nom, naissance, statut, voie, specialite, annee_evc, consentement_le)
  values (
    new.id, coalesce(new.email,''),
    left(coalesce(m->>'prenom',''), 80), left(coalesce(m->>'nom',''), 80),
    public.date_sure(m->>'naissance'),
    case when m->>'statut' in ('candidat','laureat_pact','laureat_pcc','autre') then m->>'statut' else 'candidat' end,
    case when m->>'voie' in ('interne','externe') then m->>'voie' else null end,
    left(nullif(m->>'specialite',''), 120),
    case when public.entier_sur(m->>'annee_evc') between 2000 and 2100 then public.entier_sur(m->>'annee_evc') else null end,
    case when m->>'consentement' = 'true' then now() else null end
  );
  return new;
end $$;

drop trigger if exists a_la_creation_utilisateur on auth.users;
create trigger a_la_creation_utilisateur after insert on auth.users
for each row execute function public.nouveau_membre();

-- Un membre ne peut jamais modifier ces colonnes lui-meme
create or replace function public.proteger_colonnes() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is not null and not public.est_admin() then
    new.id := old.id;
    new.numero := old.numero;
    new.email := old.email;
    new.validation := old.validation;
    new.cotisation_jusqu := old.cotisation_jusqu;
    new.role := old.role;
    new.consentement_le := old.consentement_le;
    new.cree_le := old.cree_le;
  end if;
  return new;
end $$;

drop trigger if exists avant_modification_membre on public.membres;
create trigger avant_modification_membre before update on public.membres
for each row execute function public.proteger_colonnes();

-- Regles d'acces
drop policy if exists "lire sa fiche" on public.membres;
drop policy if exists "lire toutes les fiches (admin)" on public.membres;
drop policy if exists "modifier sa fiche" on public.membres;
drop policy if exists "modifier toutes les fiches (admin)" on public.membres;

create policy "lire sa fiche" on public.membres for select to authenticated using (id = auth.uid());
create policy "lire toutes les fiches (admin)" on public.membres for select to authenticated using (public.est_admin());
create policy "modifier sa fiche" on public.membres for update to authenticated using (id = auth.uid()) with check (id = auth.uid());
create policy "modifier toutes les fiches (admin)" on public.membres for update to authenticated using (public.est_admin()) with check (public.est_admin());

-- Suppression par l'administrateur
create or replace function public.supprimer_membre(cible uuid) returns void
language plpgsql security definer set search_path = public, auth as $$
begin
  if not public.est_admin() then raise exception 'Action reservee a l''administrateur'; end if;
  if cible = auth.uid() then raise exception 'Le compte administrateur ne peut pas etre supprime ici'; end if;
  delete from auth.users where id = cible;
end $$;
revoke all on function public.supprimer_membre(uuid) from public, anon;
grant execute on function public.supprimer_membre(uuid) to authenticated;

-- Suppression de son propre compte par un membre (droit a l'effacement)
create or replace function public.supprimer_mon_compte() returns void
language plpgsql security definer set search_path = public, auth as $$
begin
  if auth.uid() is null then raise exception 'Connexion requise'; end if;
  if exists (select 1 from public.membres where id = auth.uid() and role = 'admin') then
    raise exception 'Le compte administrateur ne peut pas etre supprime ici';
  end if;
  delete from auth.users where id = auth.uid();
end $$;
revoke all on function public.supprimer_mon_compte() from public, anon;
grant execute on function public.supprimer_mon_compte() to authenticated;
