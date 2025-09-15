import 'dart:ui';
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

class _CategorySelectionTabState extends State<CategorySelectionTab>
    with SingleTickerProviderStateMixin {
  String? _selectedAgeGroup;
  String? _selectedGender;
  SportEvent? _selectedEvent;

  late Future<List<SportEvent>> _eventsFuture;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _eventsFuture =
        context.read<DatabaseService>().fetchEventsForProgram(widget.program.id);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool canStart = _selectedAgeGroup != null &&
        _selectedGender != null &&
        _selectedEvent != null;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            Text('Choose Your Competition Category',
                style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
                'Select your age group, gender, and specific event to get started.',
                style: theme.textTheme.bodyMedium),
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
            _buildGlassCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.event, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('Event/Discipline',
                          style: theme.textTheme.titleLarge),
                    ]),
                    const SizedBox(height: 16),
                    FutureBuilder<List<SportEvent>>(
                      future: _eventsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Center(
                              child: Text('Could not load events.'));
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('No events found for this program.'));
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
                              onSelected: (_) =>
                                  setState(() => _selectedEvent = event),
                              selectedColor: theme.colorScheme.primary,
                              labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : theme.colorScheme.onSurface),
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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: canStart
                  ? _buildGlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Selection',
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Chip(label: Text('Age: $_selectedAgeGroup')),
                          Chip(label: Text('Gender: $_selectedGender')),
                          Chip(
                              label: Text('Event: ${_selectedEvent!.name}')),
                        ],
                      ),
                    ],
                  ),
                ),
              )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            _buildGradientButton(
              text: 'Start Training Program',
              onPressed: canStart
                  ? () {
                context
                    .read<UserProvider>()
                    .joinProgram(programId: widget.program.id);
                NavigationHelper.navigateToPageReplaced(
                    context,
                    PerformanceDashboardPage(program: widget.program));
              }
                  : null,
            ),
          ],
        ),
      ),
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
    return _buildGlassCard(
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
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurface),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isLight
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isLight
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.grey.shade800,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required String text,
    required VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEA3B81), Color(0xFF6B47EE)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}