import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:khelpratibha/config/theme_notifier.dart';
import 'package:khelpratibha/models/sport_category.dart';
import 'package:khelpratibha/models/sport_program.dart';
import 'package:khelpratibha/providers/user_provider.dart';
import 'package:khelpratibha/screens/dashboard/profile/user_profile_page.dart';
import 'package:khelpratibha/screens/performance_dashboard/performance_dashboard_page.dart';
import 'package:khelpratibha/screens/program_detail/program_detail_page.dart';
import 'package:khelpratibha/services/database_service.dart';
import 'package:khelpratibha/utils/navigation_helper.dart';
import 'package:khelpratibha/widgets/profile_avatar.dart';
import 'package:khelpratibha/widgets/sport_program_card.dart';
import 'package:provider/provider.dart';

class GenericDashboardScaffold extends StatefulWidget {
  final String appBarTitle;
  final String headerTitle;
  final String headerSubtitle;
  final Function(SportProgram) onProgramTap;
  final SportCategory category;

  const GenericDashboardScaffold({
    super.key,
    required this.appBarTitle,
    required this.headerTitle,
    required this.headerSubtitle,
    required this.onProgramTap,
    required this.category,
  });

  @override
  State<GenericDashboardScaffold> createState() =>
      _GenericDashboardScaffoldState();
}

class _GenericDashboardScaffoldState extends State<GenericDashboardScaffold> with SingleTickerProviderStateMixin {
  late Future<List<SportProgram>> _programsFuture;
  List<SportProgram> _allPrograms = [];
  List<SportProgram> _filteredPrograms = [];
  String? _selectedSubCategoryFilter;
  double _minAthleteCount = 0;
  double _minEventCount = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _programsFuture = context.read<DatabaseService>().fetchPrograms(category: widget.category);
    _programsFuture.then((programs) {
      if (mounted) {
        setState(() {
          _allPrograms = programs;
          _filteredPrograms = List.from(_allPrograms);
        });
      }
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _filteredPrograms = _allPrograms.where((program) {
        final subCategoryMatch = _selectedSubCategoryFilter == null ||
            program.subCategory == _selectedSubCategoryFilter;
        final athleteMatch = program.athleteCount >= _minAthleteCount;
        final eventMatch = program.eventCount >= _minEventCount;
        return subCategoryMatch && athleteMatch && eventMatch;
      }).toList();
    });
  }

  void _showFilterPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FilterBottomSheet(
          initialCategory: _selectedSubCategoryFilter,
          initialAthleteCount: _minAthleteCount,
          initialEventCount: _minEventCount,
          allPrograms: _allPrograms,
          onApplyFilters: (category, athletes, events) {
            setState(() {
              _selectedSubCategoryFilter = category;
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
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isLight = themeNotifier.themeMode == ThemeMode.light;
    final theme = Theme.of(context);
    final joinedProgramIds = context.watch<UserProvider>().joinedProgramIds;

    final headerImage = widget.category == SportCategory.olympics
        ? 'https://images.pexels.com/photos/863988/pexels-photo-863988.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2'
        : 'https://images.pexels.com/photos/6763736/pexels-photo-6763736.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2';

    final headerText = widget.category == SportCategory.olympics
        ? 'Olympic Sports Excellence'
        : 'Paralympic Sports Excellence';

    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(widget.appBarTitle),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(isLight ? Icons.dark_mode : Icons.light_mode),
              color: isLight ? Colors.black : Colors.white,
              onPressed: () => themeNotifier.toggleTheme(),
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              color: isLight ? Colors.black : Colors.white,
              onPressed: _showFilterPanel,
              tooltip: 'Filter Programs',
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: GestureDetector(
                onTap: () =>
                    NavigationHelper.navigateToPage(context, const ProfilePage()),
                child: Hero(
                  tag: "user-avatar",
                  child:
                  ProfileAvatar(imageUrl: userProfile?.avatarUrl, radius: 20),
                ),
              ),
            ),
          ],
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: isLight
                ? const LinearGradient(
              colors: [Color(0xFFFFF1F5), Color(0xFFE8E2FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : const LinearGradient(
              colors: [Color(0xFF0f0c29), Color(0xFF302b63), Color(0xFF24243e)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.network(
                            headerImage,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                            ),
                          ),
                          Text(
                            headerText,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
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
                    FutureBuilder<List<SportProgram>>(
                      future: _programsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No programs available.'));
                        } else {
                          return AnimatedSwitcher(
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
                                childAspectRatio: 0.52,
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
                                        builder: (context) => PerformanceDashboardPage(program: program),
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
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
  late final List<String> _uniqueSubCategories;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _athleteCount = widget.initialAthleteCount;
    _eventCount = widget.initialEventCount;
    _uniqueSubCategories =
        widget.allPrograms.map((p) => p.subCategory).where((c) => c.isNotEmpty).toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isLight ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.5),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
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
                Text('Sub-Category',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _uniqueSubCategories.map((category) {
                    return ChoiceChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      selectedColor: theme.colorScheme.primary.withAlpha(204),
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
          ),
        ),
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
          activeColor: theme.colorScheme.primary,
          label: value.toInt().toString(),
        ),
      ],
    );
  }
}