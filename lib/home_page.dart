// lib/home_page.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'api_service.dart';
import 'workout_result.dart';

class Exercise {
  final String name;
  final String iconAssetPath;
  Exercise({required this.name, required this.iconAssetPath});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isProcessing = false;

  final List<Exercise> _allExercises = [
    Exercise(name: 'Pushups', iconAssetPath: 'assets/icons/pushup.png'),
    Exercise(name: 'Pullups', iconAssetPath: 'assets/icons/pullup.png'),
    Exercise(name: 'Situps', iconAssetPath: 'assets/icons/situp.png'),
    Exercise(name: 'Squats', iconAssetPath: 'assets/icons/squat.png'),
    Exercise(name: 'JumpingJacks', iconAssetPath: 'assets/icons/jumping_jack.png'),
  ];
  List<Exercise> _filteredExercises = [];

  @override
  void initState() {
    super.initState();
    _filteredExercises = _allExercises;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterExercises(String query) {
    final lowerCaseQuery = query.toLowerCase();
    setState(() {
      _filteredExercises = _allExercises.where((exercise) {
        return exercise.name.toLowerCase().contains(lowerCaseQuery);
      }).toList();
    });
  }

  void _showWorkoutResultDialog(WorkoutResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(child: Text('Workout Summary', style: TextStyle(fontWeight: FontWeight.bold))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                result.exercise.toUpperCase(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              // Display the new score
              Text(
                '${result.score}',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              Text('Quality Score', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 10),
              Text('${result.goodReps} Good Reps | ${result.badReps} Poor Form', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
              const Divider(height: 30),
              if (result.feedbackLog.isNotEmpty) ...[
                Text('Feedback Log', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: result.feedbackLog.length,
                    itemBuilder: (context, index) {
                      final log = result.feedbackLog[index];
                      final isGood = log.contains('Good');
                      return ListTile(
                        leading: Icon(
                          isGood ? Icons.check_circle_outline : Icons.error_outline,
                          color: isGood ? Colors.greenAccent : Colors.redAccent,
                        ),
                        title: Text(log),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('DONE'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Analysis Error'),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> _pickAndProcessVideo(String exerciseName) async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video == null) return;

    setState(() => _isProcessing = true);

    try {
      final result = await _apiService.uploadVideo(video, exerciseName);
      if (mounted) _showWorkoutResultDialog(result);
    } catch (e) {
      if (mounted) _showErrorDialog(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Exercise'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
          )
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _filterExercises,
                  decoration: InputDecoration(
                    hintText: 'Search for an exercise...',
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _filteredExercises.isEmpty
                      ? const Center(child: Text('No exercises found.'))
                      : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _filteredExercises.length,
                    itemBuilder: (context, index) {
                      return _buildExerciseCard(context, _filteredExercises[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Analyzing Video...', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, Exercise exercise) {
    return Card(
      child: InkWell(
        onTap: _isProcessing ? null : () => _pickAndProcessVideo(exercise.name),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  exercise.iconAssetPath,
                  width: 40,
                  height: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 10),
                Text(
                  exercise.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}