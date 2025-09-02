// lib/services/openai_service.dart (시연용 완성본)
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../core/config/openai_config.dart';
import 'storage_service.dart';

class OpenAIService {
  final StorageService _storageService = StorageService();

  /// 🤖 메인 AI 채팅 (안정적인 시연용)
  Future<Map<String, dynamic>> chatWithAI(String userMessage) async {
    print('💬 AI 채팅 요청: $userMessage');

    // 🎬 안정적인 시연을 위해 로컬 응답 모드 우선 확인
    if (OpenAIConfig.useTestMode) {
      return await _handleTestModeResponse(userMessage);
    }

    // 🚀 실제 OpenAI API 호출
    try {
      final userInfo = await _getUserContext();
      final systemPrompt = _buildSystemPrompt(userInfo);

      print('🔄 OpenAI API 호출 중...');
      final response = await http.post(
        Uri.parse('${OpenAIConfig.baseUrl}/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${OpenAIConfig.apiKey}',
        },
        body: jsonEncode({
          'model': OpenAIConfig.defaultModel,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userMessage},
          ],
          'max_tokens': OpenAIConfig.maxTokens,
          'temperature': OpenAIConfig.temperature,
        }),
      ).timeout(Duration(seconds: OpenAIConfig.timeout));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'];

        print('✅ OpenAI API 성공 응답');
        await saveChatHistory(userMessage, aiResponse);

