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
    return MessageModel(
      dateTime: DateTime.parse(json['created_at']),
      passage: json['passage'],
      report: json['report'],
      speechAnalysisMetrics: SpeechAnalysisMetricsModel.fromJson(
        json['speechAnalysisMetrics'],
      ),
    );
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
