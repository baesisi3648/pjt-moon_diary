import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  // API key loaded from .env file (secure)
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  // 대화 맥락을 저장
  final List<Map<String, String>> _conversationHistory = [];

  // 대화 시작 - 첫 질문 생성
  Future<String> startConversation() async {
    _conversationHistory.clear();
    
    final systemPrompt = '''
너는 따뜻하고 공감 능력이 뛰어난 친구야. 사용자의 하루에 대해 자연스럽게 대화를 나누고 싶어해.
- 반말로 친근하게 대화해
- 한 번에 1-2개의 질문만 해
- 짧고 자연스럽게 대화해
- 이모지는 가끔씩만 사용해
- 사용자의 감정에 공감해줘

첫 인사와 함께 오늘 하루에 대해 물어봐.
''';

    final response = await _sendMessage(systemPrompt, isSystem: true);
    return response;
  }

  // 사용자가 일기 변환에 동의했는지 확인
  bool _userAgreedToConvert(String message) {
    final lowerMsg = message.toLowerCase().trim();
    final agreeWords = ['응', '어', '좋아', '그래', '네', '예', 'ㅇㅇ', 'ㅇ', '부탁', '해줘', '변환', '정리'];
    return agreeWords.any((word) => lowerMsg.contains(word));
  }

  // 이전 AI 메시지가 일기 변환을 제안했는지 확인
  bool _askedForConversion() {
    if (_conversationHistory.isEmpty) return false;
    final lastAiMsg = _conversationHistory.reversed
        .firstWhere((m) => m['role'] == 'assistant', orElse: () => {})['content'] ?? '';
    return lastAiMsg.contains('일기') && (lastAiMsg.contains('정리') || lastAiMsg.contains('변환') || lastAiMsg.contains('줄까'));
  }

  // 대화 계속하기
  Future<String> chat(String userMessage) async {
    _conversationHistory.add({'role': 'user', 'content': userMessage});

    // 사용자가 일기 변환에 동의한 경우 - 자동 변환 트리거
    if (_askedForConversion() && _userAgreedToConvert(userMessage)) {
      _shouldConvert = true;
      _autoConvertTriggered = true; // 자동 변환 플래그
      return ''; // 빈 응답 반환 (화면에서 바로 변환 시작)
    }

    final prompt = '''
이전 대화 맥락:
${_formatHistory()}

사용자의 마지막 말: "$userMessage"

따뜻하게 공감하고, 더 자세한 이야기를 들을 수 있도록 자연스럽게 질문해줘.
대화가 충분히 진행됐다고 느껴지면 (보통 3-4번의 대화 후) "일기로 정리해줄까?" 라고 물어봐.
짧게 1-2문장으로 답해.
''';

    final response = await _sendMessage(prompt);
    _conversationHistory.add({'role': 'assistant', 'content': response});
    return response;
  }
  
  bool _shouldConvert = false;
  bool _autoConvertTriggered = false;
  bool get shouldConvert => _shouldConvert;
  bool get autoConvertTriggered => _autoConvertTriggered;
  
  void resetAutoConvert() {
    _autoConvertTriggered = false;
  }

  // 대화 내용을 일기로 변환 (간결 버전 - 50% 축소)
  Future<String> convertToDiary() async {
    final prompt = '''
다음 대화 내용을 바탕으로 짧고 간결한 일기를 작성해줘:

${_formatHistory()}

작성 규칙:
- 1인칭 시점으로 작성
- 감성적이지만 간결한 문체
- 그날 있었던 일과 핵심 감정 위주로 기록
- 2-3문단, 총 150-200자 내외로 짧게
- 이모지 사용하지 않기
- 날짜나 제목 넣지 않기
- 바로 본문으로 시작
- 반드시 완전한 문장으로 끝내기
- 군더더기 없이 핵심만 담기
''';

    // 간결한 일기를 위해 토큰 수 조정
    final response = await _sendMessage(prompt, maxTokens: 512);
    return response;
  }

  // 기분 분석
  Future<String> analyzeMood() async {
    final prompt = '''
다음 대화 내용에서 사용자의 주된 감정을 분석해줘:

${_formatHistory()}

다음 중 하나만 답해 (다른 말 없이 단어만):
happy, sad, angry, love, sleepy, neutral
''';

    final response = await _sendMessage(prompt);
    final mood = response.trim().toLowerCase();
    
    // 유효한 기분인지 확인
    const validMoods = ['happy', 'sad', 'angry', 'love', 'sleepy', 'neutral'];
    if (validMoods.contains(mood)) {
      return mood;
    }
    return 'neutral';
  }

  // Gemini API 호출
  Future<String> _sendMessage(String prompt, {bool isSystem = false, int maxTokens = 1024}) async {
    try {
      final url = Uri.parse('$_baseUrl?key=$_apiKey');
      
      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.8,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': maxTokens,
        }
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          return text.trim();
        } else {
          throw Exception('응답이 비어있습니다');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('API 오류: ${errorData['error']?['message'] ?? response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 대화 기록 포맷팅
  String _formatHistory() {
    return _conversationHistory.map((msg) {
      final role = msg['role'] == 'user' ? '사용자' : 'AI';
      return '$role: ${msg['content']}';
    }).join('\n');
  }

  // 대화 기록 초기화
  void clearHistory() {
    _conversationHistory.clear();
  }

  // 대화 횟수 반환
  int get conversationCount => _conversationHistory.where((m) => m['role'] == 'user').length;
}
