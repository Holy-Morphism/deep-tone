import 'package:equatable/equatable.dart';

class VoiceAnalysisEntity extends Equatable {
  final SpeechMetricsEntity speechMetrics;
  final TranscriptionEntity transcription;
  final double overallScore;

  const VoiceAnalysisEntity({
    required this.speechMetrics,
    required this.transcription,
    required this.overallScore,
  });

  @override
  List<Object?> get props => [speechMetrics, transcription, overallScore];
}

class SpeechMetricsEntity extends Equatable {
  final PitchMetrics pitch;
  final VolumeMetrics volume;
  final PaceMetrics pace;
  final double articulationScore;
  final double confidenceScore;

  const SpeechMetricsEntity({
    required this.pitch,
    required this.volume,
    required this.pace,
    required this.articulationScore,
    required this.confidenceScore,
  });

  @override
  List<Object?> get props => [
        pitch,
        volume,
        pace,
        articulationScore,
        confidenceScore,
      ];
}

class PitchMetrics extends Equatable {
  final double meanPitch;
  final double variance;
  final double minPitch;
  final double maxPitch;
  final double normalizedScore;

  const PitchMetrics({
    required this.meanPitch,
    required this.variance,
    required this.minPitch,
    required this.maxPitch,
    required this.normalizedScore,
  });

  @override
  List<Object?> get props => [
        meanPitch,
        variance,
        minPitch,
        maxPitch,
        normalizedScore,
      ];
}

class VolumeMetrics extends Equatable {
  final double meanVolume;
  final double variance;
  final double consistency;
  final double normalizedScore;

  const VolumeMetrics({
    required this.meanVolume,
    required this.variance,
    required this.consistency,
    required this.normalizedScore,
  });

  @override
  List<Object?> get props => [
        meanVolume,
        variance,
        consistency,
        normalizedScore,
      ];
}

class PaceMetrics extends Equatable {
  final double wordsPerMinute;
  final int totalWords;
  final double duration;
  final double normalizedScore;

  const PaceMetrics({
    required this.wordsPerMinute,
    required this.totalWords,
    required this.duration,
    required this.normalizedScore,
  });

  @override
  List<Object?> get props => [
        wordsPerMinute,
        totalWords,
        duration,
        normalizedScore,
      ];
}

class TranscriptionEntity extends Equatable {
  final String text;
  final List<WordEntity> words;
  final double confidence;
  final Map<String, dynamic> rawMetadata;

  const TranscriptionEntity({
    required this.text,
    required this.words,
    required this.confidence,
    required this.rawMetadata,
  });

  @override
  List<Object?> get props => [text, words, confidence, rawMetadata];
}

class WordEntity extends Equatable {
  final String word;
  final double startTime;
  final double endTime;
  final double confidence;
  final String punctuatedWord;

  const WordEntity({
    required this.word,
    required this.startTime,
    required this.endTime,
    required this.confidence,
    required this.punctuatedWord,
  });

  @override
  List<Object?> get props => [
        word,
        startTime,
        endTime,
        confidence,
        punctuatedWord,
      ];
}