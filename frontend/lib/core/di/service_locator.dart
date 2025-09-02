import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../services/openai_service.dart';
import '../../services/kakao_map_service.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> setupServiceLocator() async {
  print('🔧 서비스 로케이터 초기화 시작...');

  // Core Services
  serviceLocator.registerLazySingleton<ApiClient>(() {
    final client = ApiClient();
    client.initialize();
    print('✅ ApiClient 등록 완료');
    return client;
  });

  serviceLocator.registerLazySingleton<StorageService>(() {
    print('✅ StorageService 등록 완료');
    return StorageService();
  });

  // API Services
  serviceLocator.registerLazySingleton<ApiService>(
        () {
      print('✅ ApiService 등록 완료');
      return ApiService(serviceLocator<ApiClient>());
    },
  );

  serviceLocator.registerLazySingleton<AuthService>(
        () {
      print('✅ AuthService 등록 완료');
      return AuthService(
        serviceLocator<ApiService>(),
        serviceLocator<StorageService>(),
      );
    },
  );

  // 새로 추가된 서비스들
  serviceLocator.registerLazySingleton<OpenAIService>(() {
    print('✅ OpenAIService 등록 완료');
    return OpenAIService();
  });

  serviceLocator.registerLazySingleton<KakaoMapService>(() {
    print('✅ KakaoMapService 등록 완료');
    return KakaoMapService();
  });

  print('✅ Service Locator 초기화 완료');
  print('📱 메디핏 앱 준비 완료!');
}

// 서비스 로케이터 리셋 (테스트용)
Future<void> resetServiceLocator() async {
  print('🔄 서비스 로케이터 리셋 중...');
  await serviceLocator.reset();
  await setupServiceLocator();
  print('✅ 서비스 로케이터 리셋 완료');
}

// 특정 서비스 가져오기 헬퍼 함수들
T getService<T extends Object>() => serviceLocator<T>();

// 기존 서비스들
ApiClient get apiClient => serviceLocator<ApiClient>();
ApiService get apiService => serviceLocator<ApiService>();
AuthService get authService => serviceLocator<AuthService>();
StorageService get storageService => serviceLocator<StorageService>();

// 새로 추가된 서비스 접근자들
OpenAIService get openAIService => serviceLocator<OpenAIService>();
KakaoMapService get kakaoMapService => serviceLocator<KakaoMapService>();

// 서비스 상태 확인 함수 추가
bool areRequiredServicesReady() {
  try {
    // 각 서비스가 등록되어 있는지 확인
    if (!serviceLocator.isRegistered<ApiClient>()) {
      print('❌ 필수 서비스 누락: ApiClient');
      return false;
    }
    if (!serviceLocator.isRegistered<StorageService>()) {
      print('❌ 필수 서비스 누락: StorageService');
      return false;
    }
    if (!serviceLocator.isRegistered<ApiService>()) {
      print('❌ 필수 서비스 누락: ApiService');
      return false;
    }
    if (!serviceLocator.isRegistered<AuthService>()) {
      print('❌ 필수 서비스 누락: AuthService');
      return false;
    }
    if (!serviceLocator.isRegistered<OpenAIService>()) {
      print('❌ 필수 서비스 누락: OpenAIService');
      return false;
    }
    if (!serviceLocator.isRegistered<KakaoMapService>()) {
      print('❌ 필수 서비스 누락: KakaoMapService');
      return false;
    }

    return true;
  } catch (e) {
    print('❌ 서비스 상태 확인 오류: $e');
    return false;
  }
}

// 서비스 상태 정보 맵
Map<String, bool> getServiceStatus() {
  return {
    'ApiClient': serviceLocator.isRegistered<ApiClient>(),
    'StorageService': serviceLocator.isRegistered<StorageService>(),
    'ApiService': serviceLocator.isRegistered<ApiService>(),
    'AuthService': serviceLocator.isRegistered<AuthService>(),
    'OpenAIService': serviceLocator.isRegistered<OpenAIService>(),
    'KakaoMapService': serviceLocator.isRegistered<KakaoMapService>(),
  };
}

// 디버그용 서비스 정보 출력
void printServiceStatus() {
  if (kDebugMode) {
    final status = getServiceStatus();
    print('📊 서비스 상태:');
    status.forEach((service, isRegistered) {
      print('  ${isRegistered ? '✅' : '❌'} $service');
    });
  }
}