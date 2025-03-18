import 'package:deeptone/Messaging/domain/entities/message_entity.dart';
import 'package:deeptone/core/error/failure.dart';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:record/record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../injection_container.dart';
import '../../domain/repositories/messaging_repository.dart';

import '../models/message_model.dart';
import '../models/speech_analysis_metrics_model.dart';
import '../services/deepgram_service.dart';
import '../services/dolby_service.dart';
import '../services/open_ai_service.dart';
import '../services/pitch_service.dart';
import '../services/recording_service.dart';

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
  late final OpenAIService _openAIService;
  late String _generatedPassage = "";
  late SpeechAnalysisMetricsModel _speechAnalysisMetricsModel;
  late String _report;

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
    _openAIService = OpenAIService(dio: dio, openaiApiKey: openaiApiKey);
  }

  @override
  Future<Either<Failure, void>> startRecording() async {
    return _recordingService.startRecording();
  }

  @override
  Future<Either<Failure, SpeechAnalysisMetricsModel>> stopRecording() async {
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

      print(dolbyResult.toString());

      // Default values in case any API call fails
      double confidenceScore = 0.0;
      double volumeScore = 0.0;
      double clarityScore = 0.0;
      double paceScore = 0.0;
      double pitchScore = 0.0;
      double pronunciationAccuracyScore = 0.0;
      String transcript = "";

      if (dolbyResult is Right) {
        final Map<String, dynamic> data = dolbyResult.value;
        confidenceScore = data['confidence'] ?? 0;
        clarityScore = data['quality_score'] ?? 0;
        volumeScore = data['loudness'] ?? 0;

        print("Confidence score: $confidenceScore");
        print("Clarity score: $clarityScore");
        print("Volume score: $volumeScore");
      }

      if (deepgramResult is Right) {
        final Map<String, dynamic> data = deepgramResult.value;
        transcript = data['transcript'] ?? "";
        paceScore = data['wordsPerMinute'] ?? 0.0;
      }
      print("Transcript: $transcript");
      print("Pace score: $paceScore");
      if (pitchResult is Right) {
        pitchScore = pitchResult.value ?? 0.0;
      }
      print("Pitch Score: $pitchScore");
      // Clean up temporary file

      if (_generatedPassage.isNotEmpty) {
        pronunciationAccuracyScore =
            ratio(_generatedPassage, transcript).toDouble();
      }

      print("Pronounicaation Accuracy :$pronunciationAccuracyScore");

      await file.delete();

      _speechAnalysisMetricsModel = SpeechAnalysisMetricsModel(
        pitch: pitchScore,
        pace: paceScore,
        clarity: clarityScore,
        volume: volumeScore,
        pronunciationAccuracy: pronunciationAccuracyScore,
        confidence: confidenceScore,
        transcript: transcript,
      );

      print(_speechAnalysisMetricsModel);

      return Right(_speechAnalysisMetricsModel);
    } catch (e) {
      print(e.toString());
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

  @override
  Future<Either<Failure, String>> generatePassage() async {
    try {
      _generatedPassage = await _openAIService.generatePassage();
      return Right(_generatedPassage);
    } catch (e) {
      return Left(APIFailure("Error Genrating Passage ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, MessageModel>> generateReport() async {
    try {
      _report = await _openAIService.generateReport(
        _speechAnalysisMetricsModel,
      );

      final message = MessageModel(
        dateTime: DateTime.now(),
        passage: _generatedPassage,
        report: _report,
        speechAnalysisMetrics: _speechAnalysisMetricsModel,
      );

      _postMessage(message);

      return Right(message);
    } catch (e) {
      return Left(RecordingFailure("Error while generating prompt $_report"));
    }
  }

  Future<Either<Failure, void>> _postMessage(MessageEntity message) async {
    try {
      final currentUser = locator<SupabaseClient>().auth.currentUser;

      await locator<SupabaseClient>().from('messages').insert({
        'user_id': currentUser!.id,
        'created_at': message.dateTime.toIso8601String(),
        'passage': message.passage,
        'report': message.report,
        'transcript': message.speechAnalysisMetrics!.transcript,
        'pitch': message.speechAnalysisMetrics!.pitch,
        'pace': message.speechAnalysisMetrics!.pace,
        'clarity': message.speechAnalysisMetrics!.clarity,
        'volume': message.speechAnalysisMetrics!.volume,
        'pronunciation_accuracy':
            message.speechAnalysisMetrics!.pronunciationAccuracy,
        'confidence': message.speechAnalysisMetrics!.confidence,
      });

      return const Right(null);
    } catch (e) {
      return Left(RecordingFailure('Failed to save message: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getMessages() async {
    // Return a dummy list of messages for testing
    // return Future.value(
    //   Right([
    //     MessageModel(
    //       dateTime: DateTime.now().subtract(const Duration(days: 1)),
    //       passage: "Sample passage 1",
    //       report: "Sample report 1",
    //       speechAnalysisMetrics: SpeechAnalysisMetricsModel(
    //         transcript: "Sample transcript 1",
    //         pitch: 0.8,
    //         pace: 0.7,
    //         clarity: 0.9,
    //         volume: 0.75,
    //         pronunciationAccuracy: 0.85,
    //         confidence: 0.9,
    //       ),
    //     ),
    //     MessageModel(
    //       dateTime: DateTime.now(),
    //       passage: "Sample passage 2",
    //       report: "Sample report 2",
    //       speechAnalysisMetrics: SpeechAnalysisMetricsModel(
    //         transcript: "Sample transcript 2",
    //         pitch: 0.7,
    //         pace: 0.8,
    //         clarity: 0.85,
    //         volume: 0.8,
    //         pronunciationAccuracy: 0.9,
    //         confidence: 0.85,
    //       ),
    //     ),
    //   ]),
    // );
    try {
      final currentUser = locator<SupabaseClient>().auth.currentUser;

      final data = await locator<SupabaseClient>()
          .from('messages')
          .select()
          .eq('user_id', currentUser!.id);

      final messages =
          data.map((message) => MessageModel.fromJson(message)).toList();

      return Right(messages);
    } catch (e) {
      return Left(
        RecordingFailure('Failed to fetch messages: ${e.toString()}'),
      );
    }
  }
}
