import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khelpratibha/models/sport_category.dart';
import 'package:khelpratibha/models/user_role.dart';
import 'package:khelpratibha/providers/user_provider.dart';
import 'package:khelpratibha/screens/core/auth_gate.dart';
import 'package:khelpratibha/services/database_service.dart';
import 'package:khelpratibha/services/storage_service.dart';
import 'package:khelpratibha/widgets/custom_input_field.dart';
import 'package:khelpratibha/widgets/profile_avatar.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _sportController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late DateTime? _dateOfBirth;
  DateTime? _selectedDate;
  XFile? _selectedImage;
  SportCategory? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final userProfile = context.read<UserProvider>().userProfile;
    _fullNameController = TextEditingController(text: userProfile?.fullName);
    _sportController = TextEditingController(text: userProfile?.sport);
    _dateOfBirth = userProfile?.dateOfBirth;
    _selectedCategory = userProfile?.selectedCategory;
    _heightController = TextEditingController(text: userProfile?.heightCm?.toString());
    _weightController = TextEditingController(text: userProfile?.weightKg?.toString());
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _sportController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() => _selectedImage = pickedFile);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final userProvider = context.read<UserProvider>();
    final dbService = context.read<DatabaseService>();
    final storageService = context.read<StorageService>();
    final currentProfile = userProvider.userProfile!;

    try {
      String? avatarUrl = currentProfile.avatarUrl;
      if (_selectedImage != null) {
        avatarUrl = await storageService.uploadAvatar(_selectedImage!);
      }

      final updatedProfile = currentProfile.copyWith(
        fullName: _fullNameController.text.trim(),
        avatarUrl: avatarUrl,
        sport: _sportController.text.trim(),
        dateOfBirth: _dateOfBirth,
        selectedCategory: _selectedCategory,
        heightCm: double.tryParse(_heightController.text),
        weightKg: double.tryParse(_weightController.text),
      );

      await dbService.upsertUserProfile(updatedProfile);
      userProvider.setUserProfile(updatedProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthGate()),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<UserProvider>().userProfile;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const SizedBox(height: 16),
            Center(
              child: Stack(
                children: [
                  ProfileAvatar(
                    imageUrl: userProfile?.avatarUrl,
                    imageFile: _selectedImage,
                    radius: 60,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: theme.colorScheme.primary,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Personal Information', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 20),
                    CustomInputField(
                      controller: _fullNameController,
                      labelText: 'Full Name',
                      prefixIcon: Icons.person_outline,
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your full name' : null,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          prefixIcon: const Icon(Icons.cake_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(_selectedDate != null ? _selectedDate!.toLocal().toString().split(' ')[0] : 'Select your date of birth'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomInputField(
                      controller: _heightController,
                      labelText: 'Height (cm)',
                      prefixIcon: Icons.height,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    CustomInputField(
                      controller: _weightController,
                      labelText: 'Weight (kg)',
                      prefixIcon: Icons.fitness_center,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sporting Information', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 20),
                    CustomInputField(
                      controller: _sportController,
                      labelText: 'Primary Sport',
                      prefixIcon: Icons.sports_soccer_outlined,
                    ),
                    const SizedBox(height: 16),
                    if (userProfile?.role == UserRole.player)
                      DropdownButtonFormField<SportCategory>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Sport Category',
                          prefixIcon: const Icon(Icons.category_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: SportCategory.values.map((SportCategory category) {
                          return DropdownMenuItem<SportCategory>(
                            value: category,
                            child: Text(category.name[0].toUpperCase() + category.name.substring(1)),
                          );
                        }).toList(),
                        onChanged: (SportCategory? newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save Changes'),
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}