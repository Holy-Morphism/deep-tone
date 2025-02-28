import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:deeptone/core/error/failure.dart';
import 'package:dartz/dartz.dart';

class DolbyService {
  final Dio dio;
  final String apiKey;
  final String appSecret;
  String? _accessToken;
  DateTime? _tokenExpiry;

  DolbyService({
    required this.dio,
    required this.apiKey,
    required this.appSecret,
  }) {
    _initializeToken();
  }

  Future<void> _initializeToken() async {
    print('Initializing Dolby token...');
    final tokenResult = await getAccessToken();
    tokenResult.fold(
      (failure) =>
          print('Failed to initialize Dolby token: ${failure.message}'),
      (token) => print('Dolby token initialized successfully'),
    );
  }

  Future<Either<Failure, String>> getAccessToken() async {
    try {
      // Check if we have a valid token
      if (_accessToken != null &&
          _tokenExpiry != null &&
          DateTime.now().isBefore(_tokenExpiry!)) {
        return Right(_accessToken!);
      }

      // Create Basic Auth token
      final auth = base64Encode(utf8.encode('$apiKey:$appSecret'));

      final response = await dio.post(
        'https://api.dolby.io/v1/auth/token',
        options: Options(
          headers: {
            'Authorization': 'Basic $auth',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
        data: 'grant_type=client_credentials&expires_in=1800',
      );

      if (response.statusCode != 200) {
        print('Dolby auth failed: ${response.statusCode}');
        return Left(RecordingFailure('Dolby authentication failed'));
      }

      _accessToken = response.data['access_token'];
      _tokenExpiry = DateTime.now().add(
        Duration(seconds: response.data['expires_in'] ?? 1800),
      );

      print('Dolby token obtained successfully');
      return Right(_accessToken!);
    } catch (e) {
      print('Dolby auth error: $e');
      return Left(
        RecordingFailure('Dolby authentication failed: ${e.toString()}'),
      );
    }
  }

  String? get currentToken => _accessToken;
  bool get hasValidToken =>
      _accessToken != null &&
      _tokenExpiry != null &&
      DateTime.now().isBefore(_tokenExpiry!);

  Future<Either<Failure, String>> getUploadUrl(String filename) async {
    if (!hasValidToken) {
      return Left(RecordingFailure('No valid token available'));
    }

    try {
      final response = await dio.post(
        'https://api.dolby.com/media/input',
        options: Options(
          headers: {
            'Authorization': 'Bearer $currentToken',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
        data: {'url': 'dlb://in/$filename'},
      );

      if (response.statusCode != 200) {
        return Left(RecordingFailure('Failed to get upload URL'));
      }

      if (!response.data.containsKey('url')) {
        return Left(RecordingFailure('Invalid response format'));
      }

      return Right(response.data['url']);
    } catch (e) {
      return Left(RecordingFailure('Failed to get upload URL: $e'));
    }
  }

  Future<Either<Failure, void>> uploadFile(
    String uploadUrl,
    List<int> fileBytes,
  ) async {
    try {
      final response = await dio.put(
        uploadUrl,
        options: Options(
          headers: {
            'Content-Type': 'application/octet-stream',
            'Transfer-Encoding': 'chunked',
          },
          // Add validateStatus to handle different status codes
          validateStatus: (status) => status! < 400,
        ),
        data: fileBytes,
      );

      if (response.statusCode != 200) {
        print('Upload failed: ${response.statusCode}');
        return Left(
          RecordingFailure(
            'File upload failed with status: ${response.statusCode}',
          ),
        );
      }

      print('File uploaded successfully');
      return const Right(null);
    } catch (e) {
      print('Error uploading file: $e');
      return Left(RecordingFailure('File upload failed: ${e.toString()}'));
    }
  }

  // Replace the entire analyzeSpeech method
  Future<Either<Failure, Map<String, dynamic>>> analyzeSpeech(
    String inputFilename,
  ) async {
    try {
      if (!hasValidToken) {
        return Left(RecordingFailure('No valid token available'));
      }

      print('File Name $inputFilename');
      print(
        "file anme aft json tag ${inputFilename.replaceAll('.wav', '-metadata.json')}",
      );

      final response = await dio.post(
        'https://api.dolby.com/media/analyze/speech',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_accessToken',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
        data: jsonEncode({
          "input": "dlb://in/$inputFilename",
          "output":
              "dlb://out/${inputFilename.replaceAll('.wav', '-metadata.json')}",
        }),
      );

      if (response.statusCode != 200) {
        print('Speech analysis failed: ${response.statusCode}');
        return Left(RecordingFailure('Speech analysis failed'));
      }

      print('Speech analysis job initiated successfully');
      print('Response data: ${jsonEncode(response.data)}');

      // Get the job ID from the response
      final jobId = response.data['job_id'];

      // Poll for job completion
      int attempts = 0;
      while (attempts < 30) {
        final jobStatusResult = await getJobStatus(jobId);

        if (jobStatusResult.isLeft()) {
          // If we got a failure, return it
          return jobStatusResult;
        }

        // Extract status data from Right
        final statusData = jobStatusResult.fold(
          (l) =>
              <
                String,
                dynamic
              >{}, // This won't be used because we checked isLeft above
          (r) => r,
        );

        // Check if job is complete
        if (statusData['status'] == 'Success') {
          return Right(statusData);
        } else if (statusData['status'] == 'failed') {
          return Left(RecordingFailure('Speech analysis job failed'));
        }

        // Wait before checking again
        await Future.delayed(const Duration(seconds: 2));
        attempts++;
      }

      return Left(RecordingFailure('Speech analysis timeout'));
    } catch (e) {
      print('Error analyzing speech: $e');
      return Left(RecordingFailure('Speech analysis failed: $e'));
    }
  }

  // Add this method to the DolbyService class
  Future<Either<Failure, Map<String, dynamic>>> getJobStatus(
    String jobId,
  ) async {
    try {
      if (!hasValidToken) {
        return Left(RecordingFailure('No valid token available'));
      }

      try {
        final response = await dio.get(
          'https://api.dolby.com/media/analyze/speech?job_id=$jobId',
          options: Options(
            headers: {
              'Authorization': 'Bearer $currentToken',
              'Accept': 'application/json',
            },
          ),
        );

        if (response.statusCode != 200) {
          print('Job status check failed: ${response.statusCode}');
          return Left(RecordingFailure('Failed to get job status'));
        }

        final status = response.data['status'];
        print('Job status: $status');

        if (status == 'failed') {
          return Left(RecordingFailure('Speech analysis job failed'));
        }

        return Right(response.data);
      } catch (e) {
        print('Error checking job status: $e');
        return Left(RecordingFailure('Failed to get job status: $e'));
      }
    } catch (e) {
      print('Error in getJobStatus: $e');
      return Left(RecordingFailure('Failed to get job status: $e'));
    }
  }

  // Example usage
  // final jobId = 'd66a60e8-2a28-4aa2-8727-a5ceda6410a1';
  // final statusResult = await dolbyService.getJobStatus(jobId);
  // statusResult.fold(
  //   (failure) => print('Status check failed: ${failure.message}'),
  //   (result) {
  //     final status = result['status'];
  //     if (status == 'complete') {
  //       print('Analysis complete: ${json.encode(result['result'])}');
  //     } else {
  //       print('Job status: $status');
  //     }
  //   },
  // );
  // Add this method to the DolbyService class

  Future<Either<Failure, dynamic>> getOutput(String outputFilename) async {
    try {
      if (!hasValidToken) {
        return Left(RecordingFailure('No valid token available'));
      }

      try {
        final response = await dio.get(
          'https://api.dolby.com/media/output',
          options: Options(
            headers: {
              'Authorization': 'Bearer $currentToken',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
          queryParameters: {'url': 'dlb://out/${outputFilename.replaceAll('.wav', '-metadata.json')}'},
        );

        if (response.statusCode != 200) {
          print('Failed to get output: ${response.statusCode}');
          return Left(RecordingFailure('Failed to get analysis output'));
        }

        // Parse the response data
        if (response.data is String) {
          try {
            final decodedData = jsonDecode(response.data);
            print('Successfully retrieved and parsed analysis output');
            return Right(decodedData);
          } catch (e) {
            print('Error parsing JSON response: $e');
            return Left(RecordingFailure('Failed to parse analysis output'));
          }
        }

        print('Successfully retrieved analysis output');
        return Right(response.data);
      } catch (e) {
        print('Error getting output: $e');
        return Left(RecordingFailure('Failed to get analysis output: $e'));
      }
    } catch (e) {
      print('Error in getOutput: $e');
      return Left(RecordingFailure('Failed to get analysis output: $e'));
    }
  }
}
