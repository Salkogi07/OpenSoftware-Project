-- 랭킹: 사용자별 맞힌 문제 수와 출석일 (이번 주 또는 전체 기간)
-- 다른 사람 기록은 RLS로 막혀 있어서 security definer로 셈.
-- 대신 사용자 id·이메일은 돌려주지 않고 닉네임·프로필 사진·숫자만 돌려줌. 본인 줄은 is_me로 표시
-- 이번 주 = 한국 시간 월요일 0시부터
create function public.leaderboard(p_weekly boolean)
returns table (
  nickname text,
  avatar text,
  correct_answers integer,
  attendance_days integer,
  is_me boolean
)
language sql
stable
security definer
set search_path = ''
as $$
  with bounds as (
    select case
      when p_weekly then date_trunc('week', now() at time zone 'Asia/Seoul') at time zone 'Asia/Seoul'
      else '-infinity'::timestamptz
    end as since
  ),
  scores as (
    select
      -- 프로필 편집 전에는 profiles 줄이 없을 수 있어 가입할 때 넣은 닉네임으로 대신함
      coalesce(p.nickname, u.raw_user_meta_data ->> 'nickname', '이름 없음') as nickname,
      p.avatar,
      (select count(*) from public.attempts a
        where a.user_id = u.id and a.is_correct and a.answered_at >= b.since)::integer as correct_answers,
      (select count(*) from public.attendance t
        where t.user_id = u.id and t.attended_on >= (b.since at time zone 'Asia/Seoul')::date)::integer as attendance_days,
      u.id = auth.uid() as is_me
    from auth.users u
    cross join bounds b
    left join public.profiles p on p.id = u.id
  )
  -- ponytail: 활동한 사용자 전체를 돌려주고 정렬은 앱에서 함. 사용자가 수천 명이 되면 기준별 상위 N명만 돌려주게 바꿈
  select * from scores
  where correct_answers > 0 or attendance_days > 0 or is_me;
$$;

revoke execute on function public.leaderboard(boolean) from public, anon;
grant execute on function public.leaderboard(boolean) to authenticated;
