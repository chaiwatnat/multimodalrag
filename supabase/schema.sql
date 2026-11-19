-- Run once on a new project. For an existing installation, use migrations.
create extension if not exists vector with schema extensions;
create table public.rag_sources (id uuid primary key, name text not null, mime text not null, created_at timestamptz not null default now());
create table public.rag_chunks (id bigint generated always as identity primary key, source_id uuid not null references public.rag_sources(id) on delete cascade, content text not null, embedding extensions.vector(768) not null);
alter table public.rag_sources enable row level security;
alter table public.rag_chunks enable row level security;
revoke all on public.rag_sources, public.rag_chunks from anon, authenticated;
create function public.rag_match(query_embedding extensions.vector(768), match_count integer default 5) returns table (source_id uuid, name text, mime text, content text, similarity double precision) language sql stable set search_path = '' as $$
select s.id, s.name, s.mime, c.content, 1 - (c.embedding operator(extensions.<=>) query_embedding) from public.rag_chunks c join public.rag_sources s on s.id = c.source_id order by c.embedding operator(extensions.<=>) query_embedding limit least(greatest(match_count, 1), 20)
$$;
revoke all on function public.rag_match(extensions.vector, integer) from public, anon, authenticated;
grant execute on function public.rag_match(extensions.vector, integer) to service_role;
grant all on public.rag_sources, public.rag_chunks to service_role;
grant usage, select on sequence public.rag_chunks_id_seq to service_role;
