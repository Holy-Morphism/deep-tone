// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

import 'speech_analysis_metrics_entity.dart';

class MessageEntity extends Equatable {
  final DateTime dateTime;
  final String passage;
  final String report;
  final SpeechAnalysisMetricsEntity speechAnalysisMetrics;

  const MessageEntity(
    this.dateTime,
    this.passage,
    this.report,
    this.speechAnalysisMetrics,
  );

  @override
  List<Object> get props => [dateTime, passage, report, speechAnalysisMetrics];
}
