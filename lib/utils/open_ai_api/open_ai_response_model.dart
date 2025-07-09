class HFResponse {
  final String generatedText;

  HFResponse({required this.generatedText});

  factory HFResponse.fromJson(dynamic json) {
    // json is a List<dynamic>
    final first = json[0];
    return HFResponse(generatedText: first['generated_text']);
  }
}
