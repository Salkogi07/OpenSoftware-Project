-- 회원 탈퇴: 로그인한 본인 계정만 지움.
-- profiles·학습 기록·오답 등 사용자 표는 auth.users를 on delete cascade로 참조하므로 함께 지워짐.
create or replace function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  delete from auth.users where id = auth.uid();
end;
$$;

-- 로그인한 사용자만 부를 수 있게 함
revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;
