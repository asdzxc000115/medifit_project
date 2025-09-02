// lib/features/settings/presentation/pages/settings_screen.dart
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationEnabled = true;
  bool _medicationReminder = true;
  bool _appointmentReminder = true;
  bool _biometricEnabled = false;
  double _textSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '설정',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 프로필 섹션
            _buildProfileSection(),

            const SizedBox(height: 24),

            // 알림 설정
            _buildSection(
              title: '알림 설정',
              items: [
                SettingsItem(
                  icon: Icons.notifications_outlined,
                  title: '알림 허용',
                  subtitle: '앱 알림을 받을 수 있습니다',
                  trailing: Switch(
                    value: _notificationEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationEnabled = value;
                      });
                    },
                    activeColor: const Color(0xFF4A90E2),
                  ),
                ),
                SettingsItem(
                  icon: Icons.medication_outlined,
                  title: '복약 알림',
                  subtitle: '복용 시간에 알림을 받습니다',
                  trailing: Switch(
                    value: _medicationReminder,
                    onChanged: _notificationEnabled ? (value) {
                      setState(() {
                        _medicationReminder = value;
                      });
                    } : null,
                    activeColor: const Color(0xFF4A90E2),
                  ),
                ),
                SettingsItem(
                  icon: Icons.calendar_today_outlined,
                  title: '예약 알림',
                  subtitle: '예약 일정 알림을 받습니다',
                  trailing: Switch(
                    value: _appointmentReminder,
                    onChanged: _notificationEnabled ? (value) {
                      setState(() {
                        _appointmentReminder = value;
                      });
                    } : null,
                    activeColor: const Color(0xFF4A90E2),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 보안 설정
            _buildSection(
              title: '보안 설정',
              items: [
                SettingsItem(
                  icon: Icons.fingerprint_outlined,
                  title: '생체 인증',
                  subtitle: '지문 또는 얼굴 인식으로 로그인',
                  trailing: Switch(
                    value: _biometricEnabled,
                    onChanged: (value) {
                      setState(() {
                        _biometricEnabled = value;
                      });
                      if (value) {
                        _showBiometricDialog();
                      }
                    },
                    activeColor: const Color(0xFF4A90E2),
                  ),
                ),
                SettingsItem(
                  icon: Icons.lock_outline,
                  title: '비밀번호 변경',
                  subtitle: '계정 비밀번호를 변경합니다',
                  onTap: () => _navigateToScreen(context, '비밀번호 변경'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 화면 설정
            _buildSection(
              title: '화면 설정',
              items: [
                SettingsItem(
                  icon: Icons.text_fields_outlined,
                  title: '텍스트 크기',
                  subtitle: '앱 내 텍스트 크기를 조절합니다',
                  onTap: () => _showTextSizeDialog(),
                ),
                SettingsItem(
                  icon: Icons.dark_mode_outlined,
                  title: '다크 모드',
                  subtitle: '어두운 테마를 사용합니다',
                  onTap: () => _navigateToScreen(context, '다크 모드'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 계정 관리
            _buildSection(
              title: '계정 관리',
              items: [
                SettingsItem(
                  icon: Icons.person_outline,
                  title: '개인정보 수정',
                  subtitle: '이름, 전화번호 등을 수정합니다',
                  onTap: () => _navigateToScreen(context, '개인정보 수정'),
                ),
                SettingsItem(
                  icon: Icons.medical_information_outlined,
                  title: '의료정보 관리',
                  subtitle: '알레르기, 복용 중인 약 등',
                  onTap: () => _navigateToScreen(context, '의료정보 관리'),
                ),
                SettingsItem(
                  icon: Icons.family_restroom_outlined,
                  title: '가족 계정 연결',
                  subtitle: '가족 구성원과 정보를 공유합니다',
                  onTap: () => _navigateToScreen(context, '가족 계정 연결'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 앱 정보
            _buildSection(
              title: '앱 정보',
              items: [
                SettingsItem(
                  icon: Icons.help_outline,
                  title: '도움말',
                  subtitle: '앱 사용법과 FAQ를 확인하세요',
                  onTap: () => _navigateToScreen(context, '도움말'),
                ),
                SettingsItem(
                  icon: Icons.privacy_tip_outlined,
                  title: '개인정보 처리방침',
                  subtitle: '개인정보 보호 정책을 확인하세요',
                  onTap: () => _navigateToScreen(context, '개인정보 처리방침'),
                ),
                SettingsItem(
                  icon: Icons.description_outlined,
                  title: '서비스 이용약관',
                  subtitle: '서비스 이용 약관을 확인하세요',
                  onTap: () => _navigateToScreen(context, '서비스 이용약관'),
                ),
                SettingsItem(
                  icon: Icons.info_outline,
                  title: '앱 버전',
                  subtitle: '버전 1.0.0',
                  trailing: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('최신 버전입니다.'),
                          backgroundColor: Color(0xFF2ECC71),
                        ),
                      );
                    },
                    child: const Text(
                      '업데이트 확인',
                      style: TextStyle(color: Color(0xFF4A90E2)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 계정 관련
            _buildSection(
              title: '계정',
              items: [
                SettingsItem(
                  icon: Icons.logout_outlined,
                  title: '로그아웃',
                  subtitle: '현재 계정에서 로그아웃합니다',
                  textColor: const Color(0xFFE53E3E),
                  onTap: () => _showLogoutDialog(context),
                ),
                SettingsItem(
                  icon: Icons.delete_outline,
                  title: '회원 탈퇴',
                  subtitle: '계정을 영구적으로 삭제합니다',
                  textColor: const Color(0xFFE53E3E),
                  onTap: () => _showDeleteAccountDialog(context),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      margin: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF4A90E2).withOpacity(0.1),
            child: const Icon(
              Icons.person,
              size: 30,
              color: Color(0xFF4A90E2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '김환자',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'patient@example.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC71).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '일반 환자',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2ECC71),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _navigateToScreen(context, '프로필 수정'),
            icon: const Icon(
              Icons.edit_outlined,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<SettingsItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
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
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;

              return Column(
                children: [
                  _buildSettingsItem(item),
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 60,
                      endIndent: 20,
                      color: Colors.grey[200],
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(SettingsItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.textColor != null
                    ? item.textColor!.withOpacity(0.1)
                    : const Color(0xFF4A90E2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                item.icon,
                size: 20,
                color: item.textColor ?? const Color(0xFF4A90E2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: item.textColor ?? const Color(0xFF1A1A1A),
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (item.trailing != null)
              item.trailing!
            else
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFCCCCCC),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, String route) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$route 화면으로 이동 (구현 예정)'),
        backgroundColor: const Color(0xFF4A90E2),
      ),
    );
  }

  void _showTextSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '텍스트 크기',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '샘플 텍스트',
                style: TextStyle(fontSize: _textSize),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text('작게', style: TextStyle(fontSize: 12)),
                  Expanded(
                    child: Slider(
                      value: _textSize,
                      min: 12.0,
                      max: 24.0,
                      divisions: 6,
                      activeColor: const Color(0xFF4A90E2),
                      onChanged: (value) {
                        setDialogState(() {
                          _textSize = value;
                        });
                      },
                    ),
                  ),
                  const Text('크게', style: TextStyle(fontSize: 18)),
                ],
              ),
            ],
          ),
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
              setState(() {}); // 실제 설정 적용
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('텍스트 크기가 변경되었습니다.'),
                  backgroundColor: Color(0xFF2ECC71),
                ),
              );
            },
            child: const Text(
              '적용',
              style: TextStyle(color: Color(0xFF4A90E2)),
            ),
          ),
        ],
      ),
    );
  }

  void _showBiometricDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '생체 인증 설정',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: const Text(
          '생체 인증을 활성화하면 지문 또는 얼굴 인식으로\n빠르고 안전하게 로그인할 수 있습니다.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _biometricEnabled = false;
              });
              Navigator.of(context).pop();
            },
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
                  content: Text('생체 인증이 활성화되었습니다.'),
                  backgroundColor: Color(0xFF2ECC71),
                ),
              );
            },
            child: const Text(
              '활성화',
              style: TextStyle(color: Color(0xFF4A90E2)),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '로그아웃',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: const Text(
          '정말 로그아웃 하시겠습니까?',
          style: TextStyle(fontSize: 16),
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
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text(
              '로그아웃',
              style: TextStyle(color: Color(0xFFE53E3E)),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '회원 탈퇴',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFFE53E3E),
          ),
        ),
        content: const Text(
          '정말 회원 탈퇴를 하시겠습니까?\n모든 데이터가 삭제되며 복구할 수 없습니다.',
          style: TextStyle(fontSize: 16),
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
                  content: Text('회원 탈퇴 기능은 개발 중입니다.'),
                  backgroundColor: Color(0xFFE53E3E),
                ),
              );
            },
            child: const Text(
              '탈퇴',
              style: TextStyle(color: Color(0xFFE53E3E)),
            ),
          ),
        ],
      ),
    );
  }
}

// 설정 아이템 모델
class SettingsItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? textColor;

  SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.textColor,
  });
}