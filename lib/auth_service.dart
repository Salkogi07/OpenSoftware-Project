
import 'package:supabase_flutter/supabase_flutter.dart';

/// 로그인·회원가입 오류를 사용자에게 보여 줄 한국어 문구로 바꿈
String authErrorMessage(Object error) {
  if (error is ArgumentError) return '${error.message}';
  if (error is AuthRetryableFetchException) {
    return '인터넷 연결을 확인한 뒤 다시 시도해 주세요.';
  }
  if (error is AuthException) {
    return switch (error.code) {
      // 수파베이스는 보안상 "없는 계정"과 "틀린 비밀번호"를 구분해 알려 주지 않음
      'invalid_credentials' => '이메일 또는 비밀번호가 잘못되었습니다.',
      'email_not_confirmed' => '이메일 인증을 마친 뒤 로그인해 주세요.',
      'user_already_exists' || 'email_exists' => '이미 가입된 이메일입니다.',
      'weak_password' => '비밀번호가 너무 쉬워요. 더 길고 복잡하게 만들어 주세요.',
      'over_request_rate_limit' ||
      'over_email_send_rate_limit' => '요청이 너무 많아요. 잠시 후 다시 시도해 주세요.',
      _ => '요청을 처리하지 못했어요. 잠시 후 다시 시도해 주세요.',
    };
  }
  return '연결에 문제가 생겼어요. 잠시 후 다시 시도해 주세요.';
}

/// Supabase 이메일 인증 및 사용자 정보 관리
class AuthService {
  // 현재 프로젝트에서 초기화한 Supabase 클라이언트 사용
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 현재 로그인한 사용자
  User? get currentUser => _supabase.auth.currentUser;

  /// 현재 로그인 상태
  bool get isLoggedIn => currentUser != null;

  /// 회원가입
  /// 이메일, 비밀번호, 닉네임을 필수로 입력받음
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String nickname,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedNickname = nickname.trim();

    if (trimmedEmail.isEmpty) {
      throw ArgumentError('이메일을 입력해 주세요');
    }

    if (password.isEmpty) {
      throw ArgumentError('비밀번호를 입력해 주세요');
    }

    if (trimmedNickname.isEmpty) {
      throw ArgumentError('닉네임을 입력해 주세요');
    }

    if (trimmedNickname.length > 12) {
      throw ArgumentError('닉네임은 12자 이하로 입력해 주세요');
    }

    try {
      final response = await _supabase.auth.signUp(
        email: trimmedEmail,
        password: password,
        data: {
          'nickname': trimmedNickname,
        },
      );

      return response;
    } on AuthException {
      rethrow;
    }
  }

  /// 이메일과 비밀번호로 로그인
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      throw ArgumentError('이메일과 비밀번호를 입력해 주세요');
    }

    try {
      return await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } on AuthException {
      rethrow;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// 현재 로그인한 사용자의 프로필 조회
  Future<Map<String, dynamic>?> getMyProfile() async {
    final user = currentUser;

    if (user == null) {
      return null;
    }

    return await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
  }

  /// 로그인 상태 변경 감지
  Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }
}
