import 'package:flutter/material.dart';

import '../core/theme/theme.dart';
import '../providers/theme_provider_scope.dart';
import '../services/device_sensor_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int? _thermalState;
  bool _isLoadingThermal = true;
  int? _batteryLevel;
  String? _batteryHealth;
  String? _chargerConnection;
  String? _batteryStatus;
  bool _isLoadingBattery = true;
  int? _memoryUsage;
  bool _isLoadingMemory = true;
  Map<String, int>? _storageInfo;
  bool _isLoadingStorage = true;

  @override
  void initState() {
    super.initState();
    _fetchSensorData();
  }

  Future<void> _fetchSensorData() async {
    setState(() {
      _isLoadingThermal = true;
      _isLoadingBattery = true;
      _isLoadingMemory = true;
      _isLoadingStorage = true;
    });
    try {
      final results = await Future.wait([
        DeviceSensorService.getThermalState(),
        DeviceSensorService.getBatteryLevel(),
        DeviceSensorService.getBatteryHealth(),
        DeviceSensorService.getChargerConnection(),
        DeviceSensorService.getBatteryStatus(),
        DeviceSensorService.getMemoryUsage(),
        DeviceSensorService.getStorageInfo(),
      ]);
      if (mounted) {
        setState(() {
          _thermalState = results[0] as int?;
          _batteryLevel = results[1] as int?;
          _batteryHealth = results[2] as String?;
          _chargerConnection = results[3] as String?;
          _batteryStatus = results[4] as String?;
          _memoryUsage = results[5] as int?;
          _storageInfo = results[6] as Map<String, int>?;
          _isLoadingThermal = false;
          _isLoadingBattery = false;
          _isLoadingMemory = false;
          _isLoadingStorage = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _thermalState = null;
          _batteryLevel = null;
          _batteryHealth = null;
          _chargerConnection = null;
          _batteryStatus = null;
          _memoryUsage = null;
          _storageInfo = null;
          _isLoadingThermal = false;
          _isLoadingBattery = false;
          _isLoadingMemory = false;
          _isLoadingStorage = false;
        });
      }
    }
  }

  String _getBatteryStatus(int level) {
    if (level >= 80) return 'HEALTHY';
    if (level >= 50) return 'MODERATE';
    if (level >= 20) return 'LOW';
    return 'CRITICAL';
  }

  Color _getBatteryStatusColor(BuildContext context, int level) {
    final colors = Theme.of(context).extension<AppColors>()!;
    if (level >= 80) return colors.success;
    if (level >= 50) return colors.warning;
    if (level >= 20) return colors.low;
    return colors.error;
  }

  String _getEstimatedTimeRemaining(int level) {
    // Rough estimation: assuming average usage
    final hours = (level * 0.14).round();
    return 'Estimated ${hours}h remaining';
  }

  String _formatBatteryHealth(String health) {
    switch (health) {
      case 'GOOD':
        return 'Good';
      case 'OVERHEAT':
        return 'Overheat';
      case 'DEAD':
        return 'Dead';
      case 'OVER_VOLTAGE':
        return 'Over voltage';
      case 'UNSPECIFIED_FAILURE':
        return 'Unspecified failure';
      case 'COLD':
        return 'Cold';
      default:
        return health;
    }
  }

  String _formatChargerConnection(String connection) {
    switch (connection) {
      case 'AC':
        return 'AC Charger';
      case 'USB':
        return 'USB';
      case 'WIRELESS':
        return 'Wireless';
      case 'NONE':
        return 'Not connected';
      default:
        return connection;
    }
  }

  String _formatBatteryStatus(String status) {
    switch (status) {
      case 'CHARGING':
        return 'Charging';
      case 'DISCHARGING':
        return 'Discharging';
      case 'FULL':
        return 'Full';
      case 'NOT_CHARGING':
        return 'Not charging';
      case 'UNKNOWN':
        return 'Unknown';
      default:
        return status;
    }
  }

  String _getThermalStateLabel(int state) {
    switch (state) {
      case 0:
        return 'NONE';
      case 1:
        return 'LIGHT';
      case 2:
        return 'MODERATE';
      case 3:
        return 'SEVERE';
      default:
        return 'UNKNOWN';
    }
  }

  String _getThermalStateDescription(int state) {
    switch (state) {
      case 0:
        return 'System operating within normal temperature ranges.';
      case 1:
        return 'Slightly elevated temperature, monitoring recommended.';
      case 2:
        return 'Moderate thermal stress detected. Consider reducing usage.';
      case 3:
        return 'Severe thermal condition. Device may throttle performance.';
      default:
        return 'Thermal state unavailable.';
    }
  }

  Color _getThermalStateColor(BuildContext context, int state) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final scheme = Theme.of(context).colorScheme;
    switch (state) {
      case 0:
        return colors.success;
      case 1:
        return colors.warning;
      case 2:
        return colors.low;
      case 3:
        return colors.error;
      default:
        return scheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final themeProvider = ThemeProviderScope.of(context);

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLow,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Handle menu tap
          },
        ),
        title: const Text('Device Vital Monitor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: themeProvider.cycleThemeMode,
            tooltip: 'Toggle light / dark / system theme',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Handle more options
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSensorData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildThermalStateCard(context),
              const SizedBox(height: 16),
              _buildBatteryLevelCard(context),
              const SizedBox(height: 16),
              _buildMemoryUsageCard(context),
              const SizedBox(height: 16),
              _buildDiskSpaceCard(context),
              const SizedBox(height: 24),
              _buildLogStatusButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThermalStateCard(BuildContext context) {
    final thermalState = _thermalState ?? 0;
    final hasData = _thermalState != null && !_isLoadingThermal;
    final stateLabel = hasData ? _getThermalStateLabel(thermalState) : '—';
    final colors = Theme.of(context).extension<AppColors>()!;
    final scheme = Theme.of(context).colorScheme;
    final stateColor = hasData
        ? _getThermalStateColor(context, thermalState)
        : scheme.outline;
    final stateDescription = hasData
        ? _getThermalStateDescription(thermalState)
        : 'Loading thermal state...';
    final textTheme = Theme.of(context).textTheme;

    return _buildCard(
      context,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: stateColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.thermostat, color: stateColor, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Thermal State', style: textTheme.titleLarge),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    if (_isLoadingThermal)
                      const SizedBox(
                        height: 32,
                        width: 32,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Text('$_thermalState', style: textTheme.displayLarge),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: stateColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        stateLabel,
                        style: textTheme.labelLarge?.copyWith(
                          color: colors.onStatus,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(stateDescription, style: textTheme.bodySmall),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [
                  stateColor.withValues(alpha: 0.3),
                  stateColor.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryLevelCard(BuildContext context) {
    final batteryLevel = _batteryLevel ?? 0;
    final status = _batteryLevel != null
        ? _getBatteryStatus(batteryLevel)
        : 'LOADING';
    final colors = Theme.of(context).extension<AppColors>()!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusColor = _batteryLevel != null
        ? _getBatteryStatusColor(context, batteryLevel)
        : scheme.outline;

    return _buildCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.battery_charging_full,
                  color: scheme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Battery Level', style: textTheme.titleLarge),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: textTheme.labelLarge?.copyWith(
                              color: colors.onStatus,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_isLoadingBattery)
                      const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Text(
                        '${_batteryLevel ?? 0}%',
                        style: textTheme.displayLarge,
                      ),
                    if (_batteryLevel != null && !_isLoadingBattery) ...[
                      const SizedBox(height: 4),
                      Text(
                        _getEstimatedTimeRemaining(batteryLevel),
                        style: textTheme.bodySmall,
                      ),
                    ],
                    if (!_isLoadingBattery && _batteryHealth != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Device health: ${_formatBatteryHealth(_batteryHealth!)}',
                        style: textTheme.bodySmall,
                      ),
                    ],
                    if (!_isLoadingBattery && _chargerConnection != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Charger: ${_formatChargerConnection(_chargerConnection!)}',
                        style: textTheme.bodySmall,
                      ),
                    ],
                    if (!_isLoadingBattery && _batteryStatus != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${_formatBatteryStatus(_batteryStatus!)}',
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (_batteryLevel != null && !_isLoadingBattery) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: batteryLevel / 100,
                minHeight: 8,
                backgroundColor: colors.progressTrack,
                valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMemoryUsageCard(BuildContext context) {
    final percent = _memoryUsage ?? 0;
    final hasData = _memoryUsage != null && !_isLoadingMemory;
    final statusLabel = hasData ? _getMemoryStatusLabel(percent) : '—';
    final colors = Theme.of(context).extension<AppColors>()!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusColor = hasData
        ? _getMemoryStatusColor(context, percent)
        : scheme.outline;

    return _buildCard(
      context,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.memory, color: scheme.primary, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Memory Usage', style: textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(statusLabel, style: textTheme.bodySmall),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    if (_isLoadingMemory)
                      const SizedBox(
                        height: 28,
                        width: 28,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Text(
                        '${_memoryUsage ?? 0}%',
                        style: textTheme.displayMedium,
                      ),
                    const SizedBox(width: 8),
                    Text(
                      hasData
                          ? 'used'
                          : (_isLoadingMemory ? 'loading…' : 'unavailable'),
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: hasData ? (percent / 100).clamp(0.0, 1.0) : null,
                    strokeWidth: 8,
                    backgroundColor: colors.progressTrack,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
                Text(
                  hasData ? '$percent%' : (_isLoadingMemory ? '…' : '—'),
                  style: textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMemoryStatusLabel(int percent) {
    if (percent >= 90) return 'Critical';
    if (percent >= 75) return 'High';
    if (percent >= 50) return 'Moderate';
    if (percent >= 25) return 'Normal';
    return 'Optimized';
  }

  Color _getMemoryStatusColor(BuildContext context, int percent) {
    final colors = Theme.of(context).extension<AppColors>()!;
    if (percent >= 90) return colors.error;
    if (percent >= 75) return colors.low;
    if (percent >= 50) return colors.warning;
    return colors.success;
  }

  /// Formats bytes to human-readable format (GB, MB, etc.)
  String _formatBytes(int bytes) {
    if (bytes < 0) return '0 B';

    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    int unitIndex = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    if (unitIndex == 0) {
      return '${size.toInt()} ${units[unitIndex]}';
    } else {
      return '${size.toStringAsFixed(size >= 100 ? 0 : 1)} ${units[unitIndex]}';
    }
  }

  Widget _buildDiskSpaceCard(BuildContext context) {
    final hasData = _storageInfo != null && !_isLoadingStorage;
    final totalBytes = _storageInfo?['total'] ?? 0;
    final usedBytes = _storageInfo?['used'] ?? 0;
    final availableBytes = _storageInfo?['available'] ?? 0;
    final usagePercent = _storageInfo?['usagePercent'] ?? 0;
    final colors = Theme.of(context).extension<AppColors>()!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusColor = hasData
        ? _getMemoryStatusColor(context, usagePercent)
        : scheme.outline;

    return _buildCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.storage, color: scheme.primary, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Disk Space', style: textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      hasData ? _getMemoryStatusLabel(usagePercent) : '—',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingStorage)
            const Center(
              child: SizedBox(
                height: 32,
                width: 32,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (hasData) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(_formatBytes(totalBytes), style: textTheme.displayMedium),
                const SizedBox(width: 8),
                Text('total', style: textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Used: ${_formatBytes(usedBytes)}',
                        style: textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Available: ${_formatBytes(availableBytes)}',
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value: (usagePercent / 100).clamp(0.0, 1.0),
                          strokeWidth: 6,
                          backgroundColor: colors.progressTrack,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            statusColor,
                          ),
                        ),
                      ),
                      Text(
                        '$usagePercent%',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ] else
            Text('Storage information unavailable', style: textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required Widget child}) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildLogStatusButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        // Handle log status snapshot
      },
      icon: const Icon(Icons.bar_chart),
      label: const Text('Log Status Snapshot'),
    );
  }
}
