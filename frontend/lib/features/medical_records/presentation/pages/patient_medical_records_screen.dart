// lib/features/medical_records/presentation/pages/patient_medical_records_screen.dart
import 'package:flutter/material.dart';

class PatientMedicalRecordsScreen extends StatefulWidget {
  const PatientMedicalRecordsScreen({super.key});

  @override
  State<PatientMedicalRecordsScreen> createState() => _PatientMedicalRecordsScreenState();
}

class _PatientMedicalRecordsScreenState extends State<PatientMedicalRecordsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = '전체';
  bool _isLoading = false;

  // 더미 데이터
  final List<MedicalRecord> _allRecords = [
    MedicalRecord(
      id: '1',
      hospitalName: '아인병원',
      doctorName: '김의사',
      department: '내과',
      visitDate: DateTime(2024, 10, 15),
      diagnosis: '고혈압, 당뇨병 정기검진',
      prescription: '혈압약 1일 2회, 당뇨약 1일 1회',
      status: '완료',
      symptoms: '두통, 어지러움',
      notes: '혈압 수치 안정, 당뇨 관리 양호',
    ),
    MedicalRecord(
      id: '2',
      hospitalName: '서울대병원',
      doctorName: '이의사',
      department: '정형외과',
      visitDate: DateTime(2024, 9, 28),
      diagnosis: '어깨 충돌 증후군',
      prescription: '소염제 1일 3회, 물리치료 주 3회',
      status: '치료중',
      symptoms: '어깨 통증, 운동 제한',
      notes: '물리치료 병행 필요',
    ),
    MedicalRecord(
      id: '3',
      hospitalName: '연세병원',
      doctorName: '박의사',
      department: '안과',
      visitDate: DateTime(2024, 8, 12),
      diagnosis: '근시 진행, 안구건조증',
      prescription: '인공눈물 1일 4회',
      status: '완료',
      symptoms: '눈 피로, 건조함',
      notes: '정기 검진 6개월 후',
    ),
  ];

  List<MedicalRecord> _filteredRecords = [];

  @override
  void initState() {
    super.initState();
    _filteredRecords = _allRecords;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            icon: const Icon(Icons.filter_list, color: Color(0xFF666666)),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // 검색 바
          _buildSearchBar(),

          // 필터 칩들
          _buildFilterChips(),

          // 기록이 없을 때
          if (_filteredRecords.isEmpty && !_isLoading)
            _buildEmptyState()
          else
          // 진료 기록 목록
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: _filteredRecords.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final record = _filteredRecords[index];
                  return _buildMedicalRecordCard(record);
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // 새 진료 기록 추가 (QR 스캔 등)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('새 진료 기록 추가 기능은 개발 중입니다.'),
              backgroundColor: Color(0xFF4A90E2),
            ),
          );
        },
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('새 기록'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '병원명 및 진료내용 검색',
          hintStyle: const TextStyle(color: Color(0xFF999999)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF666666)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: Color(0xFF666666)),
            onPressed: () {
              _searchController.clear();
              _filterRecords();
            },
          )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          setState(() {});
          _filterRecords();
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['전체', '완료', '치료중', '예정'];

    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;

          return FilterChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedFilter = filter;
              });
              _filterRecords();
            },
            selectedColor: const Color(0xFF4A90E2).withOpacity(0.2),
            checkmarkColor: const Color(0xFF4A90E2),
            labelStyle: TextStyle(
              color: isSelected ? const Color(0xFF4A90E2) : const Color(0xFF666666),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? const Color(0xFF4A90E2) : Colors.grey[300]!,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty || _selectedFilter != '전체'
                  ? '검색 결과가 없습니다'
                  : '아직 진료 기록이 없습니다',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty || _selectedFilter != '전체'
                  ? '다른 검색어나 필터를 시도해보세요'
                  : '병원 방문 후 진료 기록이 추가됩니다',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalRecordCard(MedicalRecord record) {
    return InkWell(
      onTap: () => _showRecordDetail(record),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.hospitalName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${record.department} • ${record.doctorName}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(record.status),
              ],
            ),

            const SizedBox(height: 16),

            // 진료일
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: const Color(0xFF666666),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(record.visitDate),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 진단명
            Text(
              '진단: ${record.diagnosis}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
            ),

            const SizedBox(height: 8),

            // 처방
            if (record.prescription.isNotEmpty)
              Text(
                '처방: ${record.prescription}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

            const SizedBox(height: 16),

            // 더보기 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showRecordDetail(record),
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                  ),
                  label: const Text('자세히 보기'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF4A90E2),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case '완료':
        backgroundColor = const Color(0xFF2ECC71).withOpacity(0.1);
        textColor = const Color(0xFF2ECC71);
        break;
      case '치료중':
        backgroundColor = const Color(0xFFFF9800).withOpacity(0.1);
        textColor = const Color(0xFFFF9800);
        break;
      case '예정':
        backgroundColor = const Color(0xFF4A90E2).withOpacity(0.1);
        textColor = const Color(0xFF4A90E2);
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  void _filterRecords() {
    setState(() {
      _filteredRecords = _allRecords.where((record) {
        // 검색어 필터
        final searchQuery = _searchController.text.toLowerCase();
        final matchesSearch = searchQuery.isEmpty ||
            record.hospitalName.toLowerCase().contains(searchQuery) ||
            record.diagnosis.toLowerCase().contains(searchQuery) ||
            record.doctorName.toLowerCase().contains(searchQuery);

        // 상태 필터
        final matchesStatus = _selectedFilter == '전체' || record.status == _selectedFilter;

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

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
              '필터 옵션',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '기간별 조회',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                '1개월',
                '3개월',
                '6개월',
                '1년',
                '전체',
              ].map((period) => FilterChip(
                label: Text(period),
                selected: false,
                onSelected: (selected) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$period 필터 적용 (개발 중)'),
                      backgroundColor: const Color(0xFF4A90E2),
                    ),
                  );
                },
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecordDetail(MedicalRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 핸들바
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

                // 제목
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        record.hospitalName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildStatusChip(record.status),
                  ],
                ),

                const SizedBox(height: 24),

                // 상세 정보
                _buildDetailSection('기본 정보', [
                  _buildDetailRow('진료일', _formatDate(record.visitDate)),
                  _buildDetailRow('진료과', record.department),
                  _buildDetailRow('담당의', record.doctorName),
                ]),

                const SizedBox(height: 24),

                _buildDetailSection('증상', [
                  _buildDetailRow('주요 증상', record.symptoms),
                ]),

                const SizedBox(height: 24),

                _buildDetailSection('진단', [
                  _buildDetailRow('진단명', record.diagnosis),
                ]),

                const SizedBox(height: 24),

                _buildDetailSection('처방', [
                  _buildDetailRow('처방전', record.prescription),
                ]),

                if (record.notes.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildDetailSection('특이사항', [
                    _buildDetailRow('의사 소견', record.notes),
                  ]),
                ],

                const SizedBox(height: 40),

                // 액션 버튼들
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('진료 기록 공유 기능은 개발 중입니다.'),
                              backgroundColor: Color(0xFF4A90E2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('공유'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4A90E2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('PDF 다운로드 기능은 개발 중입니다.'),
                              backgroundColor: Color(0xFF4A90E2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('다운로드'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90E2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}

// 진료 기록 모델
class MedicalRecord {
  final String id;
  final String hospitalName;
  final String doctorName;
  final String department;
  final DateTime visitDate;
  final String diagnosis;
  final String prescription;
  final String status;
  final String symptoms;
  final String notes;

  MedicalRecord({
    required this.id,
    required this.hospitalName,
    required this.doctorName,
    required this.department,
    required this.visitDate,
    required this.diagnosis,
    required this.prescription,
    required this.status,
    required this.symptoms,
    required this.notes,
  });
}