// lib/features/patient/presentation/pages/patient_profile_screen.dart (수정됨)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  // 사용자 정보 데이터
  Map<String, dynamic> _userInfo = {
    'name': '홍길동',
    'email': 'hong@example.com',
    'phone': '010-1234-5678',
    'birth': '1990-01-15',
    'gender': '남성',
    'address': '서울시 강남구 논현동 123-45',
    'bloodType': 'A+',
    'height': '175',
    'weight': '70',
    'profileImage': null,
  };

  // 건강 정보 데이터 (응급연락처 포함)
  Map<String, dynamic> _healthInfo = {
    'allergies': ['페니실린', '견과류'],
    'chronicDiseases': ['고혈압'],
    'emergencyContact': {
      'name': '김영희',
      'relationship': '배우자',
      'phone': '010-9876-5432',
    },
    'emergencyContact2': {
      'name': '홍부모',
      'relationship': '부모',
      'phone': '010-1111-2222',
    },
  };

  // 즐겨찾는 병원 데이터
  List<Map<String, dynamic>> _favoriteHospitals = [
    {
      'id': 1,
      'name': '아인병원',
      'address': '서울시 강남구 논현동',
      'phone': '02-1234-5678',
      'department': '내과',
      'doctor': '김의사',
      'rating': 4.5,
      'visitCount': 5,
    },
    {
      'id': 2,
      'name': '서울대병원',
      'address': '서울시 종로구 연건동',
      'phone': '02-2000-0000',
      'department': '정형외과',
      'doctor': '이의사',
      'rating': 4.8,
      'visitCount': 3,
    },
  ];

  // 알림 설정 데이터
  Map<String, bool> _notificationSettings = {
    'medicationReminders': true,
    'appointmentReminders': true,
    'healthTips': false,
    'systemNotifications': true,
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 로컬 저장소에서 사용자 데이터 불러오기
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // 사용자 정보 불러오기
    final userInfoJson = prefs.getString('user_info');
    if (userInfoJson != null) {
      setState(() {
        _userInfo = Map<String, dynamic>.from(jsonDecode(userInfoJson));
      });
    }

    // 건강 정보 불러오기
    final healthInfoJson = prefs.getString('health_info');
    if (healthInfoJson != null) {
      setState(() {
        _healthInfo = Map<String, dynamic>.from(jsonDecode(healthInfoJson));
      });
    }

    // 즐겨찾는 병원 불러오기
    final hospitalsJson = prefs.getString('favorite_hospitals');
    if (hospitalsJson != null) {
      setState(() {
        _favoriteHospitals = List<Map<String, dynamic>>.from(jsonDecode(hospitalsJson));
      });
    }

    // 알림 설정 불러오기
    final notificationsJson = prefs.getString('notification_settings');
    if (notificationsJson != null) {
      setState(() {
        _notificationSettings = Map<String, bool>.from(jsonDecode(notificationsJson));
      });
    }
  }

  // 로컬 저장소에 사용자 데이터 저장
  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_info', jsonEncode(_userInfo));
    await prefs.setString('health_info', jsonEncode(_healthInfo));
    await prefs.setString('favorite_hospitals', jsonEncode(_favoriteHospitals));
    await prefs.setString('notification_settings', jsonEncode(_notificationSettings));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '내 정보',
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
            icon: const Icon(Icons.settings, color: Color(0xFF4A90E2)),
            onPressed: _showMoreSettings,
            tooltip: '설정',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사용자 프로필 카드
            _buildProfileCard(),
            const SizedBox(height: 20),

            // 건강 정보 카드 (응급연락처 포함)
            _buildHealthInfoCard(),
            const SizedBox(height: 20),

            // 즐겨찾는 병원 카드
            _buildFavoriteHospitalsCard(),
            const SizedBox(height: 20),

            // 설정 및 기타 옵션 (보안설정 제거됨)
            _buildSettingsCard(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 프로필 사진 및 기본 정보
            Row(
              children: [
                // 프로필 사진
                GestureDetector(
                  onTap: _changeProfilePhoto,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A90E2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: const Color(0xFF4A90E2),
                        width: 2,
                      ),
                    ),
                    child: _userInfo['profileImage'] != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(38),
                      child: Image.network(
                        _userInfo['profileImage'],
                        fit: BoxFit.cover,
                      ),
                    )
                        : const Icon(
                      Icons.person,
                      size: 40,
                      color: Color(0xFF4A90E2),
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // 사용자 기본 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userInfo['name'] ?? '사용자',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userInfo['email'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A90E2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '환자',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF4A90E2),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(color: Color(0xFFE0E0E0)),
            const SizedBox(height: 16),

            // 상세 정보
            _buildInfoItem(Icons.phone_outlined, '전화번호', _userInfo['phone'] ?? ''),
            _buildInfoItem(Icons.location_on_outlined, '주소', _userInfo['address'] ?? ''),

            const SizedBox(height: 16),

            // 수정 버튼
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _editProfile,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('프로필 수정'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthInfoCard() {
    return Container(
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '건강 정보',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                IconButton(
                  onPressed: _editHealthInfo,
                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF4A90E2)),
                  tooltip: '건강 정보 수정',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 신체 정보
            Row(
              children: [
                Expanded(
                  child: _buildHealthInfoItem(
                    '혈액형',
                    _userInfo['bloodType'] ?? 'A+',
                    Icons.bloodtype,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildHealthInfoItem(
                    '키/몸무게',
                    '${_userInfo['height'] ?? "미입력"}cm / ${_userInfo['weight'] ?? "미입력"}kg',
                    Icons.height,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 알레르기 정보
            _buildHealthSection('알레르기', _healthInfo['allergies'] ?? []),
            const SizedBox(height: 12),

            // 만성질환 정보
            _buildHealthSection('만성질환', _healthInfo['chronicDiseases'] ?? []),
            const SizedBox(height: 16),

            // 응급연락처 섹션 (새로 추가)
            _buildEmergencyContactSection(),
          ],
        ),
      ),
    );
  }

  // 응급연락처 섹션 (새로 추가)
  Widget _buildEmergencyContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '응급연락처',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            IconButton(
              onPressed: _editEmergencyContacts,
              icon: const Icon(Icons.edit_outlined,
                  color: Color(0xFF4A90E2), size: 20),
              tooltip: '응급연락처 수정',
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 1차 응급연락처
        if (_healthInfo['emergencyContact'] != null) ...[
          _buildEmergencyContactItem(
            '1차 연락처',
            _healthInfo['emergencyContact']['name'] ?? '',
            _healthInfo['emergencyContact']['relationship'] ?? '',
            _healthInfo['emergencyContact']['phone'] ?? '',
            Icons.person,
          ),
          const SizedBox(height: 8),
        ],

        // 2차 응급연락처
        if (_healthInfo['emergencyContact2'] != null) ...[
          _buildEmergencyContactItem(
            '2차 연락처',
            _healthInfo['emergencyContact2']['name'] ?? '',
            _healthInfo['emergencyContact2']['relationship'] ?? '',
            _healthInfo['emergencyContact2']['phone'] ?? '',
            Icons.person_outline,
          ),
        ],
      ],
    );
  }

  Widget _buildEmergencyContactItem(String label, String name, String relationship, String phone, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4A90E2), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label: $name ($relationship)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _callEmergencyContact(phone),
            icon: const Icon(Icons.call, color: Color(0xFF4CAF50), size: 20),
            tooltip: '전화걸기',
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteHospitalsCard() {
    return Container(
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '즐겨찾는 병원',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                TextButton(
                  onPressed: _manageFavoriteHospitals,
                  child: const Text('관리'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_favoriteHospitals.isEmpty) ...[
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.local_hospital_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '즐겨찾는 병원이 없습니다',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _favoriteHospitals.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final hospital = _favoriteHospitals[index];
                  return _buildHospitalItem(hospital);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 설정 카드 (보안설정 제거됨)
  Widget _buildSettingsCard() {
    return Container(
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '설정 및 기타',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 16),

            // 알림 설정
            _buildSettingItem(
              Icons.notifications_outlined,
              '알림 설정',
              '복약, 예약 알림 등',
                  () => _showNotificationSettings(),
            ),

            const Divider(height: 32, color: Color(0xFFE0E0E0)),

            // 이용 안내
            _buildSettingItem(
              Icons.help_outline,
              '이용 안내',
              '앱 사용법 및 FAQ',
                  () => _showAppGuide(),
            ),

            // 앱 정보
            _buildSettingItem(
              Icons.info_outline,
              '앱 정보',
              '버전, 업데이트 정보',
                  () => _showAppInfo(),
            ),

            const Divider(height: 32, color: Color(0xFFE0E0E0)),

            // 로그아웃
            _buildSettingItem(
              Icons.logout,
              '로그아웃',
              '',
                  () => _showLogoutDialog(),
              textColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthInfoItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF4A90E2), size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthSection(String title, List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        if (items.isEmpty) ...[
          Text(
            '없음',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
        ] else ...[
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: items.map<Widget>((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4A90E2),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildHospitalItem(Map<String, dynamic> hospital) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_hospital, color: Color(0xFF4A90E2)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hospital['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${hospital['department']} | ${hospital['doctor']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.star, size: 12, color: Colors.amber[600]),
                    const SizedBox(width: 2),
                    Text(
                      '${hospital['rating']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '방문 ${hospital['visitCount']}회',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle, VoidCallback onTap, {Color? textColor}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: textColor ?? Colors.grey[700]),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor ?? const Color(0xFF1A1A1A),
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  // 응급연락처 수정 기능 (새로 추가)
  void _editEmergencyContacts() {
    showDialog(
      context: context,
      builder: (context) => _EmergencyContactEditDialog(
        healthInfo: _healthInfo,
        onSaved: (updatedHealthInfo) {
          setState(() {
            _healthInfo = updatedHealthInfo;
          });
          _saveUserData();
        },
      ),
    );
  }

  // 응급연락처로 전화걸기 (새로 추가)
  void _callEmergencyContact(String phoneNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('전화걸기'),
        content: Text('$phoneNumber로 전화를 거시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 실제 앱에서는 url_launcher를 사용하여 전화 앱 실행
              // launch('tel:$phoneNumber');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$phoneNumber로 전화를 겁니다')),
              );
            },
            child: const Text('전화걸기'),
          ),
        ],
      ),
    );
  }

  void _changeProfilePhoto() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '프로필 사진 변경',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라로 촬영'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('카메라 기능은 준비 중입니다')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리에서 선택'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('갤러리 기능은 준비 중입니다')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) => _ProfileEditDialog(
        userInfo: _userInfo,
        onSaved: (updatedUserInfo) {
          setState(() {
            _userInfo = updatedUserInfo;
          });
          _saveUserData();
        },
      ),
    );
  }

  void _editHealthInfo() {
    showDialog(
      context: context,
      builder: (context) => _HealthInfoEditDialog(
        userInfo: _userInfo,
        healthInfo: _healthInfo,
        onSaved: (updatedUserInfo, updatedHealthInfo) {
          setState(() {
            _userInfo = updatedUserInfo;
            _healthInfo = updatedHealthInfo;
          });
          _saveUserData();
        },
      ),
    );
  }

  void _manageFavoriteHospitals() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: Center(
            child: Text('즐겨찾는 병원 관리 화면은 준비 중입니다'),
          ),
        ),
      ),
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => _NotificationSettingsDialog(
        notificationSettings: _notificationSettings,
        onSaved: (updatedSettings) {
          setState(() {
            _notificationSettings = updatedSettings;
          });
          _saveUserData();
        },
      ),
    );
  }

  void _showMoreSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '더보기 설정',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('언어 설정'),
              subtitle: const Text('한국어'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('언어 설정 기능은 준비 중입니다')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('다크 모드'),
              subtitle: const Text('밝은 모드'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('다크 모드 기능은 준비 중입니다')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAppGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이용 안내'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '메디핏 앱 사용법',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 12),
              Text('1. 복약 관리\n   - 복용 중인 약물 관리\n   - 복약 알림 및 일정 추적\n'),
              Text('2. 진료기록 확인\n   - 과거 진료 내역 조회\n   - 처방전 및 진단 정보 저장\n'),
              Text('3. 예약 관리\n   - 병원 예약 및 일정 관리\n   - 알림 설정으로 놓치지 않기'),
              SizedBox(height: 16),
              Text(
                '문의하기',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('이메일: support@medifit.com'),
              Text('전화: 1588-0000'),
              Text('운영시간: 평일 09:00-18:00'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showAppInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱 정보'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '메디핏 - 환자용',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('버전: 1.0.0'),
            SizedBox(height: 8),
            Text('최신 업데이트: 2025.08.28'),
            SizedBox(height: 8),
            Text('개발: 메디핏팀'),
            SizedBox(height: 16),
            Text(
              '건강한 삶을 위한 의료 파트너',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '© 2025 MediFit. All rights reserved.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?\n\n저장되지 않은 데이터는 손실될 수 있습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 실제 로그아웃 처리
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('로그아웃 되었습니다')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('로그아웃', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// 응급연락처 수정 다이얼로그 (새로 추가)
class _EmergencyContactEditDialog extends StatefulWidget {
  final Map<String, dynamic> healthInfo;
  final Function(Map<String, dynamic>) onSaved;

  const _EmergencyContactEditDialog({
    required this.healthInfo,
    required this.onSaved,
  });

  @override
  State<_EmergencyContactEditDialog> createState() => _EmergencyContactEditDialogState();
}

class _EmergencyContactEditDialogState extends State<_EmergencyContactEditDialog> {
  late Map<String, dynamic> _tempHealthInfo;
  final _formKey = GlobalKey<FormState>();

  final _contact1NameController = TextEditingController();
  final _contact1RelationshipController = TextEditingController();
  final _contact1PhoneController = TextEditingController();

  final _contact2NameController = TextEditingController();
  final _contact2RelationshipController = TextEditingController();
  final _contact2PhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tempHealthInfo = Map<String, dynamic>.from(widget.healthInfo);

    // 1차 연락처 초기값 설정
    if (_tempHealthInfo['emergencyContact'] != null) {
      _contact1NameController.text = _tempHealthInfo['emergencyContact']['name'] ?? '';
      _contact1RelationshipController.text = _tempHealthInfo['emergencyContact']['relationship'] ?? '';
      _contact1PhoneController.text = _tempHealthInfo['emergencyContact']['phone'] ?? '';
    }

    // 2차 연락처 초기값 설정
    if (_tempHealthInfo['emergencyContact2'] != null) {
      _contact2NameController.text = _tempHealthInfo['emergencyContact2']['name'] ?? '';
      _contact2RelationshipController.text = _tempHealthInfo['emergencyContact2']['relationship'] ?? '';
      _contact2PhoneController.text = _tempHealthInfo['emergencyContact2']['phone'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('응급연락처 수정'),
      content: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 500),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1차 응급연락처
                const Text(
                  '1차 응급연락처',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contact1NameController,
                  decoration: const InputDecoration(
                    labelText: '이름',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? '이름을 입력하세요' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contact1RelationshipController,
                  decoration: const InputDecoration(
                    labelText: '관계',
                    hintText: '예: 배우자, 부모, 자녀',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? '관계를 입력하세요' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contact1PhoneController,
                  decoration: const InputDecoration(
                    labelText: '전화번호',
                    hintText: '010-1234-5678',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value?.isEmpty ?? true ? '전화번호를 입력하세요' : null,
                ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),

                // 2차 응급연락처
                const Text(
                  '2차 응급연락처 (선택사항)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contact2NameController,
                  decoration: const InputDecoration(
                    labelText: '이름',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contact2RelationshipController,
                  decoration: const InputDecoration(
                    labelText: '관계',
                    hintText: '예: 배우자, 부모, 자녀',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contact2PhoneController,
                  decoration: const InputDecoration(
                    labelText: '전화번호',
                    hintText: '010-1234-5678',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _saveEmergencyContacts,
          child: const Text('저장'),
        ),
      ],
    );
  }

  void _saveEmergencyContacts() {
    if (_formKey.currentState!.validate()) {
      // 1차 연락처 저장
      _tempHealthInfo['emergencyContact'] = {
        'name': _contact1NameController.text,
        'relationship': _contact1RelationshipController.text,
        'phone': _contact1PhoneController.text,
      };

      // 2차 연락처 저장 (입력된 경우에만)
      if (_contact2NameController.text.isNotEmpty ||
          _contact2RelationshipController.text.isNotEmpty ||
          _contact2PhoneController.text.isNotEmpty) {
        _tempHealthInfo['emergencyContact2'] = {
          'name': _contact2NameController.text,
          'relationship': _contact2RelationshipController.text,
          'phone': _contact2PhoneController.text,
        };
      } else {
        _tempHealthInfo.remove('emergencyContact2');
      }

      widget.onSaved(_tempHealthInfo);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('응급연락처가 저장되었습니다'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    }
  }
}

// 기존 다이얼로그들...
class _ProfileEditDialog extends StatefulWidget {
  final Map<String, dynamic> userInfo;
  final Function(Map<String, dynamic>) onSaved;

  const _ProfileEditDialog({required this.userInfo, required this.onSaved});

  @override
  State<_ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<_ProfileEditDialog> {
  late Map<String, dynamic> _tempUserInfo;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tempUserInfo = Map<String, dynamic>.from(widget.userInfo);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('프로필 수정'),
      content: Container(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _tempUserInfo['name'],
                decoration: const InputDecoration(labelText: '이름'),
                onSaved: (value) => _tempUserInfo['name'] = value,
                validator: (value) => value?.isEmpty ?? true ? '이름을 입력하세요' : null,
              ),
              TextFormField(
                initialValue: _tempUserInfo['phone'],
                decoration: const InputDecoration(labelText: '전화번호'),
                onSaved: (value) => _tempUserInfo['phone'] = value,
              ),
              TextFormField(
                initialValue: _tempUserInfo['address'],
                decoration: const InputDecoration(labelText: '주소'),
                onSaved: (value) => _tempUserInfo['address'] = value,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              widget.onSaved(_tempUserInfo);
              Navigator.pop(context);
            }
          },
          child: const Text('저장'),
        ),
      ],
    );
  }
}

class _HealthInfoEditDialog extends StatefulWidget {
  final Map<String, dynamic> userInfo;
  final Map<String, dynamic> healthInfo;
  final Function(Map<String, dynamic>, Map<String, dynamic>) onSaved;

  const _HealthInfoEditDialog({
    required this.userInfo,
    required this.healthInfo,
    required this.onSaved,
  });

  @override
  State<_HealthInfoEditDialog> createState() => _HealthInfoEditDialogState();
}

class _HealthInfoEditDialogState extends State<_HealthInfoEditDialog> {
  late Map<String, dynamic> _tempUserInfo;
  late Map<String, dynamic> _tempHealthInfo;

  @override
  void initState() {
    super.initState();
    _tempUserInfo = Map<String, dynamic>.from(widget.userInfo);
    _tempHealthInfo = Map<String, dynamic>.from(widget.healthInfo);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('건강 정보 수정'),
      content: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 신체 정보
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _tempUserInfo['height'],
                      decoration: const InputDecoration(labelText: '키 (cm)'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _tempUserInfo['height'] = value,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: _tempUserInfo['weight'],
                      decoration: const InputDecoration(labelText: '몸무게 (kg)'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _tempUserInfo['weight'] = value,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 혈액형
              DropdownButtonFormField<String>(
                value: _tempUserInfo['bloodType'],
                decoration: const InputDecoration(labelText: '혈액형'),
                items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) => setState(() => _tempUserInfo['bloodType'] = value),
              ),

              const SizedBox(height: 16),

              // 알레르기 (간단히 텍스트로 처리)
              TextFormField(
                initialValue: (_tempHealthInfo['allergies'] as List?)?.join(', '),
                decoration: const InputDecoration(
                  labelText: '알레르기',
                  hintText: '예: 페니실린, 견과류',
                ),
                onChanged: (value) {
                  _tempHealthInfo['allergies'] = value
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();
                },
              ),

              const SizedBox(height: 16),

              // 만성질환
              TextFormField(
                initialValue: (_tempHealthInfo['chronicDiseases'] as List?)?.join(', '),
                decoration: const InputDecoration(
                  labelText: '만성질환',
                  hintText: '예: 고혈압, 당뇨',
                ),
                onChanged: (value) {
                  _tempHealthInfo['chronicDiseases'] = value
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSaved(_tempUserInfo, _tempHealthInfo);
            Navigator.pop(context);
          },
          child: const Text('저장'),
        ),
      ],
    );
  }
}

class _NotificationSettingsDialog extends StatefulWidget {
  final Map<String, bool> notificationSettings;
  final Function(Map<String, bool>) onSaved;

  const _NotificationSettingsDialog({
    required this.notificationSettings,
    required this.onSaved,
  });

  @override
  State<_NotificationSettingsDialog> createState() => _NotificationSettingsDialogState();
}

class _NotificationSettingsDialogState extends State<_NotificationSettingsDialog> {
  late Map<String, bool> _tempSettings;

  @override
  void initState() {
    super.initState();
    _tempSettings = Map<String, bool>.from(widget.notificationSettings);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('알림 설정'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSwitchTile('복약 알림', 'medicationReminders'),
          _buildSwitchTile('예약 알림', 'appointmentReminders'),
          _buildSwitchTile('건강 팁', 'healthTips'),
          _buildSwitchTile('시스템 알림', 'systemNotifications'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSaved(_tempSettings);
            Navigator.pop(context);
          },
          child: const Text('저장'),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, String key) {
    return SwitchListTile(
      title: Text(title),
      value: _tempSettings[key] ?? false,
      onChanged: (value) => setState(() => _tempSettings[key] = value),
    );
  }
}