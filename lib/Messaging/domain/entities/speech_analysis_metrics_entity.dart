// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class SpeechAnalysisMetricsEntity extends Equatable {
  final String transcript;
  final double pitch;
  final double pace;
  final double clarity;
  final double volume;
  final double pronunciationAccuracy;
  final double confidence;
  final double overallScore;

  const SpeechAnalysisMetricsEntity({
    required this.transcript,
    required this.pitch,
    required this.pace,
    required this.clarity,
    required this.volume,
    required this.pronunciationAccuracy,
    required this.confidence,
    required this.overallScore,
  });

  @override
  List<Object> get props {
    return [
      transcript,
      pitch,
      pace,
      clarity,
      volume,
      pronunciationAccuracy,
      confidence,
      overallScore,
    ];
  }
}
