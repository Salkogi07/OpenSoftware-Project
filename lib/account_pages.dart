part of 'frontend_screens.dart';

// 마이 탭 > 계정 관리: 이메일 확인, 닉네임·비밀번호 변경, 회원 탈퇴
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
          const Divider(height: 1, color: _line),
          _SettingLink(
            icon: Icons.lock_outline_rounded,
            label: '비밀번호 변경',
            onTap: () => _changePassword(context, library),
          ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              style: TextButton.styleFrom(foregroundColor: _muted),
              onPressed: () => _confirmDeleteAccount(context, library),
              child: Text(
                '회원 탈퇴',
                style: _pretendardText(15, weight: 600, color: _muted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _changePassword(
  BuildContext context,
  _StudyLibrary library,
) async {
  final form = GlobalKey<FormState>();
  var password = '';
  final changed = await showDialog<bool>(
    context: context,
    builder: (context) {
      var saving = false;
      String? error;
      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> save() async {
            if (!form.currentState!.validate()) return;
            setState(() {
              saving = true;
              error = null;
            });
            try {
              await library.changePassword(password);
              if (context.mounted) Navigator.pop(context, true);
            } catch (e) {
              setState(() {
                saving = false;
                error = authErrorMessage(e);
              });
            }
          }

          return AlertDialog(
            title: const Text('비밀번호 변경'),
            scrollable: true,
            content: Form(
              key: form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    obscureText: true,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: '새 비밀번호'),
                    onChanged: (value) => password = value,
                    validator: (value) =>
                        (value ?? '').length < 6 ? '비밀번호는 6자 이상이어야 합니다.' : null,
                  ),
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(labelText: '새 비밀번호 확인'),
                    validator: (value) =>
                        value != password ? '비밀번호가 서로 달라요.' : null,
                    onFieldSubmitted: (_) => save(),
                  ),
                  if (error case final message?)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        message,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                onPressed: saving ? null : save,
                child: Text(saving ? '바꾸는 중' : '바꾸기'),
              ),
            ],
          );
        },
      );
    },
  );
  if (changed == true && context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('비밀번호를 바꿨어요.')));
  }
}

Future<void> _confirmDeleteAccount(
  BuildContext context,
  _StudyLibrary library,
) async {
  final error = Theme.of(context).colorScheme.error;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('정말 탈퇴할까요?'),
      content: const Text('계정과 함께 학습 기록, 오답노트, 출석 기록이 모두 지워지고 되돌릴 수 없어요.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('취소'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 44),
            backgroundColor: error,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('탈퇴하기'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  try {
    await library.deleteAccount();
  } catch (e) {
    debugPrint('회원 탈퇴 실패: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('탈퇴하지 못했어요. 인터넷 연결을 확인한 뒤 다시 시도해 주세요.')),
      );
    }
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
        '로그인 상태를 유지하기 위한 인증 정보는 이 기기에 저장되며, 로그아웃하면 지워집니다.\n'
        '하루 학습 목표와 학습 알림 시간은 서버로 보내지 않고 이 기기에만 저장합니다.',
  ),
  ('4. 다른 곳에 제공하지 않음', '수집한 개인정보를 광고나 다른 회사에 제공하지 않습니다.'),
  ('5. 보관 기간', '계정이 있는 동안 보관합니다. 회원 탈퇴하면 계정과 학습 기록이 바로 삭제됩니다.'),
  (
    '6. 이용자의 권리',
    '마이 > 계정 관리에서 닉네임과 비밀번호를 바꾸거나 회원 탈퇴할 수 있습니다. '
        '저장된 정보의 확인을 원하면 개발팀에 요청할 수 있습니다.',
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
          Text('에르는 학습에 꼭 필요한 정보만 받고, 그 목적으로만 사용합니다.', style: text.bodyLarge),
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