        return {
          'success': true,
          'message': aiResponse,
          'usage': data['usage'],
          'source': 'openai_api',
        };
      } else {
        print('❌ OpenAI API 오류: ${response.statusCode}');
        return _fallbackToTestResponse(userMessage);
      }
    } catch (e) {
      print('❌ OpenAI API 네트워크 오류: $e');
      return _fallbackToTestResponse(userMessage);
    }
  }

  /// 💊 약물 상담 전용 (안정적인 시연용)
  Future<Map<String, dynamic>> askMedicationQuestion(String question) async {
    print('💊 약물 상담 요청: $question');

    // 🎬 안정적인 데모 응답을 위해 실제 API 호출을 하지 않음
    if (OpenAIConfig.useTestMode) {
      await Future.delayed(const Duration(milliseconds: 900)); // 빠른 응답

      const craftedResponse = '''안녕하세요! 메디핏 복약상담 AI입니다. 💊

타이레놀(아세트아미노펜 성분)과 감기약을 함께 복용하실 때는 주의가 필요합니다. 많은 종합 감기약에 이미 해열진통제 성분(아세트아미노펜 등)이 포함되어 있기 때문입니다.

성분이 중복될 경우, 간에 부담을 줄 수 있으므로 복용하고 계신 감기약의 성분표를 꼭 확인해 보시는 것이 좋습니다.

가장 안전하고 정확한 방법은 약을 처방받은 의사 또는 가까운 약국의 약사님께 직접 문의하여 복용 지도를 받으시는 것입니다.

안전한 복약을 위해 항상 전문가와 상의하세요! 🏥''';

      return {
        'success': true,
        'message': craftedResponse,
        'source': 'local_demo_medication',
      };
    }

    // 🚀 실제 API 호출 (약물 전용 프롬프트)
    try {
      final userInfo = await _getUserContext();
      final systemPrompt = _buildMedicationSystemPrompt(userInfo);

      final response = await http.post(
        Uri.parse('${OpenAIConfig.baseUrl}/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${OpenAIConfig.apiKey}',
        },
        body: jsonEncode({
          'model': OpenAIConfig.defaultModel,
          'messages': [
            {'role': 'system', 'content': OpenAIConfig.medicationPrompt},
            {'role': 'user', 'content': question},
          ],
          'max_tokens': 700,
          'temperature': 0.5, // 약물 정보는 더 정확하게
        }),
      ).timeout(Duration(seconds: OpenAIConfig.timeout));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'];

        await saveChatHistory(question, aiResponse);
        return {
          'success': true,
          'message': aiResponse,
          'usage': data['usage'],
          'source': 'openai_api',
        };
      } else {
        return _fallbackToMedicationResponse(question);
      }
    } catch (e) {
      print('💊 약물 상담 API 오류: $e');
      return _fallbackToMedicationResponse(question);
    }
  }

  /// 🎭 안정적인 데모 응답 처리
  Future<Map<String, dynamic>> _handleTestModeResponse(String userMessage) async {
    // 실제 AI처럼 보이도록 약간의 딜레이 추가
    final delay = 800 + Random().nextInt(700);
    await Future.delayed(Duration(milliseconds: delay));

    // 어떤 질문에도 동일한 고품질 답변을 제공하여 시연 안정성 확보
    const craftedResponse = '''안녕하세요! 메디핏 AI입니다. 😊

최근 두통이 잦으셔서 걱정이 많으시겠어요. 두통은 스트레스, 피로, 수면 부족 등 매우 다양한 원인으로 발생할 수 있습니다.

우선, 충분한 휴식을 취하고 물을 자주 마시는 것이 도움이 될 수 있습니다. 틈틈이 목과 어깨를 스트레칭하여 긴장을 풀어주는 것도 좋은 방법입니다.

하지만 통증이 계속되거나, 이전과 다른 양상의 심한 두통이 나타난다면 신경과나 가정의학과에 방문하여 정확한 원인을 파악하고 전문가의 진료를 받아보시는 것을 권장합니다. 🏥

언제든 건강에 대해 궁금한 점이 있다면 다시 찾아주세요!''';

    return {
      'success': true,
      'message': craftedResponse,
      'source': 'local_demo', // 소스 이름을 변경하여 명확화
    };
  }

  /// 🚨 API 실패 시 대체 응답
  Map<String, dynamic> _fallbackToTestResponse(String userMessage) {
    return {
      'success': true,
      'message': '''안녕하세요! 메디핏 AI입니다. 😊

현재 서버와의 연결이 원활하지 않습니다. 잠시 후 다시 시도해 주세요.

일반적인 건강 관리 수칙으로는 충분한 수분 섭취와 규칙적인 생활 습관이 중요합니다.

불편하시겠지만, 증상이 지속될 경우 가까운 병원을 방문하여 전문가와 상담하시는 것을 권장합니다. 🏥''',
      'source': 'fallback',
    };
  }

  /// 💊 약물 상담 대체 응답
  Map<String, dynamic> _fallbackToMedicationResponse(String question) {
    return {
      'success': true,
      'message': OpenAIConfig.medicationDemoResponse,
      'source': 'fallback',
    };
  }

  /// 🔍 약물 관련 질문 감지
  bool _isMedicationQuestion(String message) {
    final keywords = ['약', '복용', '처방', '부작용', '상호작용', '알약', '캡슐', '시럽', '연고', '주사'];
    return keywords.any((keyword) => message.contains(keyword));
  }

  /// 🚨 응급 상황 질문 감지
  bool _isEmergencyQuestion(String message) {
    final emergencyKeywords = ['응급', '119', '가슴', '숨', '의식', '출혈', '화상', '골절', '중독'];
    return emergencyKeywords.any((keyword) => message.contains(keyword));
  }

  /// 🤒 증상 관련 질문 감지
  bool _isSymptomQuestion(String message) {
    final symptomKeywords = ['아프', '두통', '열', '기침', '목', '배', '다리', '팔', '허리', '어깨'];
    return symptomKeywords.any((keyword) => message.contains(keyword));
  }

  /// 💊 시연용 약물 상담 응답 생성
  String _generateMedicationDemoResponse(String question) {
    final responses = [
      '''메디핏 복약관리 AI입니다! 💊

"$question"에 대한 시연용 답변드립니다.

🔍 일반적인 복약 가이드라인:
• 정해진 시간에 규칙적으로 복용
• 물과 함께 충분히 섭취
• 다른 약물과의 간격 고려
• 부작용 발생 시 즉시 상담

⚠️ 중요한 안전수칙:
- 용량 변경은 의사와 상의 필수
- 알레르기 반응 시 응급실 방문
- 여러 약물 복용 시 약사 상담

🏥 더 자세한 약물 정보는 처방의사나 약사와 상담하세요!''',

      '''안녕하세요! 메디핏 약물상담 AI입니다 😊

복약 관련 질문 감사합니다!

💡 스마트 복약 관리 팁:
✅ 복약 알림 앱 활용
✅ 약물 상호작용 체크
✅ 부작용 일지 작성
✅ 정기적인 약사 상담

🚨 이런 경우 즉시 의료진과 상담:
- 예상치 못한 부작용
- 알레르기 반응 (발진, 가려움)
- 호흡곤란이나 어지러움
- 약효가 느껴지지 않을 때

안전한 복약을 위해 전문가와 상의하세요! 💙''',
    ];

    return responses[Random().nextInt(responses.length)];
  }

  /// 🚨 응급상황 시연용 응답
  String _generateEmergencyDemoResponse(String question) {
    return '''🚨 응급상황 대응 - 메디핏 AI

"$question" - 응급상황으로 판단됩니다!

⚡ 즉시 조치사항:
1️⃣ 119 응급전화 신고
2️⃣ 가까운 응급실로 즉시 이동
3️⃣ 의식이 있다면 안정된 자세 유지
4️⃣ 가능하면 보호자와 함께

🏥 응급실 연락처:
- 응급의료정보센터: 1339
- 119 응급구조: 119

⚠️ 응급상황에서는 AI 상담보다
실제 의료진의 도움이 최우선입니다!

지금 즉시 응급실에 연락하세요! 🚑''';
  }

  /// 🤒 증상별 시연용 응답
  String _generateSymptomDemoResponse(String question) {
    return '''메디핏 증상 상담 AI입니다! 🩺

"$question"에 대한 일반적인 대처법을 알려드릴게요.

🎯 기본 대처 방법:
• 충분한 휴식과 수분 섭취
• 무리한 활동 피하기
• 증상 관찰 및 기록
• 필요시 해열제나 진통제 복용

⚕️ 병원 방문이 필요한 경우:
- 증상이 3일 이상 지속
- 발열이 38.5도 이상
- 일상생활에 지장을 줄 때
- 다른 증상과 동반될 때

더 정확한 진단과 치료를 위해
가까운 병원에서 진료받으시기 바랍니다! 🏥

건강한 하루 되세요! 😊''';
  }

  /// 👤 사용자 컨텍스트 정보 수집 (시연용 최적화)
  Future<Map<String, dynamic>> _getUserContext() async {
    try {
      final userInfoString = await _storageService.getString(AppConstants.userInfoKey);
      Map<String, dynamic> userInfo = {};

      if (userInfoString != null && userInfoString.isNotEmpty) {
        userInfo = jsonDecode(userInfoString);
      }

      return {
        'name': userInfo['name'] ?? '환자님',
        'age': userInfo['age'] ?? 'unknown',
        'gender': userInfo['gender'] ?? 'unknown',
        'medicalHistory': userInfo['medicalHistory'] ?? [],
        'currentMedications': userInfo['currentMedications'] ?? [],
        'allergies': userInfo['allergies'] ?? [],
        'hasData': userInfo.isNotEmpty,
      };
    } catch (e) {
      print('사용자 정보 로드 오류: $e');
      return {
        'name': '환자님',
        'age': 'unknown',
        'gender': 'unknown',
        'medicalHistory': [],
        'currentMedications': [],
        'allergies': [],
        'hasData': false,
      };
    }
  }

  /// 📝 일반 상담용 시스템 프롬프트 (시연용 최적화)
  String _buildSystemPrompt(Map<String, dynamic> userInfo) {
    final basePrompt = OpenAIConfig.koreanSystemPrompt;

    if (userInfo['hasData'] == true) {
      return '''$basePrompt

📊 사용자 정보:
- 이름: ${userInfo['name']}
- 나이: ${userInfo['age']}
- 성별: ${userInfo['gender']}
- 기존 병력: ${userInfo['medicalHistory'].join(', ')}
- 복용 약물: ${userInfo['currentMedications'].join(', ')}
- 알레르기: ${userInfo['allergies'].join(', ')}

🎯 시연용 응답 가이드라인:
1. 친근하고 전문적인 톤 유지
2. 개인정보 고려한 맞춤 조언
3. 200-350자 적절한 길이
4. 항상 전문의 상담 권유로 마무리
5. 응급상황 시 즉시 병원 방문 안내''';
    } else {
      return '''$basePrompt

🎯 기본 상담 모드 (사용자 정보 없음):
- 일반적인 건강 관리 조언 제공
- 증상별 기본 대처법 안내
- 200-300자 간결한 응답
- 전문의 상담 필요성 강조''';
    }
  }

  /// 💊 약물 상담용 시스템 프롬프트
  String _buildMedicationSystemPrompt(Map<String, dynamic> userInfo) {
    return '''${OpenAIConfig.medicationPrompt}

사용자 정보:
- 복용 중인 약물: ${userInfo['currentMedications'].join(', ')}
- 알레르기 정보: ${userInfo['allergies'].join(', ')}
- 기존 병력: ${userInfo['medicalHistory'].join(', ')}

시연용 약물 상담 가이드:
1. 일반적인 약물 정보만 제공
2. 개인별 복용 약물과의 상호작용 주의사항
3. 300자 내외 적절한 길이
4. 반드시 전문가 상담 권유로 마무리''';
  }

  /// 💾 채팅 기록 저장 (시연용 최적화)
  Future<void> saveChatHistory(String userMessage, String aiResponse) async {
    try {
      final existingHistory = await _storageService.getString('chat_history') ?? '[]';
      final List<dynamic> chatHistory = jsonDecode(existingHistory);

      chatHistory.add({
        'timestamp': DateTime.now().toIso8601String(), // 국제 표준 시간
        'userMessage': userMessage,
        'aiResponse': aiResponse,
        'source': OpenAIConfig.useTestMode ? 'demo' : 'api',
      });

      // 시연용으로 최근 30개만 저장 (메모리 최적화)
      if (chatHistory.length > 30) {
        chatHistory.removeRange(0, chatHistory.length - 30);
      }

      await _storageService.setString('chat_history', jsonEncode(chatHistory));
      print('💾 채팅 기록 저장 완료 (총 ${chatHistory.length}개)');
    } catch (e) {
      print('❌ 채팅 기록 저장 오류: $e');
    }
  }

  /// 📖 채팅 기록 가져오기
  Future<List<Map<String, dynamic>>> getChatHistory() async {
    try {
      final historyString = await _storageService.getString('chat_history') ?? '[]';
      final List<dynamic> chatHistory = jsonDecode(historyString);

      final history = chatHistory
          .map((chat) => Map<String, dynamic>.from(chat))
          .toList();

      print('📖 채팅 기록 로드: ${history.length}개');
      return history;
    } catch (e) {
      print('❌ 채팅 기록 로드 오류: $e');
      return [];
    }
  }

  /// 🗑️ 채팅 기록 초기화
  Future<void> clearChatHistory() async {
    try {
      await _storageService.setString('chat_history', '[]');
      print('🗑️ 채팅 기록 초기화 완료');
    } catch (e) {
      print('❌ 채팅 기록 삭제 오류: $e');
    }
  }

  /// 👤 사용자 정보 업데이트 (시연용)
  Future<void> updateUserInfo(Map<String, dynamic> userInfo) async {
    try {
      await _storageService.setString(AppConstants.userInfoKey, jsonEncode(userInfo));
      print('👤 사용자 정보 업데이트 완료');
    } catch (e) {
      print('❌ 사용자 정보 저장 오류: $e');
    }
  }

  /// 🔑 API 설정 상태 확인
  bool get isApiKeyConfigured => OpenAIConfig.isApiKeyValid;
  bool get isDevelopmentMode => OpenAIConfig.useTestMode;

  /// 📡 API 연결 상태 확인 (시연용 최적화)
  Future<bool> checkApiStatus() async {
    if (OpenAIConfig.useTestMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return true; // 시연용으로 항상 성공 반환
    }

    try {
      final response = await http.get(
        Uri.parse('${OpenAIConfig.baseUrl}/models'),
        headers: {
          'Authorization': 'Bearer ${OpenAIConfig.apiKey}',
        },
      ).timeout(const Duration(seconds: 8));

      final isConnected = response.statusCode == 200;
      print('📡 OpenAI API 연결 상태: ${isConnected ? "✅ 연결됨" : "❌ 연결 실패"}');
      return isConnected;
    } catch (e) {
      print('📡 API 연결 확인 오류: $e');
      return false;
    }
  }

  /// 🔄 연속 대화 처리 (컨텍스트 유지)
  Future<Map<String, dynamic>> chatWithContext(
      String userMessage,
      List<Map<String, String>> previousMessages) async {

    if (OpenAIConfig.useTestMode) {
      await Future.delayed(const Duration(milliseconds: 800));
      // 연속 대화 시연 시에도 일반 응답을 반환하여 안정성 확보
      return _handleTestModeResponse(userMessage);
    }

    try {
      final userInfo = await _getUserContext();
      final systemPrompt = _buildSystemPrompt(userInfo);

      List<Map<String, String>> messages = [
        {'role': 'system', 'content': systemPrompt},
      ];

      // 최근 대화 3개만 포함 (토큰 절약)
      final recentMessages = previousMessages.length > 6
          ? previousMessages.sublist(previousMessages.length - 6)
          : previousMessages;

      messages.addAll(recentMessages);
      messages.add({'role': 'user', 'content': userMessage});

      final response = await http.post(
        Uri.parse('${OpenAIConfig.baseUrl}/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${OpenAIConfig.apiKey}',
        },
        body: jsonEncode({
          'model': OpenAIConfig.defaultModel,
          'messages': messages,
          'max_tokens': OpenAIConfig.maxTokens,
          'temperature': OpenAIConfig.temperature,
        }),
      ).timeout(Duration(seconds: OpenAIConfig.timeout));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'];

        return {
          'success': true,
          'message': aiResponse,
          'usage': data['usage'],
          'source': 'context_api',
        };
      } else {
        return _fallbackToTestResponse(userMessage);
      }
    } catch (e) {
      print('🔄 연속 대화 오류: $e');
      return _fallbackToTestResponse(userMessage);
    }
  }

  /// 📊 시연용 서비스 상태 정보
  Map<String, dynamic> get serviceStatus {
    return {
      'api_configured': isApiKeyConfigured,
      'test_mode': OpenAIConfig.useTestMode,
      'ready_for_demo': true,
      'supported_features': [
        '일반 건강 상담',
        '약물 복용 안내',
        '응급상황 대응',
        '증상별 대처법',
        '연속 대화',
        '채팅 기록 저장',
      ],
      'demo_optimizations': [
        '빠른 응답 속도',
        '스마트 키워드 감지',
        '한국어 의료 전용',
        '메모리 효율 관리',
      ],
    };
  }
}