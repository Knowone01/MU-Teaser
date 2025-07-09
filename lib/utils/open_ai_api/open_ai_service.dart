// gemini_service.dart
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mu_teaser/utils/auth_tokens.dart';

class GeminiService {
  static const String _apiKey =
      AuthTokens.aiAccessToken; // Get from ai.google.dev
  static final GenerativeModel _model = GenerativeModel(
    model: 'gemini-1.5-flash', // Free tier model
    apiKey: _apiKey,
  );

  /// Generate text response (FREE)
  static Future<String> generateText(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'No response generated';
    } catch (e) {
      throw Exception('Gemini API Error: $e');
    }
  }

  /// Chat conversation (FREE)
  static Future<String> chat(List<Map<String, String>> messages) async {
    try {
      final chatHistory = messages
          .map((msg) => Content.text(msg['content']!))
          .toList();
      final response = await _model.generateContent(chatHistory);
      return response.text ?? 'No response';
    } catch (e) {
      throw Exception('Chat Error: $e');
    }
  }

   static Future<String> analyzeAd(String adContent, String userQuestion) async {
    try {
      final prompt = """
You are an expert at analyzing advertisements. Please analyze this ad and answer the user's question.

Advertisement Content:
$adContent

User Question: $userQuestion

Please provide a helpful, detailed response about this advertisement. Focus on:
- Marketing strategies used
- Target audience
- Key messages
- Effectiveness
- Any concerns or observations

Keep your response conversational and informative.
""";

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'No response generated';
    } catch (e) {
      throw Exception('Ad Analysis Error: $e');
    }
  }
}

