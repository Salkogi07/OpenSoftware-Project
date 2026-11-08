-- 데이터 접근 권한 설정하기 (1주차, 김동우)
-- 문제·주제: 누구나 보기만 가능 (추가·수정은 대시보드나 관리자 키로만)
-- 사용자 정보·학습 기록: 로그인한 본인 것만 보고 고칠 수 있음

alter table public.profiles      enable row level security;
alter table public.topics        enable row level security;
alter table public.questions     enable row level security;
alter table public.attempts      enable row level security;
alter table public.wrong_answers enable row level security;
alter table public.attendance    enable row level security;

-- 문제·주제: 읽기만 허용. insert/update/delete 정책이 없으므로 앱에서는 바꿀 수 없음
create policy "누구나 주제 보기" on public.topics
  for select to anon, authenticated using (true);

create policy "누구나 문제 보기" on public.questions
  for select to anon, authenticated using (true);

-- 사용자 정보: 본인 것만
create policy "본인 정보 보기" on public.profiles
  for select to authenticated using ((select auth.uid()) = id);

create policy "본인 정보 만들기" on public.profiles
  for insert to authenticated with check ((select auth.uid()) = id);

create policy "본인 정보 고치기" on public.profiles
  for update to authenticated
  using ((select auth.uid()) = id) with check ((select auth.uid()) = id);

-- 학습 기록 3종: 본인 것만 보기·추가·고치기·지우기
create policy "본인 기록만" on public.attempts
  for all to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);

create policy "본인 기록만" on public.wrong_answers
  for all to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);

create policy "본인 기록만" on public.attendance
  for all to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
