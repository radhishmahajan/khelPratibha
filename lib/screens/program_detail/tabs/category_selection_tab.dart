import 'package:flutter/material.dart';
import 'package:khelpratibha/models/sport_event.dart';
import 'package:khelpratibha/models/sport_program.dart';
import 'package:khelpratibha/providers/user_provider.dart';
import 'package:khelpratibha/screens/performance_dashboard/performance_dashboard_page.dart';
import 'package:khelpratibha/services/database_service.dart';
import 'package:khelpratibha/utils/navigation_helper.dart';
import 'package:provider/provider.dart';

class CategorySelectionTab extends StatefulWidget {
  final SportProgram program;
  const CategorySelectionTab({super.key, required this.program});

  @override
  State<CategorySelectionTab> createState() => _CategorySelectionTabState();
}

class _CategorySelectionTabState extends State<CategorySelectionTab> {
  String? _selectedAgeGroup;
  String? _selectedGender;
  SportEvent? _selectedEvent;

  late Future<List<SportEvent>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = context.read<DatabaseService>().fetchEventsForProgram(widget.program.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool canStart = _selectedAgeGroup != null && _selectedGender != null && _selectedEvent != null;

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        Text('Choose Your Competition Category', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text('Select your age group, gender, and specific event to get started.', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 32),
        _buildCategorySection(
          icon: Icons.access_time_filled_rounded,
          title: 'Age Group',
          options: ['Under 16', 'Under 18', 'Under 21', 'Senior'],
          selectedValue: _selectedAgeGroup,
          onSelected: (value) => setState(() => _selectedAgeGroup = value),
        ),
        const SizedBox(height: 24),
        _buildCategorySection(
          icon: Icons.people_alt_rounded,
          title: 'Gender Category',
          options: ['Men', 'Women', 'Mixed'],
          selectedValue: _selectedGender,
          onSelected: (value) => setState(() => _selectedGender = value),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.event, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('Event/Discipline', style: theme.textTheme.titleLarge),
                ]),
                const SizedBox(height: 16),
                FutureBuilder<List<SportEvent>>(
                  future: _eventsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Could not load events.'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No events found for this program.'));
                    }

                    final events = snapshot.data!;
                    return Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: events.map((event) {
                        final isSelected = _selectedEvent?.id == event.id;
                        return ChoiceChip(
                          label: Text(event.name),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedEvent = event),
                          selectedColor: theme.colorScheme.primary,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : theme.colorScheme.onSurface),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
        if (canStart)
          Card(
              color: theme.colorScheme.primary.withAlpha(26),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Selection', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Chip(label: Text('Age: $_selectedAgeGroup')),
                        Chip(label: Text('Gender: $_selectedGender')),
                        Chip(label: Text('Event: ${_selectedEvent!.name}')),
                      ],
                    ),
                  ],
                ),
              )),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: canStart
              ? () {
            context
                .read<UserProvider>()
                .joinProgram(programId: widget.program.id);
            NavigationHelper.navigateToPageReplaced(
                context, PerformanceDashboardPage(program: widget.program));
          }
              : null,
          child: const Text('Start Training Program'),
        ),
      ],
    );
  }

  Widget _buildCategorySection({
    required IconData icon,
    required String title,
    required List<String> options,
    required String? selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: theme.textTheme.titleLarge),
            ]),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: options.map((option) {
                final isSelected = selectedValue == option;
                return ChoiceChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (_) => onSelected(option),
                  selectedColor: theme.colorScheme.primary,
                  labelStyle: TextStyle(
                      color:
                      isSelected ? Colors.white : theme.colorScheme.onSurface),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}