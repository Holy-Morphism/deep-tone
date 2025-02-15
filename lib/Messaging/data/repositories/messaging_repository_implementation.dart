import 'dart:convert';
import 'dart:io';

import 'package:ai_voice_coach/Messaging/domain/entities/model_message_entity.dart';

import 'package:ai_voice_coach/core/error/failure.dart';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
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
      final directory = await Directory.systemTemp.createTemp(
        'audio_recordings',
      );
      final filePath =
          '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';

      if (await record.hasPermission()) {
        // Start recording with AAC format
        await record.start(
          const RecordConfig(
            encoder: AudioEncoder.wav, // Changed from aacLc to wav
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: filePath,
        );
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
      if (path == null) {
        return Left(
          RecordingFailure('Recording failed: No file path returned'),
        );
      }

      final file = File(path);
      if (!await file.exists()) {
        return Left(RecordingFailure('Recording file not found'));
      }

      final bytes = await file.readAsBytes();
      final base64Audio = base64Encode(bytes);

      final requestBody = {
        'model': 'gpt-4o-audio-preview-2024-12-17',
        'modalities': ['audio', 'text'],
        'audio': {'voice': 'alloy', 'format': 'wav'},
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': 'What is in this recording?'},
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


      return Right(ModelMessageModel.fromJson(response.data));
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
