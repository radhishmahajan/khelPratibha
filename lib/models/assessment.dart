import 'package:flutter/foundation.dart';

/// A data model representing a single performance assessment for a player.
class Assessment {
  final String id;
  final String playerId;
  final String coachId;
  final DateTime date;
  final Map<String, double> metrics;
  final String analysis; // AI-generated analysis text
  final List<String>? recommendations; // AI-generated recommendations (nullable)

  Assessment({
    required this.id,
    required this.playerId,
    required this.coachId,
    required this.date,
    required this.metrics,
    required this.analysis,
    this.recommendations,
  });

  factory Assessment.fromMap(Map<String, dynamic> map) {
    return Assessment(
      id: map['id'] ?? '',
      playerId: map['player_id'] ?? '',
      coachId: map['coach_id'] ?? '',
      date: DateTime.parse(map['date']),
      metrics: Map<String, double>.from(map['metrics'] ?? {}),
      analysis: map['analysis'] ?? 'No analysis available.',
      recommendations: map['recommendations'] != null
          ? List<String>.from(map['recommendations'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'player_id': playerId,
      'coach_id': coachId,
      // CORRECTED: Fixed typo from toIso8201String to toIso8601String
      'date': date.toIso8601String(),
      'metrics': metrics,
      'analysis': analysis,
      'recommendations': recommendations,
    };
  }
}

/// A simple data class to hold a single performance metric before analysis.
class PerformanceMetric {
  final String name;
  final double value;

  PerformanceMetric({required this.name, required this.value});
}

/// A data class to hold the structured results from the AI analysis service.
class AIAnalysisResult {
  final String summary;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> recommendations;
  final Map<String, double> percentileRanks;

  AIAnalysisResult({
    required this.summary,
    required this.strengths,
    required this.weaknesses,
    required this.recommendations,
    required this.percentileRanks,
  });
}

