import 'package:deeptone/injection_container.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<String> signup({
  required String email,
  required String password,
  required String username,
}) async {
  final AuthResponse res = await locator<SupabaseClient>().auth.signUp(
    email: email,
    password: password,
  );

  if (res.user != null) {
    return username;
  } else {
    throw Exception('Failed to sign up');
  }
}

Future<String> login({required String email, required String password}) async {
  final AuthResponse res = await locator<SupabaseClient>().auth
      .signInWithPassword(email: email, password: password);

  final data =
      await locator<SupabaseClient>()
          .from('profiles')
          .select('username')
          .eq('id', res.user!.id)
          .single();

  if (res.user != null) {
    return data['username'];
  } else {
    throw Exception('Failed to Log In up');
  }
}
