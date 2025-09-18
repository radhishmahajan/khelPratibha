import 'package:flutter/material.dart';
import 'package:khelpratibha/models/achievement.dart';
import 'package:khelpratibha/models/challenge.dart';
import 'package:khelpratibha/models/challenge_leaderboard_entry.dart';
import 'package:khelpratibha/models/goal.dart';
import 'package:khelpratibha/models/leaderboard_entry.dart';
import 'package:khelpratibha/models/performance_session.dart';
import 'package:khelpratibha/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final supabase = Supabase.instance.client;

  /// Fetches user profile by userId
  Future<UserProfile?> fetchUserProfile(String userId) async {
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;

    return UserProfile.fromMap(response);
  }

  /// Insert or update user profile
  Future<UserProfile> upsertUserProfile(UserProfile profile) async {
    final response = await supabase
        .from('profiles')
        .upsert(profile.toMap())
        .select()
        .single();

    return UserProfile.fromMap(response);
  }

  /// Delete user profile (optional)
  Future<void> deleteUserProfile(String userId) async {
    await supabase.from('profiles').delete().eq('id', userId);
  }

  Future<void> saveStrengthTestResult({
    required String testName,
    required double score,
    required int reps,
  }) async {
    final userId = supabase.auth.currentUser!.id;
    final test = await supabase
        .from('fitness_tests')
        .select('id')
        .eq('name', testName)
        .single();

    final testId = test['id'];
    final today = DateTime.now().toIso8601String().substring(0, 10);

    // Upsert the result for today
    await supabase.from('fitness_test_results').upsert({
      'user_id': userId,
      'test_id': testId,
      'score': score,
      'reps': reps,
      'recorded_at': today,
    }, onConflict: 'user_id, test_id, recorded_at');

    // Update the daily session
    final session = await supabase
        .from('daily_sessions')
        .select('id, total_score')
        .eq('user_id', userId)
        .eq('session_date', today)
        .maybeSingle();

    if (session == null) {
      await supabase.from('daily_sessions').insert({
        'user_id': userId,
        'total_score': score,
      });
    } else {
      await supabase.from('daily_sessions').update({
        'total_score': session['total_score'] + score,
      }).eq('id', session['id']);
    }
  }

  Future<List<Achievement>> fetchAchievements() async {
    final userId = supabase.auth.currentUser!.id;
    final response = await supabase.rpc('get_user_achievements', params: {'p_user_id': userId});

    return (response as List).map((item) => Achievement.fromMap(item)).toList();
  }

  Future<void> unlockAchievement(String achievementId) async {
    final userId = supabase.auth.currentUser!.id;
    await supabase.from('user_achievements').insert({
      'user_id': userId,
      'achievement_id': achievementId,
    });
  }

  Future<List<Goal>> fetchGoals() async {
    final userId = supabase.auth.currentUser!.id;
    final response = await supabase
        .from('goals')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return response.map((item) => Goal.fromMap(item)).toList();
  }

  Future<void> addGoal(String description) async {
    final userId = supabase.auth.currentUser!.id;
    await supabase.from('goals').insert({
      'user_id': userId,
      'description': description,
    });
  }

  Future<List<LeaderboardEntry>> fetchLeaderboard() async {
    final response = await supabase.rpc('get_leaderboard');
    return (response as List)
        .asMap()
        .entries
        .map((entry) => LeaderboardEntry.fromMap(entry.value, entry.key + 1))
        .toList();
  }

  Future<List<PerformanceSession>> fetchPerformanceHistory() async {
    final userId = supabase.auth.currentUser!.id;
    final response = await supabase
        .from('fitness_test_results')
        .select('*, fitness_tests(name)')
        .eq('user_id', userId)
        .order('recorded_at', ascending: false);

    return response.map((item) => PerformanceSession.fromMap(item)).toList();
  }

  Future<List<Map<String, dynamic>>> fetchPersonalBests() async {
    final userId = supabase.auth.currentUser!.id;
    final response = await supabase.rpc('get_user_personal_bests', params: {'p_user_id': userId});
    return (response as List).map((item) => item as Map<String, dynamic>).toList();
  }

  Future<List<Challenge>> fetchChallenges() async {
    final response = await supabase.from('challenges').select();
    return (response as List).map((item) => Challenge.fromMap(item)).toList();
  }

  Future<List<ChallengeLeaderboardEntry>> fetchChallengeLeaderboard(String challengeId) async {
    final response = await supabase.rpc('get_challenge_leaderboard', params: {'p_challenge_id': challengeId});
    return (response as List)
        .asMap()
        .entries
        .map((entry) => ChallengeLeaderboardEntry.fromMap(entry.value, entry.key + 1))
        .toList();
  }
}