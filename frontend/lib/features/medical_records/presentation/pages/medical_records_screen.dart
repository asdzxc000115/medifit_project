import 'package:flutter/material.dart';
import 'dart:async';

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedDepartmentFilter = '전체';
  String _selectedPeriodFilter = '전체';

  // 진료기록 데이터
  final List<Map<String, dynamic>> _allMedicalRecords = [
    {
      'id': 1,
      'date': '2025-08-20',
      'time': '14:30',
      'hospital': '아인병원',
      'doctor': '김의사',
      'department': '내과',
      'diagnosis': '급성 감기, 인후염',
      'symptoms': '발열(38.5°C), 기침, 목 아픔, 콧물, 두통',
      'treatment': '대증 치료, 충분한 수분 섭취 및 휴식',
      'prescription': [
        '타이레놀 500mg - 발열 시 복용',
        '덱스트로메토르판 - 기침 완화',
        '목캔디 - 목 아픔 완화',
        '종합감기약 - 1일 3회 식후 복용'
      ],
      'nextVisit': '2025-08-27',
      'medicalFee': 15000,
      'notes': '충분한 휴식과 수분 섭취가 필요합니다. 증상이 악화되면 재방문하세요.',
      'status': '완료',
      'severity': 'low', // low, medium, high
    },
    {
      'id': 2,
      'date': '2025-08-15',
      'time': '10:00',
      'hospital': '서울대병원',
      'doctor': '이의사',
      'department': '정형외과',
      'diagnosis': '목 디스크(경추간판탈출증)',
      'symptoms': '목과 어깨 통증, 팔 저림, 두통',
      'treatment': '물리치료, 견인치료, 자세 교정',
      'prescription': [
        '이부프로펜 200mg - 소염진통제',
        '근육이완제 - 근육 긴장 완화',
        '신경비타민 - 신경 회복',
        '파스 - 국소 진통'
      ],
      'nextVisit': '2025-09-15',
      'medicalFee': 85000,
      'notes': '컴퓨터 사용 시 자세 교정이 필요하며, 물리치료를 꾸준히 받으세요. 무거운 물건 들지 마세요.',
      'status': '치료 중',
      'severity': 'high',
    },
    {
      'id': 3,
      'date': '2025-08-10',
      'time': '15:20',
      'hospital': '강남성모병원',
      'doctor': '박의사',
      'department': '안과',
      'diagnosis': '안구건조증, 컴퓨터 시각 증후군',
      'symptoms': '눈 건조함, 따가움, 시야 흐림, 눈 피로',
      'treatment': '인공눈물 점안, 눈 휴식, 환경 개선',
      'prescription': [
        '히알론산 인공눈물 - 1일 4-6회',
        '비타민A 안약 - 취침 전 점안',
        '오메가3 - 눈 건강 보조제'
      ],
      'nextVisit': '2025-11-10',
      'medicalFee': 25000,
      'notes': '50-20-20 규칙을 지켜주세요. (50분 작업 후 20초간 20피트 거리 응시)',
      'status': '완료',
      'severity': 'medium',
    },
    {
      'id': 4,
      'date': '2025-07-25',
      'time': '09:30',
      'hospital': '연세세브란스병원',
      'doctor': '최의사',
      'department': '피부과',
      'diagnosis': '아토피 피부염, 알레르기 접촉성 피부염',
      'symptoms': '피부 가려움증, 발진, 건조함, 염증',
      'treatment': '보습제 사용, 알레르겐 회피, 스테로이드 치료',
      'prescription': [
        '하이드로코르티손 연고 - 염증 부위 도포',
        '항히스타민제 - 가려움 완화',
        '세라마이드 보습제 - 1일 2-3회 도포'
      ],
      'nextVisit': null,
      'medicalFee': 35000,
      'notes': '목욕 후 즉시 보습제를 발라주시고, 자극적인 섬유유연제나 세제 사용을 피하세요.',
      'status': '완료',
      'severity': 'medium',
    },
    {
      'id': 5,
      'date': '2025-07-10',
      'time': '11:15',
      'hospital': '삼성서울병원',
      'doctor': '정의사',
      'department': '심장내과',
      'diagnosis': '고혈압, 고지혈증',
      'symptoms': '두통, 어지러움, 가슴 답답함',
      'treatment': '약물치료, 식이요법, 운동요법',
      'prescription': [
        '아모디핀 5mg - 혈압약 1일 1회',
        '아토르바스타틴 20mg - 콜레스테롤 약',
        '아스피린 100mg - 혈전 예방'
      ],
      'nextVisit': '2025-10-10',
      'medicalFee': 45000,
      'notes': '규칙적인 운동과 저염식이 중요합니다. 혈압 수치를 꾸준히 체크하세요.',
      'status': '치료 중',
      'severity': 'high',
    },
    {
      'id': 6,
      'date': '2025-06-28',
      'time': '13:45',
      'hospital': '가톨릭대학교 서울성모병원',
      'doctor': '김의사',
      'department': '소화기내과',
      'diagnosis': '위염, 역류성 식도염',
      'symptoms': '속쓰림, 소화불량, 가슴 쓰림',
      'treatment': '위산분비억제제 복용, 식이요법',
      'prescription': [
        '오메프라졸 20mg - 위산억제제',
        '소화효소제 - 소화 개선',
        '위점막 보호제 - 위 보호'
      ],
      'nextVisit': null,
      'medicalFee': 28000,
      'notes': '맵고 자극적인 음식을 피하고, 식사 후 바로 눕지 마세요. 금연과 금주가 필요합니다.',
      'status': '완료',
      'severity': 'medium',
    },
  ];

  List<Map<String, dynamic>> _filteredRecords = [];
  final List<String> _departments = ['전체', '내과', '외과', '정형외과', '안과', '피부과', '심장내과', '소화기내과'];
  final List<String> _periods = ['전체', '최근 1개월', '최근 3개월', '최근 6개월', '최근 1년'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _filteredRecords = List.from(_allMedicalRecords);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredRecords = _allMedicalRecords.where((record) {
        // 검색어 필터
        bool matchesSearch = _searchQuery.isEmpty ||
            record['hospital'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            record['diagnosis'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            record['department'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            record['doctor'].toString().toLowerCase().contains(_searchQuery.toLowerCase());

        // 진료과 필터
        bool matchesDepartment = _selectedDepartmentFilter == '전체' ||
            record['department'] == _selectedDepartmentFilter;

        // 기간 필터
        bool matchesPeriod = true;
        if (_selectedPeriodFilter != '전체') {
          final recordDate = DateTime.parse(record['date']);
          final now = DateTime.now();
          switch (_selectedPeriodFilter) {
            case '최근 1개월':
              matchesPeriod = recordDate.isAfter(now.subtract(const Duration(days: 30)));
              break;
            case '최근 3개월':
              matchesPeriod = recordDate.isAfter(now.subtract(const Duration(days: 90)));
              break;
            case '최근 6개월':
              matchesPeriod = recordDate.isAfter(now.subtract(const Duration(days: 180)));
              break;
            case '최근 1년':
              matchesPeriod = recordDate.isAfter(now.subtract(const Duration(days: 365)));
              break;
          }
        }

        return matchesSearch && matchesDepartment && matchesPeriod;
      }).toList();

      // 날짜순 정렬 (최신순)
      _filteredRecords.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '진료 기록',
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
            icon: const Icon(Icons.filter_list, color: Color(0xFF4A90E2)),
            onPressed: _showFilterDialog,
            tooltip: '필터',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF4A90E2)),
            onPressed: _refreshRecords,
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
            Tab(text: '전체'),
            Tab(text: '치료 중'),
            Tab(text: '완료'),
          ],
        ),
      ),
      body: Column(
        children: [
          // 검색 바
          _buildSearchBar(),

          // 필터 칩들
          _buildFilterChips(),

          // 탭바 내용
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRecordsList(_filteredRecords),
                _buildRecordsList(_filteredRecords.where((r) => r['status'] == '치료 중').toList()),
                _buildRecordsList(_filteredRecords.where((r) => r['status'] == '완료').toList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: '병원명, 진단명, 진료과, 의사명으로 검색...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey),
          suffixIcon: null,
        ),
        onChanged: (value) {
          // _onSearchChanged에서 처리
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // 진료과 필터
          _buildFilterChip(
            '진료과: $_selectedDepartmentFilter',
                () => _showDepartmentFilter(),
          ),
          const SizedBox(width: 8),
          // 기간 필터
          _buildFilterChip(
            '기간: $_selectedPeriodFilter',
                () => _showPeriodFilter(),
          ),
          const SizedBox(width: 8),
          // 필터 리셋
          if (_selectedDepartmentFilter != '전체' || _selectedPeriodFilter != '전체')
            _buildFilterChip(
              '필터 초기화',
                  () => _resetFilters(),
              isReset: true,
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onTap, {bool isReset = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isReset
              ? const Color(0xFFE53E3E).withOpacity(0.1)
              : const Color(0xFF4A90E2).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isReset
                ? const Color(0xFFE53E3E).withOpacity(0.3)
                : const Color(0xFF4A90E2).withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isReset ? const Color(0xFFE53E3E) : const Color(0xFF4A90E2),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildRecordsList(List<Map<String, dynamic>> records) {
    if (records.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshRecords,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: records.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildMedicalRecordCard(records[index]),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_information_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '진료 기록이 없습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '병원 진료를 받으시면 기록이 여기에 표시됩니다',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalRecordCard(Map<String, dynamic> record) {
    final isOngoing = record['status'] == '치료 중';
    final severity = record['severity'] as String;
    Color severityColor;

    switch (severity) {
      case 'high':
        severityColor = const Color(0xFFE53E3E);
        break;
      case 'medium':
        severityColor = const Color(0xFFFF9800);
        break;
      default:
        severityColor = const Color(0xFF4CAF50);
    }

    return GestureDetector(
      onTap: () => _showMedicalRecordDetail(record),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isOngoing
              ? Border.all(color: const Color(0xFF4A90E2), width: 2)
              : Border.all(color: Colors.grey[200]!),
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
            // 헤더 (상태, 심각도, 날짜)
            Row(
              children: [
                // 심각도 표시
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: severityColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),

                // 상태 배지
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOngoing
                        ? const Color(0xFF4A90E2).withOpacity(0.1)
                        : const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    record['status'],
                    style: TextStyle(
                      color: isOngoing ? const Color(0xFF4A90E2) : const Color(0xFF4CAF50),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const Spacer(),

                // 날짜
                Text(
                  _formatDate(record['date']),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(width: 8),
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
                    color: severityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.local_hospital,
                    color: severityColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record['hospital'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${record['department']} · ${record['doctor']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${record['time']} 방문',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 진단명
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: severityColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.medical_information,
                    size: 18,
                    color: severityColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '진단명',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          record['diagnosis'],
                          style: TextStyle(
                            fontSize: 14,
                            color: severityColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 주요 증상 (요약)
            if (record['symptoms'] != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.note_alt,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '주요 증상',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            record['symptoms'].toString().length > 50
                                ? '${record['symptoms'].toString().substring(0, 50)}...'
                                : record['symptoms'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // 처방약 (개수만 표시)
            if (record['prescription'] != null && (record['prescription'] as List).isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.medication,
                      size: 18,
                      color: Color(0xFF4CAF50),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '처방약 ${(record['prescription'] as List).length}개',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      '자세히 보기',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // 다음 방문 예정일 (있는 경우)
            if (record['nextVisit'] != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 18,
                      color: Color(0xFFFF9800),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '다음 방문: ${_formatDate(record['nextVisit'])}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFE65100),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showMedicalRecordDetail(Map<String, dynamic> record) {
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

              // 헤더
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A90E2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.medical_information,
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
                          '진료 기록 상세',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDetailDate(record['date']),
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
              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 기본 정보
                      _buildDetailSection(
                        '기본 정보',
                        Icons.info_outline,
                        const Color(0xFF4A90E2),
                        [
                          _buildDetailRow('병원', record['hospital']),
                          _buildDetailRow('진료과', record['department']),
                          _buildDetailRow('담당의', record['doctor']),
                          _buildDetailRow('진료일', '${_formatDetailDate(record['date'])} ${record['time']}'),
                          _buildDetailRow('상태', record['status']),
                          if (record['medicalFee'] != null)
                            _buildDetailRow('진료비', '${_formatCurrency(record['medicalFee'])}원'),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 증상
                      _buildDetailSection(
                        '증상',
                        Icons.sick,
                        const Color(0xFFFF9800),
                        [
                          _buildDetailRow('주요 증상', record['symptoms']),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 진단
                      _buildDetailSection(
                        '진단',
                        Icons.medical_information,
                        const Color(0xFFE53E3E),
                        [
                          _buildDetailRow('진단명', record['diagnosis']),
                          _buildDetailRow('치료 방법', record['treatment']),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 처방약
                      if (record['prescription'] != null && (record['prescription'] as List).isNotEmpty) ...[
                        _buildPrescriptionSection(record['prescription'] as List<String>),
                        const SizedBox(height: 24),
                      ],

                      // 의사 소견
                      if (record['notes'] != null && record['notes'].toString().isNotEmpty) ...[
                        _buildDetailSection(
                          '의사 소견',
                          Icons.note_alt,
                          const Color(0xFF9C27B0),
                          [
                            _buildDetailRow('특이사항', record['notes']),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],

                      // 다음 방문
                      if (record['nextVisit'] != null) ...[
                        _buildDetailSection(
                          '다음 방문',
                          Icons.schedule,
                          const Color(0xFF4CAF50),
                          [
                            _buildDetailRow('예정일', _formatDetailDate(record['nextVisit'])),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ),

              // 액션 버튼들
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _shareRecord(record),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF4A90E2)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(
                        Icons.share,
                        size: 18,
                        color: Color(0xFF4A90E2),
                      ),
                      label: const Text(
                        '공유하기',
                        style: TextStyle(color: Color(0xFF4A90E2)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _printRecord(record),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.print, size: 18),
                      label: const Text('인쇄하기'),
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

  Widget _buildDetailSection(String title, IconData icon, Color color, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildPrescriptionSection(List<String> prescriptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.medication, color: Color(0xFF4CAF50), size: 20),
            SizedBox(width: 8),
            Text(
              '처방약',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: prescriptions.asMap().entries.map((entry) {
              final index = entry.key;
              final prescription = entry.value;

              return Padding(
                padding: EdgeInsets.only(bottom: index == prescriptions.length - 1 ? 0 : 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        prescription,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1A1A1A),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF1A1A1A),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // === 필터 다이얼로그 ===
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '필터 설정',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              '진료과',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _departments.map((dept) =>
                  FilterChip(
                    label: Text(dept),
                    selected: _selectedDepartmentFilter == dept,
                    onSelected: (selected) {
                      setState(() {
                        _selectedDepartmentFilter = dept;
                        _applyFilters();
                      });
                      Navigator.pop(context);
                    },
                    selectedColor: const Color(0xFF4A90E2).withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: _selectedDepartmentFilter == dept
                          ? const Color(0xFF4A90E2)
                          : Colors.grey[600],
                    ),
                  ),
              ).toList(),
            ),

            const SizedBox(height: 20),

            const Text(
              '기간',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _periods.map((period) =>
                  FilterChip(
                    label: Text(period),
                    selected: _selectedPeriodFilter == period,
                    onSelected: (selected) {
                      setState(() {
                        _selectedPeriodFilter = period;
                        _applyFilters();
                      });
                      Navigator.pop(context);
                    },
                    selectedColor: const Color(0xFF4A90E2).withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: _selectedPeriodFilter == period
                          ? const Color(0xFF4A90E2)
                          : Colors.grey[600],
                    ),
                  ),
              ).toList(),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showDepartmentFilter() {
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
            ...(_departments.map((dept) =>
                ListTile(
                  title: Text(dept),
                  leading: Radio<String>(
                    value: dept,
                    groupValue: _selectedDepartmentFilter,
                    onChanged: (value) {
                      setState(() {
                        _selectedDepartmentFilter = value!;
                        _applyFilters();
                      });
                      Navigator.pop(context);
                    },
                    activeColor: const Color(0xFF4A90E2),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedDepartmentFilter = dept;
                      _applyFilters();
                    });
                    Navigator.pop(context);
                  },
                ),
            ).toList()),
          ],
        ),
      ),
    );
  }

  void _showPeriodFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '기간 선택',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...(_periods.map((period) =>
                ListTile(
                  title: Text(period),
                  leading: Radio<String>(
                    value: period,
                    groupValue: _selectedPeriodFilter,
                    onChanged: (value) {
                      setState(() {
                        _selectedPeriodFilter = value!;
                        _applyFilters();
                      });
                      Navigator.pop(context);
                    },
                    activeColor: const Color(0xFF4A90E2),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedPeriodFilter = period;
                      _applyFilters();
                    });
                    Navigator.pop(context);
                  },
                ),
            ).toList()),
          ],
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedDepartmentFilter = '전체';
      _selectedPeriodFilter = '전체';
      _searchController.clear();
      _searchQuery = '';
      _applyFilters();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('필터가 초기화되었습니다.'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  // === 유틸리티 메서드들 ===
  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) return '오늘';
    if (diff == 1) return '어제';
    if (diff < 7) return '${diff}일 전';
    if (diff < 30) return '${(diff / 7).floor()}주 전';
    if (diff < 365) return '${(diff / 30).floor()}개월 전';

    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDetailDate(String dateString) {
    final date = DateTime.parse(dateString);
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];

    return '${date.year}년 ${date.month}월 ${date.day}일 (${weekdays[date.weekday % 7]})';
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }

  Future<void> _refreshRecords() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        // 데이터 새로고침 로직
        _applyFilters();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('진료 기록을 새로고침했습니다.'),
          backgroundColor: Color(0xFF4A90E2),
        ),
      );
    }
  }

  void _shareRecord(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('진료 기록 공유'),
        content: Text('${record['hospital']} 진료 기록을 공유하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('진료 기록을 공유했습니다.'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            child: const Text('공유'),
          ),
        ],
      ),
    );
  }

  void _printRecord(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('진료 기록 인쇄'),
        content: Text('${record['hospital']} 진료 기록을 인쇄하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('진료 기록을 인쇄합니다.'),
                  backgroundColor: Color(0xFF4A90E2),
                ),
              );
            },
            child: const Text('인쇄'),
          ),
        ],
      ),
    );
  }
}