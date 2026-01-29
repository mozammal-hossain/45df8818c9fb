import 'package:flutter/material.dart';

import 'package:device_vital_monitor_flutter_app/core/layout/app_insets.dart';

/// Placeholder when there is no data to show.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message, this.icon});

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final padding = AppInsets.pagePadding(context);
    final iconSize = AppInsets.iconL(context);
    final gap = AppInsets.spacingSM(context);
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: iconSize, color: scheme.outline),
              SizedBox(height: gap),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
