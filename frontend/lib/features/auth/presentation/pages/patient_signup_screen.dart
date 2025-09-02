// lib/features/auth/presentation/pages/patient_signup_screen.dart (API 연동 버전)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../services/auth_service.dart';

class PatientSignupScreen extends StatefulWidget {
  const PatientSignupScreen({super.key});

  @override
  State<PatientSignupScreen> createState() => _PatientSignupScreenState();
}

class _PatientSignupScreenState extends State<PatientSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();

  // 컨트롤러들
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _ageController = TextEditingController();

  // 상태 변수들
  int _currentPage = 0;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedBloodType = 'A+';
  bool _usernameChecked = false;
  bool _usernameAvailable = false;

  // 의존성 주입
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = getService<AuthService>();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _birthDateController.dispose();
    _ageController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('환자 회원가입'),
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 진행 표시바
          _buildProgressIndicator(),

          // 페이지 뷰
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildAccountInfoPage(),
                _buildPersonalInfoPage(),
                _buildHealthInfoPage(),
              ],
            ),
          ),

          // 하단 버튼
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: index <= _currentPage
                    ? const Color(0xFF4A90E2)
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAccountInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '계정 정보',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A90E2),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '로그인에 사용할 계정 정보를 입력하세요',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // 사용자명
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: '사용자명',
                hintText: '영문, 숫자 조합 (3-20자)',
                prefixIcon: const Icon(Icons.person_outline),
                suffixIcon: _usernameController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(
                    _usernameAvailable ? Icons.check_circle : Icons.error,
                    color: _usernameAvailable ? Colors.green : Colors.red,
                  ),
                  onPressed: _checkUsername,
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _usernameChecked = false;
                  _usernameAvailable = false;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '사용자명을 입력하세요';
                }
                if (value.length < 3 || value.length > 20) {
                  return '사용자명은 3-20자여야 합니다';
                }
                if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                  return '영문, 숫자, 언더바(_)만 사용 가능합니다';
                }
                if (!_usernameChecked) {
                  return '사용자명 중복확인을 해주세요';
                }
                if (!_usernameAvailable) {
                  return '이미 사용 중인 사용자명입니다';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _usernameController.text.isNotEmpty ? _checkUsername : null,
              child: const Text('중복확인'),
            ),

            const SizedBox(height: 16),

            // 비밀번호
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: '비밀번호',
                hintText: '6자 이상 입력하세요',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '비밀번호를 입력하세요';
                }
                if (value.length < 6) {
                  return '비밀번호는 6자 이상이어야 합니다';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // 비밀번호 확인
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: '비밀번호 확인',
                hintText: '비밀번호를 다시 입력하세요',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '비밀번호 확인을 입력하세요';
                }
                if (value != _passwordController.text) {
                  return '비밀번호가 일치하지 않습니다';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '개인 정보',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A90E2),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '개인 정보를 정확히 입력하세요',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),

          // 이름
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: '이름',
              hintText: '실명을 입력하세요',
              prefixIcon: const Icon(Icons.badge_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '이름을 입력하세요';
              }
              if (value.length < 2) {
                return '이름은 2자 이상이어야 합니다';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // 전화번호
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            decoration: InputDecoration(
              labelText: '전화번호',
              hintText: '01012345678',
              prefixIcon: const Icon(Icons.phone_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '전화번호를 입력하세요';
              }
              if (!RegExp(r'^010\d{8}$').hasMatch(value)) {
                return '올바른 전화번호 형식이 아닙니다 (010XXXXXXXX)';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // 주소
          TextFormField(
            controller: _addressController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: '주소',
              hintText: '거주지 주소를 입력하세요',
              prefixIcon: const Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '주소를 입력하세요';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // 생년월일과 나이
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _birthDateController,
                  decoration: InputDecoration(
                    labelText: '생년월일',
                    hintText: 'YYYY-MM-DD',
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime(1990, 1, 1),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      _birthDateController.text =
                      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

                      // 나이 자동 계산
                      final age = DateTime.now().year - date.year;
                      _ageController.text = age.toString();
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '생년월일을 선택하세요';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '나이',
                    hintText: '만나이',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '나이를 입력하세요';
                    }
                    final age = int.tryParse(value);
                    if (age == null || age < 1 || age > 150) {
                      return '올바른 나이를 입력하세요';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '건강 정보',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A90E2),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '의료 서비스 제공을 위한 기본 건강 정보입니다',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),

          // 혈액형
          DropdownButtonFormField<String>(
            value: _selectedBloodType,
            decoration: InputDecoration(
              labelText: '혈액형',
              prefixIcon: const Icon(Icons.bloodtype_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', '모름']
                .map((type) => DropdownMenuItem(
              value: type,
              child: Text(type),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedBloodType = value!;
              });
            },
          ),

          const SizedBox(height: 32),

          // 개인정보 처리방침 동의
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '개인정보 처리방침',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• 수집된 개인정보는 의료 서비스 제공 목적으로만 사용됩니다\n'
                      '• 개인정보는 안전하게 보호되며 제3자에게 제공되지 않습니다\n'
                      '• 회원 탈퇴 시 모든 개인정보가 삭제됩니다',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // 개인정보 처리방침 전문 표시
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('개인정보 처리방침'),
                        content: const SingleChildScrollView(
                          child: Text(
                            '본 개인정보 처리방침은 메디핏 앱 사용 시 수집되는 개인정보의 처리에 관한 사항을 안내합니다...'
                                '\n\n[상세한 개인정보 처리방침 내용]',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('확인'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('전문 보기'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentPage > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('이전'),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleNextOrSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
                  : Text(_currentPage < 2 ? '다음' : '회원가입'),
            ),
          ),
        ],
      ),
    );
  }

  // 사용자명 중복 확인
  Future<void> _checkUsername() async {
    if (_usernameController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.checkUsername(_usernameController.text.trim());

      setState(() {
        _usernameChecked = true;
        _usernameAvailable = result['available'] ?? false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _usernameAvailable
                  ? '사용 가능한 사용자명입니다'
                  : '이미 사용 중인 사용자명입니다',
            ),
            backgroundColor: _usernameAvailable ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      print('사용자명 확인 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('사용자명 확인 중 오류가 발생했습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage--;
      });
    }
  }

  Future<void> _handleNextOrSubmit() async {
    if (_currentPage < 2) {
      // 다음 페이지로
      if (_validateCurrentPage()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentPage++;
        });
      }
    } else {
      // 회원가입 처리
      await _handleSignup();
    }
  }

  bool _validateCurrentPage() {
    switch (_currentPage) {
      case 0:
        return _formKey.currentState!.validate();
      case 1:
        return _nameController.text.isNotEmpty &&
            _phoneController.text.isNotEmpty &&
            _addressController.text.isNotEmpty &&
            _birthDateController.text.isNotEmpty &&
            _ageController.text.isNotEmpty;
      case 2:
        return true;
      default:
        return false;
    }
  }

  Future<void> _handleSignup() async {
    if (!_validateCurrentPage()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('모든 필수 정보를 입력해주세요'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.registerPatient(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        patientName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        birthDate: _birthDateController.text,
        bloodType: _selectedBloodType,
        age: int.tryParse(_ageController.text) ?? 0,
      );

      if (result['success'] == true) {
        if (mounted) {
          // 성공 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? '회원가입 성공'),
              backgroundColor: Colors.green,
            ),
          );

          // 성공 다이얼로그 표시
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('회원가입 완료'),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 64,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '회원가입이 완료되었습니다.\n로그인 화면으로 이동합니다.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                    context.go('/login'); // 로그인 화면으로 이동
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('로그인하러 가기'),
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? '회원가입 실패'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('회원가입 처리 중 오류: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('회원가입 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}