import 'package:flutter/foundation.dart';
import 'package:khelpratibha/api/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final GoTrueClient _auth = SupabaseClientManager.supabase.auth;

  /// 🔹 Stream to listen for authentication changes (login, logout)
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  /// 🔹 Get the current Supabase session
  Session? get currentSession => _auth.currentSession;

  /// 🔹 Get the current user (if logged in)
  User? get currentUser => _auth.currentUser;

  /// 🔹 Sign up with email and password
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signUp(email: email, password: password);
    } on AuthException catch (e) {
      debugPrint("Error during sign-up: ${e.message}");
      rethrow;
    }
  }

  /// 🔹 Sign in with email and password
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      debugPrint("Error during sign-in: ${e.message}");
      rethrow;
    }
  }

  /// 🔹 Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

/*
  /// 🔹 (Optional) Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      const webClientId =
          'YOUR_WEB_CLIENT_ID_FROM_GOOGLE_CLOUD.apps.googleusercontent.com';

      final googleSignIn = GoogleSignIn(serverClientId: webClientId);
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) throw 'Google sign-in was cancelled.';

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) throw 'Failed to get ID token from Google.';

      await _auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (e) {
      debugPrint("Error during Google sign-in: $e");
      rethrow;
    }
  }
  */
}
