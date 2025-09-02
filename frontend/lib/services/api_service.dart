import 'dart:convert';
import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/constants/app_constants.dart';

class ApiService {
  final ApiClient _apiClient;

  ApiService(this._apiClient);

  /// 연결 테스트
  Future<Map<String, dynamic>> testConnection() async {
    try {
      print('🔄 API 연결 테스트 시작...');
      print('🔄 요청 URL: ${AppConstants.apiBaseUrl}${ApiEndpoints.testHello}');

      final response = await _apiClient.get(ApiEndpoints.testHello);
      print('🔄 응답 받음: ${response.data}');

      return {
        'success': true,
        'message': response.data,
      };
    } catch (e) {
      print('🔄 API 연결 오류: $e');
      return {
        'success': false,
        'message': '백엔드 연결 실패: $e',
      };
    }
  }

  /// 서버 상태 확인
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.testHealth);
      return {
        'success': true,
        'message': response.data,
      };
    } catch (e) {
      return {
        'success': false,
        'message': '서버 상태 확인 실패: $e',
      };
    }
  }

  /// Echo 테스트
  Future<Map<String, dynamic>> echo(String message) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.testEcho,
        data: message,
      );
      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Echo 테스트 실패: $e',
      };
    }
  }

  /// GET 요청 (일반용) - JSON 파싱 수정
  Future<Map<String, dynamic>> get(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
        Map<String, String>? headers,
      }) async {
    try {
      final response = await _apiClient.get(
        endpoint,
        queryParameters: queryParameters,
        options: headers != null ? Options(headers: headers) : null,
      );

      // 응답이 String인 경우 JSON 파싱 시도
      if (response.data is String) {
        try {
          // JSON 문자열 파싱
          final jsonData = jsonDecode(response.data);
          if (jsonData is Map<String, dynamic>) {
            return jsonData;
          }
          // JSON이 아닌 일반 문자열인 경우
          return {
            'success': true,
            'message': response.data,
            'data': response.data,
          };
        } catch (e) {
          // JSON 파싱 실패 시 문자열 그대로 반환
          return {
            'success': true,
            'message': response.data,
            'data': response.data,
          };
        }
      }

      // 응답이 이미 Map인 경우
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }

      // 기타 경우
      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      print('❌ GET 요청 실패 ($endpoint): $e');
      return {
        'success': false,
        'message': 'GET 요청 실패: $e',
      };
    }
  }

  /// POST 요청 (일반용) - JSON 파싱 수정
  Future<Map<String, dynamic>> post(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, String>? headers,
      }) async {
    try {
      final response = await _apiClient.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: headers != null ? Options(headers: headers) : null,
      );

      // 응답이 String인 경우 JSON 파싱 시도
      if (response.data is String) {
        try {
          // JSON 문자열 파싱
          final jsonData = jsonDecode(response.data);
          if (jsonData is Map<String, dynamic>) {
            return jsonData;
          }
          // JSON이 아닌 일반 문자열인 경우
          return {
            'success': true,
            'message': response.data,
            'data': response.data,
          };
        } catch (e) {
          // JSON 파싱 실패 시 문자열 그대로 반환
          return {
            'success': true,
            'message': response.data,
            'data': response.data,
          };
        }
      }

      // 응답이 이미 Map인 경우
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }

      // 기타 경우
      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      print('❌ POST 요청 실패 ($endpoint): $e');
      return {
        'success': false,
        'message': 'POST 요청 실패: $e',
      };
    }
  }

  /// PUT 요청 (일반용)
  Future<Map<String, dynamic>> put(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, String>? headers,
      }) async {
    try {
      final response = await _apiClient.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: headers != null ? Options(headers: headers) : null,
      );

      // 응답이 String인 경우 JSON 파싱 시도
      if (response.data is String) {
        try {
          final jsonData = jsonDecode(response.data);
          if (jsonData is Map<String, dynamic>) {
            return jsonData;
          }
        } catch (e) {
          // JSON 파싱 실패시 그대로 반환
        }
      }

      // 응답이 JSON인 경우
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }

      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      print('❌ PUT 요청 실패 ($endpoint): $e');
      return {
        'success': false,
        'message': 'PUT 요청 실패: $e',
      };
    }
  }

  /// DELETE 요청 (일반용)
  Future<Map<String, dynamic>> delete(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Map<String, String>? headers,
      }) async {
    try {
      final response = await _apiClient.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: headers != null ? Options(headers: headers) : null,
      );

      // 응답이 String인 경우 JSON 파싱 시도
      if (response.data is String) {
        try {
          final jsonData = jsonDecode(response.data);
          if (jsonData is Map<String, dynamic>) {
            return jsonData;
          }
        } catch (e) {
          // JSON 파싱 실패시 그대로 반환
        }
      }

      // 응답이 JSON인 경우
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }

      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      print('❌ DELETE 요청 실패 ($endpoint): $e');
      return {
        'success': false,
        'message': 'DELETE 요청 실패: $e',
      };
    }
  }

  /// 파일 업로드
  Future<Map<String, dynamic>> uploadFile(
      String endpoint,
      String filePath, {
        String? fileName,
        Map<String, dynamic>? additionalData,
        Map<String, String>? headers,
      }) async {
    try {
      final response = await _apiClient.uploadFile(
        endpoint,
        filePath,
        fileName: fileName,
        data: additionalData,
      );

      if (response.data is Map<String, dynamic>) {
        return response.data;
      }

      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      print('❌ 파일 업로드 실패 ($endpoint): $e');
      return {
        'success': false,
        'message': '파일 업로드 실패: $e',
      };
    }
  }

  /// 인증이 필요한 API 요청을 위한 헬퍼 메서드들

  /// 토큰과 함께 GET 요청
  Future<Map<String, dynamic>> getWithAuth(
      String endpoint, {
        Map<String, dynamic>? queryParameters,
      }) async {
    // StorageService에서 토큰 가져오기 (순환 참조 방지를 위해 직접 구현)
    // 실제로는 AuthService를 통해 토큰을 가져와야 함
    return await get(
      endpoint,
      queryParameters: queryParameters,
      headers: {
        // 'Authorization': 'Bearer $token', // 토큰 추가 필요
      },
    );
  }

  /// 토큰과 함께 POST 요청
  Future<Map<String, dynamic>> postWithAuth(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
      }) async {
    return await post(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      headers: {
        // 'Authorization': 'Bearer $token', // 토큰 추가 필요
      },
    );
  }
}