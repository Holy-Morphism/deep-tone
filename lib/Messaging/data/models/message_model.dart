import '../../domain/entities/message_entity.dart';
import 'speech_analysis_metrics_model.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required DateTime dateTime,
    required String passage,
    required String report,
    required SpeechAnalysisMetricsModel speechAnalysisMetrics,
  }) : super(dateTime, passage, report, speechAnalysisMetrics);

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      dateTime: DateTime.parse(json['dateTime']),
      passage: json['passage'],
      report: json['report'],
      speechAnalysisMetrics: SpeechAnalysisMetricsModel.fromJson(
        json['speechAnalysisMetrics'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateTime': dateTime.toIso8601String(),
      'passage': passage,
      'report': report,
      'speechAnalysisMetrics':
          (speechAnalysisMetrics as SpeechAnalysisMetricsModel).toJson(),
    };
  }
}
