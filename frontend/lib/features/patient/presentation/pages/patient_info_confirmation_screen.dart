// lib/features/patient/presentation/pages/patient_info_confirmation_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PatientInfoConfirmationScreen extends StatefulWidget {
  const PatientInfoConfirmationScreen({super.key});

  @override
  State<PatientInfoConfirmationScreen> createState() => _PatientInfoConfirmationScreenState();
}

class _PatientInfoConfirmationScreenState extends State<PatientInfoConfirmationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _birthdateController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '내 정보 확인',
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 프로필 헤더
                _buildProfileHeader(),

                const SizedBox(height: 32),

                // 기본 정보 섹션
                _buildSection(
                  title: '기본 정보',
                  children: [
                    _buildInputField(
                      controller: _nameController,
                      label: '이름',
                      hint: '홍길동',
                      prefixIcon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '이름을 입력해주세요';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildInputField(
                      controller: _birthdateController,
                      label: '생년월일',
                      hint: '1990.03.15',
                      prefixIcon: Icons.calendar_today_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [_DateInputFormatter()],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '생년월일을 입력해주세요';
                        }
                        if (value.length != 10) {
                          return '올바른 형식으로 입력해주세요 (YYYY.MM.DD)';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildInputField(
                      controller: _phoneController,
                      label: '전화번호',
                      hint: '010-1234-5678',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [_PhoneInputFormatter()],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '전화번호를 입력해주세요';
                        }
                        if (!value.contains('-') || value.length != 13) {
                          return '올바른 형식으로 입력해주세요 (010-1234-5678)';
                        }
                        return null;
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // 건강 정보 섹션
                _buildHealthInfoSection(),

                const SizedBox(height: 40),

                // 저장 버튼
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _savePatientInfo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      '정보 저장',
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
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
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
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF4A90E2).withOpacity(0.1),
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Color(0xFF4A90E2),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: InkWell(
                  onTap: _changeProfileImage,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A90E2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '내 정보를 확인하고 업데이트하세요',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
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
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
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
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF999999),
              fontSize: 16,
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: const Color(0xFF666666),
              size: 20,
            ),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE53E3E), width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE53E3E), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildHealthInfoSection() {
    return _buildSection(
      title: '건강 정보',
      children: [
        _buildHealthInfoItem(
          icon: Icons.favorite,
          title: '혈액형',
          value: 'A형',
          onTap: () => _showBloodTypeSelector(),
        ),
        const SizedBox(height: 12),
        _buildHealthInfoItem(
          icon: Icons.warning_amber,
          title: '알레르기',
          value: '없음',
          onTap: () => _showAllergySelector(),
        ),
        const SizedBox(height: 12),
        _buildHealthInfoItem(
          icon: Icons.medication,
          title: '복용 중인 약물',
          value: '2개',
          onTap: () => _showMedicationList(),
        ),
        const SizedBox(height: 12),
        _buildHealthInfoItem(
          icon: Icons.local_hospital,
          title: '주치의',
          value: '김의사 (아인병원)',
          onTap: () => _showDoctorSelector(),
        ),
      ],
    );
  }

  Widget _buildHealthInfoItem({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF4A90E2),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFCCCCCC),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _changeProfileImage() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '프로필 사진 변경',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Color(0xFF4A90E2)),
              title: const Text('카메라로 촬영'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('카메라 기능은 개발 중입니다.'),
                    backgroundColor: Color(0xFF4A90E2),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF2ECC71)),
              title: const Text('갤러리에서 선택'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('갤러리 선택 기능은 개발 중입니다.'),
                    backgroundColor: Color(0xFF2ECC71),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBloodTypeSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('혈액형 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['A형', 'B형', 'AB형', 'O형', '모름'].map((type) =>
              ListTile(
                title: Text(type),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$type이 선택되었습니다.'),
                      backgroundColor: const Color(0xFF4A90E2),
                    ),
                  );
                },
              ),
          ).toList(),
        ),
      ),
    );
  }

  void _showAllergySelector() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('알레르기 정보 입력 기능은 개발 중입니다.'),
        backgroundColor: Color(0xFF4A90E2),
      ),
    );
  }

  void _showMedicationList() {
    Navigator.pushNamed(context, '/medication');
  }

  void _showDoctorSelector() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('주치의 선택 기능은 개발 중입니다.'),
        backgroundColor: Color(0xFF4A90E2),
      ),
    );
  }

  void _savePatientInfo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // 실제로는 서버에 정보 저장 요청
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    // 성공 메시지
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('정보가 성공적으로 저장되었습니다.'),
        backgroundColor: Color(0xFF2ECC71),
      ),
    );
  }
}

// 날짜 입력 포맷터
class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text.replaceAll('.', '');
    if (text.length <= 4) {
      return newValue.copyWith(text: text);
    } else if (text.length <= 6) {
      return newValue.copyWith(
        text: '${text.substring(0, 4)}.${text.substring(4)}',
        selection: TextSelection.collapsed(offset: text.length + 1),
      );
    } else if (text.length <= 8) {
      return newValue.copyWith(
        text: '${text.substring(0, 4)}.${text.substring(4, 6)}.${text.substring(6)}',
        selection: TextSelection.collapsed(offset: text.length + 2),
      );
    }
    return oldValue;
  }
}

// 전화번호 입력 포맷터
class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text.replaceAll('-', '');
    if (text.length <= 3) {
      return newValue.copyWith(text: text);
    } else if (text.length <= 7) {
      return newValue.copyWith(
        text: '${text.substring(0, 3)}-${text.substring(3)}',
        selection: TextSelection.collapsed(offset: text.length + 1),
      );
    } else if (text.length <= 11) {
      return newValue.copyWith(
        text: '${text.substring(0, 3)}-${text.substring(3, 7)}-${text.substring(7)}',
        selection: TextSelection.collapsed(offset: text.length + 2),
      );
    }
    return oldValue;
  }
}