class ApiEndpoints {
  // Auth endpoints (새로 추가된 백엔드 API)
  static const String authLogin = '/auth/login';
  static const String authRegisterPatient = '/auth/register/patient';
  static const String authRegisterHospital = '/auth/register/hospital';
  static const String authKakaoLogin = '/auth/kakao-login';
  static const String authLogout = '/auth/logout';
  static const String authRefresh = '/auth/refresh';
  static const String authVerifyBusiness = '/auth/verify-business';
  static String authCheckUsername(String username) => '/auth/check-username/$username';

  // 기존 User endpoints (호환성 유지)
  static const String login = '/users/login';
  static const String register = '/users/register';
  static const String verifyBusiness = '/users/verify-business';
  static const String logout = '/users/logout';
  static const String refreshToken = '/users/refresh';

  // Test endpoints
  static const String testHello = '/test/hello';
  static const String testHealth = '/test/health';
  static const String testEcho = '/test/echo';

  // User endpoints
  static const String userProfile = '/users/profile';
  static const String updateProfile = '/users/profile';
  static const String deleteAccount = '/users/account';
  static const String checkUsername = '/users/check-username';
  static const String hospitals = '/users/hospitals';
  static String getUserById(int id) => '/users/$id';

  // Medical Records endpoints
  static const String medicalRecords = '/medical-records';
  static const String createMedicalRecord = '/medical-records';
  static String getMedicalRecord(int id) => '/medical-records/$id';
  static String updateMedicalRecord(int id) => '/medical-records/$id';
  static String deleteMedicalRecord(int id) => '/medical-records/$id';
  static const String patientRecords = '/medical-records/patient';
  static const String doctorRecords = '/medical-records/doctor';

  // Appointment endpoints
  static const String appointments = '/appointments';
  static const String createAppointment = '/appointments';
  static String getAppointment(int id) => '/appointments/$id';
  static String updateAppointment(int id) => '/appointments/$id';
  static String cancelAppointment(int id) => '/appointments/$id/cancel';
  static const String patientAppointments = '/appointments/patient';
  static const String doctorAppointments = '/appointments/doctor';
  static const String todayAppointments = '/appointments/today';

  // Medication endpoints
  static const String medications = '/medications';
  static const String createMedication = '/medications';
  static String getMedication(int id) => '/medications/$id';
  static String updateMedication(int id) => '/medications/$id';
  static String deleteMedication(int id) => '/medications/$id';
  static const String patientMedications = '/medications/patient';
  static const String medicationReminders = '/medications/reminders';
  static String takeMedication(int id) => '/medications/$id/take';

  // Notification endpoints
  static const String notifications = '/notifications';
  static const String sendMedicationReminder = '/notifications/medication-reminder';
  static const String sendAppointmentReminder = '/notifications/appointment-reminder';
  static const String markAsRead = '/notifications/read';

  // File upload endpoints
  static const String uploadFile = '/files/upload';
  static const String uploadImage = '/files/upload/image';
  static const String uploadDocument = '/files/upload/document';
  static String getFile(String filename) => '/files/$filename';

  // Location/Hospital search endpoints
  static const String nearbyHospitals = '/locations/nearby-hospitals';
  static const String searchHospitals = '/locations/search-hospitals';
  static const String hospitalDetails = '/locations/hospital-details';

  // AI Chat endpoints (추후 구현)
  static const String aiChat = '/ai/chat';
  static const String aiDiagnosis = '/ai/diagnosis';
  static const String aiSymptomAnalysis = '/ai/symptom-analysis';

  // Statistics endpoints
  static const String patientStats = '/statistics/patient';
  static const String doctorStats = '/statistics/doctor';
  static const String hospitalStats = '/statistics/hospital';

  // 쿼리 파라미터 추가 헬퍼 메서드
  static String withQuery(String endpoint, Map<String, dynamic> params) {
    if (params.isEmpty) return endpoint;

    final query = params.entries
        .where((entry) => entry.value != null)
        .map((entry) => '${entry.key}=${Uri.encodeComponent(entry.value.toString())}')
        .join('&');

    return '$endpoint?$query';
  }
}