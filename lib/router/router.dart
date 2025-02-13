import 'package:ai_voice_coach/Authentication/presentation/bloc/auth_bloc.dart';
import 'package:ai_voice_coach/Authentication/presentation/screens/login_page.dart';
import 'package:ai_voice_coach/Authentication/presentation/screens/signup_page.dart';
import 'package:ai_voice_coach/injection_container.dart';
import 'package:ai_voice_coach/router/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final router = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(
      path: Routes.logInScreen,
      builder:
          (context, state) => BlocProvider(
            create: (context) => locator<AuthenticationBloc>(),
            child: const LogInPage(),
          ),
    ),
    GoRoute(
      path: Routes.signUpScreen,
      builder:
          (context, state) => BlocProvider(
            create: (context) => locator<AuthenticationBloc>(),
            child: const SignUpPage(),
          ),
    ),
  ],
  redirect: (context, state) {
    final session = locator<SupabaseClient>().auth.currentSession;
    if (session != null) {
      return Routes.home;
    } else {
      Routes.signUpScreen;
    }
  },
);
