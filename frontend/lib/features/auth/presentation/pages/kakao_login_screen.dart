// lib/features/auth/presentation/pages/kakao_login_screen.dart
import 'package:flutter/material.dart';

class KakaoLoginScreen extends StatelessWidget {
  const KakaoLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // 로고 및 앱 소개
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 로고
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A90E2),
                        borderRadius: BorderRadius.circular(30),
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

                    // 앱 이름
                    const Text(
                      '메디핏',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 앱 설명
                    const Text(
                      '나만의 건강 관리 파트너',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF666666),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // 주요 기능 소개 (환자 전용)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildFeatureItem(
                            icon: Icons.medication,
                            title: '복약 관리',
                            subtitle: '정확한 복용 시간 알림',
                          ),
                          const SizedBox(height: 16),
                          _buildFeatureItem(
                            icon: Icons.description,
                            title: '진료 기록',
                            subtitle: '나의 모든 진료 내역 관리',
                          ),
                          const SizedBox(height: 16),
                          _buildFeatureItem(
                            icon: Icons.chat_bubble,
                            title: 'AI 건강상담',
                            subtitle: '24시간 건강 관리 도우미',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 로그인 버튼들
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 카카오 로그인 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => _handleKakaoLogin(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFEE500),
                          foregroundColor: const Color(0xFF3C1E1E),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: Color(0xFF3C1E1E),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  'K',
                                  style: TextStyle(
                                    color: Color(0xFFFEE500),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              '카카오로 시작하기',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 일반 로그인 버튼 (개발 예정)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('이메일 로그인은 개발 중입니다.'),
                              backgroundColor: Color(0xFF4A90E2),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4A90E2),
                          side: const BorderSide(color: Color(0xFF4A90E2)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          '이메일로 로그인',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 이용약관 및 개인정보처리방침
                    _buildTermsText(context),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF4A90E2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF4A90E2),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTermsText(BuildContext context) {
    return Column(
      children: [
        const Text(
          '로그인 시 서비스 이용약관 및 개인정보처리방침에 동의하게 됩니다.',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF999999),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _showTermsDialog(context, '이용약관'),
              child: const Text(
                '이용약관',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF4A90E2),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const Text(
              ' | ',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF999999),
              ),
            ),
            GestureDetector(
              onTap: () => _showTermsDialog(context, '개인정보처리방침'),
              child: const Text(
                '개인정보처리방침',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF4A90E2),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleKakaoLogin(BuildContext context) async {
    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF4A90E2),
        ),
      ),
    );

    // 카카오 로그인 시뮬레이션 (실제로는 카카오 SDK 사용)
    await Future.delayed(const Duration(seconds: 2));

    if (context.mounted) {
      Navigator.pop(context); // 로딩 닫기

      // 환자 전용이므로 바로 메인 네비게이션으로 이동
      Navigator.pushReplacementNamed(context, '/main-navigation');
    }

    // TODO: 실제 카카오 로그인 구현
    /*
    try {
      // 카카오톡으로 로그인
      OAuthToken token = await UserApi.instance.loginWithKakaoTalk();

      // 사용자 정보 가져오기
      User user = await UserApi.instance.me();

      // 백엔드로 토큰 전송하여 검증 및 회원가입/로그인 처리
      final authService = AuthService();
      final result = await authService.kakaoLogin(
        kakaoId: user.id.toString(),
        kakaoEmail: user.kakaoAccount?.email ?? '',
        kakaoNickname: user.kakaoAccount?.profile?.nickname ?? '',
        kakaoProfileImage: user.kakaoAccount?.profile?.profileImageUrl,
        userType: 'PATIENT', // 환자로 고정
      );

      if (result['success']) {
        // 로그인 성공 - 메인 화면으로 이동
        Navigator.pushReplacementNamed(context, '/main-navigation');
      } else {
        // 로그인 실패 처리
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }

    } catch (error) {
      // 카카오톡이 설치되어 있지 않은 경우 웹 로그인
      try {
        OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
        // 위와 동일한 처리
      } catch (error) {
        // 로그인 실패 처리
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인에 실패했습니다: $error')),
        );
      }
    }
    */
  }

  void _showTermsDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: SingleChildScrollView(
            child: Text(
              title == '이용약관'
                  ? '''메디핏 이용약관

제1조 (목적)
본 약관은 메디핏이 제공하는 개인 건강관리 서비스의 이용조건 및 절차에 관한 기본적인 사항을 규정함을 목적으로 합니다.

제2조 (정의)
1. "서비스"란 메디핏이 제공하는 복약 관리, 진료 기록 관리, AI 건강상담 등의 모든 서비스를 의미합니다.
2. "회원"이란 서비스에 접속하여 본 약관에 따라 서비스를 이용하는 개인 환자를 말합니다.

제3조 (서비스의 제공)
1. 회사는 연중무휴, 1일 24시간 서비스를 제공함을 원칙으로 합니다.
2. 개인 건강정보는 안전하게 암호화되어 저장됩니다.

제4조 (개인정보보호)
회사는 개인정보보호법에 따라 회원의 건강정보를 포함한 모든 개인정보를 보호합니다.'''
                  : '''개인정보처리방침

메디핏은 개인정보보호법에 따라 이용자의 개인정보 보호 및 권익을 보호하고자 다음과 같은 처리방침을 두고 있습니다.

1. 개인정보의 처리목적
- 회원가입 및 관리
- 건강관리 서비스 제공
- 복약 알림 서비스 제공
- AI 건강상담 서비스 제공

2. 개인정보의 처리 및 보유기간
- 회원 탈퇴 시까지
- 단, 건강정보는 의료법에 따라 법정 보존기간 동안 보관

3. 개인정보의 제3자 제공
원칙적으로 개인정보를 제3자에게 제공하지 않습니다. 단, 응급상황 시 의료기관에 필요한 정보를 제공할 수 있습니다.

4. 건강정보 보안
모든 건강정보는 암호화되어 저장되며, 접근권한이 엄격하게 관리됩니다.''',
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '확인',
              style: TextStyle(color: Color(0xFF4A90E2)),
            ),
          ),
        ],
      ),
    );
  }
}