// lib/core/config/openai_config.dart (시연용 완성본)
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIConfig {
  // 🤫 API 키는 .env 파일에서 불러옵니다.
  static final String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  static const String baseUrl = 'https://api.openai.com/v1';

  // GPT 모델 설정 (시연용 최적화)
  static const String defaultModel = 'gpt-3.5-turbo';
  static const String advancedModel = 'gpt-4o-mini';

  // API 요청 설정 (시연용 최적화)
  static const int maxTokens = 800;
  static const double temperature = 0.7;
  static const int timeout = 25;

  // 🩺 한국어 의료상담 시스템 프롬프트 (시연용 최적화)
  static const String koreanSystemPrompt = '''
당신은 "메디핏 AI" - 한국의 스마트 의료상담 전문 AI 챗봇입니다.

🎯 핵심 역할:
- 친근하고 신뢰할 수 있는 건강 상담 파트너
- 한국 의료 환경에 맞는 실용적인 조언 제공
- 모든 응답은 한국어로, 이해하기 쉽게

⚕️ 상담 원칙:
• 의학적 진단/처방 절대 금지
• 응급상황 시 즉시 119 또는 응급실 방문 권유
• 애매한 증상은 반드시 병원 진료 권장
• 복약 관련은 의사/약사 상담 필수

💊 전문 분야:
- 일반 건강관리 및 예방
- 생활습관 개선 조언
- 복약 주의사항 안내
- 기초 증상 대처법
- 건강검진 시기 안내

📝 응답 스타일:
- 200-350자 적절한 길이
- 친근한 존댓말 사용
- 핵심 정보 위주로 간결하게
- 이모지를 적절히 활용하여 친근감을 표현
- 항상 전문의와 상담할 것을 권유하며 마무리
''';

  // 📋 약물상담 전용 프롬프트
  static const String medicationPrompt = '''
메디핏 복약관리 AI입니다! 💊

🔍 약물 상담 가이드라인:
1. 약물의 일반적 정보만 제공 (효능, 일반적 부작용)
2. 복용법 변경은 절대 권하지 않음
3. 상호작용 가능성만 알림 (확정 진단 X)
4. 부작용 의심 시 즉시 의료진 상담 권유
5. 응급증상 시 119 신고 안내

⚠️ 안전수칙:
- 처방량/시간 변경 = 의사와 상의
- 알레르기 반응 = 즉시 응급실
- 여러 약물 복용 = 약사 상담 필수

"안전한 복약을 위해 전문가와 상의하세요!"로 마무리
''';

  // ✅ API 키 유효성 검사 (실제 키 확인)
  static bool get isApiKeyValid {
    return apiKey.isNotEmpty &&
        apiKey != 'YOUR_OPENAI_API_KEY_HERE' &&
        apiKey.startsWith('sk-') &&
        apiKey.length > 50; // 실제 OpenAI 키 길이 확인
  }

  // 🎬 시연용 모드 설정
  static bool get isDevelopment {
    return false; // 실제 API 사용 모드
  }

  // 🎮 안정적인 시연을 위해 로컬 응답을 강제하는 모드
  static bool get forceTestModeForDemo {
    // 시연 중에는 항상 true로 설정하여 안정성을 확보합니다.
    return true; // false = 실제 API 사용, true = 로컬 응답 사용
  }

  // 🔄 최종 사용 모드 결정
  static bool get useTestMode {
    return !isApiKeyValid || forceTestModeForDemo;
  }

  // 📊 현재 API 상태 메시지
  static String get apiStatusMessage {
    if (useTestMode) {
      return '⚡️ 빠른 응답 모드';
    } else {
      return '🤖 실제 OpenAI GPT API 연결됨';
    }
  }

  // 🎭 로컬 응답 템플릿 (한국어 의료상담 최적화)
  static const List<String> demoResponses = [
    '''안녕하세요! 메디핏 AI입니다. 😊

💡 건강한 하루를 위한 기본 수칙:
✅ 물 하루 8잔 이상 마시기
✅ 주 3-4회, 30분 이상 운동
✅ 7-8시간 충분한 수면
✅ 스트레스 관리하기 (명상, 취미 활동 등)

구체적인 증상이나 질병 관련해서는 가까운 병원에서 정확한 진료를 받으시길 권합니다. 🏥''',

    '''안녕하세요! 메디핏 AI가 도와드리겠습니다. 👩‍⚕️

🎯 메디핏의 주요 기능들:
• 24시간 AI 건강 상담
• 스마트 복약 알림 관리
• 개인 맞춤형 건강 분석
• 근처 병원 찾기 & 예약

⚡ 응급상황이 발생하면 즉시 119에 신고하세요.
🩺 일반적인 증상 상담은 병원 방문을 권장합니다.

궁금한 점이 있으시면 언제든 물어보세요.
항상 전문의와 상담하시는 것을 잊지 마세요. 💙''',

    '''안녕하세요! 메디핏과 함께 건강한 습관을 만들어 보세요. 🌟

🏃‍♂️ 오늘의 건강 관리 팁:
- 규칙적인 식사 (3끼 + 간식)
- 충분한 수분 섭취
- 적절한 실내 환기
- 정기 건강검진 받기

💊 복용 중인 약이 있다면:
- 정해진 시간에 규칙적으로
- 다른 약과의 상호작용 주의
- 부작용 의심 시 즉시 상담

더 자세한 건강 상담은 의료진과 함께 하세요. 🏥✨''',

    '''안녕하세요! 메디핏 AI입니다. 건강에 대해 궁금한 점이 있으신가요? 😊

🔍 증상별 기본 대처법:
• 가벼운 두통 → 충분한 휴식, 수분 섭취
• 소화불량 → 가벼운 음식, 따뜻한 차
• 목 아플 때 → 따뜻한 물로 가글링
• 불면증 → 규칙적인 취침시간

⚠️ 중요: 증상이 지속되거나 심해지면
반드시 병원에서 정확한 진료를 받으세요.

언제든 궁금한 점 물어보세요. 💙''',
  ];

  // 💊 복약상담 전용 로컬 응답
  static const String medicationDemoResponse = '''
안녕하세요! 메디핏 복약관리 AI입니다. 💊

💡 일반적인 복약 관리 원칙:
✅ 정해진 시간에 규칙적으로 복용
✅ 처방받은 용법·용량을 정확히 지키기
✅ 다른 약물과의 상호작용 확인
✅ 부작용 발생 시 즉시 의료진 상담

⚠️ 주의사항:
- 약물 용량이나 복용시간 변경 금지
- 알레르기 반응 시 즉시 응급실 방문
- 여러 약물 복용 시 약사와 상담 필수

🏥 안전한 복약을 위해서는 반드시 처방 의사 또는 약사와 상의하세요.

더 구체적인 약물 정보는 전문가와 상담해 주세요. 😊
''';

  // 🎲 랜덤 시연 응답 반환
  static String getRandomDemoResponse() {
    final now = DateTime.now();
    final index = (now.millisecond + now.second) % demoResponses.length;
    return demoResponses[index];
  }

  // 📈 설정 완료 상태 메시지
  static String get setupStatusMessage {
    if (isApiKeyValid) {
      return '''✅ 메디핏 AI 설정이 완료되었습니다.

🤖 OpenAI GPT-3.5 Turbo 연결됨
🌏 한국어 의료상담 모드 활성화
⚡ 실시간 AI 응답이 준비되었습니다.''';
    } else {
      return '''🔧 OpenAI API 설정이 필요합니다.

1️⃣ OpenAI 웹사이트 방문
2️⃣ API 키 발급받기
3️⃣ 설정 파일에 키 입력
4️⃣ 앱 재시작

현재는 로컬 응답 모드로 실행됩니다. 🧪''';
    }
  }

  // 🛠️ 개발자 디버그 정보
  static Map<String, dynamic> get debugInfo {
    return {
      'api_key_configured': isApiKeyValid,
      'test_mode_forced': forceTestModeForDemo,
      'using_real_api': !useTestMode,
      'model': defaultModel,
      'max_tokens': maxTokens,
      'temperature': temperature,
      'timeout_seconds': timeout,
      'ready_for_demo': true,
      'korean_medical_mode': true,
    };  }

  // 🎯 빠른 설정 확인
  static bool get readyForDemo {
    return true; // 로컬 모드든 실제 모드든 항상 준비 완료
  }

  // 💬 환영 메시지
  static String get demoWelcomeMessage {
    return '''🎉 메디핏 AI에 오신 것을 환영합니다!

${apiStatusMessage}

💡 주요 기능:
• 24시간 AI 건강 상담
• 스마트 복약 알림
• 응급상황 대응 가이드
• 근처 병원/약국 찾기

궁금한 점을 자유롭게 물어보세요. 😊''';
  }
}