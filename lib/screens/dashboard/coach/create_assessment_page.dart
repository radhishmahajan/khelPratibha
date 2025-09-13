import 'package:flutter/material.dart';
import 'package:khelpratibha/models/assessment.dart';
import 'package:khelpratibha/screens/dashboard/coach/assessment_result_page.dart';
import 'package:khelpratibha/services/ai_analysis_service.dart';
import 'package:khelpratibha/widgets/custom_input_field.dart';
import 'package:provider/provider.dart';

class CreateAssessmentPage extends StatefulWidget {
  const CreateAssessmentPage({super.key});

  @override
  State<CreateAssessmentPage> createState() => _CreateAssessmentPageState();
}

class _CreateAssessmentPageState extends State<CreateAssessmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _sprintController = TextEditingController();
  final _agilityController = TextEditingController();
  final _jumpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _sprintController.dispose();
    _agilityController.dispose();
    _jumpController.dispose();
    super.dispose();
  }

  Future<void> _runAnalysis() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final metrics = {
        'Sprint': double.parse(_sprintController.text),
        'Agility': double.parse(_agilityController.text),
        'Jump': double.parse(_jumpController.text),
      };

      // CORRECTED: Properly read the AiAnalysisService from the provider context
      final aiService = context.read<AiAnalysisService>();
      final assessment = await aiService.getAnalysis(
        playerId: 'mock_player_id', // Replace with actual player ID
        coachId: 'mock_coach_id',   // Replace with actual coach ID
        metrics: metrics,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => AssessmentResultPage(assessment: assessment),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Assessment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter Player Metrics',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              CustomInputField(
                controller: _sprintController,
                labelText: 'Sprint Time (s)',
                prefixIcon: Icons.timer_outlined,
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: _agilityController,
                labelText: 'Agility Score (s)',
                prefixIcon: Icons.directions_run_rounded,
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomInputField(
                controller: _jumpController,
                labelText: 'Vertical Jump (cm)',
                prefixIcon: Icons.height_rounded,
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                onPressed: _runAnalysis,
                icon: const Icon(Icons.psychology_alt_rounded),
                label: const Text('Run AI Analysis'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
