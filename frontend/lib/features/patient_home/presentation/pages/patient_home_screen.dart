// lib/features/patient_home/presentation/pages/patient_home_screen.dart
import 'package:flutter/material.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '홈',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF1A1A1A),
            ),
            onPressed: () {
              // 알림 화면으로 이동
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('알림 기능은 개발 중입니다.'),
                  backgroundColor: Color(0xFF2ECC71),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 환영 헤더
            _buildWelcomeHeader(),

            const SizedBox(height: 24),

            // 빠른 액세스 카드들
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.0,
                children: [
                  // 내 진료 기록
                  _buildCard(
                    context,
                    icon: Icons.medical_information_outlined,
                    title: '내 진료 기록',
                    subtitle: '지난 진료 내역',
                    backgroundColor: Colors.white,
                    iconColor: const Color(0xFF2ECC71),
                    iconBackgroundColor: const Color(0xFFE8F5E8),
                    onTap: () {
                      Navigator.pushNamed(context, '/patient-medical-records');
                    },
                  ),

                  // 병원 예약하기
                  _buildCard(
                    context,
                    icon: Icons.calendar_month_outlined,
                    title: '병원 예약하기',
                    subtitle: '진료 예약',
                    backgroundColor: Colors.white,
                    iconColor: const Color(0xFF4A90E2),
                    iconBackgroundColor: const Color(0xFFE8F3FF),
                    onTap: () {
                      Navigator.pushNamed(context, '/hospital-booking');
                    },
                  ),

                  // 복약 알림
                  _buildCard(
                    context,
                    icon: Icons.medication_outlined,
                    title: '복약 알림',
                    subtitle: '다음 복용',
                    time: '13:00',
                    backgroundColor: Colors.white,
                    iconColor: const Color(0xFFFF6B6B),
                    iconBackgroundColor: const Color(0xFFFFE8E8),
                    onTap: () {
                      Navigator.pushNamed(context, '/medication-alarm');
                    },
                  ),

                  // 주변 병원 찾기
                  _buildCard(
                    context,
                    icon: Icons.location_on_outlined,
                    title: '주변 병원 찾기',
                    subtitle: '내 주변 병원',
                    backgroundColor: Colors.white,
                    iconColor: const Color(0xFFFF9500),
                    iconBackgroundColor: const Color(0xFFFFF0E5),
                    onTap: () {
                      Navigator.pushNamed(context, '/nearby-hospitals');
                    },
                  ),

                  // AI 건강 상담
                  _buildCard(
                    context,
                    icon: Icons.psychology_outlined,
                    title: 'AI 건강 상담',
                    subtitle: '24시간 상담',
                    backgroundColor: Colors.white,
                    iconColor: const Color(0xFF9C27B0),
                    iconBackgroundColor: const Color(0xFFF3E5F5),
                    onTap: () {
                      Navigator.pushNamed(context, '/ai-chat');
                    },
                  ),

                  // 건강 정보
                  _buildCard(
                    context,
                    icon: Icons.health_and_safety_outlined,
                    title: '건강 정보',
                    subtitle: '건강 관리 팁',
                    backgroundColor: Colors.white,
                    iconColor: const Color(0xFF00BCD4),
                    iconBackgroundColor: const Color(0xFFE0F7FA),
                    onTap: () {
                      Navigator.pushNamed(context, '/health-info');
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 최근 활동 섹션
            _buildRecentActivity(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2ECC71).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '안녕하세요!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '홍길동님',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '오늘도 건강한 하루 되세요 💚',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.person,
              size: 30,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        String? time,
        required Color backgroundColor,
        required Color iconColor,
        required Color iconBackgroundColor,
        required VoidCallback onTap,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 아이콘
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: iconColor,
                  ),
                ),

                const SizedBox(height: 16),

                // 제목
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),

                const SizedBox(height: 4),

                // 설명
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),

                if (time != null) ...[
                  const Spacer(),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '최근 활동',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildActivityItem(
                  icon: Icons.medical_information,
                  title: '아인병원 진료',
                  subtitle: '내과 - 감기 진단',
                  time: '2025-08-01',
                  color: const Color(0xFF2ECC71),
                ),

                const Divider(height: 24),

                _buildActivityItem(
                  icon: Icons.medication,
                  title: '복약 알림',
                  subtitle: '타이레놀 500mg 복용',
                  time: '오늘 13:00',
                  color: const Color(0xFFFF6B6B),
                ),

                const Divider(height: 24),

                _buildActivityItem(
                  icon: Icons.calendar_month,
                  title: '예약 일정',
                  subtitle: '아인병원 정기검진',
                  time: '2025-08-15',
                  color: const Color(0xFF4A90E2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),

        Text(
          time,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF999999),
          ),
        ),
      ],
    );
  }
}