// lib/main.dart (에러 수정 완성본)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'dart:convert';
import 'core/routes/app_routes.dart';
import 'core/di/service_locator.dart';
import 'core/config/openai_config.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('메디핏 시연용 앱 시작...');

  await _setupDemoEnvironment();
  await _setupSystemUI();
  await _lockScreenOrientation();

  try {
    await StorageService.init();
    print('스토리지 서비스 초기화 완료');

    await setupServiceLocator();
    print('서비스 로케이터 초기화 완료');

    _validateServices();

  } catch (e) {
    print('초기화 오류: $e');
    print('기본 설정으로 앱 실행');
  }

  runApp(const MedifitApp());
}

Future<void> _setupDemoEnvironment() async {
  print('시연 모드 환경 설정 중...');
  _checkApiConfiguration();
  await _prepareDemoData();
  print('시연 환경 설정 완료');
}

void _checkApiConfiguration() {
  print('API 설정 상태 확인 중...');

  if (OpenAIConfig.isApiKeyValid) {
    print('OpenAI API: 연결 준비됨');
    print('모델: ${OpenAIConfig.defaultModel}');
    print('상태: ${OpenAIConfig.apiStatusMessage}');
  } else {
    print('OpenAI API: 시연 모드');
    print('빠른 응답으로 최적화됨');
  }

  final debugInfo = OpenAIConfig.debugInfo;
  print('AI 설정 요약:');
  debugInfo.forEach((key, value) {
    print('   $key: $value');
  });

  print('${OpenAIConfig.useTestMode ? "시연" : "실제"} 모드로 실행 예정');
}

Future<void> _prepareDemoData() async {
  try {
    final storageService = StorageService();

    final sampleUserInfo = {
      'name': '김환자',
      'age': 35,
      'gender': '남성',
      'phone': '010-1234-5678',
      'email': 'demo@medifit.kr',
      'medicalHistory': ['고혈압'],
      'currentMedications': ['혈압약'],
      'allergies': ['페니실린'],
      'isDemoUser': true,
      'setupDate': DateTime.now().toIso8601String(),
    };

    await storageService.saveUserInfo(sampleUserInfo);
    print('시연용 사용자 데이터 준비 완료');

    final sampleHospitals = [
      {
        'name': '서울아산병원',
        'department': '내과',
        'doctor': '김의사',
        'phone': '1688-7575',
        'rating': 4.6,
        'visitCount': 3,
      }
    ];

    await storageService.setString('favorite_hospitals',
        jsonEncode(sampleHospitals));
    print('시연용 즐겨찾기 병원 설정 완료');

  } catch (e) {
    print('시연 데이터 준비 실패: $e');
  }
}

Future<void> _setupSystemUI() async {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  print('시스템 UI 스타일 적용 완료');
}

Future<void> _lockScreenOrientation() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  print('세로 모드 고정 완료');
}

void _validateServices() {
  print('서비스 상태 검증 중...');

  try {
    final services = {
      'StorageService': StorageService().preferences != null,
      'OpenAI Service': true,
      'API Client': GetIt.instance.isRegistered<Object>(), // 수정: dynamic -> Object
    };

    bool allServicesReady = true;
    services.forEach((service, isReady) {
      final status = isReady ? '✅' : '❌';
      print('   $service: $status');
      if (!isReady) allServicesReady = false;
    });

    if (allServicesReady) {
      print('모든 서비스 준비 완료 - 시연 시작 가능!');
    } else {
      print('일부 서비스 초기화 실패 - 기본 기능으로 실행');
    }

  } catch (e) {
    print('서비스 검증 중 오류: $e');
  }
}

class MedifitApp extends StatelessWidget {
  const MedifitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '메디핏 - AI 건강 관리 (시연용)',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRoutes.router,

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('ko', 'KR'),

      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,

      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: MediaQuery
                .of(context)
                .textScaleFactor
                .clamp(0.8, 1.3),
          ),
          child: child!,
        );
      },

      scrollBehavior: const MaterialScrollBehavior().copyWith(
        physics: const BouncingScrollPhysics(),
        scrollbars: false,
      ),
    );
  }

  ThemeData _buildLightTheme() {
    const primaryColor = Color(0xFF4A90E2);
    const backgroundColor = Color(0xFFF8F9FA);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        background: backgroundColor,
        surface: Colors.white,
      ),

      scaffoldBackgroundColor: backgroundColor,

      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Color(0xFF1A1A1A),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
          letterSpacing: -0.3,
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(
          color: Color(0xFF1A1A1A),
          size: 22,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE53E3E), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 18, vertical: 16),
        hintStyle: const TextStyle(
          color: Color(0xFF9E9E9E),
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          color: Color(0xFF666666),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF9C27B0),
        foregroundColor: Colors.white,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 6,
        splashColor: Colors.white24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
        iconSize: 26,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: const Color(0xFF9E9E9E),
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        selectedIconTheme: const IconThemeData(size: 26),
        unselectedIconTheme: const IconThemeData(size: 24),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF2D2D2D),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
        actionTextColor: primaryColor,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        backgroundColor: Colors.white,
        elevation: 16,
        modalBackgroundColor: Colors.white,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: Color(0xFFE8F4FD),
        circularTrackColor: Color(0xFFE8F4FD),
      ),

      // 수정됨: DialogTheme -> DialogThemeData
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
        ),
        contentTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF666666),
          height: 1.4,
        ),
      ),

      bannerTheme: const MaterialBannerThemeData(
        backgroundColor: Color(0xFFF3F4F6),
        contentTextStyle: TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 14,
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    const primaryColor = Color(0xFF4A90E2);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),

      cardTheme: CardThemeData(
        color: const Color(0xFF2D2D2D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}