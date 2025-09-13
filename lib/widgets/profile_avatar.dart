import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final XFile? imageFile;
  final double radius;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.imageFile,
    this.radius = 40,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: _getImageProvider(),
      child: _getImageProvider() == null
          ? Icon(Icons.person, size: radius)
          : null,
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
