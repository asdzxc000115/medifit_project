// lib/features/auth/presentation/pages/login_screen.dart (API 연동 버전)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../services/auth_service.dart';
// ApiTestScreen 임포트를 위한 import 추가 필요
import 'package:shared_preferences/shared_preferences.dart';
import '../../../test/presentation/pages/api_test_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  // 의존성 주입
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = getService<AuthService>();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 저장된 로그인 정보 불러오기
  Future<void> _loadSavedCredentials() async {
    try {
      // SharedPreferences에서 저장된 사용자명 불러오기
      final prefs = await SharedPreferences.getInstance();
      final savedUsername = prefs.getString('saved_username');
      final rememberMe = prefs.getBool('remember_me') ?? false;

      if (savedUsername != null && rememberMe) {
        setState(() {
          _usernameController.text = savedUsername;
          _rememberMe = rememberMe;
        });
      }
    } catch (e) {
      print('저장된 로그인 정보 불러오기 실패: $e');
    }
  }

  // 로그인 정보 저장
  Future<void> _saveCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (_rememberMe) {
        await prefs.setString('saved_username', _usernameController.text);
        await prefs.setBool('remember_me', true);
      } else {
        await prefs.remove('saved_username');
        await prefs.setBool('remember_me', false);
      }
    } catch (e) {
      print('로그인 정보 저장 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),

              // 로고 및 타이틀
              _buildHeader(),

              const SizedBox(height: 60),

              // 로그인 폼
              _buildLoginForm(),

              const SizedBox(height: 24),

              // 로그인 버튼
              _buildLoginButton(),

              const SizedBox(height: 16),

              // 회원가입 링크
              _buildSignupLink(),

              const SizedBox(height: 40),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // 로고
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF4A90E2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            Icons.medical_services,
            size: 50,
            color: Color(0xFF4A90E2),
          ),
        ),
        const SizedBox(height: 24),

        // 타이틀
        const Text(
          '메디핏',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A90E2),
          ),
        ),
        const SizedBox(height: 8),

        // 서브타이틀
        Text(
          '환자를 위한 스마트 의료 관리',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // 사용자명 입력
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: '사용자명',
              hintText: '사용자명을 입력하세요',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4A90E2)),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '사용자명을 입력하세요';
              }
              if (value.length < 3) {
                return '사용자명은 3자 이상이어야 합니다';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // 비밀번호 입력
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: '비밀번호',
              hintText: '비밀번호를 입력하세요',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
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
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4A90E2)),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '비밀번호를 입력하세요';
              }
              if (value.length < 6) {
                return '비밀번호는 6자 이상이어야 합니다';
              }
              return null;
            },
          ),

          const SizedBox(height: 12),

          // 로그인 유지 체크박스
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                activeColor: const Color(0xFF4A90E2),
              ),
              const Text('로그인 정보 기억하기'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A90E2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 2,
          ),
        )
            : const Text(
          '로그인',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSignupLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('계정이 없으신가요? '),
        TextButton(
          onPressed: () {
            context.push('/signup');
          },
          child: const Text(
            '회원가입',
            style: TextStyle(
              color: Color(0xFF4A90E2),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // 테스트 데이터 자동 입력 (개발용)
  void _fillTestData() {
    setState(() {
      _usernameController.text = 'patient_hong';
      _passwordController.text = 'password123';  // 이제 이걸로 로그인 가능
    });
  }

  // 로그인 처리
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.loginPatient(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (result['success'] == true) {
        // 로그인 정보 저장
        await _saveCredentials();

        // 성공 메시지 표시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? '로그인 성공'),
              backgroundColor: Colors.green,
            ),
          );

          // 홈 화면으로 이동
          context.go('/patient-home');
        }
      } else {
        // 실패 메시지 표시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? '로그인 실패'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('로그인 처리 중 오류: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

