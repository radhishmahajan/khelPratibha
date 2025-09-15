import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final XFile? imageFile;
  final double radius;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.imageFile,
    this.radius = 40,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: radius,
          backgroundColor: theme.colorScheme.surface,
          backgroundImage: _getImageProvider(),
          child: _getImageProvider() == null
              ? Icon(
            Icons.person,
            size: radius,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          )
              : null,
        ),
      ),
    );
  }

  ImageProvider? _getImageProvider() {
    if (imageFile != null) {
      return FileImage(File(imageFile!.path));
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return NetworkImage(imageUrl!);
    }
    return null;
  }
}