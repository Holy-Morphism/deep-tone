import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:deeptone/Messaging/data/models/voice_analysis_model.dart';
import 'package:deeptone/Messaging/domain/entities/model_message_entity.dart';

import 'package:deeptone/core/error/failure.dart';
import 'package:deeptone/core/prompt/prompt.dart';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:record/record.dart';

import '../../domain/repositories/messaging_repository.dart';
import '../datasources/dolby_service.dart';
import '../models/model_message_model.dart';

class MessagingRepositoryImplementation implements MessagingRepository {
  final Dio dio;
  final AudioRecorder record;
  final String openaiApiKey;
  final String deepGramApiKey;
  final String dolbyApiKey;
  final String dolbyAppSecret;
  late final DolbyService _dolbyService;


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
  }

  @override
  Future<Either<Failure, void>> startRecording() async {
    try {
      final Directory tempDir = await getTemporaryDirectory();

      final filePath =
          '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';

      print('Recording path: $filePath'); // Debug log

      if (await record.hasPermission()) {
        // Start recording with AAC format
        print('Mic permission granted, starting recording...'); // Debug log

        await record.start(
          const RecordConfig(
            encoder: AudioEncoder.wav, // Changed from aacLc to wav
            bitRate: 256000,
            sampleRate: 44100,
            numChannels: 1,
          ),
          path: filePath,
        );
        print('Recording started successfully'); // Debug log
        return const Right(null);
      }
      return Left(RecordingFailure('Permission not granted'));
    } catch (e) {
      return Left(RecordingFailure(e.toString()));
    }
  }

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

      final pitchDetector = PitchDetector(
        audioSampleRate: 44100,
        bufferSize: 4096, // Increased buffer size
      );

      List<double> pitches = [];
      int validPitchCount = 0;

      // Process in overlapping windows for better detection
      for (var i = 0; i < pcm16Data.length - 4096; i += 2048) {
        final chunk = Uint8List.fromList(
          pcm16Data
              .sublist(i, i + 4096)
              .expand((x) => [x & 0xFF, (x >> 8) & 0xFF])
              .toList(),
        );

        final result = await pitchDetector.getPitchFromIntBuffer(chunk);

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


  Future<Either<Failure, String>> analyzeAudioWithDeepgram(
    List<int> audioBytes,
  ) async {
    try {
      final response = await dio.post(
        'https://api.deepgram.com/v1/listen',
        data: Stream.fromIterable([audioBytes]),
        queryParameters: {'model': 'nova-2', 'smart_format': 'true'},
        options: Options(
          headers: {
            'Authorization': 'Token $deepGramApiKey',
            'Content-Type': 'audio/wav',
          },
          responseType: ResponseType.json,
        ),
      );

      if (response.statusCode != 200) {
        return Left(
          RecordingFailure('Deepgram API failed: ${response.statusCode}'),
        );
      }

      return Right(
        response
            .data['results']['channels'][0]['alternatives'][0]['transcript'],
      );
    } catch (e) {
      return Left(
        RecordingFailure('Deepgram analysis failed: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, ModelMessageEntity>> stopRecording() async {
    try {
      final path = await record.stop();
      print('Recording stopped, file path: $path'); // Debug log

     if (path == null) {
        print('No recording file path returned');
        return Left(RecordingFailure('Recording failed: No file path returned'));
      }

      final file = File(path);
      if (!await file.exists()) {
        return Left(RecordingFailure('Recording file not found'));
      }

      final bytes = await file.readAsBytes();
      final base64Audio = base64Encode(bytes);
      final filename = 'recording_${DateTime.now().millisecondsSinceEpoch}.wav';


       // Dolby.io Flow
      // 1. Get upload URL
      final uploadUrlResult = await _dolbyService.getUploadUrl(filename);
      final dolbyAnalysisResult =  uploadUrlResult.fold(
        (failure) => Left(failure),
        (uploadUrl) async {
          // 2. Upload file
          final uploadResult = await _dolbyService.uploadFile(uploadUrl, bytes);
          return uploadResult.fold(
            (failure) => Left(failure),
            (_) async {
              // 3. Start analysis
              final analysisResult = await _dolbyService.analyzeSpeech(filename);
              return analysisResult;
            },
          );
        },
      );

      // Parallel API calls for other services
      final Future<Either<Failure, String>> deepgramFuture =
          analyzeAudioWithDeepgram(bytes);
      final Future<Either<Failure, double>> pitchFuture = detectPitch(bytes);

      // Wait for all analyses to complete
      final results = await Future.wait([
        Future.value(dolbyAnalysisResult),
        deepgramFuture,
        pitchFuture,
      ]);

       // Extract results
      final dolbyResult = results[0] as Either<Failure, Map<String, dynamic>>;
      final deepgramResult = results[1] as Either<Failure, String>;
      final pitchResult = results[2] as Either<Failure, double>;



     // Create voice analysis model
      final voiceAnalysis = deepgramResult.fold(
        (failure) => null,
        (deepgramData) => dolbyResult.fold(
          (failure) => null,
          (dolbyData) => VoiceAnalysisModel.fromApis(
            dolbyResponse: dolbyData,
            deepgramResponse: {
              'results': {
                'channels': [
                  {
                    'alternatives': [
                      {'transcript': deepgramData}
                    ]
                  }
                ]
              }
            },
          ),
        ),
      );

      // After creating the voice analysis model, add this logging section:
      if (voiceAnalysis != null) {
        print('\n=== Voice Analysis Results ===');
        print('Speech Metrics:');
        print('- Pitch:');
        print('  • Mean: ${voiceAnalysis.speechMetrics.pitch.meanPitch} Hz');
        print('  • Variance: ${voiceAnalysis.speechMetrics.pitch.variance}');
        print(
          '  • Score: ${voiceAnalysis.speechMetrics.pitch.normalizedScore}/100',
        );

        print('\nVolume:');
        print('  • Mean: ${voiceAnalysis.speechMetrics.volume.meanVolume}');
        print(
          '  • Consistency: ${voiceAnalysis.speechMetrics.volume.consistency}%',
        );
        print(
          '  • Score: ${voiceAnalysis.speechMetrics.volume.normalizedScore}/100',
        );

        print('\nPace:');
        print(
          '  • Words per minute: ${voiceAnalysis.speechMetrics.pace.wordsPerMinute}',
        );
        print(
          '  • Total words: ${voiceAnalysis.speechMetrics.pace.totalWords}',
        );
        print('  • Duration: ${voiceAnalysis.speechMetrics.pace.duration}s');
        print(
          '  • Score: ${voiceAnalysis.speechMetrics.pace.normalizedScore}/100',
        );

        print(
          '\nArticulation Score: ${voiceAnalysis.speechMetrics.articulationScore * 100}/100',
        );
        print(
          'Confidence Score: ${voiceAnalysis.speechMetrics.confidenceScore * 100}/100',
        );
        print('\nOverall Score: ${voiceAnalysis.overallScore}/100');

        print('\nTranscription:');
        print('Text: ${voiceAnalysis.transcription.text}');
        print('Confidence: ${voiceAnalysis.transcription.confidence}');

        print('\nWord-by-word analysis:');
        for (var word in voiceAnalysis.transcription.words) {
          print(
            '• "${word.punctuatedWord}": ${(word.confidence * 100).toStringAsFixed(1)}% confidence',
          );
        }
        print('================================\n');
      } else {
        print('Warning: Voice analysis model creation failed');
        print(
          'Deepgram Result: ${deepgramResult.fold((failure) => 'Failed: ${failure.message}', (success) => 'Success')}',
        );
        print(
          'Dolby Result: ${dolbyResult.fold((failure) => 'Failed: ${failure.message}', (success) => 'Success')}',
        );
        print(
          'Pitch Result: ${pitchResult.fold((failure) => 'Failed: ${failure.message}', (success) => '$success Hz')}',
        );
      }

      // Then continue with the existing requestBody creation...

      final requestBody = {
        'model': 'gpt-4o-audio-preview-2024-12-17',
        'modalities': ['audio', 'text'],
        'audio': {'voice': 'alloy', 'format': 'wav'},
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a voice analyser expert. Please provide detailed review.',
          },
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': Prompts.prompt},
              {
                'type': 'input_audio',
                'input_audio': {'data': base64Audio, 'format': 'wav'},
              },
            ],
          },
        ],
      };

      final response = await dio.post(
        'https://api.openai.com/v1/chat/completions',
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $openaiApiKey',
          },
        ),
      );

      // Clean up temporary file
      await file.delete();


      if (response.data == null) {
        return Left(RecordingFailure('Empty response from API'));
      }

      return Right(ModelMessageModel.fromJson(response.data, base64Audio));
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
