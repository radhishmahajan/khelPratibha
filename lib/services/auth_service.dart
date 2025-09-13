import 'package:flutter/foundation.dart';
import 'package:khelpratibha/api/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Manages all user authentication operations (sign-up, sign-in, sign-out).
/// This service acts as a clean interface between the UI and the Supabase auth client.
class AuthService {
  // CORRECTED: Uses the static 'client' getter for consistency with the rest of the app.
  final GoTrueClient _auth = SupabaseClientManager.client.auth;

  /// 🔹 A stream that notifies the app of authentication state changes (e.g., login, logout).
  /// This is the primary stream that the AuthGate listens to.
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  /// 🔹 Gets the current active session, if one exists.
  Session? get currentSession => _auth.currentSession;

  /// 🔹 Gets the current logged-in user, if one exists.
  User? get currentUser => _auth.currentUser;

  /// 🔹 Signs a new user up with their email and password.
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signUp(email: email, password: password);
    } on AuthException catch (e) {
      // It's good practice to log the specific error before rethrowing.
      debugPrint("AuthService Error (signUpWithEmail): ${e.message}");
      rethrow;
    }
  }

  /// 🔹 Signs an existing user in with their email and password.
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      debugPrint("AuthService Error (signInWithEmail): ${e.message}");
      rethrow;
    }
  }

  /// 🔹 Signs the current user out of the application.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
