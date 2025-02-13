import 'package:ai_voice_coach/Authentication/data/repositories/authentication_repository_implementation.dart';
import 'package:ai_voice_coach/Authentication/domain/repositories/authentication_repository.dart';
import 'package:ai_voice_coach/Authentication/domain/usecases/log_in.dart';
import 'package:ai_voice_coach/Authentication/domain/usecases/sign_in.dart';
import 'package:ai_voice_coach/Authentication/presentation/bloc/auth_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GetIt locator = GetIt.instance;

Future<void> setup() async {
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final supabase = Supabase.instance.client;

  locator.registerSingleton<SupabaseClient>(supabase);

  // Creating Authentication repository
  locator.registerSingleton<AuthenticationRepository>(
    AuthenticationRepositoryImplementation(),
  );

  // Initalising Authentication usecases
  locator.registerSingleton<LogIn>(locator());
  locator.registerSingleton<SignUp>(locator());

  // Initalising Authentication Bloc
  locator.registerSingleton<AuthenticationBloc>(locator());
}
