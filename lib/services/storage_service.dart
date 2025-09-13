import 'dart:io';
import 'package:khelpratibha/api/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  // Method to upload a profile picture and get the public URL
  Future<String?> uploadAvatar(XFile imageFile) async {
    try {
      final userId = SupabaseClientManager.supabase.auth.currentUser!.id;
      final fileExt = imageFile.path.split('.').last;
      final fileName = '$userId.${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'public/avatars/$fileName';

      // Upload the file to the 'avatars' bucket
      await SupabaseClientManager.supabase.storage.from('avatars').upload(
        filePath,
        File(imageFile.path),
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      // Get the public URL of the uploaded file
      final imageUrl = SupabaseClientManager.supabase.storage
          .from('avatars')
          .getPublicUrl(filePath);

      return imageUrl;
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }
}
