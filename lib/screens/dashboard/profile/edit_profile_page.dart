import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khelpratibha/providers/user_provider.dart';
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
  DateTime? _selectedDate;
  XFile? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final userProfile = context.read<UserProvider>().userProfile;
    _fullNameController = TextEditingController(text: userProfile?.fullName);
    _sportController = TextEditingController(text: userProfile?.sport);
    _selectedDate = userProfile?.dateOfBirth;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _sportController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
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
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final userProvider = context.read<UserProvider>();
      final dbService = DatabaseService();
      final storageService = StorageService();
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
          dateOfBirth: _selectedDate,
        );

        await dbService.upsertUserProfile(updatedProfile);
        userProvider.setUserProfile(updatedProfile);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
          Navigator.of(context).pop();
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
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<UserProvider>().userProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Center(
              child: Stack(
                children: [
                  ProfileAvatar(
                    imageUrl: userProfile?.avatarUrl,
                    // CORRECTED: Passing the XFile directly to the widget, which resolves the error.
                    imageFile: _selectedImage,
                    radius: 60,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CustomInputField(
              controller: _fullNameController,
              labelText: 'Full Name',
              prefixIcon: Icons.person_outline,
              validator: (value) => value == null || value.isEmpty ? 'Please enter your full name' : null,
            ),
            const SizedBox(height: 16),
            CustomInputField(
              controller: _sportController,
              labelText: 'Primary Sport',
              prefixIcon: Icons.sports_soccer_outlined,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  prefixIcon: const Icon(Icons.cake_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                ),
                child: Text(
                  _selectedDate != null ? _selectedDate!.toLocal().toString().split(' ')[0] : 'Select your date of birth',
                ),
              ),
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save Changes'),
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

