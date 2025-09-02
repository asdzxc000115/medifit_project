// lib/features/prescriptions/presentation/pages/prescriptions_screen.dart
import 'package:flutter/material.dart';

class PrescriptionsScreen extends StatefulWidget {
  const PrescriptionsScreen({super.key});

  @override
  State<PrescriptionsScreen> createState() => _PrescriptionsScreenState();
}

class _PrescriptionsScreenState extends State<PrescriptionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = '전체';

  // 더미 데이터
  final List<Prescription> _currentPrescriptions = [
    Prescription(
      id: '1',
      hospitalName: '아인병원',
      doctorName: '김의사',
      prescriptionDate: DateTime(2024, 10, 10),
      medications: [
        Medication(
          name: '아모잘탄정 5/50mg',
          dosage: '1정',
          frequency: '1일 1회',
          period: '30일',
          instructions: '아침 식후 복용',
          remainingDays: 25,
          category: '혈압약',
        ),
        Medication(
          name: '메트포르민정 500mg',
          dosage: '1정',
          frequency: '1일 2회',
          period: '30일',
          instructions: '아침, 저녁 식후 복용',
          remainingDays: 25,
          category: '당뇨약',
        ),
      ],
      diagnosis: '본태성 고혈압, 제2형 당뇨병',
      status: PrescriptionStatus.active,
      refillsRemaining: 2,
    ),
    Prescription(
      id: '2',
      hospitalName: '서울대병원',
      doctorName: '이의사',
      prescriptionDate: DateTime(2024, 9, 15),
      medications: [
        Medication(
          name: '낙센정 550mg',
          dosage: '1정',
          frequency: '1일 2회',
          period: '7일',
          instructions: '식후 복용, 위장장애 주의',
          remainingDays: 0,
          category: '소염진통제',
        ),
      ],
      diagnosis: '어깨충돌증후군',
      status: PrescriptionStatus.completed,
      refillsRemaining: 0,
    ),
  ];

  final List<Prescription> _pastPrescriptions = [
    Prescription(
      id: '3',
      hospitalName: '연세병원',
      doctorName: '박의사',
      prescriptionDate: DateTime(2024, 8, 20),
      medications: [
        Medication(
          name: '인공눈물',
          dosage: '1방울',
          frequency: '1일 4회',
          period: '14일',
          instructions: '필요시 점안',
          remainingDays: 0,
          category: '안약',
        ),
      ],
      diagnosis: '안구건조증',
      status: PrescriptionStatus.completed,
      refillsRemaining: 0,
    ),
    Prescription(
      id: '4',
      hospitalName: '고대병원',
      doctorName: '최의사',
      prescriptionDate: DateTime(2024, 7, 10),
      medications: [
        Medication(
          name: '세티리진정 10mg',
          dosage: '1정',
          frequency: '1일 1회',
          period: '14일',
          instructions: '취침전 복용',
          remainingDays: 0,
          category: '항히스타민제',
        ),
        Medication(
          name: '더마톱크림',
          dosage: '적당량',
          frequency: '1일 2회',
          period: '14일',
          instructions: '환부에 얇게 도포',
          remainingDays: 0,
          category: '외용약',
        ),
      ],
      diagnosis: '아토피 피부염',
      status: PrescriptionStatus.completed,
      refillsRemaining: 0,
    ),
  ];

  List<Prescription> _filteredPrescriptions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _filteredPrescriptions = _currentPrescriptions;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '처방전 관리',
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
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF666666)),
            onPressed: _scanPrescriptionQR,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4A90E2),
          unselectedLabelColor: const Color(0xFF666666),
          indicatorColor: const Color(0xFF4A90E2),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          onTap: (index) {
            if (index == 0) {
              _filteredPrescriptions = _currentPrescriptions;
            } else {
              _filteredPrescriptions = _pastPrescriptions;
            }
            _filterPrescriptions();
          },
          tabs: const [
            Tab(text: '복용 중'),
            Tab(text: '지난 처방'),
          ],
        ),
      ),
      body: Column(
        children: [
          // 검색 및 필터
          _buildSearchAndFilter(),

          // 복용 알림 요약 (복용 중 탭에서만)
          if (_tabController.index == 0) _buildMedicationSummary(),

          // 처방전 목록
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCurrentTab(),
                _buildPastTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPrescriptionManually,
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('수동 추가'),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 검색바
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '약물명 또는 병원명 검색',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF666666)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _filterPrescriptions();
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
            ),
            onChanged: (value) {
              setState(() {});
              _filterPrescriptions();
            },
          ),

          const SizedBox(height: 12),

          // 필터 칩들
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['전체', '혈압약', '당뇨약', '소염진통제', '안약', '항히스타민제', '외용약']
                  .map((filter) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(filter),
                  selected: _selectedFilter == filter,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                    _filterPrescriptions();
                  },
                  selectedColor: const Color(0xFF4A90E2).withOpacity(0.2),
                  checkmarkColor: const Color(0xFF4A90E2),
                  labelStyle: TextStyle(
                    color: _selectedFilter == filter
                        ? const Color(0xFF4A90E2)
                        : const Color(0xFF666666),
                    fontWeight: _selectedFilter == filter
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                ),
              ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationSummary() {
    final activeMedications = _currentPrescriptions
        .where((p) => p.status == PrescriptionStatus.active)
        .expand((p) => p.medications)
        .where((m) => m.remainingDays > 0)
        .toList();

    if (activeMedications.isEmpty) {
      return const SizedBox.shrink();
    }

    final expiringMedications = activeMedications
        .where((m) => m.remainingDays <= 7)
        .toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: expiringMedications.isNotEmpty
            ? const Color(0xFFFFF3E0)
            : const Color(0xFFE8F5E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: expiringMedications.isNotEmpty
              ? const Color(0xFFFF9800).withOpacity(0.3)
              : const Color(0xFF2ECC71).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            expiringMedications.isNotEmpty
                ? Icons.warning_amber
                : Icons.medication,
            color: expiringMedications.isNotEmpty
                ? const Color(0xFFFF9800)
                : const Color(0xFF2ECC71),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expiringMedications.isNotEmpty
                      ? '복용 종료 임박'
                      : '복용 중인 약물',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: expiringMedications.isNotEmpty
                        ? const Color(0xFFFF9800)
                        : const Color(0xFF2ECC71),
                  ),
                ),
                Text(
                  expiringMedications.isNotEmpty
                      ? '${expiringMedications.length}개 약물이 7일 이내 종료'
                      : '${activeMedications.length}개 약물 복용 중',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1A1A1A),
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

  Widget _buildCurrentTab() {
    if (_filteredPrescriptions.isEmpty) {
      return _buildEmptyState('복용 중인 처방전이 없습니다', '새로운 처방전을 추가해보세요');
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _filteredPrescriptions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final prescription = _filteredPrescriptions[index];
        return _buildPrescriptionCard(prescription, isCurrent: true);
      },
    );
  }

  Widget _buildPastTab() {
    final pastFiltered = _pastPrescriptions.where((prescription) {
      final searchQuery = _searchController.text.toLowerCase();
      final matchesSearch = searchQuery.isEmpty ||
          prescription.hospitalName.toLowerCase().contains(searchQuery) ||
          prescription.medications.any((med) =>
              med.name.toLowerCase().contains(searchQuery));

      final matchesFilter = _selectedFilter == '전체' ||
          prescription.medications.any((med) => med.category == _selectedFilter);

      return matchesSearch && matchesFilter;
    }).toList();

    if (pastFiltered.isEmpty) {
      return _buildEmptyState('지난 처방전이 없습니다', '아직 완료된 처방전이 없어요');
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: pastFiltered.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final prescription = pastFiltered[index];
        return _buildPrescriptionCard(prescription, isCurrent: false);
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
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
        ],
      ),
    );
  }

  Widget _buildPrescriptionCard(Prescription prescription, {required bool isCurrent}) {
    return InkWell(
      onTap: () => _showPrescriptionDetail(prescription),
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
          border: prescription.status == PrescriptionStatus.active
              ? Border.all(color: const Color(0xFF2ECC71).withOpacity(0.3), width: 2)
              : null,
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
              prescription.hospitalName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${prescription.doctorName} • ${_formatDate(prescription.prescriptionDate)}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
          ],
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

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
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
            style: TextStyle(
              fontSize: 16,
              color: valueColor ?? const Color(0xFF1A1A1A),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: valueColor ?? const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _requestRefill(Prescription prescription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '재처방 요청',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${prescription.hospitalName}에 재처방을 요청하시겠습니까?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '재처방 약물:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...prescription.medications.take(3).map((med) =>
                      Text(
                        '• ${med.name}',
                        style: const TextStyle(fontSize: 14),
                      ),
                  ),
                  if (prescription.medications.length > 3)
                    Text(
                      '외 ${prescription.medications.length - 3}개',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '취소',
              style: TextStyle(color: Color(0xFF666666)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('재처방 요청이 전송되었습니다.'),
                  backgroundColor: Color(0xFF2ECC71),
                ),
              );
            },
            child: const Text(
              '요청',
              style: TextStyle(color: Color(0xFF2ECC71)),
            ),
          ),
        ],
      ),
    );
  }

  void _sharePrescription(Prescription prescription) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('처방전 공유 기능은 개발 중입니다.'),
        backgroundColor: Color(0xFF4A90E2),
      ),
    );
  }
}

