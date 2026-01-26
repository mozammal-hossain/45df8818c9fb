import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/theme/theme_bloc.dart';
import '../core/injection/injection.dart';
import '../core/theme/theme.dart';
import '../l10n/app_localizations.dart';
import '../services/device_sensor_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DeviceSensorService _deviceSensorService;
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
    _deviceSensorService = getIt<DeviceSensorService>();
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
        _deviceSensorService.getThermalState(),
        _deviceSensorService.getBatteryLevel(),
        _deviceSensorService.getBatteryHealth(),
        _deviceSensorService.getChargerConnection(),
        _deviceSensorService.getBatteryStatus(),
        _deviceSensorService.getMemoryUsage(),
        _deviceSensorService.getStorageInfo(),
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

  String _getBatteryStatus(AppLocalizations l10n, int level) {
    if (level >= 80) return l10n.batteryStatusHealthy;
    if (level >= 50) return l10n.batteryStatusModerate;
    if (level >= 20) return l10n.batteryStatusLow;
    return l10n.batteryStatusCritical;
  }

  Color _getBatteryStatusColor(BuildContext context, int level) {
    final colors = Theme.of(context).extension<AppColors>()!;
    if (level >= 80) return colors.success;
    if (level >= 50) return colors.warning;
    if (level >= 20) return colors.low;
    return colors.error;
  }

  String _getEstimatedTimeRemaining(AppLocalizations l10n, int level) {
    final hours = (level * 0.14).round();
    return l10n.estimatedTimeRemaining(hours);
  }

  String _formatBatteryHealth(AppLocalizations l10n, String health) {
    switch (health) {
      case 'GOOD':
        return l10n.batteryHealthGood;
      case 'OVERHEAT':
        return l10n.batteryHealthOverheat;
      case 'DEAD':
        return l10n.batteryHealthDead;
      case 'OVER_VOLTAGE':
        return l10n.batteryHealthOverVoltage;
      case 'UNSPECIFIED_FAILURE':
        return l10n.batteryHealthUnspecifiedFailure;
      case 'COLD':
        return l10n.batteryHealthCold;
      default:
        return health;
    }
  }

  String _formatChargerConnection(AppLocalizations l10n, String connection) {
    switch (connection) {
      case 'AC':
        return l10n.chargerAc;
      case 'USB':
        return l10n.chargerUsb;
      case 'WIRELESS':
        return l10n.chargerWireless;
      case 'NONE':
        return l10n.chargerNone;
      default:
        return connection;
    }
  }

  String _formatBatteryStatus(AppLocalizations l10n, String status) {
    switch (status) {
      case 'CHARGING':
        return l10n.batteryCharging;
      case 'DISCHARGING':
        return l10n.batteryDischarging;
      case 'FULL':
        return l10n.batteryFull;
      case 'NOT_CHARGING':
        return l10n.batteryNotCharging;
      case 'UNKNOWN':
        return l10n.batteryUnknown;
      default:
        return status;
    }
  }

  String _getThermalStateLabel(AppLocalizations l10n, int state) {
    switch (state) {
      case 0:
        return l10n.thermalStateNone;
      case 1:
        return l10n.thermalStateLight;
      case 2:
        return l10n.thermalStateModerate;
      case 3:
        return l10n.thermalStateSevere;
      default:
        return l10n.thermalStateUnknown;
    }
  }

  String _getThermalStateDescription(AppLocalizations l10n, int state) {
    switch (state) {
      case 0:
        return l10n.thermalDescriptionNone;
      case 1:
        return l10n.thermalDescriptionLight;
      case 2:
        return l10n.thermalDescriptionModerate;
      case 3:
        return l10n.thermalDescriptionSevere;
      default:
        return l10n.thermalDescriptionUnavailable;
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLow,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Handle menu tap
          },
        ),
        title: Text(l10n.appTitle),
        actions: [
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.brightness_6),
                onPressed: () {
                  context.read<ThemeBloc>().add(const ThemeCycleRequested());
                },
                tooltip: l10n.toggleThemeTooltip,
              );
            },
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
    final l10n = AppLocalizations.of(context)!;
    final thermalState = _thermalState ?? 0;
    final hasData = _thermalState != null && !_isLoadingThermal;
    final stateLabel = hasData
        ? _getThermalStateLabel(l10n, thermalState)
        : l10n.dash;
    final colors = Theme.of(context).extension<AppColors>()!;
    final scheme = Theme.of(context).colorScheme;
    final stateColor = hasData
        ? _getThermalStateColor(context, thermalState)
        : scheme.outline;
    final stateDescription = hasData
        ? _getThermalStateDescription(l10n, thermalState)
        : l10n.loadingThermalState;
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
                Text(l10n.thermalState, style: textTheme.titleLarge),
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
    final l10n = AppLocalizations.of(context)!;
    final batteryLevel = _batteryLevel ?? 0;
    final status = _batteryLevel != null
        ? _getBatteryStatus(l10n, batteryLevel)
        : l10n.batteryStatusLoading;
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
                        Text(l10n.batteryLevel, style: textTheme.titleLarge),
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
                        _getEstimatedTimeRemaining(l10n, batteryLevel),
                        style: textTheme.bodySmall,
                      ),
                    ],
                    if (!_isLoadingBattery && _batteryHealth != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.deviceHealthLabel(
                          _formatBatteryHealth(l10n, _batteryHealth!),
                        ),
                        style: textTheme.bodySmall,
                      ),
                    ],
                    if (!_isLoadingBattery && _chargerConnection != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.chargerLabel(
                          _formatChargerConnection(l10n, _chargerConnection!),
                        ),
                        style: textTheme.bodySmall,
                      ),
                    ],
                    if (!_isLoadingBattery && _batteryStatus != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.statusLabel(
                          _formatBatteryStatus(l10n, _batteryStatus!),
                        ),
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
    final l10n = AppLocalizations.of(context)!;
    final percent = _memoryUsage ?? 0;
    final hasData = _memoryUsage != null && !_isLoadingMemory;
    final statusLabel = hasData
        ? _getMemoryStatusLabel(l10n, percent)
        : l10n.dash;
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
                Text(l10n.memoryUsage, style: textTheme.titleLarge),
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
                          ? l10n.used
                          : (_isLoadingMemory
                                ? l10n.loading
                                : l10n.unavailable),
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
                  hasData ? '$percent%' : (_isLoadingMemory ? '…' : l10n.dash),
                  style: textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMemoryStatusLabel(AppLocalizations l10n, int percent) {
    if (percent >= 90) return l10n.memoryCritical;
    if (percent >= 75) return l10n.memoryHigh;
    if (percent >= 50) return l10n.memoryModerate;
    if (percent >= 25) return l10n.memoryNormal;
    return l10n.memoryOptimized;
  }

  Color _getMemoryStatusColor(BuildContext context, int percent) {
    final colors = Theme.of(context).extension<AppColors>()!;
    if (percent >= 90) return colors.error;
    if (percent >= 75) return colors.low;
    if (percent >= 50) return colors.warning;
    return colors.success;
  }

  /// Formats bytes to human-readable format (GB, MB, etc.)
  String _formatBytes(AppLocalizations l10n, int bytes) {
    if (bytes < 0) return l10n.zeroBytes;

    final units = [
      l10n.unitB,
      l10n.unitKB,
      l10n.unitMB,
      l10n.unitGB,
      l10n.unitTB,
    ];
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
    final l10n = AppLocalizations.of(context)!;
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
                    Text(l10n.diskSpace, style: textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      hasData
                          ? _getMemoryStatusLabel(l10n, usagePercent)
                          : l10n.dash,
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
                Text(
                  _formatBytes(l10n, totalBytes),
                  style: textTheme.displayMedium,
                ),
                const SizedBox(width: 8),
                Text(l10n.total, style: textTheme.bodySmall),
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
                        l10n.usedFormatted(_formatBytes(l10n, usedBytes)),
                        style: textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.availableFormatted(
                          _formatBytes(l10n, availableBytes),
                        ),
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
            Text(l10n.storageUnavailable, style: textTheme.bodySmall),
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
    final l10n = AppLocalizations.of(context)!;
    return ElevatedButton.icon(
      onPressed: () {
        // Handle log status snapshot
      },
      icon: const Icon(Icons.bar_chart),
      label: Text(l10n.logStatusSnapshot),
    );
  }
}
