// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class ModelMessageEntity extends Equatable {
  final String report;
  final double pitch;
  final double pace;
  final double clarity;
  final double volume;
  final double pronunciationAccuracy;
  final double confidence;
  final double overallScore;

  // Constructor with calculated overall score
  ModelMessageEntity({
    required this.report,
    required this.pitch,
    required this.pace,
    required this.clarity,
    required this.volume,
    required this.pronunciationAccuracy,
    required this.confidence,
  }) : overallScore = _calculateOverallScore(
          pitch,
          pace,
          clarity,
          volume,
          pronunciationAccuracy,
          confidence,
        );

  // Named constructor that allows explicitly setting the overall score
  const ModelMessageEntity.withOverallScore({
    required this.report,
    required this.pitch,
    required this.pace,
    required this.clarity,
    required this.volume,
    required this.pronunciationAccuracy,
    required this.confidence,
    required this.overallScore,
  });

  // Static method to calculate the overall score
  static double _calculateOverallScore(
    double pitch,
    double pace,
    double clarity,
    double volume,
    double pronunciationAccuracy,
    double confidence,
  ) {
    return 0.25 * pitch +
        0.15 * pace +
        0.20 * clarity +
        0.15 * volume +
        0.15 * pronunciationAccuracy +
        0.10 * confidence;
  }

  @override
  List<Object> get props {
    return [
      report,
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