// 처방전 모델
class Prescription {
  final String id;
  final String hospitalName;
  final String doctorName;
  final DateTime prescriptionDate;
  final List<Medication> medications;
  final String diagnosis;
  final PrescriptionStatus status;
  final int refillsRemaining;

  Prescription({
    required this.id,
    required this.hospitalName,
    required this.doctorName,
    required this.prescriptionDate,
    required this.medications,
    required this.diagnosis,
    required this.status,
    required this.refillsRemaining,
  });
}

// 약물 모델 (기존 복약 알림용과 확장)
class Medication {
  final String name;
  final String dosage;
  final String frequency;
  final String period;
  final String instructions;
  final int remainingDays;
  final String category;

  Medication({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.period,
    required this.instructions,
    required this.remainingDays,
    required this.category,
  });
}

// 처방전 상태 열거형
enum PrescriptionStatus {
  active,
  completed,
  expired,
}
),
),
_buildStatusChip(prescription.status),
],
),

const SizedBox(height: 16),

// 진단명
Text(
'진단: ${prescription.diagnosis}',
style: const TextStyle(
fontSize: 14,
color: Color(0xFF666666),
),
),

const SizedBox(height: 12),

// 처방 약물들
...prescription.medications.take(2).map((medication) =>
Padding(
padding: const EdgeInsets.only(bottom: 8),
child: Row(
children: [
Container(
width: 8,
height: 8,
decoration: BoxDecoration(
color: _getMedicationColor(medication.category),
shape: BoxShape.circle,
),
),
const SizedBox(width: 8),
Expanded(
child: Text(
'${medication.name} • ${medication.frequency}',
style: const TextStyle(
fontSize: 14,
color: Color(0xFF1A1A1A),
),
),
),
if (isCurrent && medication.remainingDays > 0)
Text(
'${medication.remainingDays}일 남음',
style: TextStyle(
fontSize: 12,
color: medication.remainingDays <= 7
? const Color(0xFFE53E3E)
    : const Color(0xFF666666),
fontWeight: medication.remainingDays <= 7
? FontWeight.w600
    : FontWeight.normal,
),
),
],
),
),
),

