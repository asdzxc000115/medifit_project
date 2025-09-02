// lib/features/ai_chat/presentation/pages/ai_chat_screen.dart (시연용 완성본)
import 'package:flutter/material.dart';
import '../../../../services/gemini_service.dart'; // Gemini 서비스로 변경
import '../../../../services/storage_service.dart'; // 채팅 기록 저장을 위해 추가
import 'dart:convert';
import 'dart:math';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService _geminiService = GeminiService(); // Gemini 서비스 사용
  final StorageService _storageService = StorageService(); // 채팅 기록 저장을 위해 추가

  List<ChatMessage> _messages = [];
  bool _isTyping = false;

  // 🎭 시연용 애니메이션 컨트롤러
  late AnimationController _typingAnimationController;
  late Animation<double> _typingAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadChatHistory();
    _showWelcomeMessage();
  }

  /// 🎭 애니메이션 초기화
  void _initializeAnimations() {
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _typingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _typingAnimationController,
      curve: Curves.easeInOut,
    ));

    // 무한 반복 애니메이션
    _typingAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  /// 💾 채팅 기록 로드 (시연용 최적화)
  Future<void> _loadChatHistory() async {
    try {
      final history = await getChatHistory();
      if (history.isNotEmpty) {
        setState(() {
          _messages = history.map((chat) {
            return [
              ChatMessage(
                text: chat['userMessage'],
                isUser: true,
                timestamp: DateTime.parse(chat['timestamp']),
              ),
              ChatMessage(
                text: chat['aiResponse'],
                isUser: false,
                timestamp: DateTime.parse(chat['timestamp']),
              ),
            ];
          }).expand((messages) => messages).toList();
        });

        print('💾 채팅 기록 로드: ${_messages.length}개 메시지');
      }
    } catch (e) {
      print('❌ 채팅 기록 로드 실패: $e');
    }
  }

  /// 🎉 환영 메시지 표시 (시연용 최적화)
  void _showWelcomeMessage() {
    if (_messages.isEmpty) {
      final welcomeMessage = _buildWelcomeMessage();

      setState(() {
        _messages.add(ChatMessage(
          text: welcomeMessage,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });

      print('🎉 환영 메시지 표시 완료');
    }
  }

  /// 📝 환영 메시지 생성
  String _buildWelcomeMessage() {
    return '''안녕하세요! 메디핏 AI 건강상담사입니다. 😊

**무엇이든 물어보세요!**
• 증상별 기본 대처법 안내
• 복약 관리 및 주의사항
• 건강한 생활습관 조언

⚠️ **중요 안내사항:**
AI 상담은 의학적 진단이나 처방을 대체할 수 없습니다. 증상이 심각하거나 지속될 경우, 반드시 전문 의료진과 상담하세요.

궁금한 점을 편하게 말씀해 주세요! 💙''';
  }

  /// 💬 메시지 전송 (시연용 최적화)
  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isTyping) return;

    print('💬 사용자 메시지: $message');

    // 사용자 메시지 추가
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Gemini API 호출
      final response = await _geminiService.chatWithAI(message);

      final aiMessage = ChatMessage(
        text: response['success'] ? response['message'] : response['message'],
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(aiMessage);
        _isTyping = false;
      });

      // 채팅 기록 저장
      if (response['success']) {
        await saveChatHistory(message, response['message']);
      }

      print('✅ AI 응답 완료');

    } catch (e) {
      print('❌ 메시지 전송 실패: $e');

      setState(() {
        _messages.add(ChatMessage(
          text: '죄송합니다. 일시적인 오류가 발생했습니다.\n잠시 후 다시 시도해주세요. 😅',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });
    }

    _scrollToBottom();
  }

  /// ⚡ 빠른 질문 전송 (시연용)
  void _sendQuickQuestion(String question) {
    print('⚡ 빠른 질문: $question');
    _messageController.text = question;
    _sendMessage();
  }

  /// 📜 스크롤을 하단으로 이동
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// 🔄 대화 초기화
  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.refresh, color: Color(0xFFFF9800)),
            SizedBox(width: 8),
            Text('대화 초기화'),
          ],
        ),
        content: const Text('모든 대화 내용이 삭제됩니다.\n계속하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                _messages.clear();
              });
              await clearChatHistory();
              _showWelcomeMessage();
              print('🔄 채팅 초기화 완료');
            },
            child: const Text(
              '확인',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// ⚡ 빠른 질문 버튼들 (시연용 최적화)
  Widget _buildQuickQuestions() {
    final quickQuestions = [
      '💊 복용 중인 약물의 부작용이 궁금해요',
      '🤕 두통이 자주 발생하는데 어떻게 해야 할까요?',
      '😴 불면증으로 잠을 못 자겠어요',
      '🤧 감기 증상이 있는데 관리법을 알려주세요',
      '🩺 혈압약을 깜빡하고 못 먹었어요',
      '💉 다른 약과 함께 먹어도 될까요?',
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: quickQuestions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
              width: 160,
              child: ActionChip(
                label: Text(
                  quickQuestions[index],
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                onPressed: () => _sendQuickQuestion(quickQuestions[index]),
                backgroundColor: const Color(0xFFF0F8FF),
                side: BorderSide(
                  color: const Color(0xFF4A90E2).withOpacity(0.5),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'AI 건강 상담',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            Text(
              'Gemini 연결됨',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF4A90E2),
              ),
            )
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF4A90E2)),
            onPressed: _clearChat,
            tooltip: '대화 초기화',
          ),
        ],
      ),
      body: Column(
        children: [
          // 🎯 빠른 질문 섹션 (처음 몇 개 메시지에만 표시)
          if (_messages.length <= 3) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.flash_on,
                        color: Color(0xFF4A90E2),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '빠른 질문',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildQuickQuestions(),
                ],
              ),
            ),
            Container(
              height: 1,
              color: const Color(0xFFE0E0E0),
            ),
          ],

          // 💬 채팅 메시지 목록
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // ⌨️ 메시지 입력 영역
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: const Color(0xFF4A90E2).withOpacity(0.3),
                      ),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: _isTyping
                            ? 'AI가 답변 중입니다...'
                            : '증상이나 궁금한 점을 입력하세요...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      enabled: !_isTyping,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // 전송 버튼
                GestureDetector(
                  onTap: _isTyping ? null : _sendMessage,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isTyping
                            ? [Colors.grey, Colors.grey.shade400]
                            : [const Color(0xFF4A90E2), const Color(0xFF5BA4F2)],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: _isTyping ? null : [
                        BoxShadow(
                          color: const Color(0xFF4A90E2).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isTyping ? Icons.hourglass_empty : Icons.send,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 💬 메시지 버블 위젯 (시연용 최적화)
  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
        message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // AI 아바타
          if (!message.isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF5BA4F2)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A90E2).withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],

          // 메시지 내용
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: message.isUser
                    ? const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF5BA4F2)],
                )
                    : null,
                color: message.isUser ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(message.isUser ? 18 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : const Color(0xFF1A1A1A),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),

          // 사용자 아바타
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2ECC71).withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// ⏳ 타이핑 인디케이터 (시연용 애니메이션)
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF5BA4F2)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A90E2).withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _typingAnimation,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAnimatedDot(0),
                    const SizedBox(width: 6),
                    _buildAnimatedDot(1),
                    const SizedBox(width: 6),
                    _buildAnimatedDot(2),
                    const SizedBox(width: 12),
                    Text(
                      'AI가 답변 중...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 🔵 애니메이션 점 위젯
  Widget _buildAnimatedDot(int index) {
    final delay = index * 0.2;
    final animationValue = (_typingAnimation.value + delay) % 1.0;

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Color.lerp(
          Colors.grey.shade400,
          const Color(0xFF4A90E2),
          (sin(animationValue * 2 * pi) + 1) / 2,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // --- 채팅 기록 관리 헬퍼 함수 ---

  /// 💾 채팅 기록 저장
  Future<void> saveChatHistory(String userMessage, String aiResponse) async {
    try {
      final existingHistory = await _storageService.getString('chat_history') ?? '[]';
      final List<dynamic> chatHistory = jsonDecode(existingHistory);

      chatHistory.add({
        'timestamp': DateTime.now().toIso8601String(),
        'userMessage': userMessage,
        'aiResponse': aiResponse,
      });

      if (chatHistory.length > 30) {
        chatHistory.removeRange(0, chatHistory.length - 30);
      }

      await _storageService.setString('chat_history', jsonEncode(chatHistory));
    } catch (e) {
      print('❌ 채팅 기록 저장 오류: $e');
    }
  }

  /// 📖 채팅 기록 가져오기
  Future<List<Map<String, dynamic>>> getChatHistory() async {
    try {
      final historyString = await _storageService.getString('chat_history') ?? '[]';
      return List<Map<String, dynamic>>.from(jsonDecode(historyString));
    } catch (e) {
      print('❌ 채팅 기록 로드 오류: $e');
      return [];
    }
  }

  /// 🗑️ 채팅 기록 초기화
  Future<void> clearChatHistory() async {
    await _storageService.remove('chat_history');
    print('🗑️ 채팅 기록 초기화 완료');
  }
}

/// 💬 채팅 메시지 모델
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}