import 'package:flutter/material.dart';
import 'package:khelpratibha/config/app_theme.dart';
import 'package:khelpratibha/models/sport_program.dart';
import 'package:khelpratibha/providers/user_provider.dart';
import 'package:khelpratibha/screens/dashboard/profile/user_profile_page.dart';
import 'package:khelpratibha/screens/performance_dashboard/performance_dashboard_page.dart';
import 'package:khelpratibha/screens/program_detail/program_detail_page.dart';
import 'package:khelpratibha/utils/navigation_helper.dart';
import 'package:khelpratibha/widgets/profile_avatar.dart';
import 'package:khelpratibha/widgets/sport_program_card.dart';
import 'package:provider/provider.dart';

class GenericDashboardScaffold extends StatefulWidget {
  final String appBarTitle;
  final String headerTitle;
  final String headerSubtitle;
  final List<SportProgram> programs;
  final Function(SportProgram) onProgramTap; // Callback for card taps

  const GenericDashboardScaffold({
    super.key,
    required this.appBarTitle,
    required this.headerTitle,
    required this.headerSubtitle,
    required this.programs,
    required this.onProgramTap, // Added to constructor
  });

  @override
  State<GenericDashboardScaffold> createState() =>
      _GenericDashboardScaffoldState();
}

class _GenericDashboardScaffoldState extends State<GenericDashboardScaffold> {
  late List<SportProgram> _filteredPrograms;
  String? _selectedCategoryFilter;
  double _minAthleteCount = 0;
  double _minEventCount = 0;


  @override
  void initState() {
    super.initState();
    _filteredPrograms = List.from(widget.programs);
  }

  void _applyFilters() {
    setState(() {
      _filteredPrograms = widget.programs.where((program) {
        final categoryMatch = _selectedCategoryFilter == null ||
            program.category == _selectedCategoryFilter;
        final athleteMatch = program.athleteCount >= _minAthleteCount;
        final eventMatch = program.eventCount >= _minEventCount;
        return categoryMatch && athleteMatch && eventMatch;
      }).toList();
    });
  }

  void _showFilterPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Use theme color for the bottom sheet background
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return FilterBottomSheet(
          initialCategory: _selectedCategoryFilter,
          initialAthleteCount: _minAthleteCount,
          initialEventCount: _minEventCount,
          allPrograms: widget.programs,
          onApplyFilters: (category, athletes, events) {
            setState(() {
              _selectedCategoryFilter = category;
              _minAthleteCount = athletes;
              _minEventCount = events;
              _applyFilters();
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<UserProvider>().userProfile;
    final theme = Theme.of(context);
    final joinedProgramIds = context.watch<UserProvider>().joinedProgramIds;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appBarTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )),
        // Enhanced AppBar with a gradient background
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppTheme.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterPanel,
            tooltip: 'Filter Programs',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () =>
                  NavigationHelper.navigateToPage(context, const ProfilePage()),
              child: Hero(
                tag: "user-avatar", // Hero animation tag
                child:
                ProfileAvatar(imageUrl: userProfile?.avatarUrl, radius: 20),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            widget.headerTitle,
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.headerSubtitle,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          // AnimatedSwitcher provides a smooth transition when filters are applied
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _filteredPrograms.isEmpty
                ? const Center(
              key: ValueKey('empty'),
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('🚫 No programs match your filters.'),
              ),
            )
                : GridView.builder(
              key: ValueKey(_filteredPrograms.length),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.6,
              ),
              itemCount: _filteredPrograms.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final program = _filteredPrograms[index];
                final isJoined = joinedProgramIds.contains(program.id);

                return SportProgramCard(
                  program: program,
                  isJoined: isJoined,
                  onTap: () {
                    if (isJoined) {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const PerformanceDashboardPage(),
                      ));
                    } else {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ProgramDetailPage(program: program),
                      ));
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- The Filter Bottom Sheet Widget (Restyled for Dark Theme) ---
class FilterBottomSheet extends StatefulWidget {
  final String? initialCategory;
  final double initialAthleteCount;
  final double initialEventCount;
  final List<SportProgram> allPrograms;
  final Function(String?, double, double) onApplyFilters;

  const FilterBottomSheet(
      {super.key,
        this.initialCategory,
        required this.initialAthleteCount,
        required this.initialEventCount,
        required this.allPrograms,
        required this.onApplyFilters});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _selectedCategory;
  late double _athleteCount;
  late double _eventCount;
  late final List<String> _uniqueCategories;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _athleteCount = widget.initialAthleteCount;
    _eventCount = widget.initialEventCount;
    _uniqueCategories =
        widget.allPrograms.map((p) => p.category).toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade700,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text('Filter Programs',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
          Text('Category',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _uniqueCategories.map((category) {
              return ChoiceChip(
                label: Text(category),
                selected: _selectedCategory == category,
                // Use theme colors for selected state
                selectedColor: theme.colorScheme.primary.withValues(alpha: 0.8),
                labelStyle: TextStyle(
                  color: _selectedCategory == category
                      ? Colors.white
                      : theme.colorScheme.onSurface,
                ),
                onSelected: (isSelected) {
                  setState(() {
                    _selectedCategory = isSelected ? category : null;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          _buildSlider('Minimum Athletes', _athleteCount,
                  (val) => setState(() => _athleteCount = val), 300),
          _buildSlider('Minimum Events', _eventCount,
                  (val) => setState(() => _eventCount = val), 10),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                widget.onApplyFilters(
                    _selectedCategory, _athleteCount, _eventCount);
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.check),
              label: const Text('Apply Filters'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSlider(
      String title, double value, ValueChanged<double> onChanged, double max) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title: ${value.toInt()}',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w500)),
        Slider(
          value: value,
          onChanged: onChanged,
          min: 0,
          max: max,
          divisions: max.toInt(),
          // Use theme's primary color for the slider
          activeColor: theme.colorScheme.primary,
          label: value.toInt().toString(),
        ),
      ],
    );
  }
}