if (prescription.medications.length > 2)
Text(
'외 ${prescription.medications.length - 2}개 약물',
style: const TextStyle(
fontSize: 12,
color: Color(0xFF999999),
),
),

const SizedBox(height: 16),

// 액션 버튼들
Row(
children: [
Expanded(
child: OutlinedButton.icon(
onPressed: () => _showPrescriptionDetail(prescription),
icon: const Icon(Icons.visibility, size: 16),
label: const Text('상세보기'),
style: OutlinedButton.styleFrom(
foregroundColor: const Color(0xFF4A90E2),
padding: const EdgeInsets.symmetric(vertical: 8),
),
),
),
const SizedBox(width: 12),
if (isCurrent && prescription.refillsRemaining > 0)
Expanded(
child: OutlinedButton.icon(
onPressed: () => _requestRefill(prescription),
icon: const Icon(Icons.refresh, size: 16),
label: const Text('재처방'),
style: OutlinedButton.styleFrom(
foregroundColor: const Color(0xFF2ECC71),
padding: const EdgeInsets.symmetric(vertical: 8),
),
),
),
if (!isCurrent)
Expanded(
child: OutlinedButton.icon(
onPressed: () => _sharePrescription(prescription),
icon: const Icon(Icons.share, size: 16),
label: const Text('공유'),
style: OutlinedButton.styleFrom(
foregroundColor: const Color(0xFF666666),
padding: const EdgeInsets.symmetric(vertical: 8),
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

Widget _buildStatusChip(PrescriptionStatus status) {
Color backgroundColor;
Color textColor;
String text;

switch (status) {
case PrescriptionStatus.active:
backgroundColor = const Color(0xFF2ECC71).withOpacity(0.1);
textColor = const Color(0xFF2ECC71);
text = '복용중';
break;
case PrescriptionStatus.completed:
backgroundColor = const Color(0xFF666666).withOpacity(0.1);
textColor = const Color(0xFF666666);
text = '완료';
break;
case PrescriptionStatus.expired:
backgroundColor = const Color(0xFFE53E3E).withOpacity(0.1);
textColor = const Color(0xFFE53E3E);
text = '만료';
break;
}

return Container(
padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
decoration: BoxDecoration(
color: backgroundColor,
borderRadius: BorderRadius.circular(12),
),
child: Text(
text,
style: TextStyle(
fontSize: 12,
fontWeight: FontWeight.w600,
color: textColor,
),
),
);
}

Color _getMedicationColor(String category) {
switch (category) {
case '혈압약':
return const Color(0xFFE53E3E);
case '당뇨약':
return const Color(0xFF4A90E2);
case '소염진통제':
return const Color(0xFFFF9800);
case '안약':
return const Color(0xFF00BCD4);
case '항히스타민제':
return const Color(0xFF9C27B0);
case '외용약':
return const Color(0xFF2ECC71);
default:
return const Color(0xFF666666);
}
}

String _formatDate(DateTime date) {
return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
}

void _filterPrescriptions() {
setState(() {
// 현재 탭에 따라 필터링할 목록 선택
final sourceList = _tabController.index == 0 ? _currentPrescriptions : _pastPrescriptions;

_filteredPrescriptions = sourceList.where((prescription) {
final searchQuery = _searchController.text.toLowerCase();
final matchesSearch = searchQuery.isEmpty ||
prescription.hospitalName.toLowerCase().contains(searchQuery) ||
prescription.medications.any((med) =>
med.name.toLowerCase().contains(searchQuery));

final matchesFilter = _selectedFilter == '전체' ||
prescription.medications.any((med) => med.category == _selectedFilter);

return matchesSearch && matchesFilter;
}).toList();
});
}

void _scanPrescriptionQR() {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('처방전 QR 스캔 기능은 개발 중입니다.'),
backgroundColor: Color(0xFF4A90E2),
),
);
}

void _addPrescriptionManually() {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('수동 처방전 추가 기능은 개발 중입니다.'),
backgroundColor: Color(0xFF4A90E2),
),
);
}

void _showPrescriptionDetail(Prescription prescription) {
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
prescription.hospitalName,
style: const TextStyle(
fontSize: 24,
fontWeight: FontWeight.bold,
),
),
),
_buildStatusChip(prescription.status),
],
),

