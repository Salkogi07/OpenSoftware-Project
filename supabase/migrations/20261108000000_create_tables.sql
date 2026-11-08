-- 저장 표 만들기 (1주차, 김동우)
-- 사용자 정보, 주제, 문제, 문제 푼 기록, 틀린 문제, 출석

-- 사용자 정보: Supabase 로그인 계정(auth.users) 1개당 1줄
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  nickname text,
  created_at timestamptz not null default now()
);

-- 주제 3가지
create table public.topics (
  id smallint primary key,
  name text not null unique
);

insert into public.topics (id, name) values
  (1, '공식적인 자리에서 쓰는 말'),
  (2, '원래 알던 단어에서 뻗어 나온 말'),
  (3, '요즘 잘 안 쓰는 말');

-- 문제: 기획 엑셀 칸(문제 번호, 주제, 난이도, 문제, 보기 1~4, 정답, 해설, 예문)과 1:1로 맞춤
create table public.questions (
  id integer primary key,                         -- 문제 번호
  topic_id smallint not null references public.topics (id),
  difficulty smallint not null check (difficulty between 1 and 3),
  prompt text not null,                           -- 문제
  choice_1 text not null,
  choice_2 text not null,
  choice_3 text not null,
  choice_4 text not null,
  answer smallint not null check (answer between 1 and 4),  -- 정답 보기 번호
  explanation text,                               -- 해설
  example text                                    -- 예문
);

create index questions_topic_id_idx on public.questions (topic_id);

-- 문제 푼 기록: 한 문제를 풀 때마다 1줄. 걸린 시간은 복습 기능에서 씀
create table public.attempts (
  id bigint generated always as identity primary key,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  question_id integer not null references public.questions (id),
  is_correct boolean not null,
  time_spent_ms integer not null check (time_spent_ms >= 0),
  answered_at timestamptz not null default now()
);

create index attempts_user_answered_idx on public.attempts (user_id, answered_at desc);

-- 틀린 문제(어휘장): 사용자·문제당 1줄. 별표와 복습 체크 포함
create table public.wrong_answers (
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  question_id integer not null references public.questions (id),
  wrong_count integer not null default 1 check (wrong_count >= 1),
  last_wrong_at timestamptz not null default now(),
  starred boolean not null default false,
  reviewed boolean not null default false,
  primary key (user_id, question_id)
);

-- 출석: 사용자·날짜당 1줄 (연속 학습일 계산용)
create table public.attendance (
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  attended_on date not null default (now() at time zone 'Asia/Seoul')::date,  -- 서버는 UTC라서 한국 날짜로 변환
  primary key (user_id, attended_on)
);
