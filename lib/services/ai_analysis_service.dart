import 'package:khelpratibha/models/assessment.dart';
import 'package:khelpratibha/services/database_service.dart';
import 'package:uuid/uuid.dart';

class AiAnalysisService {
  final DatabaseService _dbService;
  AiAnalysisService(this._dbService);

  /// Analyzes metrics, creates a full assessment object, saves it, and returns it.
  Future<Assessment> getAnalysis({
    required String playerId,
    required Map<String, double> metrics,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    final metricList = metrics.entries
        .map((e) => PerformanceMetric(name: e.key, value: e.value))
        .toList();

    // --- Mock AI Analysis Logic ---
    final strengths = <String>[];
    final weaknesses = <String>[];
    final recommendations = <String>[];

    for (var metric in metricList) {
      switch (metric.name.toLowerCase()) {
        case 'sprint':
          if (metric.value <= 4.8) {
            strengths.add('Exceptional speed and acceleration.');
            recommendations.add('Focus on maintaining top speed for longer durations.');
          } else {
            weaknesses.add('Sprint time indicates room for improvement in explosive power.');
            recommendations.add('Incorporate plyometric exercises.');
          }
          break;
        case 'agility':
          if (metric.value <= 9.5) {
            strengths.add('Excellent agility and change-of-direction ability.');
          } else {
            weaknesses.add('Agility score can be improved.');
            recommendations.add('Practice ladder and cone drills.');
          }
          break;
        case 'jump':
          if (metric.value >= 60) {
            strengths.add('Powerful vertical leap.');
          } else {
            weaknesses.add('Lower body explosive power can be enhanced.');
            recommendations.add('Implement a squat and deadlift program.');
          }
          break;
      }
    }
    if (strengths.isEmpty) strengths.add("Consistent all-round performance.");
    if (weaknesses.isEmpty) weaknesses.add("No significant weaknesses identified.");

    final summary = 'This assessment highlights strong potential in ${strengths.isNotEmpty ? strengths.first.toLowerCase() : 'various areas'} with opportunities to develop greater ${weaknesses.isNotEmpty ? weaknesses.first.toLowerCase() : 'skills'}.';
    // --- End of Mock Logic ---

    // Create the final Assessment object
    final newAssessment = Assessment(
      id: const Uuid().v4(), // Generate a unique ID
      playerId: playerId,
      date: DateTime.now(),
      metrics: metrics,
      analysis: summary,
      recommendations: recommendations,
    );

    // Save the new assessment to the database
    await _dbService.createAssessment(newAssessment);

    return newAssessment;
  }
}

