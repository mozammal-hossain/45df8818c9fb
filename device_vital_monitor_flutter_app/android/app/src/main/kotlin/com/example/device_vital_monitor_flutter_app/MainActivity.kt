package com.example.device_vital_monitor_flutter_app

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.os.StatFs
import android.os.Environment
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "device_vital_monitor/sensors"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getBatteryLevel" -> {
                    try {
                        val batteryLevel = getBatteryLevel()
                        result.success(batteryLevel)
                    } catch (e: Exception) {
                        result.error("BATTERY_ERROR", "Failed to get battery level: ${e.message}", null)
                    }
                }
                "getBatteryHealth" -> {
                    try {
                        val health = getBatteryHealth()
                        result.success(health)
                    } catch (e: Exception) {
                        result.error("BATTERY_ERROR", "Failed to get battery health: ${e.message}", null)
                    }
                }
                "getChargerConnection" -> {
                    try {
                        val connection = getChargerConnection()
                        result.success(connection)
                    } catch (e: Exception) {
                        result.error("BATTERY_ERROR", "Failed to get charger connection: ${e.message}", null)
                    }
                }
                "getBatteryStatus" -> {
                    try {
                        val status = getBatteryStatus()
                        result.success(status)
                    } catch (e: Exception) {
                        result.error("BATTERY_ERROR", "Failed to get battery status: ${e.message}", null)
                    }
                }
                "getMemoryUsage" -> {
                    try {
                        val usage = getMemoryUsage()
                        result.success(usage)
                    } catch (e: Exception) {
                        result.error("MEMORY_ERROR", "Failed to get memory usage: ${e.message}", null)
                    }
                }
                "getStorageInfo" -> {
                    try {
                        val storageInfo = getStorageInfo()
                        result.success(storageInfo)
                    } catch (e: Exception) {
                        result.error("STORAGE_ERROR", "Failed to get storage info: ${e.message}", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getBatteryLevel(): Int {
        val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = getBatteryIntent()
            val level = intent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
            val scale = intent?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
            if (level >= 0 && scale > 0) {
                (level * 100 / scale.toFloat()).toInt()
            } else {
                -1
            }
        }
    }

    private fun getBatteryHealth(): String {
        val intent = getBatteryIntent()
        if (intent == null) {
            Log.w(TAG, "getBatteryHealth: battery intent null")
            return "UNKNOWN"
        }
        val health = intent.getIntExtra(BatteryManager.EXTRA_HEALTH, BatteryManager.BATTERY_HEALTH_UNKNOWN)
        val result = when (health) {
            BatteryManager.BATTERY_HEALTH_GOOD -> "GOOD"
            BatteryManager.BATTERY_HEALTH_OVERHEAT -> "OVERHEAT"
            BatteryManager.BATTERY_HEALTH_DEAD -> "DEAD"
            BatteryManager.BATTERY_HEALTH_OVER_VOLTAGE -> "OVER_VOLTAGE"
            BatteryManager.BATTERY_HEALTH_UNSPECIFIED_FAILURE -> "UNSPECIFIED_FAILURE"
            BatteryManager.BATTERY_HEALTH_COLD -> "COLD"
            else -> "UNKNOWN"
        }
        Log.d(TAG, "getBatteryHealth: raw=$health -> $result")
        return result
    }

    private fun getChargerConnection(): String {
        val intent = getBatteryIntent()
        if (intent == null) {
            Log.w(TAG, "getChargerConnection: battery intent null")
            return "NONE"
        }
        val plugged = intent.getIntExtra(BatteryManager.EXTRA_PLUGGED, -1)
        val result = when (plugged) {
            BatteryManager.BATTERY_PLUGGED_AC -> "AC"
            BatteryManager.BATTERY_PLUGGED_USB -> "USB"
            BatteryManager.BATTERY_PLUGGED_WIRELESS -> "WIRELESS"
            0 -> "NONE"
            else -> "NONE"
        }
        Log.d(TAG, "getChargerConnection: raw=$plugged -> $result")
        return result
    }

    private fun getBatteryStatus(): String {
        val intent = getBatteryIntent()
        if (intent == null) {
            Log.w(TAG, "getBatteryStatus: battery intent null")
            return "UNKNOWN"
        }
        val status = intent.getIntExtra(BatteryManager.EXTRA_STATUS, BatteryManager.BATTERY_STATUS_UNKNOWN)
        val result = when (status) {
            BatteryManager.BATTERY_STATUS_CHARGING -> "CHARGING"
            BatteryManager.BATTERY_STATUS_DISCHARGING -> "DISCHARGING"
            BatteryManager.BATTERY_STATUS_FULL -> "FULL"
            BatteryManager.BATTERY_STATUS_NOT_CHARGING -> "NOT_CHARGING"
            BatteryManager.BATTERY_STATUS_UNKNOWN -> "UNKNOWN"
            else -> "UNKNOWN"
        }
        Log.d(TAG, "getBatteryStatus: raw=$status -> $result")
        return result
    }

    companion object {
        private const val TAG = "DeviceVitalMonitor"
    }

    private fun getMemoryUsage(): Int {
        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memoryInfo = ActivityManager.MemoryInfo()
        activityManager.getMemoryInfo(memoryInfo)
        val totalMem = memoryInfo.totalMem
        val availMem = memoryInfo.availMem
        if (totalMem <= 0) {
            Log.w(TAG, "getMemoryUsage: totalMem <= 0")
            return 0
        }
        val usedMem = totalMem - availMem
        val percent = (usedMem * 100 / totalMem).toInt().coerceIn(0, 100)
        Log.d(TAG, "getMemoryUsage: used=$usedMem total=$totalMem -> $percent%")
        return percent
    }

    private fun getBatteryIntent(): Intent? {
        return registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
    }

    private fun getStorageInfo(): Map<String, Any> {
        val stat = StatFs(Environment.getDataDirectory().path)
        val blockSize = stat.blockSizeLong
        val totalBlocks = stat.blockCountLong
        val availableBlocks = stat.availableBlocksLong
        
        val totalBytes = totalBlocks * blockSize
        val availableBytes = availableBlocks * blockSize
        val usedBytes = totalBytes - availableBytes
        
        val usagePercent = if (totalBytes > 0) {
            ((usedBytes * 100) / totalBytes).toInt().coerceIn(0, 100)
        } else {
            0
        }
        
        Log.d(TAG, "getStorageInfo: total=$totalBytes used=$usedBytes available=$availableBytes percent=$usagePercent%")
        
        // Return as Map<String, Any> to handle Long values (bytes) and Int (percentage)
        // Flutter will convert Long to int automatically if within int range
        return mapOf(
            "total" to totalBytes,
            "used" to usedBytes,
            "available" to availableBytes,
            "usagePercent" to usagePercent
        )
    }
}
