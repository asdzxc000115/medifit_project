// lib/services/medical_record_service.dart
import '../core/api/api_endpoints.dart';
import 'api_service.dart';

class MedicalRecordService {
  final ApiService _apiService;

  MedicalRecordService(this._apiService);

  // 진료기록 목록 조회
  Future<Map<String, dynamic>> getMedicalRecords({int? patientId}) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.medicalRecords,
        queryParameters: patientId != null ? {'patientId': patientId} : null,
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'data': response['data'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? '진료기록 조회 실패',
        };
      }
    } catch (e) {
      print('진료기록 조회 오류: $e');
      return {
        'success': false,
        'message': '진료기록 조회 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 특정 진료기록 조회
  Future<Map<String, dynamic>> getMedicalRecordById(int recordId) async {
    try {
      final response = await _apiService.get('${ApiEndpoints.medicalRecords}/$recordId');

      if (response['success'] == true) {
        return {
          'success': true,
          'data': response['data'],
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? '진료기록 조회 실패',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '진료기록 조회 중 오류가 발생했습니다: $e',
      };
    }
  }
}

// lib/services/appointment_service.dart
import '../core/api/api_endpoints.dart';
import 'api_service.dart';

class AppointmentService {
  final ApiService _apiService;

  AppointmentService(this._apiService);

  // 예약 목록 조회
  Future<Map<String, dynamic>> getAppointments({int? patientId}) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.appointments,
        queryParameters: patientId != null ? {'patientId': patientId} : null,
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'data': response['data'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? '예약 목록 조회 실패',
        };
      }
    } catch (e) {
      print('예약 목록 조회 오류: $e');
      return {
        'success': false,
        'message': '예약 목록 조회 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 예약 생성
  Future<Map<String, dynamic>> createAppointment({
    required int patientId,
    required int hospitalId,
    required String appointmentDate,
    required String department,
    String? notes,
    String? symptoms,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.appointmentBooking,
        data: {
          'patientId': patientId,
          'hospitalId': hospitalId,
          'appointmentDate': appointmentDate,
          'department': department,
          'notes': notes,
          'symptoms': symptoms,
          'status': 'SCHEDULED',
          'appointmentType': 'CONSULTATION',
        },
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'message': '예약이 완료되었습니다',
          'data': response['data'],
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? '예약 생성 실패',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '예약 생성 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 예약 취소
  Future<Map<String, dynamic>> cancelAppointment(int appointmentId) async {
    try {
      final response = await _apiService.put(
        '${ApiEndpoints.appointments}/$appointmentId/cancel',
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'message': '예약이 취소되었습니다',
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? '예약 취소 실패',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '예약 취소 중 오류가 발생했습니다: $e',
      };
    }
  }
}

// lib/services/medication_service.dart
import '../core/api/api_endpoints.dart';
import 'api_service.dart';

class MedicationService {
  final ApiService _apiService;

  MedicationService(this._apiService);

  // 복약 목록 조회
  Future<Map<String, dynamic>> getMedications({int? patientId}) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.medications,
        queryParameters: patientId != null ? {'patientId': patientId} : null,
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'data': response['data'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? '복약 목록 조회 실패',
        };
      }
    } catch (e) {
      print('복약 목록 조회 오류: $e');
      return {
        'success': false,
        'message': '복약 목록 조회 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 오늘의 복약 조회
  Future<Map<String, dynamic>> getTodayMedications(int patientId) async {
    try {
      final response = await _apiService.get(
        '${ApiEndpoints.medications}/today',
        queryParameters: {'patientId': patientId},
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'data': response['data'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? '오늘의 복약 조회 실패',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '오늘의 복약 조회 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 복약 완료 처리
  Future<Map<String, dynamic>> markMedicationTaken(int medicationId) async {
    try {
      final response = await _apiService.put(
        '${ApiEndpoints.medications}/$medicationId/taken',
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'message': '복약이 기록되었습니다',
          'data': response['data'],
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? '복약 기록 실패',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '복약 기록 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 복약 알림 설정 토글
  Future<Map<String, dynamic>> toggleMedicationReminder(
      int medicationId,
      bool enabled
      ) async {
    try {
      final response = await _apiService.put(
        '${ApiEndpoints.medications}/$medicationId/reminder',
        data: {'enabled': enabled},
      );

      if (response['success'] == true) {
        return {
          'success': true,
          'message': enabled ? '알림이 활성화되었습니다' : '알림이 비활성화되었습니다',
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? '알림 설정 실패',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '알림 설정 중 오류가 발생했습니다: $e',
      };
    }
  }
}

// lib/services/hospital_service.dart
import '../core/api/api_endpoints.dart';
import 'api_service.dart';

class HospitalService {
  final ApiService _apiService;

  HospitalService(this._apiService);

  // 병원 목록 조회
  Future<Map<String, dynamic>> getHospitals() async {
    try {
      final response = await _apiService.get(ApiEndpoints.hospitals);

      if (response['success'] == true) {
        return {
          'success': true,
          'data': response['data'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? '병원 목록 조회 실패',
        };
      }
    } catch (e) {
      print('병원 목록 조회 오류: $e');
      return {
        'success': false,
        'message': '병원 목록 조회 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 근처 병원 검색 (카카오맵 API 연동 준비)
  Future<Map<String, dynamic>> searchNearbyHospitals({
    required double latitude,
    required double longitude,
    int radius = 5000,
  }) async {
    try {
      // 향후 카카오맵 API 연동 예정
      return {
        'success': false,
        'message': '근처 병원 검색 중 오류가 발생했습니다: $e',
      };
    }
  }
}

// lib/services/storage_service.dart (업데이트)
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class StorageService {
  // 토큰 관리
  Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.accessTokenKey, token);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.accessTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.refreshTokenKey, token);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.refreshTokenKey);
  }

  // 사용자 정보 관리
  Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userInfoKey, jsonEncode(userInfo));
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userInfoJson = prefs.getString(AppConstants.userInfoKey);
    if (userInfoJson != null) {
      return Map<String, dynamic>.from(jsonDecode(userInfoJson));
    }
    return null;
  }

  // 모든 데이터 삭제
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.accessTokenKey);
    await prefs.remove(AppConstants.refreshTokenKey);
    await prefs.remove(AppConstants.userInfoKey);
  }

  // 일반 키-값 저장
  Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }
}

// lib/core/di/service_locator.dart (업데이트)
import 'package:get_it/get_it.dart';
import '../api/api_client.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../services/medical_record_service.dart';
import '../../services/appointment_service.dart';
import '../../services/medication_service.dart';
import '../../services/hospital_service.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Core Services
  serviceLocator.registerLazySingleton<ApiClient>(() {
    final client = ApiClient();
    client.initialize();
    return client;
  });

  serviceLocator.registerLazySingleton<StorageService>(() => StorageService());

  // API Services
  serviceLocator.registerLazySingleton<ApiService>(
        () => ApiService(serviceLocator<ApiClient>()),
  );

  serviceLocator.registerLazySingleton<AuthService>(
        () => AuthService(
      serviceLocator<ApiService>(),
      serviceLocator<StorageService>(),
    ),
  );

  // Data Services
  serviceLocator.registerLazySingleton<MedicalRecordService>(
        () => MedicalRecordService(serviceLocator<ApiService>()),
  );

  serviceLocator.registerLazySingleton<AppointmentService>(
        () => AppointmentService(serviceLocator<ApiService>()),
  );

  serviceLocator.registerLazySingleton<MedicationService>(
        () => MedicationService(serviceLocator<ApiService>()),
  );

  serviceLocator.registerLazySingleton<HospitalService>(
        () => HospitalService(serviceLocator<ApiService>()),
  );

  print('✅ Service Locator 초기화 완료');
}

// 서비스 로케이터 리셋 (테스트용)
Future<void> resetServiceLocator() async {
  await serviceLocator.reset();
  await setupServiceLocator();
}

// 헬퍼 함수들
T getService<T extends Object>() => serviceLocator<T>();

ApiClient get apiClient => serviceLocator<ApiClient>();
ApiService get apiService => serviceLocator<ApiService>();
AuthService get authService => serviceLocator<AuthService>();
StorageService get storageService => serviceLocator<StorageService>();
MedicalRecordService get medicalRecordService => serviceLocator<MedicalRecordService>();
AppointmentService get appointmentService => serviceLocator<AppointmentService>();
MedicationService get medicationService => serviceLocator<MedicationService>();
HospitalService get hospitalService => serviceLocator<HospitalService>();검색 기능은 준비 중입니다',
};
} catch (e) {
return {
'success': false,
'message': '근처 병원