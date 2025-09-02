// lib/features/nearby_hospitals/presentation/pages/nearby_hospitals_screen.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'dart:math';

class NearbyHospitalsScreen extends StatefulWidget {
  const NearbyHospitalsScreen({super.key});

  @override
  State<NearbyHospitalsScreen> createState() => _NearbyHospitalsScreenState();
}

class _NearbyHospitalsScreenState extends State<NearbyHospitalsScreen> {
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _nearbyHospitals = [];
  List<Map<String, dynamic>> _favoriteHospitals = [];

  WebViewController? _webViewController;

  // 목록 뷰를 기본으로 표시
  bool _showMap = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteHospitals();
    _getCurrentLocationAndFindHospitals();
  }

  Future<void> _loadFavoriteHospitals() async {
    final prefs = await SharedPreferences.getInstance();
    final hospitalsJson = prefs.getString('favorite_hospitals');
    if (hospitalsJson != null) {
      if (!mounted) return;
      setState(() {
        _favoriteHospitals =
        List<Map<String, dynamic>>.from(jsonDecode(hospitalsJson));
      });
    }
  }

  Future<void> _saveFavoriteHospitals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('favorite_hospitals', jsonEncode(_favoriteHospitals));
  }

  // 데이터 로딩 함수
  Future<void> _getCurrentLocationAndFindHospitals() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // 데모 데이터를 즉시 로드
    await Future.delayed(const Duration(milliseconds: 800)); // 실제 로딩처럼 보이게 함

    _currentPosition = Position(
      latitude: 37.5665,
      longitude: 126.9780,
      timestamp: DateTime.now(),
      accuracy: 10.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );
    _currentAddress = '서울특별시 중구';

    _searchNearbyHospitalsWithDemoData();

    // 맵뷰가 기본값이므로 웹뷰를 초기화
    if (_showMap) {
      _initializeMapWebView();
    }
  }

  void _searchNearbyHospitalsWithDemoData() {
    final demoHospitals = [
      {
        'id': 'demo_hospital_1',
        'name': '서울아산병원',
        'address': '서울 송파구 올림픽로43길 88',
        'phone': '1688-7575',
        'distance': 0.8,
        'rating': 4.6,
        'departments': ['내과', '외과', '소아과', '정형외과', '산부인과', '신경외과'],
        'operatingHours': '평일 08:00-18:00, 토요일 08:00-13:00',
        'latitude': 37.5262,
        'longitude': 127.1086,
        'isOpen': _checkIfOpen(),
        'specialties': '종합병원',
      },
      {
        'id': 'demo_hospital_2',
        'name': '삼성서울병원',
        'address': '서울 강남구 일원로 81',
        'phone': '1599-3114',
        'distance': 1.2,
        'rating': 4.7,
        'departments': ['내과', '외과', '신경외과', '심장내과', '종양내과', '안과'],
        'operatingHours': '평일 08:30-17:30, 토요일 08:30-12:30',
        'latitude': 37.4881,
        'longitude': 127.0855,
        'isOpen': _checkIfOpen(),
        'specialties': '종합병원',
      },
      {
        'id': 'demo_hospital_3',
        'name': '강남세브란스병원',
        'address': '서울 강남구 언주로 211',
        'phone': '1599-1004',
        'distance': 1.5,
        'rating': 4.5,
        'departments': ['내과', '외과', '정신건강의학과', '재활의학과', '피부과'],
        'operatingHours': '평일 08:00-17:00, 토요일 08:00-12:00',
        'latitude': 37.5186,
        'longitude': 127.0267,
        'isOpen': false,
        'specialties': '종합병원',
      },
      {
        'id': 'demo_hospital_4',
        'name': '서울성모병원',
        'address': '서울 서초구 반포대로 222',
        'phone': '1588-1511',
        'distance': 2.1,
        'rating': 4.4,
        'departments': ['내과', '외과', '소아과', '신경과', '이비인후과'],
        'operatingHours': '평일 08:00-18:00, 토요일 09:00-13:00',
        'latitude': 37.5013,
        'longitude': 126.9967,
        'isOpen': _checkIfOpen(),
        'specialties': '종합병원',
      },
    ];

    demoHospitals.sort((a, b) {
      final aDistance = a['distance'] as double;
      final bDistance = b['distance'] as double;
      return aDistance.compareTo(bDistance);
    });

    if (!mounted) return;
    setState(() {
      _nearbyHospitals = demoHospitals;
      _isLoading = false;
    });
  }

  bool _checkIfOpen() {
    final now = DateTime.now();
    final hour = now.hour;
    final weekday = now.weekday;

    if (weekday == 6) return hour >= 8 && hour < 13;
    if (weekday == 7) return false;
    return hour >= 8 && hour < 18;
  }

  void _initializeMapWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(_generateDemoMapHtml());
  }

  // 지도 화면 HTML 생성
  String _generateDemoMapHtml() {
    final hospitalListItems = _nearbyHospitals.map((hospital) {
      final name = hospital['name'];
      final distance = hospital['distance'];
      return '''
        <li class="hospital-item">
            <span class="pin">📍</span>
            <div class="hospital-info">
                <div class="hospital-name">$name</div>
                <div class="hospital-distance">${distance}km</div>
            </div>
        </li>
      ''';
    }).join('');

    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <title>메디핏 병원 지도</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap');
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html, body { 
            height: 100%; 
            font-family: 'Noto Sans KR', -apple-system, sans-serif;
            background-color: #eaf2f8;
            -webkit-user-select: none; /* Disable text selection */
            user-select: none;
        }
        #map-container {
            width: 100%;
            height: 100%;
            background-image: url('https://i.imgur.com/5vC4t7e.png'); /* 흐릿한 지도 배경 이미지 */
            background-size: cover;
            background-position: center;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 16px;
        }
        .map-overlay {
            width: 100%;
            max-width: 400px;
            background: rgba(255, 255, 255, 0.88);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border-radius: 24px;
            padding: 24px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
            text-align: center;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        .map-title {
            font-size: 22px;
            font-weight: 700;
            color: #1A1A1A;
            margin-bottom: 8px;
        }
        .map-subtitle {
            font-size: 14px;
            color: #555;
            margin-bottom: 20px;
        }
        .hospital-list-box {
            background-color: #fff;
            border-radius: 16px;
            padding: 15px;
            margin-bottom: 20px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.05);
        }
        .list-header {
            font-size: 16px;
            font-weight: 700;
            color: #4A90E2;
            margin-bottom: 15px;
            text-align: left;
        }
        .hospital-list {
            list-style: none;
            padding: 0;
            text-align: left;
            max-height: 220px; /* 높이 조정 */
            overflow-y: auto;
        }
        .hospital-item {
            display: flex;
            align-items: center;
            padding: 10px 5px;
            border-bottom: 1px solid #f0f0f0;
        }
        .hospital-item:last-child {
            border-bottom: none;
        }
        .pin {
            font-size: 20px;
            margin-right: 12px;
            color: #E53E3E;
        }
        .hospital-info { flex-grow: 1; }
        .hospital-name {
            font-size: 15px;
            font-weight: 500;
            color: #333;
        }
        .hospital-distance {
            font-size: 13px;
            color: #777;
        }
    </style>
