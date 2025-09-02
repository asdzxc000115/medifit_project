// lib/services/gemini_service.dart

import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/config/gemini_config.dart';

class GeminiService {
  /// 🤖 메인 AI 채팅 (Gemini API 사용)
  Future<Map<String, dynamic>> chatWithAI(String userMessage) async {
    print('💬 Gemini AI 채팅 요청: $userMessage');

    // API 키가 설정되었는지 확인
    if (!GeminiConfig.isApiKeyValid) {
      print('❌ Gemini API 키가 설정되지 않았습니다.');
      return _fallbackResponse();
    }

    try {
      // Gemini 모델 초기화
      final model = GenerativeModel(
        model: GeminiConfig.defaultModel,
        apiKey: GeminiConfig.apiKey,
        // 시스템 지침 설정
        systemInstruction: Content.text(GeminiConfig.systemPrompt),
      );

      print('🔄 Gemini API 호출 중...');
      // 사용자 메시지로 콘텐츠 생성 요청
      final response = await model
          .generateContent([Content.text(userMessage)])
          .timeout(const Duration(seconds: 20));

      print('✅ Gemini API 성공 응답');
      final aiResponse = response.text ?? '죄송합니다. 답변을 생성하는 데 실패했습니다.';

      return {
        'success': true,
        'message': aiResponse,
        'source': 'gemini_api',
      };
    } catch (e) {
      print('❌ Gemini API 오류: $e');
      // 타임아웃 또는 기타 오류 발생 시 대체 응답 반환
      return _fallbackResponse();
    }
  }

  /// 🚨 API 실패 시 대체 응답
  Map<String, dynamic> _fallbackResponse() {
    return {
      'success': true, // UI가 깨지지 않도록 성공으로 처리
      'message': '''안녕하세요! 메디핏 AI입니다. 😊

현재 서버와의 연결이 원활하지 않습니다. 잠시 후 다시 시도해 주세요.

일반적인 건강 관리 수칙으로는 충분한 수분 섭취와 규칙적인 생활 습관이 중요합니다.

불편하시겠지만, 증상이 지속될 경우 가까운 병원을 방문하여 전문가와 상담하시는 것을 권장합니다. 🏥''',
      'source': 'fallback',
    };
  }
}