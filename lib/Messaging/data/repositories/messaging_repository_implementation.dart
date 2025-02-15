import 'dart:convert';
import 'dart:io';

import 'package:ai_voice_coach/Messaging/domain/entities/model_message_entity.dart';

import 'package:ai_voice_coach/core/error/failure.dart';
import 'package:ai_voice_coach/core/prompt/prompt.dart';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../domain/repositories/messaging_repository.dart';
import '../models/model_message_model.dart';

class MessagingRepositoryImplementation implements MessagingRepository {
  final Dio dio;
  final AudioRecorder record;
  final String openaiApiKey;
  const MessagingRepositoryImplementation({
    required this.dio,
    required this.record,
    required this.openaiApiKey,
  });

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
            bitRate: 128000,
            sampleRate: 44100,
            numChannels: 1, // Add this
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

  @override
  Future<Either<Failure, ModelMessageEntity>> stopRecording() async {
    try {
      final path = await record.stop();
      print('Recording stopped, file path: $path'); // Debug log

      if (path == null) {
        print('No recording file path returned'); // Debug log
        return Left(
          RecordingFailure('Recording failed: No file path returned'),
        );
      }

      final file = File(path);
      final exists = await file.exists();
      print('File exists: $exists'); // Debug log

      if (!await file.exists()) {
        return Left(RecordingFailure('Recording file not found'));
      }

      final bytes = await file.readAsBytes();
      print('File size: ${bytes.length} bytes'); // Debug log
      final base64Audio = base64Encode(bytes);

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

      if (response.statusCode != 200) {
        return Left(
          RecordingFailure('API request failed: ${response.statusCode}'),
        );
      }

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
