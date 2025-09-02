// lib/features/medication/presentation/pages/medications_screen.dart (수정됨)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = '전체';
  bool _showOnlyReminders = false;

  // 현재 복용 약물 데이터
  final List<Map<String, dynamic>> _currentMedications = [
    {
      'id': 1,
      'name': '타이레놀 500mg',
      'genericName': '아세트아미노펜',
      'dosage': '500mg',
      'frequency': '1일 3회',
      'timing': ['아침 식후', '점심 식후', '저녁 식후'],
      'duration': 7,
      'remainingDays': 3,
      'purpose': '해열, 진통',
      'sideEffects': ['위장 장애', '간 손상 위험'],
      'warnings': ['과복용 금지', '음주와 함께 복용 금지'],
      'color': const Color(0xFFE57373),
      'shape': 'tablet',
      'hospital': '서울대병원',
      'doctor': '김의사',
      'prescriptionDate': '2025-08-20',
      'category': '해열진통제',
      'isActive': true,
      'lastTaken': '2025-08-26 19:30',
      'nextDose': '2025-08-27 07:30',
      'adherenceRate': 95.5,
    },
    {
      'id': 2,
      'name': '낙센 275mg',
      'genericName': '나프록센',
      'dosage': '275mg',
      'frequency': '1일 2회',
      'timing': ['아침 식후', '저녁 식후'],
      'duration': 14,
      'remainingDays': 8,
      'purpose': '소염, 진통',
      'sideEffects': ['위장 장애', '어지러움'],
      'warnings': ['식후 복용 권장'],
      'color': const Color(0xFF81C784),
      'shape': 'tablet',
      'hospital': '연세세브란스병원',
      'doctor': '이의사',
      'prescriptionDate': '2025-08-18',
      'category': '해열진통제',
      'isActive': true,
      'lastTaken': '2025-08-26 19:00',
      'nextDose': '2025-08-27 07:00',
      'adherenceRate': 92.3,
    },
    {
      'id': 3,
      'name': '베아제정 50mg',
      'genericName': '시메티딘',
      'dosage': '50mg',
      'frequency': '1일 2회',
      'timing': ['아침 식전', '저녁 식전'],
      'duration': 30,
      'remainingDays': 15,
      'purpose': '소화불량, 위산 과다',
      'sideEffects': ['변비', '설사'],
      'warnings': ['식전 30분 복용'],
      'color': const Color(0xFF64B5F6),
      'shape': 'tablet',
      'hospital': '삼성서울병원',
      'doctor': '박의사',
      'prescriptionDate': '2025-08-10',
      'category': '소화기약',
      'isActive': true,
      'lastTaken': '2025-08-26 07:00',
      'nextDose': '2025-08-27 07:00',
      'adherenceRate': 89.2,
    },
  ];

  // 과거 복용 약물 데이터
  final List<Map<String, dynamic>> _pastMedications = [
    {
      'id': 5,
      'name': '아목시실린 250mg',
      'genericName': '아목시실린',
      'dosage': '250mg',
      'frequency': '1일 3회',
      'timing': ['아침 식후', '점심 식후', '저녁 식후'],
      'duration': 7,
      'remainingDays': 0,
      'purpose': '세균 감염 치료, 항생제',
      'sideEffects': ['설사', '복통', '알레르기 반응'],
      'warnings': ['전체 처방량 완전 복용 필요', '알레르기 반응 주의'],
      'color': const Color(0xFFFF9800),
      'shape': 'capsule',
      'hospital': '연세세브란스병원',
      'doctor': '정의사',
      'prescriptionDate': '2025-07-15',
      'completionDate': '2025-07-22',
      'category': '항생제',
      'isActive': false,
      'adherenceRate': 100.0,
    },
  ];

  List<Map<String, dynamic>> _filteredCurrentMedications = [];
  List<Map<String, dynamic>> _filteredPastMedications = [];

  final List<String> _categories = [
    '전체', '해열진통제', '소화기약', '심혈관약', '안과약', '항생제', '항히스타민제', '외용약'
  ];

  // 복약 알림 설정
  bool _notificationsEnabled = true;
  TimeOfDay _morningTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _afternoonTime = const TimeOfDay(hour: 13, minute: 0);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 19, minute: 0);

  @override
  void initState() {
    super.initState();
    // 달력 탭을 제거하여 2개 탭만 사용
    _tabController = TabController(length: 2, vsync: this);
    _filteredCurrentMedications = List.from(_currentMedications);
    _filteredPastMedications = List.from(_pastMedications);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

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
            icon: Icon(
              _notificationsEnabled
                  ? Icons.notifications
                  : Icons.notifications_off,
              color: const Color(0xFF4A90E2),
            ),
            onPressed: _toggleNotifications,
            tooltip: '알림 설정',
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
          // 달력 탭 제거 - 복용 중, 복용 기록만 남김
          tabs: const [
            Tab(text: '복용 중'),
            Tab(text: '복용 기록'),
          ],
        ),
      ),
      body: Column(
        children: [
          // 검색 바 및 필터
          _buildSearchAndFilter(),

          // 탭바 내용
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCurrentMedicationsTab(),
                _buildPastMedicationsTab(),
                // 달력 탭 제거됨
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMedicationDialog,
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('약물 추가'),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 검색 바
          Container(
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
              decoration: InputDecoration(
                hintText: '약물명, 용도로 검색...',
                border: InputBorder.none,
                icon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged();
                  },
                )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 카테고리 필터 칩
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                        _applyFilters();
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFF4A90E2).withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF4A90E2) : Colors.grey[600],
                    ),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF4A90E2) : Colors.grey[300]!,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentMedicationsTab() {
    if (_filteredCurrentMedications.isEmpty) {
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
              '복용 중인 약물이 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '+ 버튼을 눌러 약물을 추가하세요',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredCurrentMedications.length,
      itemBuilder: (context, index) {
        final medication = _filteredCurrentMedications[index];
        return _buildMedicationCard(medication, isActive: true);
      },
    );
  }

  Widget _buildPastMedicationsTab() {
    if (_filteredPastMedications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '복용 기록이 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredPastMedications.length,
      itemBuilder: (context, index) {
        final medication = _filteredPastMedications[index];
        return _buildMedicationCard(medication, isActive: false);
      },
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> medication, {required bool isActive}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showMedicationDetail(medication),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 약물 아이콘
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: medication['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      medication['shape'] == 'capsule'
                          ? Icons.medication
                          : Icons.medication_outlined,
                      color: medication['color'],
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // 약물 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${medication['dosage']} | ${medication['frequency']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          medication['purpose'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 상태 표시
                  if (isActive) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '복용 중',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF4CAF50),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '완료',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // 복약 진행 상황 (활성 약물만)
              if (isActive) ...[
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      '다음 복용: ${medication['nextDose']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '복약률 ${medication['adherenceRate']}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: medication['adherenceRate'] > 90
                            ? const Color(0xFF4CAF50)
                            : medication['adherenceRate'] > 70
                            ? Colors.orange
                            : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: medication['adherenceRate'] / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    medication['adherenceRate'] > 90
                        ? const Color(0xFF4CAF50)
                        : medication['adherenceRate'] > 70
                        ? Colors.orange
                        : Colors.red,
                  ),
                ),
              ],

              // 완료일 정보 (완료된 약물만)
              if (!isActive && medication['completionDate'] != null) ...[
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      '완료일: ${medication['completionDate']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '복약률 ${medication['adherenceRate']}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF4CAF50),
                        fontWeight: FontWeight.w500,
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

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredCurrentMedications = _currentMedications.where((medication) {
        // 검색어 필터
        final searchQuery = _searchController.text.toLowerCase();
        final matchesSearch = searchQuery.isEmpty ||
            medication['name'].toString().toLowerCase().contains(searchQuery) ||
            medication['genericName'].toString().toLowerCase().contains(searchQuery) ||
            medication['purpose'].toString().toLowerCase().contains(searchQuery);

        // 카테고리 필터
        final matchesCategory = _selectedCategory == '전체' ||
            medication['category'] == _selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();

      _filteredPastMedications = _pastMedications.where((medication) {
        // 검색어 필터
        final searchQuery = _searchController.text.toLowerCase();
        final matchesSearch = searchQuery.isEmpty ||
            medication['name'].toString().toLowerCase().contains(searchQuery) ||
            medication['genericName'].toString().toLowerCase().contains(searchQuery) ||
            medication['purpose'].toString().toLowerCase().contains(searchQuery);

        // 카테고리 필터
        final matchesCategory = _selectedCategory == '전체' ||
            medication['category'] == _selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _toggleNotifications() {
    setState(() {
      _notificationsEnabled = !_notificationsEnabled;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _notificationsEnabled ? '복약 알림이 켜졌습니다' : '복약 알림이 꺼졌습니다',
        ),
        backgroundColor: _notificationsEnabled
            ? const Color(0xFF4CAF50)
            : Colors.grey[600],
      ),
    );
  }

  void _showAddMedicationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('약물 추가'),
        content: const Text('약물 추가 기능은 준비 중입니다.\n\n의료진이 처방한 약물만 추가할 수 있습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showMedicationDetail(Map<String, dynamic> medication) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 헤더
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: medication['color'].withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.medication,
                      color: medication['color'],
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medication['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            medication['genericName'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // 내용
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 복용 정보
                      _buildDetailSection('복용 정보', [
                        _buildDetailItem('용량', medication['dosage']),
                        _buildDetailItem('복용 횟수', medication['frequency']),
                        _buildDetailItem('복용 시점', (medication['timing'] as List).join(', ')),
                        if (medication['isActive'])
                          _buildDetailItem('남은 일수', '${medication['remainingDays']}일'),
                      ]),

                      const SizedBox(height: 20),

                      // 처방 정보
                      _buildDetailSection('처방 정보', [
                        _buildDetailItem('용도', medication['purpose']),
                        _buildDetailItem('병원', medication['hospital']),
                        _buildDetailItem('담당의', medication['doctor']),
                        _buildDetailItem('처방일', medication['prescriptionDate']),
                      ]),

                      const SizedBox(height: 20),

                      // 주의사항
                      _buildDetailSection('주의사항', [
                        ...((medication['sideEffects'] as List<String>).map((effect) =>
                            _buildDetailItem('부작용', effect))),
                        ...((medication['warnings'] as List<String>).map((warning) =>
                            _buildDetailItem('주의', warning))),
                      ]),
                    ],
                  ),
                ),
              ),

              // 액션 버튼
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    if (medication['isActive']) ...[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _markAsTaken(medication);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('복용 완료'),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('닫기'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...items,
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _markAsTaken(Map<String, dynamic> medication) {
    // 복용 완료 처리 로직
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${medication['name']} 복용이 기록되었습니다'),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}