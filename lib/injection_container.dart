import 'package:deeptone/Authentication/data/repositories/authentication_repository_implementation.dart';
import 'package:deeptone/Authentication/domain/repositories/authentication_repository.dart';
import 'package:deeptone/Authentication/domain/usecases/log_in.dart';
import 'package:deeptone/Authentication/domain/usecases/sign_in.dart';
import 'package:deeptone/Authentication/presentation/bloc/auth_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:record/record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'Messaging/data/repositories/messaging_repository_implementation.dart';
import 'Messaging/domain/repositories/messaging_repository.dart';
import 'Messaging/domain/usecases/generate_passage.dart';
import 'Messaging/domain/usecases/generate_report.dart';
import 'Messaging/domain/usecases/get_messages.dart';
import 'Messaging/domain/usecases/get_mic_permission.dart';
import 'Messaging/domain/usecases/start_recording.dart';
import 'Messaging/domain/usecases/stop_recording.dart';
import 'Messaging/presentation/bloc/messaging_bloc.dart';

final GetIt locator = GetIt.instance;

Future<void> setup() async {
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
    ),
  );

  final supabase = Supabase.instance.client;

  locator.registerSingleton<SupabaseClient>(supabase);

  // Creating Authentication repository
  locator.registerSingleton<AuthenticationRepository>(
    AuthenticationRepositoryImplementation(),
  );

  // Initalising Authentication usecases
  locator.registerSingleton<LogIn>(LogIn(locator()));
  locator.registerSingleton<SignUp>(SignUp(locator()));

  // Initalising Authentication Bloc
  locator.registerFactory<AuthenticationBloc>(
    () => AuthenticationBloc(logIn: locator(), signUp: locator()),
  );

  //Initializing Dio and recorder
  locator.registerSingleton<Dio>(Dio());
  //locator<Dio>().interceptors.add(PrettyDioLogger(requestBody: false));
  locator.registerSingleton<AudioRecorder>(AudioRecorder());

  //Initializing Messaging Repository
  locator.registerSingleton<MessagingRepository>(
    MessagingRepositoryImplementation(
      dio: locator(),
      record: locator(),
      openaiApiKey: dotenv.env['OPEN_AI_API_KEY']!,
      deepGramApiKey: dotenv.env['DEEPGRAM_API_KEY']!,
      dolbyApiKey: dotenv.env['DOLBY_API_KEY']!,
      dolbyAppSecret: dotenv.env['DOLBY_API_SECRET']!,
    ),
  );

  //Initializing Messaging Usecases
  locator.registerSingleton<StartRecording>(StartRecording(locator()));
  locator.registerSingleton<StopRecording>(StopRecording(locator()));
  locator.registerSingleton<GetMicPermission>(GetMicPermission(locator()));
  locator.registerSingleton<GeneratePassage>(GeneratePassage(locator()));
  locator.registerSingleton<GenerateReport>(GenerateReport(locator()));
  locator.registerSingleton<GetMessages>(GetMessages(locator()));

  //Initializing Messaging Bloc
  locator.registerFactory<MessagingBloc>(
    () => MessagingBloc(
      startRecording: locator(),
      stopRecording: locator(),
      getMicPermission: locator(),
      generatePassage: locator(),
      generateReport: locator(),
      getMessages: locator(),
    ),
  );
}
