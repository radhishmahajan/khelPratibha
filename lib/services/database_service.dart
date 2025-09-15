import 'package:khelpratibha/models/achievement.dart';
import 'package:khelpratibha/models/assessment.dart';
import 'package:khelpratibha/models/performance_session.dart';
import 'package:khelpratibha/models/sport_category.dart';
import 'package:khelpratibha/models/sport_event.dart';
import 'package:khelpratibha/models/sport_program.dart';
import 'package:khelpratibha/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khelpratibha/models/goal.dart';
import 'package:khelpratibha/models/recommendation.dart';

class DatabaseService {
  final supabase = Supabase.instance.client;

  /// 隼 Fetch user profile by userId
  Future<UserProfile?> fetchUserProfile(String userId) async {
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;

    return UserProfile.fromMap(response);
  }

  /// 隼 Insert or update user profile
  Future<UserProfile> upsertUserProfile(UserProfile profile) async {
    final response = await supabase
        .from('profiles')
        .upsert(profile.toMap())
        .select()
        .single();

    return UserProfile.fromMap(response);
  }

  /// 隼 Delete user profile (optional)
  Future<void> deleteUserProfile(String userId) async {
    await supabase.from('profiles').delete().eq('id', userId);
  }

  /// 隼 Creates a new assessment record in the 'assessments' table.
  Future<void> createAssessment(Assessment assessment) async {
    await supabase.from('assessments').insert(assessment.toMap());
  }

  Future<List<SportProgram>> fetchPrograms({SportCategory? category}) async {
    // Call the new Supabase function
    var query = supabase.rpc('get_programs_with_athlete_counts');

    if (category != null) {
      // Filter the results from the function by category
      query = query.eq('category', category.name);
    }

    final response = await query;

    // The RPC response is a list of maps, so we can parse it directly
    return (response as List)
        .map((item) => SportProgram.fromMap(item))
        .toList();
  }

  /// 隼 Fetches a list of program titles the user has joined.
  Future<List<String>> fetchJoinedProgramIds(String userId) async {
    final response = await supabase
        .from('joined_programs')
        .select('program_id')
        .eq('user_id', userId);
    return response.map((item) => item['program_id'] as String).toList();
  }

  /// 隼 Adds a record to link a user to a program.
  Future<void> joinProgram({required String userId, required String programId}) async {
    await supabase.from('joined_programs').insert({
      'user_id': userId,
      'program_id': programId,
    });
  }

  Future<void> leaveProgram({required String userId, required String programId}) async {
    await supabase
        .from('joined_programs')
        .delete()
        .match({'user_id': userId, 'program_id': programId});
  }

  /// Fetches all events for a specific program ID.
  Future<List<SportEvent>> fetchEventsForProgram(String programId) async {
    final response = await supabase
        .from('events')
        .select()
        .eq('program_id', programId);

    return response.map((item) => SportEvent.fromMap(item)).toList();
  }

  Future<void> createSession(Map<String, dynamic> sessionData) async {
    await supabase.from('sessions').insert(sessionData);
  }

  /// Fetches all sessions for a user within a specific program.
  Future<List<PerformanceSession>> fetchSessions(String programId) async {
    final userId = supabase.auth.currentUser!.id;
    final response = await supabase
        .from('sessions')
        .select()
        .eq('user_id', userId)
        .eq('program_id', programId)
        .order('created_at', ascending: false);

    return response.map((item) => PerformanceSession.fromMap(item)).toList();
  }

  Future<List<Achievement>> fetchAchievements() async {
    final userId = supabase.auth.currentUser!.id;
    final response = await supabase.rpc('get_user_achievements', params: {'p_user_id': userId});

    return (response as List).map((item) => Achievement.fromMap(item)).toList();
  }

  /// Unlocks a specific achievement for a user.
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

  Future<List<Recommendation>> fetchRecommendations() async {
    final userId = supabase.auth.currentUser!.id;
    final response = await supabase
        .from('recommendations')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return response.map((item) => Recommendation.fromMap(item)).toList();
  }

  Future<Map<String, dynamic>> fetchCategoryStats() async {
    final response = await supabase.rpc('get_category_stats');
    final stats = {
      'olympics': {'programs': 0, 'athletes': 0, 'tags': <String>[]},
      'paralympics': {'programs': 0, 'athletes': 0, 'tags': <String>[]},
    };

    for (var row in response) {
      final category = row['category_name'];
      if (stats.containsKey(category)) {
        stats[category]!['programs'] = row['program_count'] ?? 0;
        stats[category]!['athletes'] = row['athlete_count'] ?? 0;
      }
    }

    // Fetch sport tags for each category
    final olympicsTagsResponse = await supabase.rpc('get_sports_for_category', params: {'p_category': 'olympics', 'p_limit': 5});
    stats['olympics']!['tags'] = (olympicsTagsResponse as List).map<String>((item) => item['title'] as String).toList();

    final paralympicsTagsResponse = await supabase.rpc('get_sports_for_category', params: {'p_category': 'paralympics', 'p_limit': 5});
    stats['paralympics']!['tags'] = (paralympicsTagsResponse as List).map<String>((item) => item['title'] as String).toList();

    return stats;
  }

}