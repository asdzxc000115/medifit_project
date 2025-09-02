// lib/features/medication/presentation/pages/medication_reminder_screen.dart
import 'package:flutter/material.dart';

class MedicationReminderScreen extends StatefulWidget {
  const MedicationReminderScreen({super.key});

  @override
  State<MedicationReminderScreen> createState() => _MedicationReminderScreenState();
}

class _MedicationReminderScreenState extends State<MedicationReminderScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 더미 데이터
  final List<Medication> _todayMedications = [
    Medication(
      id: '1',
      name: '혈압약',
      dosage: '1정',
      time: TimeOfDay(hour: 8, minute: 0),
      isTaken: true,
      color: Colors.blue,
      description: '식후 30분 복용',
    ),
    Medication(
      id: '2',
      name: '당뇨약',
      dosage: '1정',
      time: TimeOfDay(hour: 13, minute: 0),
      isTaken: false,
      color: Colors.green,
      description: '식전 30분 복용',
    ),
    Medication(
      id: '3',
      name: '소염제',
      dosage: '1정',
      time: TimeOfDay(hour: 18, minute: 0),
      isTaken: false,
      color: Colors.orange,
      description: '식후 복용',
    ),
    Medication(
      id: '4',
      name: '비타민',
      dosage: '1정',
      time: TimeOfDay(hour: 21, minute: 0),
      isTaken: false,
      color: Colors.purple,
      description: '취침 전 복용',
    ),
  ];

  final List<Medication> _allMedications = [
    Medication(
      id: '1',
      name: '혈압약',
      dosage: '1정',
      time: TimeOfDay(hour: 8, minute: 0),
      isTaken: true,
      color: Colors.blue,
      description: '식후 30분 복용',
      frequency: '1일 2회',
      duration: '30일',
    ),
    Medication(
      id: '2',
      name: '당뇨약',
      dosage: '1정',
      time: TimeOfDay(hour: 13, minute: 0),
      isTaken: false,
      color: Colors.green,
      description: '식전 30분 복용',
      frequency: '1일 1회',
      duration: '90일',
    ),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF1A1A1A)),
            onPressed: _addNewMedication,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4A90E2),
          unselectedLabelColor: const Color(0xFF666666),
          indicatorColor: const Color(0xFF4A90E2),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: '오늘'),
            Tab(text: '전체'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayTab(),
          _buildAllMedicationsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewMedication,
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTodayTab() {
    final completedCount = _todayMedications.where((med) => med.isTaken).length;
    final totalCount = _todayMedications.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return SingleChildScrollView(
      child: Column(
        children: [
          // 진행 상황 카드
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A90E2).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '오늘의 복약 현황',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$completedCount/$totalCount 완료',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 6,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        Text(
                          '${(progress * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 6,
                ),
              ],
            ),
          ),

          // 다음 복용 알림
          _buildNextMedicationAlert(),

          const SizedBox(height: 16),

          // 오늘의 복약 목록
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _todayMedications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final medication = _todayMedications[index];
              return _buildMedicationCard(medication, isTodayView: true);
            },
          ),

          const SizedBox(height: 100), // FAB 공간
        ],
      ),
    );
  }

  Widget _buildAllMedicationsTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _allMedications.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final medication = _allMedications[index];
        return _buildMedicationCard(medication, isTodayView: false);
      },
    );
  }

  Widget _buildNextMedicationAlert() {
    final nextMedication = _todayMedications
        .where((med) => !med.isTaken)
        .fold<Medication?>(null, (closest, med) {
      if (closest == null) return med;

      final now = TimeOfDay.now();
      final medTime = med.time;
      final closestTime = closest.time;

      final medMinutes = medTime.hour * 60 + medTime.minute;
      final closestMinutes = closestTime.hour * 60 + closestTime.minute;
      final nowMinutes = now.hour * 60 + now.minute;

      // 오늘 남은 시간 중 가장 가까운 것
      if (medMinutes >= nowMinutes && closestMinutes >= nowMinutes) {
        return medMinutes < closestMinutes ? med : closest;
      } else if (medMinutes >= nowMinutes) {
        return med;
      } else if (closestMinutes >= nowMinutes) {
        return closest;
      } else {
        return medMinutes > closestMinutes ? med : closest;
      }
    });

    if (nextMedication == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF9800).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            color: const Color(0xFFFF9800),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '다음 복용 시간',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFFFF9800),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${nextMedication.name} • ${_formatTime(nextMedication.time)}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // 알림 설정
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('알림이 설정되었습니다.'),
                  backgroundColor: Color(0xFF4A90E2),
                ),
              );
            },
            child: Text(
              '알림 설정',
              style: TextStyle(
                color: const Color(0xFFFF9800),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(Medication medication, {required bool isTodayView}) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        border: medication.isTaken && isTodayView
            ? Border.all(color: const Color(0xFF2ECC71).withOpacity(0.3), width: 2)
            : null,
      ),
      child: Row(
        children: [
          // 약물 아이콘
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: medication.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.medication,
              color: medication.color,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // 약물 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        medication.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: medication.isTaken && isTodayView
                              ? const Color(0xFF666666)
                              : const Color(0xFF1A1A1A),
                          decoration: medication.isTaken && isTodayView
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    if (isTodayView)
                      _buildStatusChip(medication.isTaken),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  '${medication.dosage} • ${_formatTime(medication.time)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: medication.isTaken && isTodayView
                        ? const Color(0xFF999999)
                        : const Color(0xFF666666),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  medication.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: medication.isTaken && isTodayView
                        ? const Color(0xFF999999)
                        : const Color(0xFF999999),
                  ),
                ),

                if (!isTodayView && medication.frequency != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.repeat,
                        size: 14,
                        color: const Color(0xFF666666),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${medication.frequency} • ${medication.duration}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // 액션 버튼
          if (isTodayView)
            InkWell(
              onTap: () => _toggleMedicationStatus(medication),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  medication.isTaken ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: medication.isTaken ? const Color(0xFF2ECC71) : const Color(0xFFCCCCCC),
                  size: 28,
                ),
              ),
            )
          else
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: Color(0xFF666666)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20, color: const Color(0xFF4A90E2)),
                      const SizedBox(width: 8),
                      const Text('수정'),
                    ],
                  ),
                  onTap: () => _editMedication(medication),
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: const Color(0xFFE53E3E)),
                      const SizedBox(width: 8),
                      const Text('삭제'),
                    ],
                  ),
                  onTap: () => _deleteMedication(medication),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(bool isTaken) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isTaken
            ? const Color(0xFF2ECC71).withOpacity(0.1)
            : const Color(0xFFFF9800).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isTaken ? '복용 완료' : '복용 예정',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isTaken ? const Color(0xFF2ECC71) : const Color(0xFFFF9800),
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? '오전' : '오후';
    return '$period ${hour == 0 ? 12 : hour}:$minute';
  }

  void _toggleMedicationStatus(Medication medication) {
    setState(() {
      medication.isTaken = !medication.isTaken;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          medication.isTaken
              ? '${medication.name} 복용을 완료했습니다.'
              : '${medication.name} 복용을 취소했습니다.',
        ),
        backgroundColor: medication.isTaken
            ? const Color(0xFF2ECC71)
            : const Color(0xFFFF9800),
        action: SnackBarAction(
          label: '취소',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              medication.isTaken = !medication.isTaken;
            });
          },
        ),
      ),
    );
  }

  void _addNewMedication() {
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

                const Text(
                  '새 복약 추가',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 32),

                // 폼 필드들
                const Text(
                  '약물명',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: '약물명을 입력하세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  '용량',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: '예: 1정, 5ml',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  '복용 시간',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    // 선택된 시간 처리
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.grey[600]),
                        const SizedBox(width: 12),
                        const Text(
                          '시간 선택',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const Spacer(),
                        Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // 버튼들
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('취소'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('새 복약이 추가되었습니다.'),
                              backgroundColor: Color(0xFF2ECC71),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90E2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('추가'),
                      ),
                    ),
                  ],
                ),

                // 키보드 공간
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _editMedication(Medication medication) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('약물 수정 기능은 개발 중입니다.'),
        backgroundColor: Color(0xFF4A90E2),
      ),
    );
  }

  void _deleteMedication(Medication medication) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '약물 삭제',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: Text(
          '${medication.name}을(를) 삭제하시겠습니까?\n삭제된 약물은 복구할 수 없습니다.',
          style: const TextStyle(fontSize: 16),
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
                SnackBar(
                  content: Text('${medication.name}이(가) 삭제되었습니다.'),
                  backgroundColor: const Color(0xFFE53E3E),
                ),
              );
            },
            child: const Text(
              '삭제',
              style: TextStyle(color: Color(0xFFE53E3E)),
            ),
          ),
        ],
      ),
    );
  }
}

// 약물 모델
class Medication {
  final String id;
  final String name;
  final String dosage;
  final TimeOfDay time;
  bool isTaken;
  final Color color;
  final String description;
  final String? frequency;
  final String? duration;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    this.isTaken = false,
    required this.color,
    required this.description,
    this.frequency,
    this.duration,
  });
}