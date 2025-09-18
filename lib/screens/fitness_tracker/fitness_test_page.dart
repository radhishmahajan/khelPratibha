import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khelpratibha/providers/achievement_provider.dart';
import 'package:khelpratibha/providers/goal_provider.dart';
import 'package:khelpratibha/providers/leaderboard_provider.dart';
import 'package:khelpratibha/providers/performance_provider.dart';
import 'package:khelpratibha/providers/user_provider.dart';
import 'package:khelpratibha/services/analysis_service.dart';
import 'package:khelpratibha/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class FitnessTestPage extends StatefulWidget {
  final String testName;

  const FitnessTestPage({super.key, required this.testName});

  @override
  State<FitnessTestPage> createState() => _FitnessTestPageState();
}

class _FitnessTestPageState extends State<FitnessTestPage> {
  XFile? _mediaFile;
  VideoPlayerController? _videoPlayerController;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;
  String? _errorMessage;

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  bool get _isPhotoTest {
    return widget.testName.toLowerCase().contains('height & weight');
  }

  Future<void> _initializeVideoPlayer(XFile file) async {
    _videoPlayerController?.dispose();
    _videoPlayerController = VideoPlayerController.file(File(file.path));
    await _videoPlayerController!.initialize();
    setState(() {});
  }

  Future<void> _pickMedia() async {
    final pickedFile = _isPhotoTest
        ? await ImagePicker().pickImage(source: ImageSource.gallery)
        : await ImagePicker().pickVideo(source: ImageSource.gallery, maxDuration: const Duration(minutes: 1));

    if (pickedFile != null) {
      setState(() {
        _mediaFile = pickedFile;
        _analysisResult = null;
        _errorMessage = null;
      });
      if (!_isPhotoTest) {
        await _initializeVideoPlayer(pickedFile);
      }
    }
  }

  Future<void> _analyzeMedia() async {
    if (_mediaFile == null) return;

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final result = _isPhotoTest
          ? await AnalysisService().analyzeHeightWeight(_mediaFile!)
          : await AnalysisService().analyzeStrengthAndPower(_mediaFile!);

      setState(() {
        _analysisResult = result;
      });

      final userProvider = context.read<UserProvider>();
      final dbService = context.read<DatabaseService>();
      final performanceProvider = context.read<PerformanceProvider>();
      final leaderboardProvider = context.read<LeaderboardProvider>();
      final achievementProvider = context.read<AchievementProvider>();
      final goalProvider = context.read<GoalProvider>();

      // FIX: Extract the core test name before saving to the database.
      String coreTestName = widget.testName;
      if (widget.testName.contains('(')) {
        coreTestName = widget.testName.split('(').first.trim();
      }


      if (!_isPhotoTest) {
        await dbService.saveStrengthTestResult(
          testName: coreTestName,
          score: result['score'],
          reps: result['reps'],
        );
        await achievementProvider.checkAndUnlockAchievements(result['reps'], 0);
        await goalProvider.addGoal('Improve ${widget.testName} score by 10%');
      } else {
        final updatedProfile = userProvider.userProfile!.copyWith(
          heightCm: result['height_cm'],
          weightKg: result['weight_kg'],
        );
        await userProvider.saveUserProfile(updatedProfile);
      }

      await performanceProvider.fetchPerformanceHistory();
      await leaderboardProvider.fetchLeaderboard();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Analysis complete and data updated!')),
        );
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
    final bool supportsMediaAnalysis =
    fitnessTestsWithAnalysis.any((test) => widget.testName.toLowerCase().contains(test));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.testName),
      ),
      body: supportsMediaAnalysis
          ? _buildMediaAnalysisUI()
          : _buildPlaceholderUI(),
    );
  }

  final List<String> fitnessTestsWithAnalysis = [
    'height & weight',
    'jump',
    'push-up',
    'sit-up',
    'shuttle run',
    'sprint',
    'run/walk',
    'beep test',
    'sit-and-reach'
  ];

  Widget _buildMediaAnalysisUI() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade700),
                borderRadius: BorderRadius.circular(24),
              ),
              child: _mediaFile != null
                  ? (_isPhotoTest)
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.file(File(_mediaFile!.path), fit: BoxFit.cover),
              )
                  : (_videoPlayerController != null && _videoPlayerController!.value.isInitialized)
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(
                  aspectRatio:
                  _videoPlayerController!.value.aspectRatio,
                  child: VideoPlayer(_videoPlayerController!),
                ),
              )
                  : const Center(child: CircularProgressIndicator())
                  : Center(
                child: Icon(
                  _isPhotoTest ? Icons.photo_camera : Icons.videocam,
                  size: 60,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pickMedia,
                  icon: Icon(_isPhotoTest ? Icons.photo_library : Icons.video_library),
                  label: Text(_isPhotoTest ? 'Select Photo' : 'Select Video'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                  _mediaFile != null && !_isAnalyzing ? _analyzeMedia : null,
                  icon: const Icon(Icons.analytics),
                  label: const Text('Analyze'),
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
                  Text('Analyzing your media...'),
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
                      const Text('Analysis Result', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (!_isPhotoTest) ...[
                        Text(
                          'Score: ${_analysisResult!['score'].toStringAsFixed(1)}',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Reps: ${_analysisResult!['reps']}',
                        ),
                      ] else ...[
                        Text(
                          'Height: ${_analysisResult!['height_cm'].toStringAsFixed(2)} cm',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Weight: ${_analysisResult!['weight_kg'].toStringAsFixed(2)} kg',
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.fitness_center, size: 100, color: Colors.blue),
          const SizedBox(height: 20),
          Text(
            widget.testName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              'Instructions and tracking for this test will be available here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}