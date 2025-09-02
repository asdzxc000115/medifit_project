// lib/services/kakao_map_service.dart (새 파일)
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';

class KakaoMapService {
  // 키워드로 병원 검색
  Future<Map<String, dynamic>> searchHospitalsByKeyword({
    required String keyword,
    required double latitude,
    required double longitude,
    int page = 1,
    int size = 15,
  }) async {
    try {
      final url = Uri.parse(
          '${AppConstants.kakaoMapBaseUrl}/search/keyword.json'
      ).replace(queryParameters: {
        'query': '$keyword 병원',
        'category_group_code': AppConstants.hospitalCategory,
        'x': longitude.toString(),
        'y': latitude.toString(),
        'radius': AppConstants.searchRadius.toString(),
        'page': page.toString(),
        'size': size.toString(),
        'sort': 'distance', // 거리순 정렬
      });

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'KakaoAK ${AppConstants.kakaoRestApiKey}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'hospitals': _parseHospitalData(data['documents'] ?? []),
          'meta': data['meta'],
        };
      } else {
        print('카카오맵 API 오류: ${response.statusCode}');
        return {
          'success': false,
          'message': '병원 검색 중 오류가 발생했습니다.',
          'hospitals': _getSampleHospitals(latitude, longitude), // 샘플 데이터로 대체
        };
      }
    } catch (e) {
      print('카카오맵 API 호출 오류: $e');
      return {
        'success': false,
        'message': '네트워크 오류가 발생했습니다.',
        'hospitals': _getSampleHospitals(latitude, longitude), // 샘플 데이터로 대체
      };
    }
  }

  // 카테고리로 주변 병원 검색
  Future<Map<String, dynamic>> searchNearbyHospitals({
    required double latitude,
    required double longitude,
    int page = 1,
    int size = 15,
  }) async {
    try {
      final url = Uri.parse(
          '${AppConstants.kakaoMapBaseUrl}/search/category.json'
      ).replace(queryParameters: {
        'category_group_code': AppConstants.hospitalCategory,
        'x': longitude.toString(),
        'y': latitude.toString(),
        'radius': AppConstants.searchRadius.toString(),
        'page': page.toString(),
        'size': size.toString(),
        'sort': 'distance',
      });

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'KakaoAK ${AppConstants.kakaoRestApiKey}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'hospitals': _parseHospitalData(data['documents'] ?? []),
          'meta': data['meta'],
        };
      } else {
        print('카카오맵 API 오류: ${response.statusCode}');
        return {
          'success': false,
          'message': '주변 병원 검색 중 오류가 발생했습니다.',
          'hospitals': _getSampleHospitals(latitude, longitude),
        };
      }
    } catch (e) {
      print('카카오맵 API 호출 오류: $e');
      return {
        'success': false,
        'message': '네트워크 오류가 발생했습니다.',
        'hospitals': _getSampleHospitals(latitude, longitude),
      };
    }
  }

  // 카카오맵 API 응답 파싱
  List<Map<String, dynamic>> _parseHospitalData(List<dynamic> documents) {
    return documents.map((doc) {
      final distance = double.tryParse(doc['distance'] ?? '0') ?? 0;
      return {
        'id': doc['id'] ?? 'unknown',
        'name': doc['place_name'] ?? '병원명 없음',
        'address': doc['address_name'] ?? '주소 없음',
        'roadAddress': doc['road_address_name'] ?? '',
        'phone': doc['phone'] ?? '전화번호 없음',
        'distance': distance / 1000, // 미터를 킬로미터로 변환
        'latitude': double.tryParse(doc['y'] ?? '0') ?? 0,
        'longitude': double.tryParse(doc['x'] ?? '0') ?? 0,
        'placeUrl': doc['place_url'] ?? '',
        'categoryName': doc['category_name'] ?? '병원',
        'rating': 4.0 + (doc['id'].hashCode % 10) * 0.05, // 가상 평점 (4.0~4.5)
        'isOpen': DateTime.now().hour >= 8 && DateTime.now().hour < 18, // 진료시간 추정
        'departments': _generateDepartments(), // 임시 진료과목
      };
    }).toList();
  }

  // 샘플 병원 데이터 (API 실패 시 사용)
  List<Map<String, dynamic>> _getSampleHospitals(double lat, double lng) {
    return [
      {
        'id': 'sample_1',
        'name': '서울아산병원',
        'address': '서울 송파구 올림픽로43길 88',
        'roadAddress': '서울 송파구 올림픽로43길 88',
        'phone': '1688-7575',
        'distance': 0.8,
        'latitude': lat + 0.01,
        'longitude': lng + 0.01,
        'placeUrl': 'http://www.amc.seoul.kr',
        'categoryName': '종합병원',
        'rating': 4.6,
        'isOpen': true,
        'departments': ['내과', '외과', '소아과', '정형외과', '산부인과'],
      },
      {
        'id': 'sample_2',
        'name': '삼성서울병원',
        'address': '서울 강남구 일원로 81',
        'roadAddress': '서울 강남구 일원로 81',
        'phone': '1599-3114',
        'distance': 1.2,
        'latitude': lat - 0.01,
        'longitude': lng + 0.01,
        'placeUrl': 'http://www.samsunghospital.com',
        'categoryName': '종합병원',
        'rating': 4.7,
        'isOpen': true,
        'departments': ['내과', '외과', '신경외과', '심장내과', '종양내과'],
      },
      {
        'id': 'sample_3',
        'name': '강남세브란스병원',
        'address': '서울 강남구 언주로 211',
        'roadAddress': '서울 강남구 언주로 211',
        'phone': '1599-1004',
        'distance': 1.5,
        'latitude': lat + 0.01,
        'longitude': lng - 0.01,
        'placeUrl': 'https://gs.iseverance.com',
        'categoryName': '종합병원',
        'rating': 4.5,
        'isOpen': false,
        'departments': ['내과', '외과', '정신건강의학과', '재활의학과'],
      },
    ];
  }

  // 임시 진료과목 생성
  List<String> _generateDepartments() {
    final allDepartments = [
      '내과', '외과', '소아과', '정형외과', '산부인과',
      '신경외과', '심장내과', '종양내과', '정신건강의학과',
      '재활의학과', '이비인후과', '안과', '피부과', '비뇨의학과'
    ];
    allDepartments.shuffle();
    return allDepartments.take(3 + (allDepartments.length % 3)).toList();
  }

  // 병원 상세 정보 조회 (향후 확장용)
  Future<Map<String, dynamic>> getHospitalDetail(String hospitalId) async {
    // 실제로는 병원 상세 정보 API를 호출
    // 현재는 기본 정보만 반환
    return {
      'success': true,
      'detail': {
        'operatingHours': '평일 09:00-18:00, 토요일 09:00-13:00',
        'breakTime': '12:00-13:00',
        'parkingAvailable': true,
        'emergencyService': true,
        'website': 'https://example-hospital.com',
        'description': '지역 주민들의 건강을 책임지는 신뢰할 수 있는 의료기관입니다.',
      }
    };
  }
}