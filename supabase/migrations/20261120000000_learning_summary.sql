-- 홈·마이페이지 숫자용 요약 (김동우)
-- 내 전체 푼 문제 수, 맞힌 수, 푼 단어 수(중복 제외), 오늘(한국 날짜) 푼 문제 수
-- security invoker라서 RLS 그대로: 로그인한 본인 기록만 셈
create function public.my_learning_summary()
returns table (
  total_answers integer,
  correct_answers integer,
  learned_words integer,
  today_answers integer
)
language sql
stable
security invoker
set search_path = ''
as $$
  select
    count(*)::integer,
    count(*) filter (where is_correct)::integer,
    count(distinct question_id)::integer,
    count(*) filter (
      where (answered_at at time zone 'Asia/Seoul')::date = (now() at time zone 'Asia/Seoul')::date
    )::integer
  from public.attempts
  where user_id = auth.uid();
$$;

revoke execute on function public.my_learning_summary() from public, anon;
grant execute on function public.my_learning_summary() to authenticated;
