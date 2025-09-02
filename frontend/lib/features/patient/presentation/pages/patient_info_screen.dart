// lib/features/patient/presentation/pages/patient_info_screen.dart
import 'package:flutter/material.dart';

class PatientInfoScreen extends StatefulWidget {
  const PatientInfoScreen({super.key});

  @override
  State<PatientInfoScreen> createState() => _PatientInfoScreenState();
}

class _PatientInfoScreenState extends State<PatientInfoScreen> {
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _focusNode = FocusNode();
  bool _showKeyboard = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _showKeyboard = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '환자 정보 확인',
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
          icon: const Icon(Icons.close, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _handleSave,
            child: const Text(
              '저장',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A90E2),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 입력 영역
          Expanded(
            flex: _showKeyboard ? 1 : 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 안내 텍스트
                  const Text(
                    '환자 정보를 입력해주세요',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 환자 이름
                  _buildInputField(
                    controller: _nameController,
                    label: '환자 이름',
                    hintText: '이름을 입력하세요',
                  ),
                  const SizedBox(height: 24),

                  // 환자 번호
                  _buildInputField(
                    controller: _numberController,
                    label: '환자 번호',
                    hintText: '번호를 입력하세요',
                    focusNode: _focusNode,
                    readOnly: true,
                    onTap: () {
                      setState(() {
                        _showKeyboard = true;
                      });
                      _focusNode.requestFocus();
                    },
                  ),
                  const SizedBox(height: 32),

                  // 확인 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _handleConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '확인',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 취소 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4A90E2),
                        side: const BorderSide(color: Color(0xFF4A90E2), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '취소',
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

          // 커스텀 키보드 (숫자패드)
          if (_showKeyboard)
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF0F0F0),
                border: Border(
                  top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                ),
              ),
              child: _buildCustomKeyboard(),
            ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    FocusNode? focusNode,
    bool readOnly = false,
    VoidCallback? onTap,
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
            focusNode: focusNode,
            readOnly: readOnly,
            onTap: onTap,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                fontSize: 18,
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
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomKeyboard() {
    return Container(
      height: 320,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 키보드 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '키보드',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showKeyboard = false;
                  });
                  _focusNode.unfocus();
                },
                icon: const Icon(
                  Icons.keyboard_hide,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 숫자 키패드
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                // 숫자 1-9
                for (int i = 1; i <= 9; i++)
                  _buildKeyboardButton(i.toString()),

                // 특수 키들
                _buildKeyboardButton(
                  '',
                  icon: Icons.backspace_outlined,
                  onPressed: _handleBackspace,
                ),
                _buildKeyboardButton('0'),
                _buildKeyboardButton(
                  'Enter',
                  backgroundColor: const Color(0xFF4A90E2),
                  textColor: Colors.white,
                  onPressed: () {
                    setState(() {
                      _showKeyboard = false;
                    });
                    _focusNode.unfocus();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyboardButton(
      String text, {
        IconData? icon,
        Color? backgroundColor,
        Color? textColor,
        VoidCallback? onPressed,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed ?? () => _handleKeyPress(text),
          child: Center(
            child: icon != null
                ? Icon(
              icon,
              size: 24,
              color: textColor ?? const Color(0xFF666666),
            )
                : Text(
              text,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: textColor ?? const Color(0xFF1A1A1A),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleKeyPress(String key) {
    if (key.isEmpty) return;

    final currentText = _numberController.text;
    _numberController.text = currentText + key;
    _numberController.selection = TextSelection.fromPosition(
      TextPosition(offset: _numberController.text.length),
    );
  }

  void _handleBackspace() {
    final currentText = _numberController.text;
    if (currentText.isNotEmpty) {
      _numberController.text = currentText.substring(0, currentText.length - 1);
      _numberController.selection = TextSelection.fromPosition(
        TextPosition(offset: _numberController.text.length),
      );
    }
  }

  void _handleSave() {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('환자 이름을 입력해주세요');
      return;
    }

    if (_numberController.text.trim().isEmpty) {
      _showSnackBar('환자 번호를 입력해주세요');
      return;
    }

    _showSuccessDialog();
  }

  void _handleConfirm() {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('환자 이름을 입력해주세요');
      return;
    }

    if (_numberController.text.trim().isEmpty) {
      _showSnackBar('환자 번호를 입력해주세요');
      return;
    }

    _showSuccessDialog();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFE53E3E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '저장 완료',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: Text(
          '환자 정보가 저장되었습니다.\n\n'
              '이름: ${_nameController.text}\n'
              '번호: ${_numberController.text}',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text(
              '확인',
              style: TextStyle(color: Color(0xFF4A90E2)),
            ),
          ),
        ],
      ),
    );
  }
}