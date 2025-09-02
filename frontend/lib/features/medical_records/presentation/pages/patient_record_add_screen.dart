// lib/features/medical_records/presentation/pages/patient_record_add_screen.dart
import 'package:flutter/material.dart';

class PatientRecordAddScreen extends StatefulWidget {
  const PatientRecordAddScreen({super.key});

  @override
  State<PatientRecordAddScreen> createState() => _PatientRecordAddScreenState();
}

class _PatientRecordAddScreenState extends State<PatientRecordAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisController = TextEditingController();
  final _doctorNameController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _visitReasonController = TextEditingController();
  final _treatmentRoomController = TextEditingController();

  @override
  void dispose() {
    _diagnosisController.dispose();
    _doctorNameController.dispose();
    _symptomsController.dispose();
    _visitReasonController.dispose();
    _treatmentRoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '환자 기록 추가',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 병원명 헤더
                Container(
                  width: double.infinity,
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

                const SizedBox(height: 24),

                // 환자 정보 헤더
                Row(
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

                const SizedBox(height: 32),

                // 진단명 입력
                _buildInputField(
                  controller: _diagnosisController,
                  label: '진단명',
                  hintText: '진단명을 입력하세요',
                ),

                const SizedBox(height: 20),

                // 진단의 입력
                _buildInputField(
                  controller: _doctorNameController,
                  label: '진단의',
                  hintText: '진단의를 입력하세요',
                ),

                const SizedBox(height: 20),

                // 치방 내역 입력
                _buildInputField(
                  controller: _symptomsController,
                  label: '치방 내역',
                  hintText: '치방 내역을 입력하세요',
                ),

                const SizedBox(height: 20),

                // 방문 목적 입력
                _buildInputField(
                  controller: _visitReasonController,
                  label: '방문 목적',
                  hintText: '방문 목적을 입력하세요',
                ),

                const SizedBox(height: 20),

                // 병실 진료실 입력
                _buildInputField(
                  controller: _treatmentRoomController,
                  label: '병실 진료실',
                  hintText: '병실 진료실을 입력하세요',
                ),

                const SizedBox(height: 40),

                // 하단 버튼들
                Row(
                  children: [
                    // 취소 버튼
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4A90E2),
                          side: const BorderSide(color: Color(0xFF4A90E2), width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          '취소',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // 저장 버튼
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveRecord,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90E2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                        child: const Text(
                          '저장',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // 하단 탭 바 (진단기록 / 처방기록)
                Container(
                  width: double.infinity,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // 진단기록 탭
                      Expanded(
                        child: Container(
                          height: double.infinity,
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                              onTap: () {
                                // 진단기록 탭 선택
                              },
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.assignment,
                                    size: 24,
                                    color: Color(0xFF4A90E2),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '진단기록',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF4A90E2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 처방기록 탭
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, '/patient-prescription');
                            },
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.medical_services,
                                  size: 24,
                                  color: Color(0xFF999999),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '처방기록',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF999999),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
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
          child: TextFormField(
            controller: controller,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1A1A1A),
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                fontSize: 16,
                color: Color(0xFFCCCCCC),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _saveRecord() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('환자 진단 기록이 저장되었습니다.'),
          backgroundColor: Color(0xFF4A90E2),
        ),
      );
      Navigator.pop(context);
    }
  }
}