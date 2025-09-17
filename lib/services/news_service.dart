import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:khelpratibha/models/article.dart';

class NewsService {
  final String _apiKey = dotenv.env['NEWS_API_KEY'] ?? '';
  final String _baseUrl = 'https://newsapi.org/v2/everything';

  /// Fetches news articles relevant to a specific sport.
  ///
  /// This function creates a targeted search query using the sport's title
  /// and a broader category to ensure high relevance and filter out random news.
  Future<List<Article>> fetchSportsNews(String sportTitle) async {
    if (_apiKey.isEmpty) {
      throw Exception('News API key is not configured in .env file');
    }

    // 1. Use the exact sport title for the primary search term.
    //    Using quotes like "'sprinting'" makes the search more precise.
    final preciseQuery = '"$sportTitle"';

    final broaderCategory = _getBroaderCategory(sportTitle);

    final finalQuery = '$preciseQuery OR "$broaderCategory"';

    final response = await http.get(
      Uri.parse(
        '$_baseUrl?q=${Uri.encodeComponent(finalQuery)}&sortBy=publishedAt&language=en&apiKey=$_apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      final List<dynamic> articlesJson = json['articles'];
      // Filter out articles that might not be relevant before displaying them
      return articlesJson
          .map((json) => Article.fromJson(json))
          .where((article) =>
      article.title != "[Removed]" && article.description != null)
          .toList();
    } else {
      // Provide a clearer error message
      throw Exception('Failed to load news. Status code: ${response.statusCode}');
    }
  }

  /// Helper function to map a specific sport to its broader category for better search results.
  String _getBroaderCategory(String sport) {
    switch (sport.toLowerCase()) {
      case 'sprinting':
      case 'hurdles':
      case 'high jump':
      case 'long jump':
        return 'athletics';
      case 'shot put':
        return 'track and field';
      default:
        return sport;
    }
  }
}