</head>
<body>
    <div id="map-container">
        <div class="map-overlay">
            <div class="map-title">🗺️ 주변 병원 지도</div>
            <div class="map-subtitle">주변 병원의 위치를 확인하세요.</div>
            <div class="hospital-list-box">
                <div class="list-header">📍 내 주변 병원 목록 (${_nearbyHospitals
        .length}개)</div>
                <ul class="hospital-list">
                    $hospitalListItems
                </ul>
            </div>
        </div>
    </div>
</body>
</html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '주변 병원 찾기',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            key: const ValueKey('map_toggle'),
            icon: Icon(
              _showMap ? Icons.list_alt_rounded : Icons.map_outlined,
              color: const Color(0xFF4A90E2),
            ),
            onPressed: () {
              setState(() {
                _showMap = !_showMap;
                if (_showMap && _webViewController == null) {
                  _initializeMapWebView();
                }
              });
            },
          ),
          IconButton(
            key: const ValueKey('refresh'),
            icon: const Icon(Icons.refresh, color: Color(0xFF4A90E2)),
            onPressed: _getCurrentLocationAndFindHospitals,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
            ),
            SizedBox(height: 16),
            Text('주변 병원을 검색하고 있습니다...'),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(_errorMessage, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _getCurrentLocationAndFindHospitals,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                ),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    if (_showMap && _webViewController != null) {
      return WebViewWidget(controller: _webViewController!);
    }

    return Column(
      children: [
        if (_currentPosition != null) _buildLocationInfo(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: _nearbyHospitals.length,
            itemBuilder: (context, index) {
              return _buildHospitalCard(_nearbyHospitals[index], index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4A90E2).withOpacity(0.1),
            const Color(0xFF4A90E2).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4A90E2).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.my_location, color: Color(0xFF4A90E2)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '현재 위치',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A90E2),
                  ),
                ),
                if (_currentAddress != null)
                  Text(
                    _currentAddress!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${_nearbyHospitals.length}개 병원',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalCard(Map<String, dynamic> hospital, int index) {
    final isFavorite =
    _favoriteHospitals.any((fav) => fav['name'] == hospital['name']);

    return Card(
      key: ValueKey('hospital_$index'),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                hospital['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: hospital['isOpen']
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFE53E3E),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                hospital['isOpen'] ? '진료중' : '진료종료',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Color(0xFFFFA000), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              hospital['rating'].toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.location_on,
                                color: Color(0xFF4A90E2), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${hospital['distance'].toStringAsFixed(1)}km',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4A90E2),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: ValueKey('fav_$index'),
                    onPressed: () => _toggleFavorite(hospital),
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? const Color(0xFFE53E3E) : Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      color: Color(0xFF666666), size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(hospital['address'])),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time,
                      color: Color(0xFF666666), size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(hospital['operatingHours'])),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children:
                (hospital['departments'] as List).take(5).map<Widget>((dept) {
                  return Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A90E2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      dept.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4A90E2),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _navigateToHospital(hospital),
                      icon: const Icon(Icons.directions, size: 16),
                      label: const Text('길찾기'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4A90E2),
                        side: const BorderSide(color: Color(0xFF4A90E2)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: hospital['isOpen']
                          ? () => _makeAppointment(hospital)
                          : null,
                      icon: const Icon(Icons.calendar_month, size: 16),
                      label: const Text('예약하기'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleFavorite(Map<String, dynamic> hospital) {
    if (!mounted) return;
    setState(() {
      final existingIndex =
      _favoriteHospitals.indexWhere((fav) => fav['name'] == hospital['name']);

      if (existingIndex != -1) {
        _favoriteHospitals.removeAt(existingIndex);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${hospital['name']} 즐겨찾기 해제'),
            backgroundColor: const Color(0xFFE53E3E),
          ),
        );
      } else {
        _favoriteHospitals.add({
          'id': hospital['id'],
          'name': hospital['name'],
          'address': hospital['address'],
          'phone': hospital['phone'],
          'rating': hospital['rating'],
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${hospital['name']} 즐겨찾기 추가'),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
      }
    });
    _saveFavoriteHospitals();
  }

  void _callHospital(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('전화를 걸 수 없습니다.')),
      );
    }
  }

  void _navigateToHospital(Map<String, dynamic> hospital) async {
    if (_currentPosition == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('현재 위치를 먼저 확인해주세요.'),
          backgroundColor: Color(0xFFE53E3E),
        ),
      );
      return;
    }

    final latitude = _currentPosition!.latitude;
    final longitude = _currentPosition!.longitude;
    final hospitalName = Uri.encodeComponent(hospital['name']);

    final kakaoMapAppUrl =
    Uri.parse('kakaomap://search?q=$hospitalName&p=$latitude,$longitude');
    final daumMapAppUrl =
    Uri.parse('daummaps://search?q=$hospitalName&p=$latitude,$longitude');
    final appleMapsUrl =
    Uri.parse('maps://?q=$hospitalName&ll=$latitude,$longitude');
    final googleMapsAppUrl =
    Uri.parse('comgooglemaps://?q=$hospitalName&center=$latitude,$longitude');
    final kakaoMapWebUrl =
    Uri.parse('https://map.kakao.com/link/search/$hospitalName');

    try {
      if (await canLaunchUrl(kakaoMapAppUrl)) {
        await launchUrl(kakaoMapAppUrl);
      } else if (await canLaunchUrl(daumMapAppUrl)) {
        await launchUrl(daumMapAppUrl);
      } else if (await canLaunchUrl(googleMapsAppUrl)) {
        await launchUrl(googleMapsAppUrl);
      } else if (await canLaunchUrl(appleMapsUrl)) {
        await launchUrl(appleMapsUrl);
      } else {
        await launchUrl(kakaoMapWebUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('지도 앱을 열 수 없습니다: $e')),
      );
    }
  }

  void _makeAppointment(Map<String, dynamic> hospital) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.calendar_month, color: Color(0xFF4A90E2)),
                const SizedBox(width: 8),
                const Text('예약하기'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${hospital['name']}에 예약하시겠습니까?',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.phone,
                              size: 16, color: Color(0xFF4A90E2)),
                          const SizedBox(width: 8),
                          Text('전화: ${hospital['phone']}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: Color(0xFF4A90E2)),
                          const SizedBox(width: 8),
                          Expanded(child: Text(hospital['address'])),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/appointment-booking', extra: hospital);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                ),
                child: const Text('예약'),
              ),
            ],
          ),
    );
  }
}