import '../../domain/entities/speech_analysis_metrics_entity.dart';

class SpeechAnalysisMetricsModel extends SpeechAnalysisMetricsEntity {
  const SpeechAnalysisMetricsModel({
    required super.transcript,
    required super.pitch,
    required super.pace,
    required super.clarity,
    required super.volume,
    required super.pronunciationAccuracy,
    required super.confidence,
    required super.overallScore,
  });
}
