import 'package:flutter/material.dart';

import 'package:device_vital_monitor_flutter_app/core/layout/app_insets.dart';

/// Full-screen or inline error message with optional retry.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final padding = AppInsets.pagePadding(context);
    final iconSize = AppInsets.iconXL(context);
    final gap = AppInsets.spacingM(context);
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize, color: scheme.error),
            SizedBox(height: gap),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              SizedBox(height: gap),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