const SizedBox(height: 24),

// 처방 정보
_buildDetailSection('처방 정보', [
_buildDetailRow('처방일', _formatDate(prescription.prescriptionDate)),
_buildDetailRow('담당의', prescription.doctorName),
_buildDetailRow('진단명', prescription.diagnosis),
if (prescription.refillsRemaining > 0)
_buildDetailRow('재처방 가능', '${prescription.refillsRemaining}회'),
]),

const SizedBox(height: 24),

// 처방 약물 목록
_buildDetailSection('처방 약물',
prescription.medications.map((med) =>
Container(
margin: const EdgeInsets.only(bottom: 16),
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(12),
border: Border.all(color: Colors.grey[200]!),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
Container(
width: 12,
height: 12,
decoration: BoxDecoration(
color: _getMedicationColor(med.category),
shape: BoxShape.circle,
),
),
const SizedBox(width: 8),
Expanded(
child: Text(
med.name,
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.w600,
),
),
),
Container(
padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
decoration: BoxDecoration(
color: _getMedicationColor(med.category).withOpacity(0.1),
borderRadius: BorderRadius.circular(8),
),
child: Text(
med.category,
style: TextStyle(
fontSize: 12,
color: _getMedicationColor(med.category),
fontWeight: FontWeight.w500,
),
),
),
],
),
const SizedBox(height: 12),
_buildMedicationRow('용량', '${med.dosage} ${med.frequency}'),
_buildMedicationRow('복용법', med.instructions),
_buildMedicationRow('처방기간', med.period),
if (med.remainingDays > 0)
_buildMedicationRow('남은 일수', '${med.remainingDays}일',
valueColor: med.remainingDays <= 7
? const Color(0xFFE53E3E)
    : const Color(0xFF2ECC71)),
],
),
),
).toList(),
),

const SizedBox(height: 40),

// 액션 버튼들
if (prescription.status == PrescriptionStatus.active) ...[
Row(
children: [
Expanded(
child: OutlinedButton.icon(
onPressed: () {
Navigator.pop(context);
_sharePrescription(prescription);
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
if (prescription.refillsRemaining > 0)
Expanded(
child: ElevatedButton.icon(
onPressed: () {
Navigator.pop(context);
_requestRefill(prescription);
},
icon: const Icon(Icons.refresh),
label: const Text('재처방 요청'),
style: ElevatedButton.styleFrom(
backgroundColor: const Color(0xFF2ECC71),
foregroundColor: Colors.white,
padding: const EdgeInsets.symmetric(vertical: 12),
),
),
),
],
),
],