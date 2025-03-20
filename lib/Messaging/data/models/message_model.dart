import '../../domain/entities/message_entity.dart';
import 'speech_analysis_metrics_model.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.dateTime,
    required super.passage,
    required String super.report,
    required SpeechAnalysisMetricsModel super.speechAnalysisMetrics,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final m = MessageModel(
      dateTime: DateTime.parse(json['created_at']),
      passage: json['passage'],
      report: json['report'],
      speechAnalysisMetrics: SpeechAnalysisMetricsModel(
        transcript: json['transcript'],
        pitch: double.parse(json['pitch'].toString()),
        pace: double.parse(json['pace'].toString()),
        clarity: double.parse(json['clarity'].toString()),
        volume: double.parse(json['volume'].toString()),
        pronunciationAccuracy: double.parse(json['pronunciation'].toString()),
        confidence: double.parse(json['confidence'].toString()),
      ),
    );
    print(m);
    return m;
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': dateTime.toIso8601String(),
      'passage': passage,
      'report': report,
      'speechAnalysisMetrics':
          (speechAnalysisMetrics as SpeechAnalysisMetricsModel).toJson(),
    };
  }
}
