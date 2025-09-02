// lib/features/splash/presentation/pages/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  String _statusMessage = '앱을 시작하는 중...';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // 1. 서비스 로케이터 초기화 (이미 main.dart에서 완료)
      setState(() {
        _statusMessage = '서비스 초기화 중...';
      });

      await Future.delayed(const Duration(milliseconds: 500));

      // 2. API 연결 테스트
      setState(() {
        _statusMessage = '서버 연결 확인 중...';
      });

      final apiService = getService<ApiService>();
      final connectionResult = await apiService.testConnection();

      if (connectionResult['success'] != true) {
        throw Exception('서버 연결 실패: ${connectionResult['message']}');
      }

      await Future.delayed(const Duration(milliseconds: 500));

      // 3. 자동 로그인 시도
      setState(() {
        _statusMessage = '로그인 상태 확인 중...';
      });

      final authService = getService<AuthService>();
      final autoLoginResult = await authService.autoLogin();

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      if (autoLoginResult['success'] == true) {
        // 자동 로그인 성공 - 홈 화면으로
        setState(() {
          _statusMessage = '로그인 성공! 메인 화면으로 이동 중...';
        });

        await Future.delayed(const Duration(milliseconds: 1000));

        if (mounted) {
          context.go('/patient-home');
        }
      } else {
        // 자동 로그인 실패 - 로그인 화면으로
        setState(() {
          _statusMessage = '로그인이 필요합니다';
        });

        await Future.delayed(const Duration(milliseconds: 1000));

        if (mounted) {
          context.go('/login');
        }
      }

    } catch (e) {
      print('앱 초기화 오류: $e');

      setState(() {
        _hasError = true;
        _statusMessage = '초기화 오류가 발생했습니다';
      });

      // 오류 발생 시 3초 후 로그인 화면으로
      await Future.delayed(const Duration(seconds: 3));

      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 로고
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(60),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4A90E2).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.medical_services,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 앱 타이틀
                    const Text(
                      '메디핏',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A90E2),
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // 서브타이틀
                    Text(
                      '환자를 위한 스마트 의료 관리',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w300,
                      ),
                    ),

                    const SizedBox(height: 80),

                    // 로딩 인디케이터
                    if (!_hasError) ...[
                      const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
                          strokeWidth: 3,
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.error_outline,
                        size: 32,
                        color: Colors.red[400],
                      ),
                    ],

                    const SizedBox(height: 16),

                    // 상태 메시지
                    Text(
                      _statusMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: _hasError ? Colors.red[600] : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // 오류 시 재시도 버튼
                    if (_hasError) ...[
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _hasError = false;
                            _statusMessage = '앱을 다시 시작하는 중...';
                          });
                          _initializeApp();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90E2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('다시 시도'),
                      ),

                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: () {
                          context.go('/login');
                        },
                        child: const Text(
                          '로그인 화면으로 이동',
                          style: TextStyle(color: Color(0xFF4A90E2)),
                        ),
                      ),
                    ],

                    const SizedBox(height: 60),

                    // 버전 정보
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}