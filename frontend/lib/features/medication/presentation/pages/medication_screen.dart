import 'package:flutter/material.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  // 임시 복약 데이터
  final List<Map<String, dynamic>> _medications = [
    {
      'id': 1,
      'name': '타이레놀 500mg',
      'dosage': '1정',
      'frequency': '하루 3회',
      'times': ['아침 식후', '점심 식후', '저녁 식후'],
      'startDate': '2025-08-01',
      'endDate': '2025-08-15',
      'totalDays': 14,
      'remainingDays': 5,
      'taken': [true, true, false], // 오늘의 복용 상태
      'purpose': '해열, 진통',
      'sideEffects': '드물게 위장장애 가능',
      'color': Color(0xFF4A90E2),
      'isActive': true,
    },
    {
      'id': 2,
      'name': '소염제 200mg',
      'dosage': '1정',
      'frequency': '하루 2회',
      'times': ['아침 식후', '저녁 식후'],
      'startDate': '2025-07-25',
      'endDate': '2025-08-10',
      'totalDays': 16,
      'remainingDays': 0,
      'taken': [true, true], // 복용 완료
      'purpose': '염증 완화',
      'sideEffects': '식후 복용 권장',
      'color': Color(0xFF4CAF50),
      'isActive': false,
    },
    {
      'id': 3,
      'name': '혈압약 10mg',
      'dosage': '1정',
      'frequency': '하루 1회',
      'times': ['아침 식전'],
      'startDate': '2025-01-01',
      'endDate': '2025-12-31',
      'totalDays': 365,
      'remainingDays': 128,
      'taken': [true], // 오늘의 복용 상태
      'purpose': '고혈압 관리',
      'sideEffects': '어지럼증 주의',
      'color': Color(0xFFE91E63),
      'isActive': true,
      'isLongTerm': true,
    },
  ];

  int _selectedTabIndex = 0;
  final List<String> _tabs = ['복용 중', '완료된 약물'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '복약 관리',
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
            onPressed: () => _showAddMedicationDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 오늘의 복약 현황 카드
          _buildTodayMedicationStatus(),

          // 탭 메뉴
          _buildTabMenu(),

          // 복약 목록
          Expanded(
            child: _buildMedicationList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayMedicationStatus() {
    final activeMeds = _medications.where((med) => med['isActive']).toList();
    final totalToday = activeMeds.fold<int>(0, (sum, med) => sum + (med['times'] as List).length);
    final completedToday = activeMeds.fold<int>(0, (sum, med) {
      final taken = med['taken'] as List<bool>;
      return sum + taken.where((t) => t).length;
    });

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '오늘의 복약 현황',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '$completedToday',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      ' / $totalToday',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  completedToday == totalToday
                      ? '오늘 복약을 모두 완료했어요! 👏'
                      : '${totalToday - completedToday}번의 복약이 남아있어요',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: totalToday > 0 ? completedToday / totalToday : 0,
                      strokeWidth: 6,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
                const Center(
                  child: Icon(
                    Icons.medication,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabMenu() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Row(
        children: _tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = _selectedTabIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF4A90E2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tab,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF666666),
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMedicationList() {
    final filteredMeds = _selectedTabIndex == 0
        ? _medications.where((med) => med['isActive']).toList()
        : _medications.where((med) => !med['isActive']).toList();

    if (filteredMeds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedTabIndex == 0 ? Icons.medication_outlined : Icons.check_circle_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _selectedTabIndex == 0 ? '복용 중인 약물이 없습니다' : '완료된 약물이 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedTabIndex == 0 ? '새로운 약물을 추가해보세요' : '복용 완료된 약물이 여기에 나타납니다',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filteredMeds.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final medication = filteredMeds[index];
        return _buildMedicationCard(medication);
      },
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> medication) {
    final bool isCompleted = !medication['isActive'];
    final bool isLongTerm = medication['isLongTerm'] ?? false;

    return GestureDetector(
      onTap: () => _showMedicationDetail(medication),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted
                ? const Color(0xFF4CAF50).withOpacity(0.3)
                : (medication['color'] as Color).withOpacity(0.3),
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
            // 헤더
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (medication['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_circle : Icons.medication,
                    color: medication['color'],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              medication['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                                  : isLongTerm
                                  ? const Color(0xFFFF9800).withOpacity(0.1)
                                  : const Color(0xFF4A90E2).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isCompleted
                                  ? '복용 완료'
                                  : isLongTerm
                                  ? '장기복용'
                                  : '복용 중',
                              style: TextStyle(
                                color: isCompleted
                                    ? const Color(0xFF4CAF50)
                                    : isLongTerm
                                    ? const Color(0xFFFF9800)
                                    : const Color(0xFF4A90E2),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${medication['dosage']} ${medication['frequency']}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 복용 시간
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: Color(0xFF666666)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    (medication['times'] as List).join(', '),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 용도
            Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Color(0xFF666666)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    medication['purpose'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
              ],
            ),

            if (!isCompleted) ...[
              const SizedBox(height: 16),

              // 남은 기간
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Color(0xFF666666)),
                      const SizedBox(width: 6),
                      Text(
                        isLongTerm
                            ? '${medication['remainingDays']}일 남음'
                            : '${medication['remainingDays']}일 남음',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                  if (!isLongTerm)
                    Container(
                      width: 60,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (medication['totalDays'] - medication['remainingDays']) / medication['totalDays'],
                        child: Container(
                          decoration: BoxDecoration(
                            color: medication['color'],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // 오늘의 복용 체크
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
                      '오늘 복용 현황',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(
                        (medication['times'] as List).length,
                            (index) {
                          final time = medication['times'][index];
                          final taken = (medication['taken'] as List<bool>)[index];

                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  (medication['taken'] as List<bool>)[index] = !taken;
                                });

                                if (!taken) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('$time 복용을 완료했습니다!'),
                                      backgroundColor: const Color(0xFF4CAF50),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.only(right: index < (medication['times'] as List).length - 1 ? 8 : 0),
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: taken ? const Color(0xFF4CAF50) : Colors.white,
                                  border: Border.all(
                                    color: taken ? const Color(0xFF4CAF50) : const Color(0xFFDDDDDD),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      taken ? Icons.check : Icons.circle_outlined,
                                      size: 16,
                                      color: taken ? Colors.white : const Color(0xFF666666),
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        time,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: taken ? Colors.white : const Color(0xFF666666),
                                          fontWeight: taken ? FontWeight.w600 : FontWeight.w400,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
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

  void _showMedicationDetail(Map<String, dynamic> medication) {
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

                // 약물 정보 상세 내용
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (medication['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.medication,
                        color: medication['color'],
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medication['name'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${medication['dosage']} ${medication['frequency']}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 상세 정보 섹션들
                _buildDetailSection('복용 정보', [
                  _buildDetailRow('용도', medication['purpose']),
                  _buildDetailRow('용량', medication['dosage']),
                  _buildDetailRow('복용 횟수', medication['frequency']),
                  _buildDetailRow('복용 시간', (medication['times'] as List).join(', ')),
                ]),

                _buildDetailSection('기간 정보', [
                  _buildDetailRow('시작일', _formatDate(medication['startDate'])),
                  _buildDetailRow('종료일', _formatDate(medication['endDate'])),
                  if (medication['isActive'])
                    _buildDetailRow('남은 기간', '${medication['remainingDays']}일'),
                ]),

                _buildDetailSection('주의사항', [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFB74D), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF8F00), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            medication['sideEffects'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  void _showAddMedicationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('약물 추가'),
        content: const Text('처방전을 통해 약물을 추가하거나\n직접 입력하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('처방전 스캔 기능은 개발 중입니다.'),
                  backgroundColor: Color(0xFF4A90E2),
                ),
              );
            },
            child: const Text('처방전 스캔'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showManualInputDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
            ),
            child: const Text('직접 입력', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showManualInputDialog() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final purposeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('약물 직접 입력'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '약물명',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medication),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: dosageController,
                decoration: const InputDecoration(
                  labelText: '용량 (예: 500mg)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.straighten),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: purposeController,
                decoration: const InputDecoration(
                  labelText: '복용 목적',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && dosageController.text.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${nameController.text}이(가) 추가되었습니다.'),
                    backgroundColor: const Color(0xFF4CAF50),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
            ),
            child: const Text('추가', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }