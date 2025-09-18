import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeProvider with ChangeNotifier {
  final SupabaseClient _supabaseClient;
  late final RealtimeChannel _leaderboardChannel;

  RealtimeProvider(this._supabaseClient) {
    _initializeSubscriptions();
  }

  void _initializeSubscriptions() {
    // Correctly initialize the channel
    _leaderboardChannel = _supabaseClient.channel('public:leaderboard');

    // Use the new syntax for listening to Postgres changes
    _leaderboardChannel
        .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'leaderboard',
        callback: (payload) {
          // When there is a change in the leaderboard table, notify listeners.
          // You would typically fetch the new data here or update the UI directly.
          notifyListeners();
        })
        .subscribe();
  }

  @override
  void dispose() {
    _leaderboardChannel.unsubscribe();
    super.dispose();
  }
}