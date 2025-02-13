import 'package:ai_voice_coach/Authentication/data/repositories/authentication_repository_implementation.dart';
import 'package:ai_voice_coach/Authentication/domain/repositories/authentication_repository.dart';
import 'package:ai_voice_coach/Authentication/domain/usecases/log_in.dart';
import 'package:ai_voice_coach/Authentication/domain/usecases/sign_in.dart';
import 'package:ai_voice_coach/Authentication/presentation/bloc/auth_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'Messaging/presentation/bloc/messaging_bloc_bloc.dart';

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

  //Initialising messaging bloc
  locator.registerSingleton<MessagingBloc>(MessagingBloc());
}
