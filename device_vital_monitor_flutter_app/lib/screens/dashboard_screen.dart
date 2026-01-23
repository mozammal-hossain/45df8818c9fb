import 'package:flutter/material.dart';
import '../services/device_sensor_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int? _batteryLevel;
  String? _batteryHealth;
  String? _chargerConnection;
  String? _batteryStatus;
  bool _isLoadingBattery = true;

  @override
  void initState() {
    super.initState();
    _fetchBatteryLevel();
  }

  Future<void> _fetchBatteryLevel() async {
    setState(() => _isLoadingBattery = true);
    try {
      final results = await Future.wait([
        DeviceSensorService.getBatteryLevel(),
        DeviceSensorService.getBatteryHealth(),
        DeviceSensorService.getChargerConnection(),
        DeviceSensorService.getBatteryStatus(),
      ]);
      if (mounted) {
        setState(() {
          _batteryLevel = results[0] as int?;
          _batteryHealth = results[1] as String?;
          _chargerConnection = results[2] as String?;
          _batteryStatus = results[3] as String?;
          _isLoadingBattery = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _batteryLevel = null;
          _batteryHealth = null;
          _chargerConnection = null;
          _batteryStatus = null;
          _isLoadingBattery = false;
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

  Color _getBatteryStatusColor(int level) {
    if (level >= 80) return const Color(0xFF4CAF50);
    if (level >= 50) return const Color(0xFFFF9800);
    if (level >= 20) return const Color(0xFFFF5722);
    return const Color(0xFFD32F2F);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {
            // Handle menu tap
          },
        ),
        title: const Text(
          'Device Vital Monitor',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {
              // Handle more options
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchBatteryLevel,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thermal State Card
              _buildThermalStateCard(),
            const SizedBox(height: 16),
            
            // Battery Level Card
            _buildBatteryLevelCard(),
            const SizedBox(height: 16),
            
            // Memory Usage Card
            _buildMemoryUsageCard(),
            const SizedBox(height: 16),
            
            // CPU Load and Disk Space Cards (side by side)
            Row(
              children: [
                Expanded(child: _buildCpuLoadCard()),
                const SizedBox(width: 16),
                Expanded(child: _buildDiskSpaceCard()),
              ],
            ),
            const SizedBox(height: 24),
            
            // Log Status Snapshot Button
            _buildLogStatusButton(),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildThermalStateCard() {
    return _buildCard(
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.thermostat,
              color: Colors.orange,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Thermal State',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      '1',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8A87C),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'LIGHT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'System operating within normal temperature ranges.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          // Visual element placeholder
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [
                  Colors.orange[200]!,
                  Colors.orange[400]!,
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

  Widget _buildBatteryLevelCard() {
    final batteryLevel = _batteryLevel ?? 0;
    final status = _batteryLevel != null ? _getBatteryStatus(batteryLevel) : 'LOADING';
    final statusColor = _batteryLevel != null 
        ? _getBatteryStatusColor(batteryLevel) 
        : Colors.grey;

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.battery_charging_full,
                  color: Colors.blue,
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
                        const Text(
                          'Battery Level',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
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
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    if (_batteryLevel != null && !_isLoadingBattery) ...[
                      const SizedBox(height: 4),
                      Text(
                        _getEstimatedTimeRemaining(batteryLevel),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                    if (!_isLoadingBattery && _batteryHealth != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Device health: ${_formatBatteryHealth(_batteryHealth!)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                    if (!_isLoadingBattery && _chargerConnection != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Charger: ${_formatChargerConnection(_chargerConnection!)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                    if (!_isLoadingBattery && _batteryStatus != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${_formatBatteryStatus(_batteryStatus!)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
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
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.blue[600]!,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMemoryUsageCard() {
    return _buildCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.memory,
              color: Colors.blue,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Memory Usage',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Optimized',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      '3.6 GB',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'of 8GB used',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Circular progress indicator
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
                    value: 0.45,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue[600]!,
                    ),
                  ),
                ),
                const Text(
                  '45%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCpuLoadCard() {
    return _buildCard(
      backgroundColor: Colors.blue[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CPU LOAD',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '12%',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiskSpaceCard() {
    return _buildCard(
      backgroundColor: Colors.blue[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DISK SPACE',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '242 GB',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required Widget child,
    Color? backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildLogStatusButton() {
    return ElevatedButton.icon(
      onPressed: () {
        // Handle log status snapshot
      },
      icon: const Icon(Icons.bar_chart, color: Colors.white),
      label: const Text(
        'Log Status Snapshot',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[600],
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
    );
  }
}
