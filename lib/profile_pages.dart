part of 'frontend_screens.dart';

// 프로필 사진으로 고를 수 있는 캐릭터
const _mascotAvatars = [
  'assets/images/chick_mascot_transparent.png',
  'assets/images/chick_mascot_happy.png',
  'assets/images/chick_greeting.png',
  'assets/images/chick_reading.png',
  'assets/images/chick_celebrate.png',
  'assets/images/chick_thinking.png',
];

/// 프로필 사진: 고른 캐릭터·사진, 없으면 기본 병아리
class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.avatar, required this.radius});

  final String? avatar;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final value = avatar ?? 'mascot:$_homeMascotAsset';
    final fallback = Image.asset(_homeMascotAsset, fit: BoxFit.contain);
    final Widget image = switch (value.split(':').first) {
      'photo' => Image.network(
        value.substring('photo:'.length),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      ),
      // 미리보기에서 고른 사진: 웹은 브라우저 임시 주소, 휴대폰은 기기 파일 경로
      'file' when kIsWeb => Image.network(
        value.substring('file:'.length),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      ),
      'file' => Image.file(
        File(value.substring('file:'.length)),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      ),
      _ => Padding(
        padding: EdgeInsets.all(radius * 0.12),
        child: Image.asset(
          value.substring('mascot:'.length),
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => fallback,
        ),
      ),
    };
    return Semantics(
      label: '프로필 사진',
      image: true,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xfffbf5e7),
        child: ClipOval(
          child: SizedBox.square(dimension: radius * 2, child: image),
        ),
      ),
    );
  }
}

// 마이 탭 > 프로필 설정: 프로필 사진, 닉네임, 배지
class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context) {
    final library = _LibraryScope.watch(context)!;
    final badges = studyBadges(library.summary, library.longestStreak);
    final earned = badges.where((badge) => badge.earned).length;
    return Scaffold(
      appBar: AppBar(title: const Text('프로필 설정')),
      body: ScreenBody(
        children: [
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    _ProfileAvatar(avatar: library.avatar, radius: 56),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: IconButton.filled(
                        tooltip: '프로필 사진 바꾸기',
                        style: IconButton.styleFrom(
                          backgroundColor: navy,
                          side: const BorderSide(color: Colors.white, width: 3),
                        ),
                        onPressed: () => _changeAvatar(context, library),
                        icon: const Icon(Icons.photo_camera_outlined, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(library.nickname, style: _pretendardText(22, weight: 850)),
                const SizedBox(height: 4),
                Text(
                  'Lv.${levelFor(library.summary.xp).level} · 배지 $earned개',
                  style: _pretendardText(14, weight: 650, color: _muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const _MyHeading('프로필'),
          _SettingLink(
            icon: Icons.face_outlined,
            label: '프로필 사진',
            detail: '바꾸기',
            onTap: () => _changeAvatar(context, library),
          ),
          const Divider(height: 1, color: _line),
          _SettingLink(
            icon: Icons.badge_outlined,
            label: '닉네임',
            detail: library.nickname,
            onTap: () => _editNickname(context, library),
          ),
          const SizedBox(height: 18),
          _MyHeading('배지', trailing: '$earned / ${badges.length}'),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.86,
            children: [for (final badge in badges) _BadgeTile(badge)],
          ),
        ],
      ),
    );
  }
}

/// 캐릭터 고르기 / 갤러리 사진 고르기
Future<void> _changeAvatar(BuildContext context, _StudyLibrary library) async {
  const gallery = '__gallery__';
  final choice = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('프로필 사진', style: _pretendardText(20, weight: 850)),
            const SizedBox(height: 16),
            Text('캐릭터', style: _pretendardText(15, weight: 750, color: _muted)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final asset in _mascotAvatars)
                  Semantics(
                    button: true,
                    selected: library.avatar == 'mascot:$asset',
                    label: '캐릭터',
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.pop(context, asset),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: library.avatar == 'mascot:$asset'
                                ? green
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: _ProfileAvatar(
                          avatar: 'mascot:$asset',
                          radius: 30,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context, gallery),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('갤러리에서 사진 선택'),
            ),
          ],
        ),
      ),
    ),
  );
  if (choice == null || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  try {
    if (choice != gallery) {
      await library.chooseMascot(choice);
      return;
    }
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (file == null) return;
    messenger.showSnackBar(const SnackBar(content: Text('사진을 올리는 중이에요.')));
    await library.choosePhoto(file);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('프로필 사진을 바꿨어요.')));
  } catch (e) {
    debugPrint('프로필 사진 변경 실패: $e');
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('프로필 사진을 바꾸지 못했어요. 잠시 후 다시 시도해 주세요.')),
      );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile(this.badge);

  final StudyBadge badge;

  @override
  Widget build(BuildContext context) {
    final icon = switch (badge.title) {
      '첫 걸음' => Icons.flag_rounded,
      '꾸준한 출석' => Icons.local_fire_department_rounded,
      '일주일 완주' => Icons.calendar_month_rounded,
      '단어 수집가' => Icons.auto_stories_rounded,
      '어휘 박사' => Icons.school_rounded,
      '문제 해결사' => Icons.task_alt_rounded,
      _ => Icons.track_changes_rounded,
    };
    final earned = badge.earned;
    return Semantics(
      label:
          '${badge.title} 배지, ${badge.description}, ${earned ? '획득' : '진행 ${badge.current}/${badge.goal}'}',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: earned ? mint : const Color(0xfff6f7f8),
          borderRadius: cardRadius,
          border: Border.all(color: earned ? _line : const Color(0xffeceef0)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 12, 6, 10),
          child: Column(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: earned ? orange : const Color(0xffe6e9ec),
                child: Icon(
                  earned ? icon : Icons.lock_outline_rounded,
                  color: earned ? _tabSelectedColor : const Color(0xff9aa4ae),
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                badge.title,
                textAlign: TextAlign.center,
                style: _pretendardText(
                  14,
                  weight: 800,
                  color: earned ? navy : _muted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                badge.description,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _pretendardText(11.5, weight: 600, color: _muted),
              ),
              if (!earned) ...[
                const Spacer(),
                LinearProgressIndicator(
                  value: badge.current / badge.goal,
                  minHeight: 5,
                  borderRadius: BorderRadius.circular(3),
                  color: green,
                  backgroundColor: const Color(0xffe2e6ea),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
