package com.example.device_vital_monitor_flutter_app

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.os.PowerManager
import android.util.Log

/**
 * Helper to read thermal, battery, and memory from any Context.
 * Used by MainActivity (MethodChannel) and VitalsLogWorker (background).
 */
object VitalsSensorHelper {
    private const val TAG = "VitalsSensorHelper"

    fun getThermalState(context: Context): Int {
        val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val thermalStatus = powerManager.currentThermalStatus
            return thermalStatusToMappedValue(thermalStatus)
        }
        Log.w(TAG, "getThermalState: API ${Build.VERSION.SDK_INT} < 29, returning 0")
        return 0
    }

    fun thermalStatusToMappedValue(thermalStatus: Int): Int = when (thermalStatus) {
        PowerManager.THERMAL_STATUS_NONE -> 0
        PowerManager.THERMAL_STATUS_LIGHT -> 1
        PowerManager.THERMAL_STATUS_MODERATE -> 2
        PowerManager.THERMAL_STATUS_SEVERE,
        PowerManager.THERMAL_STATUS_CRITICAL,
        PowerManager.THERMAL_STATUS_EMERGENCY,
        PowerManager.THERMAL_STATUS_SHUTDOWN -> 3
        else -> 0
    }

    fun getBatteryLevel(context: Context): Int {
        val batteryManager = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = getBatteryIntent(context)
            val level = intent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
            val scale = intent?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
            if (level >= 0 && scale > 0) {
                (level * 100 / scale.toFloat()).toInt()
            } else {
                -1
            }
        }
    }

    fun getMemoryUsage(context: Context): Int {
        val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memoryInfo = ActivityManager.MemoryInfo()
        activityManager.getMemoryInfo(memoryInfo)
        val totalMem = memoryInfo.totalMem
        val availMem = memoryInfo.availMem
        if (totalMem <= 0) {
            Log.w(TAG, "getMemoryUsage: totalMem <= 0")
            return 0
        }
        val usedMem = totalMem - availMem
        return (usedMem * 100 / totalMem).toInt().coerceIn(0, 100)
    }

    private fun getBatteryIntent(context: Context): Intent? {
        return context.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
    }
}
