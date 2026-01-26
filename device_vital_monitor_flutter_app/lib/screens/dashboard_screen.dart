import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/theme/theme_bloc.dart';
import '../core/injection/injection.dart';
import '../l10n/app_localizations.dart';
import '../services/device_sensor_service.dart';
import '../widgets/battery_level_card.dart';
import '../widgets/disk_space_card.dart';
import '../widgets/memory_usage_card.dart';
import '../widgets/thermal_state_card.dart';

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
              ThermalStateCard(
                thermalState: _thermalState,
                isLoading: _isLoadingThermal,
              ),
              const SizedBox(height: 16),
              BatteryLevelCard(
                batteryLevel: _batteryLevel,
                batteryHealth: _batteryHealth,
                chargerConnection: _chargerConnection,
                batteryStatus: _batteryStatus,
                isLoading: _isLoadingBattery,
              ),
              const SizedBox(height: 16),
              MemoryUsageCard(
                memoryUsage: _memoryUsage,
                isLoading: _isLoadingMemory,
              ),
              const SizedBox(height: 16),
              DiskSpaceCard(
                storageInfo: _storageInfo,
                isLoading: _isLoadingStorage,
              ),
              const SizedBox(height: 24),
              _buildLogStatusButton(context),
            ],
          ),
        ),
      ),
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
