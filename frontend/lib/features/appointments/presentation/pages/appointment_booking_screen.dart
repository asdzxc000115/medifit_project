// lib/features/appointments/presentation/pages/appointment_booking_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AppointmentBookingScreen extends StatefulWidget {
  final Map<String, dynamic>? selectedHospital;

  const AppointmentBookingScreen({super.key, this.selectedHospital});

  @override
  State<AppointmentBookingScreen> createState() => _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  final _formKey = GlobalKey<FormState>();

  // 선택된 값들
  Map<String, dynamic>? _selectedHospital;
  String? _selectedDepartment;
  DateTime? _selectedDate;
  String? _selectedTime;

  // 샘플 병원 데이터
  final List<Map<String, dynamic>> _hospitals = [
    {
      'id': 'hospital_1',
      'name': '서울아산병원',
      'address': '서울 송파구 올림픽로43길 88',
      'phone': '1688-7575',
      'departments': ['내과', '외과', '소아과', '정형외과', '산부인과', '피부과', '안과', '이비인후과'],
    },
    {
      'id': 'hospital_2',
      'name': '삼성서울병원',
      'address': '서울 강남구 일원로 81',
      'phone': '1599-3114',
      'departments': ['내과', '외과', '신경외과', '심장내과', '종양내과', '정형외과', '소아과'],
    },
    {
      'id': 'hospital_3',
      'name': '강남세브란스병원',
      'address': '서울 강남구 언주로 211',
      'phone': '1599-1004',
      'departments': ['내과', '외과', '정신건강의학과', '재활의학과', '피부과', '안과'],
    },
  ];

  // 예약 가능한 시간대
  final List<String> _availableTimes = [
    '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
    '14:00', '14:30', '15:00', '15:30', '16:00', '16:30', '17:00'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.selectedHospital != null) {
      _selectedHospital = widget.selectedHospital;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '병원 예약하기',
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 안내 메시지
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4A90E2).withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFF4A90E2),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '병원, 진료과, 날짜, 시간을 선택하여 예약하세요.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4A90E2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 1. 병원 선택
              _buildSectionTitle('1. 병원 선택'),
              const SizedBox(height: 12),
              _buildHospitalSelector(),

              const SizedBox(height: 32),

              // 2. 진료과 선택
              _buildSectionTitle('2. 진료과 선택'),
              const SizedBox(height: 12),
              _buildDepartmentSelector(),

              const SizedBox(height: 32),

              // 3. 날짜 선택
              _buildSectionTitle('3. 예약 날짜'),
              const SizedBox(height: 12),
              _buildDateSelector(),

              const SizedBox(height: 32),

              // 4. 시간 선택
              _buildSectionTitle('4. 예약 시간'),
              const SizedBox(height: 12),
              _buildTimeSelector(),

              const SizedBox(height: 40),

              // 예약 요약
              if (_selectedHospital != null &&
                  _selectedDepartment != null &&
                  _selectedDate != null &&
                  _selectedTime != null)
                _buildBookingSummary(),

              const SizedBox(height: 32),

              // 예약하기 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _canMakeBooking() ? _makeBooking : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '예약하기',
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
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A1A),
      ),
    );
  }

  Widget _buildHospitalSelector() {
    return Container(
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
      child: DropdownButtonFormField<Map<String, dynamic>>(
        value: _selectedHospital,
        hint: const Text('병원을 선택하세요'),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.local_hospital, color: Color(0xFF4A90E2)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        items: _hospitals.map((hospital) {
          return DropdownMenuItem(
            value: hospital,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  hospital['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  hospital['address'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedHospital = value;
            _selectedDepartment = null; // 병원 변경시 진료과 초기화
          });
        },
        validator: (value) {
          if (value == null) {
            return '병원을 선택해주세요';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDepartmentSelector() {
    final departments = _selectedHospital?['departments'] as List<String>? ??
        [];

    if (departments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          '먼저 병원을 선택해주세요',
          style: TextStyle(
            color: Color(0xFF666666),
          ),
        ),
      );
    }

    return Container(
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
      child: DropdownButtonFormField<String>(
        value: _selectedDepartment,
        hint: const Text('진료과를 선택하세요'),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.medical_services, color: Color(0xFF4A90E2)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        items: departments.map((dept) {
          return DropdownMenuItem(
            value: dept,
            child: Text(dept),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedDepartment = value;
          });
        },
        validator: (value) {
          if (value == null) {
            return '진료과를 선택해주세요';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
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
      child: InkWell(
        onTap: _selectDate,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: Color(0xFF4A90E2)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedDate != null
                      ? _formatDate(_selectedDate!)
                      : '날짜를 선택하세요',
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedDate != null
                        ? const Color(0xFF1A1A1A)
                        : const Color(0xFF666666),
                  ),
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Color(0xFF666666)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    if (_selectedDate == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          '먼저 날짜를 선택해주세요',
          style: TextStyle(
            color: Color(0xFF666666),
          ),
        ),
      );
    }

    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.access_time, color: Color(0xFF4A90E2)),
                SizedBox(width: 12),
                Text(
                  '예약 가능한 시간',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableTimes.map((time) {
                final isSelected = _selectedTime == time;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTime = time;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4A90E2)
                          : const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4A90E2)
                            : const Color(0xFFE0E0E0),
                      ),
                    ),
                    child: Text(
                      time,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4A90E2).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4A90E2).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '예약 정보 확인',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A90E2),
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryItem('병원', _selectedHospital!['name']),
          _buildSummaryItem('진료과', _selectedDepartment!),
          _buildSummaryItem('날짜', _formatDate(_selectedDate!)),
          _buildSummaryItem('시간', _selectedTime!),
          _buildSummaryItem('전화번호', _selectedHospital!['phone']),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = now;
    final DateTime lastDate = now.add(const Duration(days: 30));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
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
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = null; // 날짜 변경시 시간 초기화
      });
    }
  }

  String _formatDate(DateTime date) {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day
        .toString().padLeft(2, '0')} (${weekdays[date.weekday - 1]})';
  }

  bool _canMakeBooking() {
    return _selectedHospital != null &&
        _selectedDepartment != null &&
        _selectedDate != null &&
        _selectedTime != null;
  }

  Future<void> _makeBooking() async {
    if (!_formKey.currentState!.validate()) return;

    // 예약 정보 생성
    final appointment = {
      'id': DateTime
          .now()
          .millisecondsSinceEpoch
          .toString(),
      'hospital': _selectedHospital!['name'],
      'department': _selectedDepartment,
      'date': _selectedDate!.toIso8601String(),
      'time': _selectedTime,
      'status': 'scheduled',
      'hospitalPhone': _selectedHospital!['phone'],
      'hospitalAddress': _selectedHospital!['address'],
      'createdAt': DateTime.now().toIso8601String(),
    };

    try {
      // SharedPreferences에 저장
      final prefs = await SharedPreferences.getInstance();
      final existingAppointments = prefs.getStringList('appointments') ?? [];
      existingAppointments.add(jsonEncode(appointment));
      await prefs.setStringList('appointments', existingAppointments);

      // 성공 다이얼로그 표시
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Color(0xFF4CAF50),
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text('예약 완료'),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('예약이 성공적으로 완료되었습니다.'),
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
                          Text('병원: ${_selectedHospital!['name']}'),
                          Text('진료과: $_selectedDepartment'),
                          Text('날짜: ${_formatDate(_selectedDate!)}'),
                          Text('시간: $_selectedTime'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '예약 확인을 위해 병원에서 연락드릴 예정입니다.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // 다이얼로그 닫기
                      Navigator.pop(context); // 예약 화면 닫기
                    },
                    child: const Text('확인'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('예약 중 오류가 발생했습니다: $e'),
          backgroundColor: const Color(0xFFE53E3E),
        ),
      );
    }
  }
}
