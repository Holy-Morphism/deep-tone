import '../../domain/entities/voice_analysis_entity.dart';

class VoiceAnalysisModel extends VoiceAnalysisEntity {
  const VoiceAnalysisModel({
    required super.speechMetrics,
    required super.transcription,
    required super.overallScore,
  });

  factory VoiceAnalysisModel.fromApis({
    required Map<String, dynamic> dolbyResponse,
    required Map<String, dynamic> deepgramResponse,
  }) {
    final speechMetrics = _extractSpeechMetrics(dolbyResponse);
    final transcription = _extractTranscription(deepgramResponse);
    final overallScore = _calculateOverallScore(speechMetrics);

    return VoiceAnalysisModel(
      speechMetrics: speechMetrics,
      transcription: transcription,
      overallScore: overallScore,
    );
  }

  static SpeechMetricsEntity _extractSpeechMetrics(Map<String, dynamic> dolbyResponse) {
    final metrics = dolbyResponse['metrics'];
    
    return SpeechMetricsEntity(
      pitch: PitchMetrics(
        meanPitch: metrics['pitch']['mean'] ?? 0.0,
        variance: metrics['pitch']['variance'] ?? 0.0,
        minPitch: metrics['pitch']['min'] ?? 0.0,
        maxPitch: metrics['pitch']['max'] ?? 0.0,
        normalizedScore: _normalizePitchScore(metrics['pitch']['mean'] ?? 0.0),
      ),
      volume: VolumeMetrics(
        meanVolume: metrics['volume']['mean'] ?? 0.0,
        variance: metrics['volume']['variance'] ?? 0.0,
        consistency: metrics['volume']['consistency'] ?? 0.0,
        normalizedScore: 100 * (1 - (metrics['volume']['variance'] ?? 0.0)).toDouble(),
      ),
      pace: PaceMetrics(
        wordsPerMinute: metrics['pace']['wpm'] ?? 0.0,
        totalWords: metrics['pace']['total_words'] ?? 0,
        duration: metrics['pace']['duration'] ?? 0.0,
        normalizedScore: _normalizePaceScore(metrics['pace']['wpm'] ?? 0.0),
      ),
      articulationScore: metrics['articulation']['quality'] ?? 0.0,
      confidenceScore: metrics['confidence']['overall'] ?? 0.0,
    );
  }

  static TranscriptionEntity _extractTranscription(Map<String, dynamic> deepgramResponse) {
    final alternative = deepgramResponse['results']['channels'][0]['alternatives'][0];
    
    return TranscriptionEntity(
      text: alternative['transcript'] ?? '',
      words: (alternative['words'] as List?)
          ?.map((w) => WordEntity(
                word: w['word'],
                startTime: w['start']?.toDouble() ?? 0.0,
                endTime: w['end']?.toDouble() ?? 0.0,
                confidence: w['confidence']?.toDouble() ?? 0.0,
                punctuatedWord: w['punctuated_word'] ?? w['word'],
              ))
          .toList() ??
          [],
      confidence: alternative['confidence']?.toDouble() ?? 0.0,
      rawMetadata: deepgramResponse['metadata'] ?? {},
    );
  }

  static double _calculateOverallScore(SpeechMetricsEntity metrics) {
    const weights = {
      'pitch': 0.25,
      'volume': 0.15,
      'pace': 0.20,
      'articulation': 0.25,
      'confidence': 0.15,
    };

    return (metrics.pitch.normalizedScore * weights['pitch']!) +
        (metrics.volume.normalizedScore * weights['volume']!) +
        (metrics.pace.normalizedScore * weights['pace']!) +
        (metrics.articulationScore * 100 * weights['articulation']!) +
        (metrics.confidenceScore * 100 * weights['confidence']!);
  }

  static double _normalizePitchScore(double pitch) {
    const minIdealPitch = 85.0;
    const maxIdealPitch = 255.0;
    
    if (pitch < minIdealPitch) {
      return 100 * (pitch / minIdealPitch);
    } else if (pitch > maxIdealPitch) {
      return 100 * (maxIdealPitch / pitch);
    }
    return 100.0;
  }

  static double _normalizePaceScore(double wpm) {
    const idealWPM = 150.0;
    const tolerance = 30.0;
    
    final difference = (wpm - idealWPM).abs();
    if (difference <= tolerance) {
      return 100.0;
    }
    return 100.0 * (1 - (difference - tolerance) / idealWPM);
  }
}