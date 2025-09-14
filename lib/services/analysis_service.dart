import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

class AnalysisService {
  final String _baseUrl = 'http://10.0.2.2:8000/api/v1';


  // Future<Map<String, dynamic>> analyzeVideo({
  //   required XFile videoFile,
  //   required String sport,
  //   required double athleteHeight,
  // }) async {
  //   // Simulate a network delay for a realistic testing experience
  //   await Future.delayed(const Duration(seconds: 1));
  //
  //   // Generate a random score and select a random feedback message
  //   final random = Random();
  //   final randomScore = 50 + random.nextDouble() * 45; // Score between 50.0 and 95.0
  //   final feedbackMessages = [
  //     'Excellent form, but watch your follow-through.',
  //     'Great power, but your initial stance could be more stable.',
  //     'Good speed, but try to maintain your pace in the final stretch.',
  //     'Your technique is solid, but there is room to improve your timing.',
  //   ];
  //   final randomFeedback = feedbackMessages[random.nextInt(feedbackMessages.length)];
  //
  //   // Return a mock analysis result that matches your Python API's structure
  //   return {
  //     'analysis_results': {
  //       'talent_score': randomScore,
  //       'feedback': randomFeedback,
  //     }
  //   };
  // }

  Future<Map<String, dynamic>> analyzeVideo({
    required XFile videoFile,
    required String sport,
    required double athleteHeight,
  }) async {
    final uri = Uri.parse('$_baseUrl/analysis/');
    final request = http.MultipartRequest('POST', uri)
      ..fields['sport'] = sport
      ..fields['athlete_height_m'] = athleteHeight.toString()
      ..files.add(await http.MultipartFile.fromPath(
        'video_file',
        videoFile.path,
        contentType: MediaType('video', 'mp4'), // Add this line
      ));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      return json.decode(responseBody);
    } else {
      final errorBody = await response.stream.bytesToString();
      throw Exception('Failed to analyze video: ${response.statusCode} $errorBody');
    }
  }
}