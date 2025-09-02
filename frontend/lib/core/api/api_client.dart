import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import 'api_endpoints.dart';
import 'dart:convert';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late Dio _dio;

  Dio get dio => _dio;

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      sendTimeout: AppConstants.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      // 텍스트 응답도 처리할 수 있도록 설정
      responseType: ResponseType.plain,
    ));

    // 상세 로깅 인터셉터 추가
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: false,
      responseHeader: false,
      error: true,
      logPrint: (obj) {
        print('🔍 DIO LOG: $obj');
      },
    ));

    // 커스텀 요청 인터셉터 추가
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        print('🚀 API 요청 시작');
        print('   - Method: ${options.method}');
        print('   - Full URL: ${options.baseUrl}${options.path}');
        print('   - Headers: ${options.headers}');
        print('   - Data: ${options.data}');
        handler.next(options);
      },

      onResponse: (response, handler) {
        print('✅ API 응답 성공');
        print('   - Status Code: ${response.statusCode}');
        print('   - Data Type: ${response.data.runtimeType}');
        print('   - Data: ${response.data}');
        handler.next(response);
      },

      onError: (error, handler) async {
        print('❌ API 에러 발생');
        print('   - Type: ${error.type}');
        print('   - Message: ${error.message}');
        print('   - Response Code: ${error.response?.statusCode}');
        print('   - Response Data: ${error.response?.data}');
        print('   - Request URL: ${error.requestOptions.baseUrl}${error.requestOptions.path}');
        print('   - Original Error: ${error.error}');

        // 네트워크 연결 상태 자세한 분석
        switch (error.type) {
          case DioExceptionType.connectionTimeout:
            print('🔍 연결 타임아웃 - 서버가 응답하지 않음');
            break;
          case DioExceptionType.sendTimeout:
            print('🔍 전송 타임아웃 - 데이터 전송 시간 초과');
            break;
          case DioExceptionType.receiveTimeout:
            print('🔍 수신 타임아웃 - 응답 받기 시간 초과');
            break;
          case DioExceptionType.badResponse:
            print('🔍 잘못된 응답 - HTTP 에러 상태 코드');
            break;
          case DioExceptionType.connectionError:
            print('🔍 연결 에러 - 네트워크 연결 불가');
            break;
          case DioExceptionType.unknown:
            print('🔍 알 수 없는 에러 - 네트워크나 서버 연결 문제');
            print('🔍 실제 에러: ${error.error}');
            if (error.error != null) {
              print('🔍 에러 타입: ${error.error.runtimeType}');
            }
            break;
          default:
            print('🔍 기타 에러');
        }

        handler.next(error);
      },
    ));
  }

  // GET 요청 (텍스트 응답 처리 개선)
  Future<Response<T>> get<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      print('🔄 GET 요청 준비: $path');

      // 테스트 엔드포인트의 경우 텍스트 응답 허용
      Options requestOptions = options ?? Options();
      if (path.contains('/test/')) {
        requestOptions = requestOptions.copyWith(
          responseType: ResponseType.plain,
        );
      }

      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: requestOptions,
      );

      print('🔄 GET 요청 성공: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      print('🔄 GET 요청 DioException: ${e.type} - ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      print('🔄 GET 요청 일반 Exception: $e');
      print('🔄 Exception 타입: ${e.runtimeType}');
      rethrow;
    }
  }

  // POST 요청
  Future<Response<T>> post<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // PUT 요청
  Future<Response<T>> put<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // DELETE 요청
  Future<Response<T>> delete<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 파일 업로드
  Future<Response<T>> uploadFile<T>(
      String path,
      String filePath, {
        String? fileName,
        Map<String, dynamic>? data,
      }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        if (data != null) ...data,
      });

      return await _dio.post<T>(
        path,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 인증이 필요한 엔드포인트인지 확인
  bool _needsAuthentication(String path) {
    final publicEndpoints = [
      ApiEndpoints.login,
      ApiEndpoints.register,
      ApiEndpoints.verifyBusiness,
      ApiEndpoints.testHello,
      ApiEndpoints.testHealth,
      ApiEndpoints.testEcho,
    ];

    return !publicEndpoints.any((endpoint) => path.contains(endpoint));
  }

  // 액세스 토큰 가져오기
  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.accessTokenKey);
  }

  // 리프레시 토큰으로 액세스 토큰 갱신
  Future<bool> _refreshAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(AppConstants.refreshTokenKey);

      if (refreshToken == null) return false;

      final response = await _dio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final newAccessToken = response.data['data']['accessToken'];
        await prefs.setString(AppConstants.accessTokenKey, newAccessToken);
        return true;
      }

      return false;
    } catch (e) {
      print('토큰 갱신 실패: $e');
      return false;
    }
  }

  // 토큰 정리
  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.accessTokenKey);
    await prefs.remove(AppConstants.refreshTokenKey);
    await prefs.remove(AppConstants.userInfoKey);
  }

  // Dio 에러 처리
  Exception _handleDioError(DioException e) {
    print('🔍 _handleDioError 호출: ${e.type}');

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        print('🔍 연결 타임아웃 처리');
        return Exception('서버 연결 시간이 초과되었습니다. 백엔드 서버가 실행 중인지 확인해주세요.');

      case DioExceptionType.sendTimeout:
        print('🔍 전송 타임아웃 처리');
        return Exception('데이터 전송 시간이 초과되었습니다.');

      case DioExceptionType.receiveTimeout:
        print('🔍 수신 타임아웃 처리');
        return Exception('서버 응답 시간이 초과되었습니다.');

      case DioExceptionType.badResponse:
        print('🔍 잘못된 응답 처리');
        final statusCode = e.response?.statusCode;

        String message = '서버 에러가 발생했습니다';

        // 안전한 방식으로 메시지 추출
        try {
          final responseData = e.response?.data;
          if (responseData != null) {
            if (responseData is Map<String, dynamic>) {
              message = responseData['message']?.toString() ?? message;
            } else if (responseData is String) {
              // JSON 문자열인 경우 파싱 시도
              final jsonData = json.decode(responseData);
              if (jsonData is Map<String, dynamic>) {
                message = jsonData['message']?.toString() ?? message;
              }
            }
          }
        } catch (parseError) {
          print('응답 데이터 파싱 에러: $parseError');
          // 기본 메시지 사용
        }

        return Exception('HTTP 에러 [$statusCode]: $message');

      case DioExceptionType.connectionError:
        print('🔍 연결 에러 처리');
        return Exception('서버에 연결할 수 없습니다. 네트워크 연결과 백엔드 서버 상태를 확인해주세요.');

      case DioExceptionType.badCertificate:
        print('🔍 인증서 에러 처리');
        return Exception('SSL 인증서 오류가 발생했습니다.');

      case DioExceptionType.cancel:
        print('🔍 요청 취소 처리');
        return Exception('요청이 취소되었습니다.');

      case DioExceptionType.unknown:
      default:
        print('🔍 알 수 없는 에러 처리');
        final errorMessage = e.error?.toString() ?? '알 수 없는 오류';

        // FormatException인 경우 특별 처리
        if (e.error is FormatException) {
          print('🔍 FormatException 감지 - JSON 파싱 오류');
          return Exception('서버 응답 형식 오류: JSON이 아닌 텍스트 응답입니다.');
        }

        return Exception('네트워크 연결 문제가 발생했습니다: $errorMessage');
    }
  }
}