import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme.dart';
import 'main_navigation_screen.dart';

// env.json에서 --dart-define-from-file로 주입됩니다. (README '수파베이스 연결' 참고)
// 앱에는 공개용 publishable(예전 이름 anon) 키만 넣습니다. secret(service_role) 키는 절대 넣지 마세요.
const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabasePublishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 키가 없으면 수파베이스 없이 화면만 실행합니다. (화면 작업용)
  if (supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty) {
    await Supabase.initialize(url: supabaseUrl, publishableKey: supabasePublishableKey);
  } else {
    debugPrint('env.json에 수파베이스 키가 없어 연결 없이 실행합니다.');
  }
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
      home: const MainNavigationScreen(),
    );
  }
}