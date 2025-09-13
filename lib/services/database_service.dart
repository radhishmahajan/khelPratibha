import 'package:khelpratibha/models/assessment.dart';
import 'package:khelpratibha/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final supabase = Supabase.instance.client;

  /// 🔹 Fetch user profile by userId
  Future<UserProfile?> fetchUserProfile(String userId) async {
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;

    return UserProfile.fromMap(response);
  }

  /// 🔹 Insert or update user profile
  Future<UserProfile> upsertUserProfile(UserProfile profile) async {
    final response = await supabase
        .from('profiles')
        .upsert(profile.toMap())
        .select()
        .single();

    return UserProfile.fromMap(response);
  }

  /// 🔹 Delete user profile (optional)
  Future<void> deleteUserProfile(String userId) async {
    await supabase.from('profiles').delete().eq('id', userId);
  }

  /// 🔹 Creates a new assessment record in the 'assessments' table.
  Future<void> createAssessment(Assessment assessment) async {
    await supabase.from('assessments').insert(assessment.toMap());
  }
}

