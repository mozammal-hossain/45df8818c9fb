import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:device_vital_monitor_flutter_app/domain/entities/vital_log.dart';

class VitalLogItem extends StatelessWidget {
  const VitalLogItem({super.key, required this.log});

  final VitalLog log;

  static final _timeFormat = DateFormat('MMM d, HH:mm');

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final time =
        log.timestamp.isUtc ? log.timestamp : log.timestamp.toUtc();
    final timeStr = _timeFormat.format(time.toLocal());
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(timeStr, style: textTheme.titleSmall),
        subtitle: Text(
          'Thermal: ${log.thermalValue} · Battery: ${log.batteryLevel.toStringAsFixed(0)}% · Memory: ${log.memoryUsage.toStringAsFixed(0)}%',
          style: textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
