// lib/features/medication/presentation/pages/medication_alarm_screen.dart
import 'package:flutter/material.dart';

class MedicationAlarmScreen extends StatefulWidget {
  const MedicationAlarmScreen({super.key});

  @override
  State<MedicationAlarmScreen> createState() => _MedicationAlarmScreenState();
}

class _MedicationAlarmScreenState extends State<MedicationAlarmScreen> {
  final List<Map<String, dynamic>> _alarmTimes = [
    {'time': '09:00', 'label': '아침', 'enabled': true},
    {'time': '13:00', 'label': '점심', 'enabled': true},
    {'time': '19:00', 'label': '저녁', 'enabled': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '복약 알림 설정',
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 알림 시간 리스트
            Expanded(
              child: ListView.separated(
                itemCount: _alarmTimes.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final alarm = _alarmTimes[index];
                  return _buildAlarmCard(
                    label: alarm['label'],
                    time: alarm['time'],
                    enabled: alarm['enabled'],
                    onToggle: (value) {
                      setState(() {
                        _alarmTimes[index]['enabled'] = value;
                      });
                    },
                    onTimeChange: () {
                      _showTimePicker(context, index);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // 저장 버튼
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '저장',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlarmCard({
    required String label,
    required String time,
    required bool enabled,
    required Function(bool) onToggle,
    required VoidCallback onTimeChange,
  }) {
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
      child: Row(
        children: [
          // 시간대 라벨
          Expanded(
            child:               Text(
              label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),

          // 시간 표시 및 변경 버튼
          GestureDetector(
            onTap: enabled ? onTimeChange : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: enabled
                    ? const Color(0xFFF5F5F5)
                    : const Color(0xFFF5F5F5).withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: enabled
                      ? const Color(0xFFE0E0E0)
                      : const Color(0xFFE0E0E0).withOpacity(0.5),
                ),
              ),
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: enabled
                      ? const Color(0xFF1A1A1A)
                      : const Color(0xFF999999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTimePicker(BuildContext context, int index) {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(_alarmTimes[index]['time'].split(':')[0]),
        minute: int.parse(_alarmTimes[index]['time'].split(':')[1]),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4A90E2),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
    ).then((selectedTime) {
      if (selectedTime != null) {
        setState(() {
          _alarmTimes[index]['time'] =
          '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
        });
      }
    });
  }

  void _saveSettings() {
    // 설정 저장 로직
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('복약 알림 설정이 저장되었습니다.'),
        backgroundColor: Color(0xFF4A90E2),
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pop(context);
  }
}