package com.example.device_vital_monitor_flutter_app

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.os.PowerManager
import android.os.SystemClock
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "device_vital_monitor/sensors"
    private val THERMAL_EVENT_CHANNEL = "device_vital_monitor/thermal_events"

    // ADPF: getThermalHeadroom must not be called more than once per 10 seconds (returns NaN otherwise)
    private val MIN_HEADROOM_INTERVAL_MS = 10_000L
    private var lastThermalHeadroomTimeMs: Long = 0
    private var lastThermalHeadroomValue: Float? = null

    private var thermalEventSink: EventChannel.EventSink? = null
    private var thermalStatusListener: PowerManager.OnThermalStatusChangedListener? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getThermalState" -> {
                    try {
                        val thermalState = getThermalState()
                        result.success(thermalState)
                    } catch (e: Exception) {
                        result.error("THERMAL_ERROR", "Failed to get thermal state: ${e.message}", null)
                    }
                }
                "getThermalHeadroom" -> {
                    try {
                        val forecastSeconds = (call.arguments as? Number)?.toInt() ?: 10
                        val headroom = getThermalHeadroom(forecastSeconds)
                        result.success(headroom)
                    } catch (e: Exception) {
                        result.error("THERMAL_ERROR", "Failed to get thermal headroom: ${e.message}", null)
                    }
                }
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
                else -> {
                    result.notImplemented()
                }
            }
        }

        EventChannel(messenger, THERMAL_EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    thermalEventSink = events
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
                        thermalStatusListener = PowerManager.OnThermalStatusChangedListener { status ->
                            val mapped = thermalStatusToMappedValue(status)
                            runOnUiThread {
                                thermalEventSink?.success(mapped)
                            }
                        }
                        powerManager.addThermalStatusListener(mainExecutor, thermalStatusListener!!)
                    }
                }

                override fun onCancel(arguments: Any?) {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && thermalStatusListener != null) {
                        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
                        powerManager.removeThermalStatusListener(thermalStatusListener!!)
                    }
                    thermalStatusListener = null
                    thermalEventSink = null
                }
            }
        )
    }

    private fun thermalStatusToMappedValue(thermalStatus: Int): Int = when (thermalStatus) {
        PowerManager.THERMAL_STATUS_NONE -> 0
        PowerManager.THERMAL_STATUS_LIGHT -> 1
        PowerManager.THERMAL_STATUS_MODERATE -> 2
        PowerManager.THERMAL_STATUS_SEVERE,
        PowerManager.THERMAL_STATUS_CRITICAL,
        PowerManager.THERMAL_STATUS_EMERGENCY,
        PowerManager.THERMAL_STATUS_SHUTDOWN -> 3
        else -> 0
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

    /**
     * Returns thermal headroom (0.0–1.0+, 1.0 = severe throttling). Null if unsupported or NaN.
     * Must not be called more than once per 10 seconds (ADPF requirement).
     */
    private fun getThermalHeadroom(forecastSeconds: Int): Float? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) return null
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        val now = SystemClock.elapsedRealtime()
        if (now - lastThermalHeadroomTimeMs < MIN_HEADROOM_INTERVAL_MS) {
            return lastThermalHeadroomValue
        }
        val headroom = powerManager.getThermalHeadroom(forecastSeconds.coerceIn(0, 60))
        lastThermalHeadroomTimeMs = now
        when {
            headroom.isNaN() -> {
                lastThermalHeadroomValue = null
                Log.w(TAG, "getThermalHeadroom: NaN (throttled or unsupported)")
                return null
            }
            else -> {
                lastThermalHeadroomValue = headroom
                Log.d(TAG, "getThermalHeadroom: $headroom (forecast=${forecastSeconds}s)")
                return headroom
            }
        }
    }

    private fun getThermalState(): Int {
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // API 29+: getCurrentThermalStatus per brief and ADPF
            val thermalStatus = powerManager.currentThermalStatus
            var result = thermalStatusToMappedValue(thermalStatus)

            // ADPF device-limitation heuristics: when status is NONE, some devices don't update
            // getCurrentThermalStatus; use getThermalHeadroom (API 30+) to infer throttling.
            if (thermalStatus == PowerManager.THERMAL_STATUS_NONE && Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                val headroom = getThermalHeadroom(10)
                if (headroom != null && !headroom.isNaN()) {
                    when {
                        headroom > 1.0f -> result = 3   // could be SEVERE or higher
                        headroom > 0.95f -> result = 2  // could be MODERATE or higher
                        headroom > 0.85f -> result = 1  // could be LIGHT
                    }
                    if (result != 0) {
                        Log.d(TAG, "getThermalState: status=NONE, headroom=$headroom -> heuristic $result")
                    }
                }
            } else if (result != 0) {
                Log.d(TAG, "getThermalState: raw=$thermalStatus -> $result")
            }
            return result
        }

        // API < 29: no thermal API (brief allows getThermalHeadroom for "older" – headroom is API 30+, so no fallback)
        Log.w(TAG, "getThermalState: API ${Build.VERSION.SDK_INT} < 29, returning 0")
        return 0
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

    
}
