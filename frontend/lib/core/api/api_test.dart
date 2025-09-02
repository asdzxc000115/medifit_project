// lib/core/api/api_test.dart - API 연동 테스트용 코드

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class ApiTest {

  // 🔥 백엔드 서버 연결 테스트
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      print('🔍 백엔드 서버 연결 테스트 시작...');
      print('🔍 API Base URL: ${AppConstants.apiBaseUrl}');

      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.healthEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('🔍 응답 상태 코드: ${response.statusCode}');
      print('🔍 응답 헤더: ${response.headers}');
      print('🔍 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': '백엔드 서버 연결 성공!',
          'data': response.body,
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': '서버 응답 오류: ${response.statusCode}',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('🔍 연결 테스트 오류: $e');
      return {
        'success': false,
        'message': '서버 연결 실패: $e',
        'error': e.toString(),
      };
    }
  }

  // 🔥 환자 목록 조회 테스트
  static Future<Map<String, dynamic>> testGetPatients() async {
    try {
      print('🔍 환자 목록 조회 테스트 시작...');

      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/patients'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('🔍 환자 목록 응답 상태: ${response.statusCode}');
      print('🔍 환자 목록 응답: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': '환자 목록 조회 성공!',
          'data': data,
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': '환자 목록 조회 실패: ${response.statusCode}',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('🔍 환자 목록 조회 오류: $e');
      return {
        'success': false,
        'message': '환자 목록 조회 오류: $e',
        'error': e.toString(),
      };
    }
  }

  // 🔥 의료기록 조회 테스트
  static Future<Map<String, dynamic>> testGetMedicalRecords() async {
    try {
      print('🔍 의료기록 조회 테스트 시작...');

      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/medical-records'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('🔍 의료기록 응답 상태: ${response.statusCode}');
      print('🔍 의료기록 응답: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': '의료기록 조회 성공!',
          'data': data,
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': '의료기록 조회 실패: ${response.statusCode}',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('🔍 의료기록 조회 오류: $e');
      return {
        'success': false,
        'message': '의료기록 조회 오류: $e',
        'error': e.toString(),
      };
    }
  }

  // 🔥 예약 목록 조회 테스트
  static Future<Map<String, dynamic>> testGetAppointments() async {
    try {
      print('🔍 예약 목록 조회 테스트 시작...');

      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/appointments'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('🔍 예약 목록 응답 상태: ${response.statusCode}');
      print('🔍 예약 목록 응답: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': '예약 목록 조회 성공!',
          'data': data,
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': '예약 목록 조회 실패: ${response.statusCode}',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('🔍 예약 목록 조회 오류: $e');
      return {
        'success': false,
        'message': '예약 목록 조회 오류: $e',
        'error': e.toString(),
      };
    }
  }

  // 🔥 복약 정보 조회 테스트
  static Future<Map<String, dynamic>> testGetMedications() async {
    try {
      print('🔍 복약 정보 조회 테스트 시작...');

      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/medications'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('🔍 복약 정보 응답 상태: ${response.statusCode}');
      print('🔍 복약 정보 응답: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': '복약 정보 조회 성공!',
          'data': data,
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': '복약 정보 조회 실패: ${response.statusCode}',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('🔍 복약 정보 조회 오류: $e');
      return {
        'success': false,
        'message': '복약 정보 조회 오류: $e',
        'error': e.toString(),
      };
    }
  }

  // 🔥 전체 API 테스트 실행
  static Future<Map<String, dynamic>> runAllTests() async {
    Map<String, dynamic> testResults = {
      'timestamp': DateTime.now().toIso8601String(),
      'results': {},
    };

    print('🚀 =========================');
    print('🚀 전체 API 연동 테스트 시작');
    print('🚀 =========================');

    // 1. 서버 연결 테스트
    print('\n1️⃣ 서버 연결 테스트');
    testResults['results']['connection'] = await testConnection();
    await Future.delayed(const Duration(seconds: 1));

    // 2. 환자 목록 조회 테스트
    print('\n2️⃣ 환자 목록 조회 테스트');
    testResults['results']['patients'] = await testGetPatients();
    await Future.delayed(const Duration(seconds: 1));

    // 3. 의료기록 조회 테스트
    print('\n3️⃣ 의료기록 조회 테스트');
    testResults['results']['medicalRecords'] = await testGetMedicalRecords();
    await Future.delayed(const Duration(seconds: 1));

    // 4. 예약 목록 조회 테스트
    print('\n4️⃣ 예약 목록 조회 테스트');
    testResults['results']['appointments'] = await testGetAppointments();
    await Future.delayed(const Duration(seconds: 1));

    // 5. 복약 정보 조회 테스트
    print('\n5️⃣ 복약 정보 조회 테스트');
    testResults['results']['medications'] = await testGetMedications();

    // 테스트 결과 요약
    print('\n🏁 =========================');
    print('🏁 API 연동 테스트 완료');
    print('🏁 =========================');

    int successCount = 0;
    int totalTests = testResults['results'].length;

    testResults['results'].forEach((testName, result) {
      bool isSuccess = result['success'] ?? false;
      if (isSuccess) successCount++;

      String status = isSuccess ? '✅ 성공' : '❌ 실패';
      print('$status - $testName: ${result['message']}');
    });

    testResults['summary'] = {
      'total': totalTests,
      'success': successCount,
      'failed': totalTests - successCount,
      'successRate': '${(successCount / totalTests * 100).toStringAsFixed(1)}%',
    };

    print('\n📊 테스트 결과 요약:');
    print('   전체: $totalTests개');
    print('   성공: $successCount개');
    print('   실패: ${totalTests - successCount}개');
    print('   성공률: ${testResults['summary']['successRate']}');

    return testResults;
  }
}