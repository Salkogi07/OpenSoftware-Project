part of 'frontend_screens.dart';

// 마이 탭 > 계정 관리: 로그인한 이메일 확인, 닉네임 변경
class _AccountScreen extends StatelessWidget {
  const _AccountScreen();

  @override
  Widget build(BuildContext context) {
    final library = _LibraryScope.watch(context)!;
    final email = library.email ?? (library.preview ? '미리보기 계정' : '-');
    return Scaffold(
      appBar: AppBar(title: const Text('계정 관리')),
      body: ScreenBody(
        children: [
          const _MyHeading('내 계정'),
          _InfoRow(label: '이메일', value: email),
          const Divider(height: 1, color: _line),
          _SettingLink(
            icon: Icons.badge_outlined,
            label: '닉네임',
            detail: library.nickname,
            onTap: () => _editNickname(context, library),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    visualDensity: VisualDensity.compact,
    contentPadding: const EdgeInsets.symmetric(horizontal: 5),
    leading: const Icon(
      Icons.mail_outline_rounded,
      size: 24,
      color: _tabUnselectedColor,
    ),
    title: Text(label, style: _pretendardText(17, weight: 820)),
    trailing: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 210),
      child: Text(
        value,
        overflow: TextOverflow.ellipsis,
        style: _pretendardText(14, weight: 650, color: _muted),
      ),
    ),
  );
}

// 개인정보 처리방침 본문. 앱이 실제로 저장하는 항목(auth_service.dart, learning_repository.dart) 기준
const _privacyPolicy = [
  (
    '1. 수집하는 개인정보',
    '회원가입할 때 이메일 주소, 비밀번호, 닉네임을 받습니다.\n'
        '학습하는 동안 푼 문제, 정답 여부, 문제를 푸는 데 걸린 시간, 학습한 날짜가 자동으로 기록됩니다.',
  ),
  (
    '2. 이용 목적',
    '회원 확인과 로그인, 학습 기록 저장, 연속 학습·정답률·주간 기록·오답 복습 같은 학습 통계를 보여 주는 데만 사용합니다.',
  ),
  (
    '3. 저장 위치와 보호',
    '정보는 클라우드 데이터베이스·인증 서비스인 Supabase에 저장됩니다. '
        '비밀번호는 암호화되어 저장되므로 개발팀도 원래 비밀번호를 볼 수 없습니다.\n'
        '로그인 상태를 유지하기 위한 인증 정보는 이 기기에 저장되며, 로그아웃하면 지워집니다.',
  ),
  ('4. 다른 곳에 제공하지 않음', '수집한 개인정보를 광고나 다른 회사에 제공하지 않습니다.'),
  ('5. 보관 기간', '계정이 있는 동안 보관합니다. 계정 삭제를 요청하면 관련 정보를 지체 없이 삭제합니다.'),
  (
    '6. 이용자의 권리',
    '닉네임은 마이 > 계정 관리에서 언제든 바꿀 수 있습니다. '
        '저장된 정보의 확인이나 삭제를 원하면 개발팀에 요청할 수 있습니다.',
  ),
  ('7. 문의', '동양미래대학교 오픈소프트웨어 팀프로젝트 개발팀'),
];

class _PrivacyPolicyScreen extends StatelessWidget {
  const _PrivacyPolicyScreen();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('개인정보 처리방침')),
      body: ScreenBody(
        children: [
          Text('하루어휘는 학습에 꼭 필요한 정보만 받고, 그 목적으로만 사용합니다.', style: text.bodyLarge),
          for (final (title, body) in _privacyPolicy) ...[
            const SizedBox(height: 24),
            Text(title, style: text.titleMedium),
            const SizedBox(height: 8),
            Text(body, style: text.bodyMedium),
          ],
        ],
      ),
    );
  }
}
