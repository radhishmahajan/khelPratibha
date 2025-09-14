import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khelpratibha/models/sport_program.dart';
import 'package:khelpratibha/providers/achievement_provider.dart';
import 'package:khelpratibha/providers/session_provider.dart';
import 'package:khelpratibha/providers/user_provider.dart';
import 'package:khelpratibha/services/analysis_service.dart';
import 'package:khelpratibha/services/database_service.dart';
import 'package:khelpratibha/utils/sport_name_mapper.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class MediaAnalysisTab extends StatefulWidget {
  final SportProgram program;
  const MediaAnalysisTab({super.key, required this.program});

  @override
  State<MediaAnalysisTab> createState() => _MediaAnalysisTabState();
}

class _MediaAnalysisTabState extends State<MediaAnalysisTab> {
  XFile? _videoFile;
  VideoPlayerController? _videoPlayerController;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;
  String? _errorMessage;

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideoPlayer(XFile file) async {
    _videoPlayerController?.dispose();
    _videoPlayerController = VideoPlayerController.file(File(file.path));
    await _videoPlayerController!.initialize();
    setState(() {});
  }

  Future<void> _pickVideo() async {
    final pickedFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _videoFile = pickedFile;
        _analysisResult = null;
        _errorMessage = null;
      });
      await _initializeVideoPlayer(pickedFile);
    }
  }

  String _calculateLevel(int sessionCount, double averageScore) {
    if (sessionCount >= 10 && averageScore >= 80) {
      return 'Advanced';
    } else if (sessionCount >= 5 && averageScore >= 50) {
      return 'Intermediate';
    } else {
      return 'Beginner';
    }
  }

  Future<void> _analyzeVideo() async {
    if (_videoFile == null) return;

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final result = await context.read<AnalysisService>().analyzeVideo(
        videoFile: _videoFile!,
        sport: mapProgramTitleToSportKey(widget.program.title),
        athleteHeight: 1.8,
      );
      setState(() {
        _analysisResult = result;
      });

      final sessionData = {
        'user_id': context.read<UserProvider>().userProfile!.id,
        'program_id': widget.program.id,
        'score': result['analysis_results']['talent_score'],
        'feedback': result['analysis_results']['feedback'],
      };
      await context.read<DatabaseService>().createSession(sessionData);

      if (mounted) {
        final sessionProvider = context.read<SessionProvider>();
        final achievementProvider = context.read<AchievementProvider>();

        await sessionProvider.fetchSessions(widget.program.id);

        final sessions = sessionProvider.sessions;
        final overallScore = sessions.isNotEmpty
            ? (sessions.map((s) => s.score).reduce((a, b) => a + b) / sessions.length)
            : 0.0;
        final currentLevel = _calculateLevel(sessions.length, overallScore);

        await achievementProvider.checkAndUnlockAchievements(sessions, currentLevel);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Media Analysis',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload a video of your performance for AI-powered feedback.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade700),
                borderRadius: BorderRadius.circular(12),
                color: Colors.black,
              ),
              child: _videoPlayerController != null &&
                  _videoPlayerController!.value.isInitialized
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: _videoPlayerController!.value.aspectRatio,
                  child: VideoPlayer(_videoPlayerController!),
                ),
              )
                  : const Center(
                child: Icon(Icons.videocam, size: 60, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.video_library),
                  label: const Text('Select Video'),
                  onPressed: _pickVideo,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.analytics),
                  label: const Text('Analyze'),
                  onPressed: _videoFile != null && !_isAnalyzing ? _analyzeVideo : null,
                ),
              ),
            ],
          ),
          if (_isAnalyzing)
            const Padding(
              padding: EdgeInsets.only(top: 24.0),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Analyzing your video...'),
                ],
              ),
            ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          if (_analysisResult != null)
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Analysis Result', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        'Feedback: ${_analysisResult!['analysis_results']['feedback']}',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Talent Score: ${_analysisResult!['analysis_results']['talent_score']}',
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}