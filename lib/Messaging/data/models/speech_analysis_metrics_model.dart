import '../../domain/entities/speech_analysis_metrics_entity.dart';

class SpeechAnalysisMetricsModel extends SpeechAnalysisMetricsEntity {
  SpeechAnalysisMetricsModel({
    required super.transcript,
    required super.pitch,
    required super.pace,
    required super.clarity,
    required super.volume,
    required super.pronunciationAccuracy,
    required super.confidence,
  });

  factory SpeechAnalysisMetricsModel.fromJson(Map<String, dynamic> json) {
    return SpeechAnalysisMetricsModel(
      transcript: json['transcript'] as String,
      pitch: json['pitch'] as double,
      pace: json['pace'] as double,
      clarity: json['clarity'] as double,
      volume: json['volume'] as double,
      pronunciationAccuracy: json['pronunciationAccuracy'] as double,
      confidence: json['confidence'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transcript': transcript,
      'pitch': pitch,
      'pace': pace,
      'clarity': clarity,
      'volume': volume,
      'pronunciationAccuracy': pronunciationAccuracy,
      'confidence': confidence,
    };
  }
}
