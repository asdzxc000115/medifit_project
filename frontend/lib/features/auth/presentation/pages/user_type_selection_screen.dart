// lib/features/auth/presentation/pages/user_type_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '사용자 유형 선택',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // 제목 섹션
                Column(
                  children: [
                    const Text(
                      '어떤 서비스를\n이용하시나요?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '사용자 유형에 따라 맞춤형 서비스를 제공합니다',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                // 사용자 타입 카드들
                // 일반 환자 카드
                _buildUserTypeCard(
                  context,
                  type: UserType.patient,
                  title: '일반 환자',
                  subtitle: '진료 기록 관리 및 복약 알림',
                  icon: Icons.person,
                  color: const Color(0xFF2ECC71),
                  features: [
                    '진료 기록 확인',
                    '복약 알림 설정',
                    '병원 예약 관리',
                    'AI 건강 상담',
                  ],
                ),

                const SizedBox(height: 24),

                // 병원 관계자 카드
                _buildUserTypeCard(
                  context,
                  type: UserType.hospital,
                  title: '병원 관계자',
                  subtitle: '환자 관리 및 진료 기록 작성',
                  icon: Icons.local_hospital,
                  color: const Color(0xFF4A90E2),
                  features: [
                    '환자 정보 관리',
                    '진료 기록 작성',
                    '처방전 발급',
                    '예약 관리',
                  ],
                ),

                const SizedBox(height: 40),

                // 하단 텍스트
                _buildBottomText(context),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeCard(
      BuildContext context, {
        required UserType type,
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required List<String> features,
      }) {
    return InkWell(
      onTap: () => _selectUserType(context, type),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 기능 목록
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: color,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    feature,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            )),

            const SizedBox(height: 20),

            // 선택 버튼
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: color.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '선택하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: color,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomText(BuildContext context) {
    return Column(
      children: [
        const Text(
          '선택한 유형은 나중에 설정에서 변경할 수 있습니다',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF999999),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        // 뒤로가기 버튼
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            '이전으로 돌아가기',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF4A90E2),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  void _selectUserType(BuildContext context, UserType type) {
    // 선택 피드백
    HapticFeedback.lightImpact();

    // 사용자 타입에 따른 처리
    if (type == UserType.hospital) {
      // 병원 관계자 → 사업자 인증이 필요하지만 일단 메인으로
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('병원 관계자로 로그인되었습니다.'),
          backgroundColor: Color(0xFF4A90E2),
        ),
      );
      Navigator.pushReplacementNamed(context, '/main-navigation');
    } else {
      // 일반 환자 → 바로 메인 화면으로
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('환자로 로그인되었습니다.'),
          backgroundColor: Color(0xFF2ECC71),
        ),
      );
      Navigator.pushReplacementNamed(context, '/main-navigation');
    }
  }
}

// 사용자 타입 열거형
enum UserType {
  hospital,
  patient,
}