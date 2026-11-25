import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'theme.dart';
import 'auth_screen.dart';
import 'frontend_screens.dart' show VocabularyApp;
import 'main_navigation_screen.dart';

// env.json에서 --dart-define-from-file로 주입됩니다. (README '수파베이스 연결' 참고)
// 앱에는 공개용 publishable(예전 이름 anon) 키만 넣습니다. secret(service_role) 키는 절대 넣지 마세요.
const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabasePublishableKey = String.fromEnvironment(
  'SUPABASE_PUBLISHABLE_KEY',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty) {
    runApp(const VocabularyApp());
    return;
  }

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );
  runApp(const ErreApp());
}

class ErreApp extends StatelessWidget {
  const ErreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '에르',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      // 저장된 로그인 세션이 있으면 로그인 화면을 건너뜀 (자동 로그인)
      home: Supabase.instance.client.auth.currentSession == null
          ? const AuthScreen()
          : const MainNavigationScreen(),
    );
  }
}
