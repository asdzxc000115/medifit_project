// lib/core/routes/app_routes.dart (최종 제출용)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/patient_signup_screen.dart';
import '../../features/patient/presentation/pages/patient_main_screen.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/appointments/presentation/pages/appointments_screen.dart';
import '../../features/appointments/presentation/pages/appointment_booking_screen.dart';
import '../../features/medical_records/presentation/pages/medical_records_screen.dart';
import '../../features/medication/presentation/pages/medications_screen.dart';
import '../../features/patient/presentation/pages/patient_profile_screen.dart';
import '../../features/ai_chat/presentation/pages/ai_chat_screen.dart';
import '../../features/nearby_hospitals/presentation/pages/nearby_hospitals_screen.dart';

class AppRoutes {
  // 라우트 경로 상수들
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String patientHome = '/patient-home';
  static const String appointments = '/appointments';
  static const String appointmentBooking = '/appointment-booking';
  static const String nearbyHospitals = '/nearby-hospitals';
  static const String medicalRecords = '/medical-records';
  static const String medications = '/medications';
  static const String profile = '/profile';
  static const String aiChat = '/ai-chat';

  static final GoRouter router = GoRouter(
    // 기존 로그인 화면을 초기 경로로 설정
    initialLocation: login,
    debugLogDiagnostics: true,

    routes: [
      // === 인증 관련 라우트 ===
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: signup,
        name: 'signup',
        builder: (context, state) => const PatientSignupScreen(),
      ),

      // === 메인 화면 라우트 ===
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const PatientMainScreen(),
      ),

      GoRoute(
        path: patientHome,
        name: 'patient-home',
        builder: (context, state) => const PatientMainScreen(),
      ),

      // === AI 채팅 기능 ===
      GoRoute(
        path: aiChat,
        name: 'ai-chat',
        builder: (context, state) => const AiChatScreen(),
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const AiChatScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeInOut)),
                ),
                child: child,
              );
            },
          );
        },
      ),

      // === 기능별 화면들 ===
      GoRoute(
        path: appointments,
        name: 'appointments',
        builder: (context, state) => const AppointmentsScreen(),
      ),

      GoRoute(
        path: appointmentBooking,
        name: 'appointment-booking',
        builder: (context, state) {
          final hospital = state.extra as Map<String, dynamic>?;
          return AppointmentBookingScreen(selectedHospital: hospital);
        },
      ),

      GoRoute(
        path: nearbyHospitals,
        name: 'nearby-hospitals',
        builder: (context, state) => const NearbyHospitalsScreen(),
      ),

      GoRoute(
        path: medicalRecords,
        name: 'medical-records',
        builder: (context, state) => const MedicalRecordsScreen(),
      ),

      GoRoute(
        path: medications,
        name: 'medications',
        builder: (context, state) => const MedicationsScreen(),
      ),

      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => const PatientProfileScreen(),
      ),

      // === 향후 추가 기능들 ===
      GoRoute(
        path: '/health-analytics',
        name: 'health-analytics',
        builder: (context, state) => _buildComingSoonScreen(
          context,
          '건강 데이터 분석',
          Icons.analytics,
          'AI가 개인 건강 데이터를 분석하여\n맞춤형 건강 관리 솔루션을 제공합니다.',
        ),
      ),

      GoRoute(
        path: '/family-management',
        name: 'family-management',
        builder: (context, state) => _buildComingSoonScreen(
          context,
          '가족 계정 관리',
          Icons.family_restroom,
          '가족 구성원의 건강 정보를\n통합 관리할 수 있습니다.',
        ),
      ),
    ],

    // === 리다이렉트 처리 ===
    redirect: (context, state) {
      // 루트 경로('/')로 접근 시 로그인 화면으로 리다이렉트
      if (state.matchedLocation == '/') {
        return login;
      }
      return null;
    },

    // === 에러 페이지 처리 ===
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('페이지 오류'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '페이지를 찾을 수 없습니다',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '요청하신 페이지가 존재하지 않거나\n이동된 것 같습니다.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.go(login),
                icon: const Icon(Icons.login),
                label: const Text('로그인 화면으로'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  // === 헬퍼 메서드들 ===

  /// 향후 추가될 기능들을 위한 "준비 중" 화면 생성
  static Widget _buildComingSoonScreen(
      BuildContext context,
      String title,
      IconData icon,
      String description,
      ) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  icon,
                  size: 60,
                  color: const Color(0xFF4A90E2),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '🛠️ 준비 중인 기능',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A90E2),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('이전 화면으로'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}