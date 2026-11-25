import 'auth_service.dart';
import 'package:flutter/material.dart';
// 경로가 다를 경우 프로젝트 폴더 구조에 맞게 수정해 주세요.

import 'main_navigation_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // true면 로그인 모드, false면 회원가입 모드
    bool _isLogin = true;

    bool _isLoading = false;
    final AuthService _authService = AuthService();

  // 비밀번호 숨김/표시 토글
  bool _obscurePassword = true;

  // 로그인·회원가입 실패 안내 (입력을 고치면 지움)
  String? _errorText;

  void _clearError(String _) {
    if (_errorText != null) setState(() => _errorText = null);
  }

  // 입력값 검증을 위한 Form 키
  final _formKey = GlobalKey<FormState>();

  // 입력 컨트롤러
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  // 로그인 / 회원가입 버튼 눌렀을 때 실행되는 함수
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      if (_isLogin) {
        // 로그인
        await _authService.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        // 회원가입
        await _authService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          nickname: _nicknameController.text.trim(),
        );
      }

      // 로그인 또는 회원가입 성공 시 메인 화면으로 이동
      if (!mounted) return;

      if (_isLogin) {
      // 로그인 성공 시 메인 화면으로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainNavigationScreen(),
        ),
      );
    } else {
      // 회원가입 성공 시 이메일 인증 안내
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('인증 이메일을 전송했습니다. 이메일 인증 후 로그인해 주세요'),
        ),
      );

      setState(() {
        _isLogin = true;
      });
    }
    } catch (e) {
      // 오류 내용을 한국어 문구로 바꿔 입력칸 아래에 보여 줌
      if (mounted) setState(() => _errorText = authErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. 상단 앱 로고 및 타이틀 영역
                  Icon(
                    Icons.menu_book_rounded,
                    size: 56,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '에르 (Erre)',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin
                        ? '대학생을 위한 스마트 어휘 학습'
                        : '지금 가입하고 나만의 어휘장을 만들어보세요',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 2. 회원가입 모드일 때만 보이는 닉네임 입력창
                  if (!_isLogin) ...[
                    TextFormField(
                      controller: _nicknameController,
                      decoration: InputDecoration(
                        labelText: '닉네임',
                        hintText: '앱에서 사용할 이름을 입력하세요',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (!_isLogin && (value == null || value.trim().isEmpty)) {
                          return '닉네임을 입력해 주세요.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 3. 이메일 입력창
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: _clearError,
                    decoration: InputDecoration(
                      labelText: '이메일',
                      hintText: 'example@university.ac.kr',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '이메일을 입력해 주세요.';
                      }
                      if (!value.contains('@')) {
                        return '올바른 이메일 형식이 아닙니다.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 4. 비밀번호 입력창
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    onChanged: _clearError,
                    decoration: InputDecoration(
                      labelText: '비밀번호',
                      hintText: '6자 이상 입력하세요',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return '비밀번호는 6자 이상이어야 합니다.';
                      }
                      return null;
                    },
                  ),
                  if (_errorText case final message?)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        message,
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 28),

                  // 5. 로그인 / 회원가입 실행 버튼 (theme.dart의 ElevatedButton 스타일 자동 적용)
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isLogin ? '로그인' : '회원가입 완료',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 6. 로그인 ↔ 회원가입 모드 전환 버튼
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin ? '아직 계정이 없으신가요?' : '이미 계정이 있으신가요?',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                            _errorText = null;
                            _formKey.currentState?.reset();
                          });
                        },
                        child: Text(
                          _isLogin ? '회원가입' : '로그인',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}