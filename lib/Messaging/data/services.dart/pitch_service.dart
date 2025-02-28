import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:deeptone/core/error/failure.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';

class PitchService {
  // Pitch detector is initialized when class is instantiated
  final PitchDetector _pitchDetector;

  // Constructor
  PitchService({double sampleRate = 44100, int bufferSize = 4096})
    : _pitchDetector = PitchDetector(
        audioSampleRate: sampleRate,
        bufferSize: bufferSize,
      );

  // Method using the class's pitch detector instance
  Future<Either<Failure, double>> detectPitch(Uint8List audioData) async {
    try {
      print('Starting pitch detection. Audio data length: ${audioData.length}');

      // Convert audio data to PCM16 format if needed
      List<int> pcm16Data = [];
      for (int i = 0; i < audioData.length; i += 2) {
        if (i + 1 < audioData.length) {
          int sample = (audioData[i + 1] << 8) | audioData[i];
          pcm16Data.add(sample);
        }
      }

      List<double> pitches = [];
      int validPitchCount = 0;

      // Process in overlapping windows for better detection
      for (
        var i = 0;
        i < pcm16Data.length - _pitchDetector.bufferSize;
        i += _pitchDetector.bufferSize ~/ 2
      ) {
        // Don't exceed the array bounds
        if (i + _pitchDetector.bufferSize > pcm16Data.length) break;

        final chunk = Uint8List.fromList(
          pcm16Data
              .sublist(i, i + _pitchDetector.bufferSize)
              .expand((x) => [x & 0xFF, (x >> 8) & 0xFF])
              .toList(),
        );

        // Use the class instance of the pitch detector
        final result = await _pitchDetector.getPitchFromIntBuffer(chunk);

        if (result.pitched && result.pitch >= 50 && result.pitch <= 500) {
          // Only accept reasonable human voice frequencies
          pitches.add(result.pitch);
          validPitchCount++;
          print('Valid pitch detected: ${result.pitch} Hz');
        }
      }

      print('Total valid pitches detected: $validPitchCount');

      if (pitches.isNotEmpty) {
        // Remove outliers
        pitches.sort();

        // Ensure we have enough data points for quartile calculation
        if (pitches.length < 4) {
          // If we have very few points, just use them all
          double averagePitch =
              pitches.reduce((a, b) => a + b) / pitches.length;
          print('Final average pitch (few samples): $averagePitch Hz');
          return Right(averagePitch);
        }

        var q1Index = (pitches.length * 0.25).floor();
        var q3Index = (pitches.length * 0.75).floor();
        var filtered = pitches.sublist(q1Index, q3Index + 1);

        double averagePitch =
            filtered.reduce((a, b) => a + b) / filtered.length;
        print('Final average pitch: $averagePitch Hz');
        return Right(averagePitch);
      } else {
        print('No valid pitches detected in the audio sample');
        return const Left(RecordingFailure('No valid pitch detected'));
      }
    } catch (e, stackTrace) {
      print('Pitch detection error: $e');
      print('Stack trace: $stackTrace');
      return Left(RecordingFailure('Pitch detection failed: ${e.toString()}'));
    }
  }

  // Additional helper method to check if audio contains speech
  Future<bool> containsVoice(
    Uint8List audioData, {
    double threshold = 0.5,
  }) async {
    final result = await detectPitch(audioData);

    return result.fold(
      (failure) => false, // No voice detected if there's a failure
      (pitch) => true, // Voice detected if we got a valid pitch
    );
  }

  // Get the current pitch detector configuration
  Map<String, dynamic> getConfiguration() {
    return {
      'sampleRate': _pitchDetector.audioSampleRate,
      'bufferSize': _pitchDetector.bufferSize,
    };
  }
}
