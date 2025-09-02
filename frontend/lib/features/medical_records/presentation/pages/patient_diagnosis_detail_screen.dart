// lib/features/medical_records/presentation/pages/patient_diagnosis_detail_screen.dart
import 'package:flutter/material.dart';

class PatientDiagnosisDetailScreen extends StatefulWidget {
  const PatientDiagnosisDetailScreen({super.key});

  @override
  State<PatientDiagnosisDetailScreen> createState() => _PatientDiagnosisDetailScreenState();
}

class _PatientDiagnosisDetailScreenState extends State<PatientDiagnosisDetailScreen> {
  int _selectedIndex = 0; // 0: 진료완료, 1: 예약취소

  final List<Map<String, dynamic>> _diagnosisRecords = [
    {
      'date': '2025-08-01',
      'time': '10:00~10:20',
      'department': '진료 과목 : 내과',
      'doctor': '진단명 : 감기',
      'doctorName': '진단의 : 김철수',
      'prescription': '처방 내역 : 타이레놀 500mg',
      'visitReason': '방문 목적 : 초진',
      'room': '병실 / 진료실 : 302호',
      'status': '진료완료',
    },
    {
      'date': '2025-08-02',
      'time': '10:20~10:40',
      'department': '진료 과목 : 내과',
      'doctor': '진단명 : 감기',
      'status': '예약취소',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '환자 진단기록',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: Color(0xFF1A1A1A),
          ),
          onPressed: () {
            // 메뉴 열기
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.tune,
              color: Color(0xFF1A1A1A),
            ),
            onPressed: () {
              // 필터 기능
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 병원명 헤더
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              'xx 병원',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),

          // 환자 정보 헤더
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text(
                  '홍길동 (남) / 29',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A90E2),
                  ),
                ),
                const Spacer(),
                const Text(
                  '2508-37-001',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4A90E2),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 진료 정보 헤더
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  '진료 정보',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const Spacer(),
                // 진료완료/예약취소 버튼
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '진료완료',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.keyboard_arrow_up,
                  color: Color(0xFF666666),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 진료 기록 리스트
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _diagnosisRecords.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final record = _diagnosisRecords[index];
                return _buildDiagnosisCard(record);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisCard(Map<String, dynamic> record) {
    final isCompleted = record['status'] == '진료완료';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜와 상태
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: isCompleted ? const Color(0xFF4A90E2) : const Color(0xFFE53E3E),
              ),
              const SizedBox(width: 8),
              Text(
                record['date'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isCompleted ? const Color(0xFF4A90E2) : const Color(0xFFE53E3E),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted ? const Color(0xFF4A90E2) : const Color(0xFFE53E3E),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  record['status'],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isCompleted ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_down,
                color: const Color(0xFF666666),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 시간
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 16,
                color: Color(0xFF666666),
              ),
              const SizedBox(width: 8),
              Text(
                record['time'],
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),

          if (isCompleted) ...[
            const SizedBox(height: 16),

            // 상세 정보 (진료완료인 경우만)
            _buildDetailText(record['department']),
            const SizedBox(height: 8),
            _buildDetailText(record['doctor']),
            const SizedBox(height: 8),
            _buildDetailText(record['doctorName']),
            const SizedBox(height: 8),
            _buildDetailText(record['prescription']),
            const SizedBox(height: 8),
            _buildDetailText(record['visitReason']),
            const SizedBox(height: 8),
            _buildDetailText(record['room']),
          ] else ...[
            const SizedBox(height: 16),
            _buildDetailText(record['department']),
            const SizedBox(height: 8),
            _buildDetailText(record['doctor']),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF1A1A1A),
        height: 1.4,
      ),
    );
  }
}