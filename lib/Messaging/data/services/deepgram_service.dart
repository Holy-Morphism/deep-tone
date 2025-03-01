import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:deeptone/core/error/failure.dart';
import 'package:dio/dio.dart';

class DeepgramService {
  final Dio _dio;
  final String _apiKey;
  final String _baseUrl = 'https://api.deepgram.com/v1';
  
  // Constructor 
  DeepgramService({
    required Dio dio,
    required String apiKey,
  }) : _dio = dio,
       _apiKey = apiKey;

  /// Transcribes audio data using Deepgram's API
  /// 
  /// [audioBytes] - The raw audio bytes to transcribe
  /// [model] - The Deepgram model to use (defaults to 'nova-2')
  /// [mimetype] - MIME type of the audio (defaults to 'audio/wav')
  /// [smartFormat] - Whether to use smart formatting (defaults to true)
  Future<Either<Failure, Map<String, dynamic>>> transcribeAudio({
    required Uint8List audioBytes,
    String model = 'nova-2',
    String mimetype = 'audio/wav',
    bool smartFormat = true,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/listen',
        data: Stream.fromIterable([audioBytes]),
        queryParameters: {
          'model': model,
          'smart_format': smartFormat.toString(),
        },
        options: Options(
          headers: {
            'Authorization': 'Token $_apiKey',
            'Content-Type': mimetype,
          },
          responseType: ResponseType.json,
        ),
      );

      if (response.statusCode != 200) {
        return Left(
          RecordingFailure('Deepgram API failed with status code: ${response.statusCode}'),
        );
      }

      return Right(response.data);
    } catch (e, stackTrace) {
      print('Deepgram transcription error: $e');
      print('Stack trace: $stackTrace');
      return Left(
        RecordingFailure('Deepgram transcription failed: ${e.toString()}'),
      );
    }
  }

  /// Extract just the transcript text from a full Deepgram response
  /// 
  /// [deepgramResponse] - The full response from Deepgram's API
  String extractTranscript(Map<String, dynamic> deepgramResponse) {
    try {
      return deepgramResponse['results']['channels'][0]['alternatives'][0]['transcript'];
    } catch (e) {
      print('Error extracting transcript: $e');
      return '';
    }
  }

  /// Gets the confidence score from a Deepgram response
  /// 
  /// [deepgramResponse] - The full response from Deepgram's API
  double extractConfidence(Map<String, dynamic> deepgramResponse) {
    try {
      return deepgramResponse['results']['channels'][0]['alternatives'][0]['confidence'] ?? 0.0;
    } catch (e) {
      print('Error extracting confidence: $e');
      return 0.0;
    }
  }

  /// Extract words with timestamps and confidence from the Deepgram response
  /// 
  /// [deepgramResponse] - The full response from Deepgram's API
  List<Map<String, dynamic>> extractWords(Map<String, dynamic> deepgramResponse) {
    try {
      final List<dynamic> rawWords = deepgramResponse['results']['channels'][0]['alternatives'][0]['words'] ?? [];
      return rawWords.map((word) => {
        'word': word['word'],
        'punctuatedWord': word['punctuated_word'] ?? word['word'],
        'startTime': word['start'] ?? 0.0,
        'endTime': word['end'] ?? 0.0,
        'confidence': word['confidence'] ?? 0.0,
      }).toList().cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error extracting words: $e');
      return [];
    }
  }

  /// Simplified method to get just the transcript text from audio bytes
  /// 
  /// [audioBytes] - The raw audio bytes to transcribe
  Future<Either<Failure, String>> getTranscript(Uint8List audioBytes) async {
    final result = await transcribeAudio(audioBytes: audioBytes);
    
    return result.fold(
      (failure) => Left(failure),
      (response) => Right(extractTranscript(response)),
    );
  }

  /// Analyze audio for metrics like speaking rate and filler words
  /// 
  /// [audioBytes] - The raw audio bytes to analyze
  Future<Either<Failure, Map<String, dynamic>>> analyzeAudio(Uint8List audioBytes) async {
    final result = await transcribeAudio(
      audioBytes: audioBytes,
      model: 'nova-2', // Using the most accurate model
      smartFormat: true,
    );
    
    return result.fold(
      (failure) => Left(failure),
      (response) {
        try {
          final transcript = extractTranscript(response);
          final words = extractWords(response);
          
          // Calculate speaking rate (words per minute)
          double durationInMinutes = 0;
          if (words.isNotEmpty) {
            durationInMinutes = words.last['endTime'] / 60.0;
          }
          
          final wordsPerMinute = durationInMinutes > 0 
              ? words.length / durationInMinutes 
              : 0;
              
          // Count filler words
          // final fillerWordPatterns = [
          //   RegExp(r'\bum\b', caseSensitive: false),
          //   RegExp(r'\buh\b', caseSensitive: false),
          //   RegExp(r'\blike\b', caseSensitive: false),
          //   RegExp(r'\byou know\b', caseSensitive: false),
          //   RegExp(r'\bactually\b', caseSensitive: false),
          //   RegExp(r'\bbasically\b', caseSensitive: false),
          // ];
          
          // int fillerWordCount = 0;
          // for (var pattern in fillerWordPatterns) {
          //   fillerWordCount += pattern.allMatches(transcript).length;
          // }
          
          // Metrics to return
          return Right({
            'transcript': transcript,
           // 'confidence': extractConfidence(response),
            'words': words,
            'wordsPerMinute': wordsPerMinute,
            
          });
        } catch (e) {
          return Left(RecordingFailure('Failed to analyze audio: ${e.toString()}'));
        }
      },
    );
  }
}