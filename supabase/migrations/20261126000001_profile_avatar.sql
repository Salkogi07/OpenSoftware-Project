-- 프로필 사진: 'mascot:<캐릭터 이름>' 또는 'photo:<공개 주소>'
alter table public.profiles add column if not exists avatar text;

-- 갤러리에서 고른 프로필 사진 저장소 (누구나 주소로 볼 수 있고, 2MB 이하 이미지만)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('avatars', 'avatars', true, 2097152, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

-- 본인 폴더(<사용자 id>/...)에만 올리고 고치고 지울 수 있음
create policy "본인 프로필 사진 보기" on storage.objects
  for select to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text);

create policy "본인 프로필 사진 올리기" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text);

create policy "본인 프로필 사진 바꾸기" on storage.objects
  for update to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text);

create policy "본인 프로필 사진 지우기" on storage.objects
  for delete to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text);
