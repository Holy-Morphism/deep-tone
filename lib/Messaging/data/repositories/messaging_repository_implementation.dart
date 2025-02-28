import 'package:deeptone/Messaging/domain/entities/model_message_entity.dart';

import 'package:deeptone/core/error/failure.dart';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:record/record.dart';

import '../../domain/repositories/messaging_repository.dart';
import '../datasources/deepgram_service.dart';
import '../datasources/dolby_service.dart';
import '../datasources/pitch_service.dart';
import '../services.dart/recording_service.dart';

class MessagingRepositoryImplementation implements MessagingRepository {
  final Dio dio;
  final AudioRecorder record;
  final String openaiApiKey;
  final String deepGramApiKey;
  final String dolbyApiKey;
  final String dolbyAppSecret;
  late final DolbyService _dolbyService;
  late final PitchService _pitchService;
  late final DeepgramService _deepgramService;
  late final RecordingService _recordingService;

  MessagingRepositoryImplementation({
    required this.dio,
    required this.record,
    required this.openaiApiKey,
    required this.deepGramApiKey,
    required this.dolbyApiKey,
    required this.dolbyAppSecret,
  }) {
    _dolbyService = DolbyService(
      apiKey: dolbyApiKey,
      appSecret: dolbyAppSecret,
      dio: dio,
    );
    _deepgramService = DeepgramService(dio: dio, apiKey: deepGramApiKey);
    _pitchService = PitchService();
    _recordingService = RecordingService(audioRecorder: AudioRecorder());
  }

  @override
  Future<Either<Failure, void>> startRecording() async {
    return _recordingService.startRecording();
  }

  @override
  Future<Either<Failure, ModelMessageEntity>> stopRecording() async {
    try {
      final result = await _recordingService.stopRecording();
      if (result.isLeft()) {
        return result.fold(
          (failure) => Left(failure),
          (_) => throw Exception('Unreachable'),
        );
      }
      final file = result.fold(
        (_) => throw Exception('Unreachable'),
        (success) => success,
      );

      final bytes = await file.readAsBytes();
      //final base64Audio = base64Encode(bytes);
      final filename = 'recording_${DateTime.now().millisecondsSinceEpoch}.wav';

      // Dolby.io Flow
      // 1. Get upload URL
      final uploadUrlResult = await _dolbyService.getUploadUrl(filename);
      final dolbyAnalysisResult = uploadUrlResult.fold(
        (failure) => Left(failure),
        (uploadUrl) async {
          // 2. Upload file
          final uploadResult = await _dolbyService.uploadFile(uploadUrl, bytes);
          return uploadResult.fold((failure) => Left(failure), (_) async {
            // 3. Start analysis
            await _dolbyService.analyzeSpeech(filename);
            final analysisResult = await _dolbyService.getOutput(filename);

            return analysisResult;
          });
        },
      );

      // Parallel API calls for other services
      final Future<Either<Failure, dynamic>> deepgramFuture = _deepgramService
          .analyzeAudio(bytes);
      final Future<Either<Failure, double>> pitchFuture = _pitchService
          .detectPitch(bytes);

      // Wait for all analyses to complete
      final results = await Future.wait([
        Future.value(dolbyAnalysisResult),
        deepgramFuture,
        pitchFuture,
      ]);

      // Extract results
      final dolbyResult = results[0];
      final deepgramResult = results[1];
      final pitchResult = results[2];

      print("Dolby result ${dolbyResult}");
      print("deep gram result :${deepgramResult}");
      print("pitch result :${pitchResult}");

      if (dolbyResult is Right) {
        final Map<String, dynamic> data = dolbyResult.value;

        double confidence =
            data['processed_region']['audio']['speech']['details'][0]['sections'][0]['confidence'];
        double qualityScore =
            data['processed_region']['audio']['speech']['details'][0]['quality_score'];
        double loudness =
            data['processed_region']['audio']['speech']['details'][0]['loudness']['measured'];
        print(confidence);
        print(qualityScore);
        print(loudness);
      }

      // Clean up temporary file
      await file.delete();

      return Right(
        ModelMessageEntity(
          report: "report",
          pitch: 0,
          pace: 0,
          clarity: 0,
          volume: 0,
          pronunciationAccuracy: 0,
          confidence: 0,
        ),
      );
    } catch (e) {
      return Left(
        RecordingFailure('Recording process failed: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> getMicPermission() async {
    try {
      if (await record.hasPermission()) {
        return Right(null);
      }
      return Left(MicError('Enable to Retreive mic'));
    } catch (e) {
      return Left(RecordingFailure('Retreiving Mic Erros'));
    }
  }
}
