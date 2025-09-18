// lib/widgets/info_banner.dart
import 'dart:async';
import 'package:flutter/material.dart';

enum NotificationType { success, error }

class AppNotification {
  final String message;
  final NotificationType type;

  AppNotification({required this.message, required this.type});
}

class InfoBanner extends StatefulWidget {
  final AppNotification notification;
  final VoidCallback onDismiss;

  const InfoBanner({
    super.key,
    required this.notification,
    required this.onDismiss,
  });

  @override
  State<InfoBanner> createState() => _InfoBannerState();
}

class _InfoBannerState extends State<InfoBanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
    _dismissTimer = Timer(const Duration(seconds: 4), () {
      _controller.reverse().then((_) => widget.onDismiss());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSuccess = widget.notification.type == NotificationType.success;
    final backgroundColor = isSuccess ? Colors.green.shade600 : theme.colorScheme.error;
    final icon = isSuccess ? Icons.check_circle_outline : Icons.error_outline;

    return SlideTransition(
      position: _offsetAnimation,
      child: Material(
        child: Container(
          color: backgroundColor,
          padding: EdgeInsets.fromLTRB(16, 12 + MediaQuery.of(context).padding.top, 16, 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.notification.message,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}