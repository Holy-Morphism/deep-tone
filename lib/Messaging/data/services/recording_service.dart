import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:deeptone/core/error/failure.dart';

class RecordingService {
  final AudioRecorder _audioRecorder;
  
  RecordingService({
    required AudioRecorder audioRecorder,
  }) : _audioRecorder = audioRecorder;
  
  /// Check if microphone permission is granted
  Future<Either<Failure, void>> checkMicPermission() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        return const Right(null);
      }
      return Left(MicError('Microphone permission not granted'));
    } catch (e) {
      return Left(RecordingFailure('Error checking microphone permission: ${e.toString()}'));
    }
  }
  
  /// Start recording audio
  Future<Either<Failure, void>> startRecording() async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
      
      print('Recording path: $filePath'); // Debug log

      if (await _audioRecorder.hasPermission()) {
        print('Mic permission granted, starting recording...'); // Debug log
        
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            bitRate: 256000,
            sampleRate: 44100,
            numChannels: 1,
          ),
          path: filePath,
        );
        
        print('Recording started successfully'); // Debug log
        return Right(null);
      }
      
      return Left(RecordingFailure('Permission not granted'));
    } catch (e) {
      print('Recording error: ${e.toString()}');
      return Left(RecordingFailure('Failed to start recording: ${e.toString()}'));
    }
  }
  
  /// Stop recording and return the file path
  Future<Either<Failure, File>> stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      print('Recording stopped, file path: $path'); // Debug log

      if (path == null) {
        print('No recording file path returned');
        return Left(RecordingFailure('Recording failed: No file path returned'));
      }

      final file = File(path);
      if (!await file.exists()) {
        return Left(RecordingFailure('Recording file not found'));
      }
      
      return Right(file);
    } catch (e) {
      return Left(RecordingFailure('Failed to stop recording: ${e.toString()}'));
    }
  }
  
  /// Record audio and return the file and bytes
  /// This combines startRecording and stopRecording in one method
  Future<Either<Failure, Map<String, dynamic>>> recordAudio(Duration duration) async {
    try {
      // Start recording
      final startResult = await startRecording();
      if (startResult.isLeft()) {
        return Left(startResult.fold(
          (failure) => failure, 
          (_) => RecordingFailure('Unknown error')
        ));
      }
      
      // Wait for the specified duration
      await Future.delayed(duration);
      
      // Stop recording
      final stopResult = await stopRecording();
      if (stopResult.isLeft()) {
        return Left(stopResult.fold(
          (failure) => failure, 
          (_) => RecordingFailure('Unknown error')
        ));
      }
      
      final file = stopResult.getOrElse(() => File(''));
      final bytes = await file.readAsBytes();
      
      return Right({
        'file': file,
        'bytes': bytes,
        'path': file.path,
        'base64': base64Encode(bytes),
        'filename': file.path.split('/').last,
      });
    } catch (e) {
      return Left(RecordingFailure('Recording process failed: ${e.toString()}'));
    }
  }
  
  /// Is recording in progress
  Future<bool> isRecording() async {
    return await _audioRecorder.isRecording();
  }
  
  /// Delete a recording file
  Future<Either<Failure, void>> deleteRecording(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
      return const Right(null);
    } catch (e) {
      return Left(RecordingFailure('Failed to delete recording: ${e.toString()}'));
    }
  }
}

