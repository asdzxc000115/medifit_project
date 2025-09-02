// lib/features/home/presentation/pages/home_screen.dart (업데이트)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import '../../../ai_chat/presentation/pages/ai_chat_screen.dart'; // go_router 사용 시 직접 import 불필요

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _notificationCount = 3;

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('알림'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.medication),
                title: Text('복약 시간 알림'),
                subtitle: Text('오후 7시 혈압약 복용 시간입니다.'),
              ),
              ListTile(
                leading: Icon(Icons.event_available),
                title: Text('예약 확정'),
                subtitle: Text('내일 오후 3시 진료 예약이 확정되었습니다.'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _notificationCount = 0; // 알림을 확인하면 카운트를 0으로 초기화
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '메디핏',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        centerTitle: false,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Color(0xFF1A1A1A), size: 28),
                onPressed: _showNotificationsDialog,
              ),
              if (_notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_notificationCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      // ✅ [수정됨] 비어있던 body 속성을 추가했습니다.
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // AI 채팅 안내 카드
          _buildAiChatCard(context),
          const SizedBox(height: 24),
          // 주요 기능 메뉴
          _buildMainMenu(context),
        ],
      ),
    );
  }

  /// AI 채팅 안내 카드 위젯
  Widget _buildAiChatCard(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.smart_toy, color: Colors.white, size: 28),
                SizedBox(width: 8),
                Text(
                  'AI 건강 상담',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '건강이나 복용 중인 약에 대해 궁금한 점이 있다면 언제든지 AI 상담사에게 물어보세요.',
              style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/ai-chat'), // GoRouter로 AI 채팅 화면 이동
                icon: const Icon(Icons.arrow_forward),
                label: const Text('지금 시작하기'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color(0xFF4A90E2),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 주요 기능 메뉴 위젯
  Widget _buildMainMenu(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildMenuItem(
          context,
          icon: Icons.calendar_month,
          label: '진료 예약',
          onTap: () => context.push('/appointments'),
        ),
        _buildMenuItem(
          context,
          icon: Icons.medication,
          label: '복약 관리',
          onTap: () => context.push('/medications'),
        ),
        _buildMenuItem(
          context,
          icon: Icons.medical_services,
          label: '진료 기록',
          onTap: () => context.push('/medical-records'),
        ),
        _buildMenuItem(
          context,
          icon: Icons.local_hospital,
          label: '주변 병원 찾기',
          onTap: () => context.push('/nearby-hospitals'),
        ),
      ],
    );
  }

  /// 메뉴 아이템 위젯
  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF4A90E2)),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }
}