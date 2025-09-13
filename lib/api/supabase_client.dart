import 'package:supabase_flutter/supabase_flutter.dart';

/// Manages the Supabase client instance and its initialization.
///
/// This class provides a professional and safe way to handle the Supabase client
/// by separating the initialization logic from the client access. This prevents
/// errors caused by accessing the client before it is ready.

  class SupabaseClientManager {
  // The static, final instance of the Supabase client.
  static final supabase = Supabase.instance.client;
  /// Initializes the Supabase client with your project's credentials.
  ///
  /// This method must be called once and awaited in `main.dart` before `runApp()`
  /// to ensure that all services can safely access the client.
  static Future<void> initialize() async {
    await Supabase.initialize(
      // IMPORTANT: Replace these placeholders with your actual Supabase credentials.
      url: 'supabase url',
      anonKey: 'anon key',
    );
  }

  /// Provides a global static getter for the Supabase client instance.
  ///
  /// After `initialize()` has been called, this getter can be used from anywhere
  /// in the app to interact with your Supabase backend.
  ///
  /// ### Example Usage:
  /// ```dart
  /// final response = await SupabaseManager.client.auth.signUp(...);
  /// ```
  static SupabaseClient get client => Supabase.instance.client;
}


