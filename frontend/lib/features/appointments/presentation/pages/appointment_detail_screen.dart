import 'package:flutter/material.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 임시 예약 데이터
  final List<Map<String, dynamic>> _upcomingAppointments = [
    {
      'id': 1,
      'date': '2025-08-27',
      'time': '14:00 - 14:30',
      'hospital': '아인병원',
      'department': '내과',
      'doctor': '김의사',
      'status': '예약 확정',
      'statusColor': Color(0xFF4A90E2),
      'address': '서울시 강남구 테헤란로 123',
      'phone': '02-1234-5678',
    },
    {
      'id': 2,
      'date': '2025-08-30',
      'time': '10:30 - 11:00',
      'hospital': '서울대병원',
      'department': '정형외과',
      'doctor': '이의사',
      'status': '예약 대기',
      'statusColor': Color(0xFFFFB347),
      'address': '서울시 종로구 대학로 101',
      'phone': '02-2000-0000',
    },
  ];

  final List<Map<String, dynamic>> _pastAppointments = [
    {
      'id': 3,
      'date': '2025-07-28',
      'time': '09:00 - 09:30',
      'hospital': '연세병원',
      'department': '안과',
      'doctor': '박의사',
      'status': '진료 완료',
      'statusColor': Color(0xFF4CAF50),
      'diagnosis': '안구건조증',
      'prescription': '인공눈물',
    },
    {
      'id': 4,
      'date': '2025-07-15',
      'time': '15:30 - 16:00',
      'hospital': '고려병원',
      'department': '피부과',
      'doctor': '최의사',
      'status': '진료 완료',
      'statusColor': Color(0xFF4CAF50),
      'diagnosis': '아토피 피부염',
      'prescription': '스테로이드 연고',
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
            icon: const Icon(Icons.add, color: Color(0xFF4A90E2)),
            onPressed: _showBookAppointmentDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4A90E2),
          unselectedLabelColor: const Color(0xFF666666),
          indicatorColor: const Color(0xFF4A90E2),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
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
    );
  }

  Widget _buildUpcomingAppointments() {
    if (_upcomingAppointments.isEmpty) {
      return _buildEmptyState(
        icon: Icons.calendar_month,
        title: '예정된 예약이 없습니다',
        subtitle: '새로운 예약을 만들어보세요',
        buttonText: '예약하기',
        onPressed: _showBookAppointmentDialog,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _upcomingAppointments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final appointment = _upcomingAppointments[index];
        return _buildAppointmentCard(
          appointment: appointment,
          isUpcoming: true,
        );
      },
    );
  }

  Widget _buildPastAppointments() {
    if (_pastAppointments.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history,
        title: '지난 예약이 없습니다',
        subtitle: '병원 방문 후 기록이 여기에 나타납니다',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _pastAppointments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final appointment = _pastAppointments[index];
        return _buildAppointmentCard(
          appointment: appointment,
          isUpcoming: false,
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: const Color(0xFFE0E0E0),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF999999),
              ),
            ),
            if (buttonText != null && onPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard({
    required Map<String, dynamic> appointment,
    required bool isUpcoming,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (appointment['statusColor'] as Color).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 (날짜 및 상태)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(appointment['date']),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (appointment['statusColor'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  appointment['status'],
                  style: TextStyle(
                    color: appointment['statusColor'],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 시간
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Color(0xFF666666)),
              const SizedBox(width: 6),
              Text(
                appointment['time'],
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 병원 및 진료과
          Row(
            children: [
              const Icon(Icons.local_hospital, size: 16, color: Color(0xFF666666)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${appointment['hospital']} - ${appointment['department']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 의사
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: Color(0xFF666666)),
              const SizedBox(width: 6),
              Text(
                appointment['doctor'],
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),

          // 과거 예약인 경우 진단 정보 추가
          if (!isUpcoming) ...[
            if (appointment['diagnosis'] != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '진단',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment['diagnosis'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    if (appointment['prescription'] != null) ...[
                      const SizedBox(height: 8),
                      const Text(
                        '처방',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment['prescription'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],

          // 예정된 예약인 경우 액션 버튼들
          if (isUpcoming) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showCancelDialog(appointment),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE53E3E)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '예약 취소',
                      style: TextStyle(color: Color(0xFFE53E3E), fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showRescheduleDialog(appointment),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '일정 변경',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final diff = date.difference(now).inDays;

    if (diff == 0) return '오늘';
    if (diff == 1) return '내일';
    if (diff == -1) return '어제';

    return '${date.month}월 ${date.day}일';
  }

  void _showBookAppointmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 예약'),
        content: const Text('병원 검색 화면으로 이동하여\n원하는 병원에 예약하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 주변 병원 찾기 화면으로 이동
              Navigator.pushNamed(context, '/nearby-hospitals');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
            ),
            child: const Text('병원 찾기', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('예약 취소'),
        content: Text(
          '${appointment['hospital']} ${appointment['department']} 예약을 취소하시겠습니까?\n\n'
              '취소 후에는 복구할 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('아니오'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _upcomingAppointments.removeWhere((item) => item['id'] == appointment['id']);
              });
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
            child: const Text('네, 취소합니다', style: TextStyle(color: Colors.white)),
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
        content: Text(
          '${appointment['hospital']} 예약 일정을 변경하시겠습니까?\n\n'
              '병원에 직접 연락하여 변경 가능한 시간을 확인하세요.\n\n'
              '📞 ${appointment['phone']}',
        ),
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
                  content: Text('${appointment['hospital']}에 연락하여 일정을 변경해주세요.'),
                  backgroundColor: const Color(0xFF4A90E2),
                  action: SnackBarAction(
                    label: '전화걸기',
                    textColor: Colors.white,
                    onPressed: () {
                      // 전화 앱 실행 기능
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('전화 앱 실행 기능은 개발 중입니다.'),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}