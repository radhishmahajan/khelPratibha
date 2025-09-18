import 'package:flutter/material.dart';
import 'package:khelpratibha/models/achievement.dart';
import 'package:khelpratibha/models/challenge.dart';
import 'package:khelpratibha/models/challenge_leaderboard_entry.dart';
import 'package:khelpratibha/models/fitness_test_category.dart';
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
    final testResponse = await supabase
        .from('fitness_tests')
        .select('id')
        .like('name', '$testName%')
        .limit(1)
        .maybeSingle();

    if (testResponse == null) {
      throw Exception('Fitness test "$testName" not found in the database. Please check the test names.');
    }

    final testId = testResponse['id'];
    final now = DateTime.now().toIso8601String();

    // This insert will now work for every test because 'now' is a unique timestamp
    await supabase.from('fitness_test_results').insert({
      'user_id': userId,
      'test_id': testId,
      'score': score,
      'reps': reps,
      'recorded_at': now,
    });


    // Update the daily session
    final today = now.substring(0, 10);
    final sessionResponse = await supabase
        .from('daily_sessions')
        .select('id, total_score')
        .eq('user_id', userId)
        .eq('session_date', today)
        .maybeSingle();

    if (sessionResponse == null) {
      await supabase.from('daily_sessions').insert({
        'user_id': userId,
        'total_score': score,
      });
    } else {
      await supabase.from('daily_sessions').update({
        'total_score': sessionResponse['total_score'] + score,
      }).eq('id', sessionResponse['id']);
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

  Future<List<LeaderboardEntry>> fetchLeaderboardForTest(String testName) async {
    final response = await supabase.rpc('get_leaderboard_for_test', params: {'p_test_name': testName});
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
        .select('*, fitness_tests(name, icon_name)')
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

  Future<List<FitnessTestCategory>> fetchFitnessTestCategories() async {
    final response = await supabase
        .from('fitness_test_categories')
        .select('name, icon_name, fitness_tests(name)');

    return (response as List)
        .map((item) => FitnessTestCategory.fromMap(item))
        .toList();
  }
}