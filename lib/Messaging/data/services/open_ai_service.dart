import 'dart:convert';
import 'package:dio/dio.dart';

class OpenAIService {
  final Dio dio;
  final String openaiApiKey;
  const OpenAIService({required this.dio, required this.openaiApiKey});

  Future<String> generatePassage() async {
    final response = await dio.post(
      ' https://api.openai.com/v1/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer $openaiApiKey',
          'Content-Type': 'application/json',
        },
      ),
      data: json.encode({
        "model": "gpt-4o",
        "store": true,
        "messages": [
          {
            "role": "system",
            "content": "You are an expert speech analysis therapist.",
          },
          {
            "role": "user",
            "content":
                "1. Please generate a small passage.\n2. The Passage should be of 3 to 4 lines.\n3. The passage could be a random story.\n4. Don't make up words.",
          },
        ],
      }),
    );
    if (response.statusCode != 200) {
      print("Error genraating Passage: ${response.statusMessage}");
    }

    final Map<String, dynamic> data = response.data;

    final choices = data['choices'];
    final message = choices[0]["message"];
    final String content = message["content"] ?? "";

    return content;
  }

  Future<String> generateReport({
    required String transcript,
    required double pitch,
    required double pace,
    required double clarity,
    required double volume,
    required double pronunciationAccuracy,
    required double confidence,
  }) async {
    final String prompt = """
I have collected several parameters related to my voice from an audio analysis system. Here are the details:
Transcript: $transcript
Pitch: ${pitch.toString()}
Pace:  ${pace.toString()}
Clarity:  ${clarity.toString()}
Volume:  ${volume.toString()}
Pronunciation Accuracy:  ${pronunciationAccuracy.toString()}
Confidence:  ${confidence.toString()}
Based on these values, please generate a detailed report on how I can deepen my voice. The report should analyze my current voice characteristics, highlight areas that contribute to a higher or weaker pitch, and provide practical recommendations for lowering my voice tone.
Additionally, include actionable exercises (such as breathing techniques, resonance training, or articulation improvements) that would help me develop a deeper and more authoritative voice. If possible, explain how each factor (e.g., pitch, pace, clarity) influences voice depth and how I can improve them.
                """;

    final response = await dio.post(
      ' https://api.openai.com/v1/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer $openaiApiKey',
          'Content-Type': 'application/json',
        },
      ),
      data: json.encode({
        "model": "gpt-4o",
        "store": true,
        "messages": [
          {
            "role": "system",
            "content": "You are an expert speech analysis therapist.",
          },
          {"role": "user", "content": prompt},
        ],
      }),
    );
    if (response.statusCode != 200) {
      print("Error genrating Report: ${response.statusMessage}");
    }

    final Map<String, dynamic> data = response.data;

    final choices = data['choices'];
    final message = choices[0]["message"];
    final String content = message["content"] ?? "";

    print(content);
    return content;
  }
}
