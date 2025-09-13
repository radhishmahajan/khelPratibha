// lib/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'workout_result.dart';

class ApiService {
  // ▼▼▼ IMPORTANT: Replace with your computer's IP address ▼▼▼
  static const String _baseUrl = 'http://192.168.1.5:5000';

  Future<WorkoutResult> uploadVideo(XFile videoFile, String exerciseType) async {
    final uri = Uri.parse('$_baseUrl/process_video');

    http.MultipartRequest request;
    try {
      request = http.MultipartRequest('POST', uri)
        ..fields['exercise_type'] = exerciseType.toLowerCase()
        ..files.add(await http.MultipartFile.fromPath(
          'video',
          videoFile.path,
          filename: basename(videoFile.path),
        ));
    } catch (e) {
      throw Exception('Failed to prepare the video file for upload.');
    }

    http.StreamedResponse streamedResponse;
    try {
      streamedResponse = await request.send();
    } on SocketException {
      throw Exception('Failed to connect to the server. Check the IP address and your network connection.');
    } catch (e) {
      throw Exception('An unexpected error occurred while sending the video.');
    }

    final response = await http.Response.fromStream(streamedResponse);
    final responseData = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return WorkoutResult.fromJson(responseData);
    } else {
      // Throw the specific error message from the server (e.g., "Exercise Mismatch")
      throw Exception(responseData['error'] ?? 'An unknown error occurred on the server.');
    }
  }
}