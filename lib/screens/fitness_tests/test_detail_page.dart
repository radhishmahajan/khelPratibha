import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khelpratibha/models/fitness_test.dart';
import 'package:khelpratibha/providers/achievement_provider.dart';
import 'package:khelpratibha/providers/goal_provider.dart';
import 'package:khelpratibha/providers/leaderboard_provider.dart';
import 'package:khelpratibha/providers/performance_provider.dart';
import 'package:khelpratibha/providers/user_provider.dart';
import 'package:khelpratibha/services/analysis_service.dart';
import 'package:khelpratibha/services/database_service.dart';
import 'package:khelpratibha/utils/test_instructions.dart';
import 'package:khelpratibha/widgets/info_banner.dart'; // Import the new banner
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class TestDetailPage extends StatefulWidget {
  final FitnessTest test;

  const TestDetailPage({super.key, required this.test});

  @override
  State<TestDetailPage> createState() => _TestDetailPageState();
}

class _TestDetailPageState extends State<TestDetailPage> {
  XFile? _mediaFile;
  VideoPlayerController? _videoPlayerController;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;
  AppNotification? _notification; // State for the notification

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  void _showNotification(String message, NotificationType type) {
    setState(() {
      _notification = AppNotification(message: message, type: type);
    });
  }

  bool get _isPhotoTest {
    return widget.test.name.toLowerCase().contains('height & weight');
  }

  Future<void> _initializeVideoPlayer(XFile file) async {
    _videoPlayerController?.dispose();
    _videoPlayerController = VideoPlayerController.file(File(file.path));
    await _videoPlayerController!.initialize();
    await _videoPlayerController!.setLooping(true);
    await _videoPlayerController!.play();
    setState(() {});
  }

  Future<void> _pickMedia() async {
    final pickedFile = _isPhotoTest
        ? await ImagePicker().pickImage(source: ImageSource.gallery)
        : await ImagePicker().pickVideo(
        source: ImageSource.gallery, maxDuration: const Duration(minutes: 1));

    if (pickedFile != null) {
      setState(() {
        _mediaFile = pickedFile;
        _analysisResult = null;
        _notification = null;
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
      _notification = null;
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

      String coreTestName = widget.test.name.split('(').first.trim();

      if (!_isPhotoTest) {
        await dbService.saveStrengthTestResult(
          testName: coreTestName,
          score: result['score'],
          reps: result['reps'],
        );
        await achievementProvider.checkAndUnlockAchievements(result['reps'], 0);
        await goalProvider.addGoal('Improve ${widget.test.name} score by 10%');
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
        _showNotification('Analysis complete and data saved!', NotificationType.success);
      }
    } catch (e) {
      if (mounted) {
        _showNotification('Analysis failed: ${e.toString()}', NotificationType.error);
      }
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.test.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          _buildNewMediaAnalysisUI(),
          if (_notification != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: InfoBanner(
                notification: _notification!,
                onDismiss: () => setState(() => _notification = null),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNewMediaAnalysisUI() {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final instructions = getInstructionsForTest(widget.test.name); // Get dynamic instructions

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.test.name,
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                _buildTag(widget.test.difficulty, Colors.deepOrange, isLight),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.test.description,
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor),
            ),
            const SizedBox(height: 24),

            // Recording Area
            _RecordingArea(
              mediaFile: _mediaFile,
              isPhotoTest: _isPhotoTest,
              videoPlayerController: _videoPlayerController,
              onStartRecording: _pickMedia,
            ),
            const SizedBox(height: 24),

            // Test Instructions
            _TestInstructionsCard(
              duration: widget.test.duration,
              isLight: isLight,
              steps: instructions.steps, // Pass dynamic steps
              features: instructions.features, // Pass dynamic features
            ),
            const SizedBox(height: 24),

            // Analyze Button
            if (_mediaFile != null)
              _isAnalyzing
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _analyzeMedia,
                  icon: const Icon(Icons.analytics_outlined),
                  label: const Text('Analyze Performance'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

            // Error and Result Display

            if (_analysisResult != null)
              _AnalysisResultCard(
                analysisResult: _analysisResult!,
                isPhotoTest: _isPhotoTest,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color, bool isLight) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _RecordingArea extends StatelessWidget {
  final XFile? mediaFile;
  final bool isPhotoTest;
  final VideoPlayerController? videoPlayerController;
  final VoidCallback onStartRecording;

  const _RecordingArea({
    this.mediaFile,
    required this.isPhotoTest,
    this.videoPlayerController,
    required this.onStartRecording,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.camera_alt_outlined, color: theme.hintColor),
              const SizedBox(width: 8),
              Text(
                'Upload Area',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: mediaFile != null
                  ? (isPhotoTest)
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:
                Image.file(File(mediaFile!.path), fit: BoxFit.cover),
              )
                  : (videoPlayerController != null &&
                  videoPlayerController!.value.isInitialized)
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: videoPlayerController!.value.aspectRatio,
                  child: VideoPlayer(videoPlayerController!),
                ),
              )
                  : const Center(child: CircularProgressIndicator())
                  : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload_file, size: 40, color: Colors.grey.shade600),
                    const SizedBox(height: 8),
                    Text(
                      'Your media will appear here',
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                    Text(
                      'Upload a video of your performance',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onStartRecording,
              icon: const Icon(Icons.upload_rounded),
              label: Text(mediaFile == null ? 'Upload Media' : 'Upload Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TestInstructionsCard extends StatelessWidget {
  final String duration;
  final bool isLight;
  final List<String> steps;
  final List<String> features;

  const _TestInstructionsCard({
    required this.duration,
    required this.isLight,
    required this.steps,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Test Instructions',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('Duration: $duration',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 16),
          Text('Steps to follow:',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...steps.asMap().entries.map((entry) {
            return _InstructionStep(number: '${entry.key + 1}.', text: entry.value);
          }),
          const Divider(height: 24),
          Text('AI Analysis Features:',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...features.map((feature) => _FeatureCheck(text: feature)),
          const Divider(height: 24),
          Text(
            'Ensure your device is stable and you have enough space to perform the test safely.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final String number;
  final String text;

  const _InstructionStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(number, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _FeatureCheck extends StatelessWidget {
  final String text;
  const _FeatureCheck({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}

class _AnalysisResultCard extends StatelessWidget {
  final Map<String, dynamic> analysisResult;
  final bool isPhotoTest;

  const _AnalysisResultCard(
      {required this.analysisResult, required this.isPhotoTest});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Analysis Result',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (!isPhotoTest) ...[
                Text('Score: ${analysisResult['score'].toStringAsFixed(1)}'),
                const SizedBox(height: 8),
                Text('Reps: ${analysisResult['reps']}'),
              ] else ...[
                Text(
                    'Height: ${analysisResult['height_cm'].toStringAsFixed(2)} cm'),
                const SizedBox(height: 8),
                Text(
                    'Weight: ${analysisResult['weight_kg'].toStringAsFixed(2)} kg'),
              ]
            ],
          ),
        ),
      ),
    );
  }
}