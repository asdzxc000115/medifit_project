// lib/core/constants/app_constants.dart (오류 수정됨)
class AppConstants {
  // 기존 API 엔드포인트들
  static const String baseUrlDevice = 'http://192.168.1.100:8080';
  static const String baseUrlSimulator = 'http://127.0.0.1:8080';

  // 토큰 키
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userInfoKey = 'user_info';

  // 오류 메시지
  static const String networkError = '네트워크 연결을 확인해주세요. 서버가 실행 중인지 확인하세요.';

  // 앱 정보
  static const String appName = '메디핏 - 환자용';
  static const String appVersion = '1.0.0';

  // 카카오 API 키 설정 (실제 키로 설정됨)
  static const String kakaoNativeAppKey = 'd818e275279044f812b3b46d1b51f004';
  static const String kakaoJavaScriptKey = '71618b59fd9edd408b6aa0e6ed2122c8';
  static const String kakaoRestApiKey = '1de4ffeb8a7bf2a0fdcdf9de10a8f5fb';

  // 카카오맵 관련 상수들
  static const String kakaoMapBaseUrl = 'https://dapi.kakao.com/v2/local';
  static const int searchRadius = 5000; // 5km
  static const String hospitalCategory = 'HP8'; // 병원 카테고리

  // API 타임아웃 설정 (누락된 상수들 추가)
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // 진료기록 상태
  static const String recordStatusActive = 'ACTIVE';
  static const String recordStatusCompleted = 'COMPLETED';
  static const String recordStatusCancelled = 'CANCELLED';
  static const String recordStatusDraft = 'DRAFT';

  // 예약 상태
  static const String appointmentStatusScheduled = 'SCHEDULED';
  static const String appointmentStatusCompleted = 'COMPLETED';
  static const String appointmentStatusCancelled = 'CANCELLED';
  static const String appointmentStatusConfirmed = 'CONFIRMED';
  static const String appointmentStatusInProgress = 'IN_PROGRESS';
  static const String appointmentStatusNoShow = 'NO_SHOW';

  // 복약 상태
  static const String medicationStatusActive = 'ACTIVE';
  static const String medicationStatusCompleted = 'COMPLETED';
  static const String medicationStatusPaused = 'PAUSED';
  static const String medicationStatusDiscontinued = 'DISCONTINUED';

  // 복약 시간
  static const List<String> medicationTimes = [
    '아침 식전', '아침 식후', '점심 식전', '점심 식후',
    '저녁 식전', '저녁 식후', '취침 전', '필요시',
  ];

  // 혈액형 리스트
  static const List<String> bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', '모름'
  ];

  // 정규식 패턴
  static const String phonePattern = r'^010-?\d{4}-?\d{4}$';
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String usernamePattern = r'^[a-zA-Z0-9_]{3,20}$';

  // 환경별 URL 반환
  static String get apiBaseUrl => baseUrlSimulator;

  // 디버그 모드 여부
  static bool get isDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  // API 버전 정보
  static const String apiVersion = 'v1';
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // 파일 업로드 제한
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentExtensions = ['pdf', 'doc', 'docx'];

  // 알림 설정 키
  static const String notificationMedicationKey = 'notification_medication';
  static const String notificationAppointmentKey = 'notification_appointment';
  static const String notificationHealthTipsKey = 'notification_health_tips';

  // 테마 설정
  static const String themeKey = 'app_theme';
  static const String fontSizeKey = 'font_size';
  static const int cacheValidityMinutes = 30;

  // API 상태 확인
  static bool get isKakaoApiConfigured {
    return kakaoRestApiKey.isNotEmpty &&
        kakaoRestApiKey != 'YOUR_KAKAO_REST_API_KEY';
  }
}