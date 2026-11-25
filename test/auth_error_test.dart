import 'package:flutter_test/flutter_test.dart';
import 'package:opensoftware_project/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('비밀번호가 틀리면 잘못되었다는 한국어 문구를 보여 준다', () {
    const error = AuthApiException(
      'Invalid login credentials',
      statusCode: '400',
      code: 'invalid_credentials',
    );
    expect(authErrorMessage(error), '이메일 또는 비밀번호가 잘못되었습니다.');
  });

  test('이메일 인증 전·인터넷 끊김·알 수 없는 오류도 영어 원문을 보여 주지 않는다', () {
    expect(
      authErrorMessage(
        const AuthApiException(
          'Email not confirmed',
          code: 'email_not_confirmed',
        ),
      ),
      '이메일 인증을 마친 뒤 로그인해 주세요.',
    );
    expect(
      authErrorMessage(
        AuthRetryableFetchException(message: 'Failed host lookup'),
      ),
      '인터넷 연결을 확인한 뒤 다시 시도해 주세요.',
    );
    expect(authErrorMessage(Exception('boom')), isNot(contains('Exception')));
  });
}
