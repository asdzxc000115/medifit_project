import 'package:flutter/material.dart';
import 'dart:async';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  // 예약 데이터
  final List<Map<String, dynamic>> _upcomingAppointments = [
    {
      'id': 1,
      'hospital': '아인병원',
      'department': '내과',
      'doctor': '김의사',
      'date': '2025-08-27',
      'time': '14:00',
      'status': '예약 확정',
      'phone': '02-1234-5678',
      'address': '서울시 강남구 논현동',
      'symptoms': '감기 증상, 열, 목 아픔',
    },
    {
      'id': 2,
      'hospital': '서울대병원',
      'department': '정형외과',
      'doctor': '이의사',
      'date': '2025-08-30',
      'time': '10:30',
      'status': '예약 대기',
      'phone': '02-2000-0000',
      'address': '서울시 종로구 연건동',
      'symptoms': '목 디스크, 목과 어깨 통증',
    },
  ];

  final List<Map<String, dynamic>> _pastAppointments = [
    {
      'id': 3,
      'hospital': '강남성모병원',
      'department': '내과',
      'doctor': '박의사',
      'date': '2025-08-20',
      'time': '15:00',
      'status': '진료 완료',
      'phone': '02-3333-4444',
      'address': '서울시 서초구 반포동',
      'diagnosis': '급성 위염',
      'prescription': ['위장약', '소화제'],
    },
    {
      'id': 4,
      'hospital': '삼성서울병원',
      'department': '피부과',
      'doctor': '최의사',
      'date': '2025-08-15',
      'time': '09:00',
      'status': '진료 완료',
      'phone': '02-5555-6666',
      'address': '서울시 강남구 일원동',
      'diagnosis': '아토피 피부염',
      'prescription': ['스테로이드 연고', '항히스타민제'],
    },
  ];

  // 주변 병원 데이터
  final List<Map<String, dynamic>> _nearbyHospitals = [
    {
      'id': 1,
      'name': '아인병원',
      'address': '서울시 강남구 논현동',
      'distance': '500m',
      'rating': 4.5,
      'departments': ['내과', '외과', '소아과', '이비인후과'],
      'phone': '02-1234-5678',
      'availableTimes': ['09:00', '10:00', '11:00', '14:00', '15:00'],
      'image': 'hospital_1',
    },
    {
      'id': 2,
      'name': '서울대병원',
      'address': '서울시 종로구 연건동',
      'distance': '2.3km',
      'rating': 4.8,
      'departments': ['내과', '외과', '정형외과', '신경과', '심장내과'],
      'phone': '02-2000-0000',
      'availableTimes': ['08:30', '09:30', '10:30', '13:30', '14:30'],
      'image': 'hospital_2',
    },
    {
      'id': 3,
      'name': '강남성모병원',
      'address': '서울시 서초구 반포동',
      'distance': '1.2km',
      'rating': 4.6,
      'departments': ['내과', '외과', '산부인과', '소아과', '정형외과'],
      'phone': '02-3333-4444',
      'availableTimes': ['09:00', '10:00', '13:00', '15:00', '16:00'],
      'image': 'hospital_3',
    },
    {
      'id': 4,
      'name': '삼성서울병원',
      'address': '서울시 강남구 일원동',
      'distance': '3.1km',
      'rating': 4.9,
      'departments': ['내과', '외과', '피부과', '성형외과', '암센터'],
      'phone': '02-5555-6666',
      'availableTimes': ['08:00', '09:00', '10:00', '14:00', '16:00'],
      'image': 'hospital_4',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '예약 관리',
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
            icon: const Icon(Icons.refresh, color: Color(0xFF4A90E2)),
            onPressed: _refreshAppointments,
            tooltip: '새로고침',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF4A90E2),
          indicatorWeight: 3,
          labelColor: const Color(0xFF4A90E2),
          unselectedLabelColor: const Color(0xFF9E9E9E),
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          tabs: const [
            Tab(text: '예정된 예약'),
            Tab(text: '지난 예약'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUpcomingAppointments(),
          _buildPastAppointments(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewAppointmentDialog,
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          '새 예약',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildUpcomingAppointments() {
    if (_upcomingAppointments.isEmpty) {
      return _buildEmptyState('예정된 예약이 없습니다', '새로운 병원 예약을 만들어보세요!');
    }

    return RefreshIndicator(
      onRefresh: _refreshAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _upcomingAppointments.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildUpcomingAppointmentCard(_upcomingAppointments[index]),
          );
        },
      ),
    );
  }

  Widget _buildPastAppointments() {
    if (_pastAppointments.isEmpty) {
      return _buildEmptyState('지난 예약이 없습니다', '첫 번째 병원 방문을 시작해보세요!');
    }

    return RefreshIndicator(
      onRefresh: _refreshAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pastAppointments.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildPastAppointmentCard(_pastAppointments[index]),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showNewAppointmentDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text(
              '새 예약 만들기',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointmentCard(Map<String, dynamic> appointment) {
    final isToday = _isToday(appointment['date']);
    final isTomorrow = _isTomorrow(appointment['date']);

    return GestureDetector(
      onTap: () => _showAppointmentDetail(appointment, isUpcoming: true),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isToday
                ? const Color(0xFF4CAF50)
                : isTomorrow
                ? const Color(0xFFFF9800)
                : const Color(0xFF4A90E2).withOpacity(0.2),
            width: isToday || isTomorrow ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상태 및 시급성 표시
            Row(
              children: [
                if (isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '오늘',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (isTomorrow)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '내일',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (isToday || isTomorrow) const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: appointment['status'] == '예약 확정'
                        ? const Color(0xFF4A90E2).withOpacity(0.1)
                        : const Color(0xFFFF9800).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appointment['status'],
                    style: TextStyle(
                      color: appointment['status'] == '예약 확정'
                          ? const Color(0xFF4A90E2)
                          : const Color(0xFFFF9800),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 병원 및 진료과 정보
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_hospital,
                    color: Color(0xFF4A90E2),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment['hospital'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${appointment['department']} · ${appointment['doctor']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 날짜 및 시간 정보
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 18,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_formatDetailDate(appointment['date'])} ${appointment['time']}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.location_on,
                    size: 18,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${appointment['address'].split(' ')[1]} ${appointment['address'].split(' ')[2]}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            // 증상 정보 (있는 경우만)
            if (appointment['symptoms'] != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.note_alt,
                      size: 18,
                      color: Color(0xFFFF9800),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '증상: ${appointment['symptoms']}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFE65100),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // 액션 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _callHospital(appointment['phone']),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4A90E2),
                      side: const BorderSide(color: Color(0xFF4A90E2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.phone, size: 16),
                    label: const Text(
                      '전화하기',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showRescheduleDialog(appointment),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.edit_calendar, size: 16),
                    label: const Text(
                      '변경하기',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastAppointmentCard(Map<String, dynamic> appointment) {
    return GestureDetector(
      onTap: () => _showAppointmentDetail(appointment, isUpcoming: false),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상태 표시
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appointment['status'],
                    style: const TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 병원 및 진료과 정보
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.local_hospital,
                    color: Colors.grey[600],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment['hospital'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${appointment['department']} · ${appointment['doctor']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 날짜 및 진단 정보
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 18,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_formatDetailDate(appointment['date'])} ${appointment['time']}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  if (appointment['diagnosis'] != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.medical_information,
                          size: 18,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '진단: ${appointment['diagnosis']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // 처방약 정보 (있는 경우만)
            if (appointment['prescription'] != null &&
                (appointment['prescription'] as List).isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.medication,
                          size: 18,
                          color: Color(0xFF4CAF50),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '처방약',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...((appointment['prescription'] as List<String>).map((med) =>
                        Padding(
                          padding: const EdgeInsets.only(left: 26, bottom: 4),
                          child: Text(
                            '• $med',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                    ).toList()),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // === 새 예약 기능 구현 ===
  void _showNewAppointmentDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.7,
        builder: (context, scrollController) => _buildNewAppointmentSheet(scrollController),
      ),
    );
  }

  Widget _buildNewAppointmentSheet(ScrollController scrollController) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.add_circle, color: Color(0xFF4A90E2), size: 28),
              const SizedBox(width: 12),
              const Text(
                '새 예약 만들기',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '원하는 병원을 찾아 예약을 진행하세요',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // 검색 바
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              decoration: const InputDecoration(
                hintText: '병원 이름이나 진료과목으로 검색...',
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.grey),
              ),
              onChanged: (value) {
                // 검색 기능 구현
                _filterHospitals(value);
              },
            ),
          ),
          const SizedBox(height: 20),

          // 빠른 필터
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('전체', true),
                const SizedBox(width: 8),
                _buildFilterChip('내과', false),
                const SizedBox(width: 8),
                _buildFilterChip('외과', false),
                const SizedBox(width: 8),
                _buildFilterChip('정형외과', false),
                const SizedBox(width: 8),
                _buildFilterChip('소아과', false),
                const SizedBox(width: 8),
                _buildFilterChip('피부과', false),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 병원 목록
          const Text(
            '주변 병원',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.separated(
              controller: scrollController,
              itemCount: _nearbyHospitals.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildHospitalSearchCard(_nearbyHospitals[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        // 필터 선택 로직 구현
        _applyDepartmentFilter(label);
      },
      selectedColor: const Color(0xFF4A90E2).withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF4A90E2) : Colors.grey[600],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildHospitalSearchCard(Map<String, dynamic> hospital) {
    return GestureDetector(
      onTap: () => _selectHospitalForBooking(hospital),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.local_hospital,
                    color: Color(0xFF4A90E2),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hospital['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hospital['address'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          hospital['rating'].toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hospital['distance'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: (hospital['departments'] as List<String>).take(4).map((dept) =>
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A90E2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      dept,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4A90E2),
                      ),
                    ),
                  ),
              ).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _callHospital(hospital['phone']),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF4A90E2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('전화하기'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectHospitalForBooking(hospital),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('예약하기'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // === 병원 선택 및 예약 프로세스 ===
  void _selectHospitalForBooking(Map<String, dynamic> hospital) {
    Navigator.pop(context); // 병원 선택 시트 닫기
    _showBookingProcessDialog(hospital);
  }

  void _showBookingProcessDialog(Map<String, dynamic> hospital) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.6,
        builder: (context, scrollController) => _buildBookingProcessSheet(hospital, scrollController),
      ),
    );
  }

  Widget _buildBookingProcessSheet(Map<String, dynamic> hospital, ScrollController scrollController) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 선택된 병원 정보
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_hospital, color: Color(0xFF4A90E2), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hospital['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A90E2),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hospital['address'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4A90E2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ListView(
              controller: scrollController,
              children: [
                // 진료과 선택
                _buildBookingStep(
                  '1단계',
                  '진료과 선택',
                  '받고 싶은 진료과를 선택해주세요',
                  Icons.medical_services,
                      () => _selectDepartment(hospital),
                ),
                const SizedBox(height: 16),

                // 의사 선택
                _buildBookingStep(
                  '2단계',
                  '의사 선택',
                  '담당받을 의사를 선택해주세요',
                  Icons.person,
                      () => _selectDoctor(hospital),
                ),
                const SizedBox(height: 16),

                // 날짜 선택
                _buildBookingStep(
                  '3단계',
                  '날짜 선택',
                  '진료받을 날짜를 선택해주세요',
                  Icons.calendar_today,
                      () => _selectDate(hospital),
                ),
                const SizedBox(height: 16),

                // 시간 선택
                _buildBookingStep(
                  '4단계',
                  '시간 선택',
                  '진료받을 시간을 선택해주세요',
                  Icons.access_time,
                      () => _selectTime(hospital),
                ),
                const SizedBox(height: 16),

                // 증상 입력
                _buildBookingStep(
                  '5단계',
                  '증상 입력',
                  '현재 증상을 간단히 적어주세요',
                  Icons.edit_note,
                      () => _inputSymptoms(hospital),
                ),
                const SizedBox(height: 32),

                // 예약 확정하기 버튼
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _confirmBooking(hospital),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '예약 확정하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingStep(String step, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF4A90E2), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        step,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // === 예약 단계별 구현 ===
  void _selectDepartment(Map<String, dynamic> hospital) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '진료과 선택',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: (hospital['departments'] as List<String>).length,
                itemBuilder: (context, index) {
                  final department = (hospital['departments'] as List<String>)[index];
                  return ListTile(
                    leading: const Icon(Icons.medical_services, color: Color(0xFF4A90E2)),
                    title: Text(department),
                    subtitle: Text('${hospital['name']} $department'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$department를 선택했습니다.'),
                          backgroundColor: const Color(0xFF4A90E2),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectDoctor(Map<String, dynamic> hospital) {
    final doctors = ['김의사', '이의사', '박의사', '최의사', '정의사'];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '의사 선택',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.person, color: Color(0xFF4A90E2)),
                    title: Text(doctors[index]),
                    subtitle: Text('전문의 · ${hospital['name']}'),
                    trailing: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text('4.8'),
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${doctors[index]}를 선택했습니다.'),
                          backgroundColor: const Color(0xFF4A90E2),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectDate(Map<String, dynamic> hospital) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4A90E2),
            ),
          ),
          child: child!,
        );
      },
    ).then((selectedDate) {
      if (selectedDate != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${selectedDate.month}/${selectedDate.day} 날짜를 선택했습니다.'),
            backgroundColor: const Color(0xFF4A90E2),
          ),
        );
      }
    });
  }

  void _selectTime(Map<String, dynamic> hospital) {
    final availableTimes = hospital['availableTimes'] as List<String>;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '시간 선택',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '예약 가능한 시간을 선택해주세요',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.5,
              children: availableTimes.map((time) =>
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$time 시간을 선택했습니다.'),
                          backgroundColor: const Color(0xFF4A90E2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2).withOpacity(0.1),
                      foregroundColor: const Color(0xFF4A90E2),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(time),
                  ),
              ).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _inputSymptoms(Map<String, dynamic> hospital) {
    final TextEditingController symptomsController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '증상 입력',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '현재 느끼는 증상을 간단히 적어주시면 진료에 도움이 됩니다.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: symptomsController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: '예: 목이 아프고 기침이 계속 나요...',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('증상을 입력했습니다.'),
                            backgroundColor: Color(0xFF4A90E2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                      ),
                      child: const Text('완료'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmBooking(Map<String, dynamic> hospital) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('예약 확정'),
        content: Text('${hospital['name']}에 예약을 확정하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              // 예약 데이터 추가
              setState(() {
                _upcomingAppointments.add({
                  'id': _upcomingAppointments.length + 1,
                  'hospital': hospital['name'],
                  'department': '내과', // 선택된 진료과
                  'doctor': '김의사', // 선택된 의사
                  'date': '2025-08-28', // 선택된 날짜
                  'time': '10:00', // 선택된 시간
                  'status': '예약 대기',
                  'phone': hospital['phone'],
                  'address': hospital['address'],
                  'symptoms': '목이 아프고 기침이 계속 나요',
                });
              });

              Navigator.pop(context); // 다이얼로그 닫기
              Navigator.pop(context); // 예약 프로세스 시트 닫기

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${hospital['name']} 예약이 완료되었습니다!'),
                  backgroundColor: const Color(0xFF4CAF50),
                  action: SnackBarAction(
                    label: '확인',
                    textColor: Colors.white,
                    onPressed: () {},
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('확정'),
          ),
        ],
      ),
    );
  }

  // === 유틸리티 메서드들 ===
  bool _isToday(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isTomorrow(String dateString) {
    final date = DateTime.parse(dateString);
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }

  String _formatDetailDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final diff = date.difference(now).inDays;

    if (diff == 0) return '오늘 (${date.month}/${date.day})';
    if (diff == 1) return '내일 (${date.month}/${date.day})';
    if (diff == 2) return '모레 (${date.month}/${date.day})';

    return '${date.month}월 ${date.day}일';
  }

  Future<void> _refreshAppointments() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        // 데이터 새로고침 로직
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('예약 목록을 새로고침했습니다.'),
          backgroundColor: Color(0xFF4A90E2),
        ),
      );
    }
  }

  void _filterHospitals(String query) {
    // 병원 검색 필터링 로직
    if (query.isEmpty) {
      // 전체 목록 표시
    } else {
      // 검색어에 맞는 병원 필터링
    }
  }

  void _applyDepartmentFilter(String department) {
    // 진료과별 병원 필터링 로직
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$department 필터를 적용했습니다.'),
        backgroundColor: const Color(0xFF4A90E2),
      ),
    );
  }

  void _callHospital(String phoneNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('전화 걸기'),
        content: Text('$phoneNumber로 전화를 걸까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$phoneNumber로 전화를 겁니다.'),
                  backgroundColor: const Color(0xFF4CAF50),
                ),
              );
            },
            child: const Text('전화하기'),
          ),
        ],
      ),
    );
  }

  void _showAppointmentDetail(Map<String, dynamic> appointment, {required bool isUpcoming}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${appointment['hospital']} 예약 상세',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('병원', appointment['hospital']),
                      _buildDetailRow('진료과', appointment['department']),
                      _buildDetailRow('담당의', appointment['doctor']),
                      _buildDetailRow('날짜', _formatDetailDate(appointment['date'])),
                      _buildDetailRow('시간', appointment['time']),
                      _buildDetailRow('상태', appointment['status']),
                      _buildDetailRow('연락처', appointment['phone']),
                      _buildDetailRow('주소', appointment['address']),

                      if (isUpcoming && appointment['symptoms'] != null)
                        _buildDetailRow('증상', appointment['symptoms']),

                      if (!isUpcoming) ...[
                        if (appointment['diagnosis'] != null)
                          _buildDetailRow('진단명', appointment['diagnosis']),
                        if (appointment['prescription'] != null &&
                            (appointment['prescription'] as List).isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            '처방약',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...((appointment['prescription'] as List<String>).map((med) =>
                              Padding(
                                padding: const EdgeInsets.only(left: 16, bottom: 4),
                                child: Row(
                                  children: [
                                    const Icon(Icons.medication, size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(med),
                                  ],
                                ),
                              ),
                          ).toList()),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              if (isUpcoming) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showRescheduleDialog(appointment);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFF9800)),
                        ),
                        child: const Text(
                          '일정 변경',
                          style: TextStyle(color: Color(0xFFFF9800)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showCancelDialog(appointment);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE53E3E)),
                        ),
                        child: const Text(
                          '예약 취소',
                          style: TextStyle(color: Color(0xFFE53E3E)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRescheduleDialog(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일정 변경'),
        content: Text('${appointment['hospital']} 예약 일정을 변경하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showDateTimePicker(appointment);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9800),
            ),
            child: const Text('변경하기'),
          ),
        ],
      ),
    );
  }

  void _showDateTimePicker(Map<String, dynamic> appointment) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF9800),
            ),
          ),
          child: child!,
        );
      },
    ).then((selectedDate) {
      if (selectedDate != null) {
        showTimePicker(
          context: context,
          initialTime: const TimeOfDay(hour: 10, minute: 0),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFFFF9800),
                ),
              ),
              child: child!,
            );
          },
        ).then((selectedTime) {
          if (selectedTime != null) {
            setState(() {
              final index = _upcomingAppointments.indexWhere((apt) => apt['id'] == appointment['id']);
              if (index != -1) {
                _upcomingAppointments[index]['date'] =
                '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
                _upcomingAppointments[index]['time'] =
                '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
                _upcomingAppointments[index]['status'] = '예약 변경됨';
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('예약 일정이 변경되었습니다.'),
                backgroundColor: Color(0xFFFF9800),
              ),
            );
          }
        });
      }
    });
  }

  void _showCancelDialog(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('예약 취소'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${appointment['hospital']} 예약을 취소하시겠습니까?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE5E5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Color(0xFFE53E3E), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '취소된 예약은 복구할 수 없습니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFE53E3E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('돌아가기'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _upcomingAppointments.removeWhere((apt) => apt['id'] == appointment['id']);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('예약이 취소되었습니다.'),
                  backgroundColor: Color(0xFFE53E3E),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
            ),
            child: const Text('예, 취소합니다'),
          ),
        ],
      ),
    );
  }
}