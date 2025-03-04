import 'dart:convert';
import 'package:dio/dio.dart';

import '../../domain/entities/speech_analysis_metrics_entity.dart';

class OpenAIService {
  final Dio dio;
  final String openaiApiKey;
  const OpenAIService({required this.dio, required this.openaiApiKey});

  Future<String> generatePassage() async {
    final response = await dio.post(
      'https://api.openai.com/v1/chat/completions',
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

  Future<String> generateReport(
    SpeechAnalysisMetricsEntity speechAnalysisMetricsModel,
  ) async {
    final String prompt = """
1. These parameters have been collected be a audio analysis system.
2. Based on these values, please generate a detailed report on how can one deepen voice.
3. Refer to the person reading the report as you
Transcript: ${speechAnalysisMetricsModel.transcript}

Pitch: ${speechAnalysisMetricsModel.pitch.toString()}

Pace: ${speechAnalysisMetricsModel.pace.toString()}

Clarity: ${speechAnalysisMetricsModel.clarity.toString()}

Volume: ${speechAnalysisMetricsModel.volume.toString()}

Pronunciation Accuracy: ${speechAnalysisMetricsModel.pronunciationAccuracy.toString()}

Confidence: ${speechAnalysisMetricsModel.confidence.toString()}

This as an example
### **Overview**  
A deep, resonant voice often carries a sense of authority and confidence. The way we speak—our pitch, pacing, clarity, and even how we breathe—plays a crucial role in how our voice is perceived. Small adjustments in vocal technique can make a significant impact, enhancing both the richness and depth of one's tone. 

### **Breaking Down the Decision**  
For each aspect of my voice, analyse its role in shaping voice depth:  
- **Pitch**: Does my pitch contribute to a higher or deeper tone?  
- **Pace**: How does speaking speed affect the perception of depth?  
- **Clarity**: Can improving articulation add more weight to my voice?  
- **Volume**: Does my current volume help or hinder a strong presence?  
- **Pronunciation Accuracy**: How does pronunciation impact depth and resonance?  
- **Confidence**: Does vocal confidence enhance depth, or does it need adjustments?  

### **Practical Recommendations**  
Provide specific exercises to develop a deeper voice:  
- **Breathing Techniques** (diaphragmatic breathing for better control).  
- **Resonance Training** (humming and chest resonance exercises).  
- **Pitch Control** (gliding from high to low to strengthen depth).  
- **Pace Adjustment** (slowing down for a more grounded sound).  
- **Pronunciation & Clarity** (tongue twisters for crisp articulation).  
- **Volume Control** (projection exercises to enhance vocal presence).  

### **Conclusion**  
Summarize the key takeaways and provide actionable steps to help refine and develop a deeper, more authoritative voice over time.
""";

    final response = await dio.post(
      'https://api.openai.com/v1/chat/completions',
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
