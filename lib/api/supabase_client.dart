import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

  class SupabaseClientManager {
  static final supabase = Supabase.instance.client;
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");

    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }
  static SupabaseClient get client => Supabase.instance.client;
}


