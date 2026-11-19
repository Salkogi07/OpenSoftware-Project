-- 푼 결과 저장·틀린 문제 모으기·출석 (2~3주차, 김동우)
-- 1) 문제 표를 앱이 쓰는 assets/questions.json 형식(id 'ER-001', 난이도 하/중/상, 보기 4개)에 맞춤
-- 2) 답 하나를 저장하면서 틀린 문제를 자동으로 모으는 record_answer, 출석을 남기는 mark_attendance 추가
--
-- 기존 topics/questions/attempts/wrong_answers는 데이터가 0건이라 지우고 다시 만듦.
-- (profiles, attendance는 그대로 둠)

drop table public.wrong_answers;
drop table public.attempts;
drop table public.questions;
drop table public.topics;  -- 주제는 문제마다 이름으로 저장하므로 따로 표가 필요 없음

-- 문제: questions.json 칸과 1:1
create table public.questions (
  id text primary key,                                    -- 예: 'ER-001'
  topic text not null,
  difficulty text not null check (difficulty in ('하', '중', '상')),
  prompt text not null,
  choices text[] not null check (cardinality(choices) = 4),
  answer smallint not null check (answer between 1 and 4), -- 정답 보기 번호(1~4)
  word text not null,
  meaning text not null,
  explanation text not null
);

-- 문제 푼 기록: 한 문제를 풀 때마다 1줄. 걸린 시간은 복습 문제 뽑기에 씀
create table public.attempts (
  id bigint generated always as identity primary key,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  question_id text not null references public.questions (id),
  is_correct boolean not null,
  time_spent_ms integer not null check (time_spent_ms >= 0),
  answered_at timestamptz not null default now()
);

create index attempts_user_answered_idx on public.attempts (user_id, answered_at desc);

-- 틀린 문제(어휘장): 틀리면 들어오고, 다시 맞히면 빠짐
create table public.wrong_answers (
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  question_id text not null references public.questions (id),
  wrong_count integer not null default 1 check (wrong_count >= 1),
  last_wrong_at timestamptz not null default now(),
  starred boolean not null default false,
  reviewed boolean not null default false,
  primary key (user_id, question_id)
);

-- 공개 권한과 접근 권한(RLS): 문제는 누구나 보기만, 기록은 본인 것만
grant select on public.questions to anon, authenticated;
grant select, insert, update, delete on public.attempts, public.wrong_answers to authenticated;

alter table public.questions     enable row level security;
alter table public.attempts      enable row level security;
alter table public.wrong_answers enable row level security;

create policy "누구나 문제 보기" on public.questions
  for select to anon, authenticated using (true);

create policy "본인 기록만" on public.attempts
  for all to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);

create policy "본인 기록만" on public.wrong_answers
  for all to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);

-- 답 하나 저장: 기록을 남기고, 틀리면 어휘장에 넣고(횟수 +1), 맞히면 어휘장에서 뺌
-- security invoker라서 위 RLS가 그대로 적용됨 (본인 기록만 바뀜)
create function public.record_answer(
  p_question_id text,
  p_is_correct boolean,
  p_time_spent_ms integer
) returns void
language plpgsql
security invoker
set search_path = ''
as $$
begin
  insert into public.attempts (question_id, is_correct, time_spent_ms)
  values (p_question_id, p_is_correct, p_time_spent_ms);

  if p_is_correct then
    delete from public.wrong_answers
    where user_id = auth.uid() and question_id = p_question_id;
  else
    insert into public.wrong_answers (question_id)
    values (p_question_id)
    on conflict (user_id, question_id) do update
      set wrong_count = public.wrong_answers.wrong_count + 1,
          last_wrong_at = now(),
          reviewed = false;
  end if;
end;
$$;

-- 출석: 학습을 한 번 끝내면 오늘(한국 날짜) 출석을 남김. 같은 날 여러 번 끝내도 1번만
create function public.mark_attendance() returns void
language sql
security invoker
set search_path = ''
as $$
  insert into public.attendance default values
  on conflict (user_id, attended_on) do nothing;
$$;

revoke execute on function public.record_answer(text, boolean, integer) from public, anon;
revoke execute on function public.mark_attendance() from public, anon;
grant execute on function public.record_answer(text, boolean, integer) to authenticated;
grant execute on function public.mark_attendance() to authenticated;
