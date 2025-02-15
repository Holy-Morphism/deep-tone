import 'dart:async';

import 'package:ai_voice_coach/Authentication/presentation/bloc/auth_bloc.dart';
import 'package:ai_voice_coach/Authentication/presentation/screens/Authentication_page.dart';
import 'package:ai_voice_coach/injection_container.dart';
import 'package:ai_voice_coach/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Messaging/presentation/bloc/messaging_bloc.dart';
import '../Messaging/presentation/screens/messages_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  initialLocation: "/",
  navigatorKey: _rootNavigatorKey,
  refreshListenable: GoRouterRefreshStream(
    locator<SupabaseClient>().auth.onAuthStateChange,
  ),
  routes: [
    GoRoute(
      path: Routes.authenticationScreen,
      builder:
          (context, state) => BlocProvider(
            create: (context) => locator<AuthenticationBloc>(),
            child: const AuthenticationScreen(),
          ),
    ),
    GoRoute(
      path: Routes.home,
      builder:
          (context, state) => BlocProvider(
            create: (context) => locator<MessagingBloc>()..add(GetMicPermissionEvent()),
            child: const MessagingScreen(),
          ),
    ),
  ],
  redirect: (context, state) {
    final session = locator<SupabaseClient>().auth.currentSession;

    // Handle initial state and auth changes
    if (session == null &&
        state.uri.toString() != Routes.authenticationScreen) {
      return Routes.authenticationScreen;
    }

    if (session != null &&
        state.uri.toString() == Routes.authenticationScreen) {
      return Routes.home;
    }

    return null;
  },
);

// Create a RefreshListenable class to handle auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.listen((AuthState _) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
