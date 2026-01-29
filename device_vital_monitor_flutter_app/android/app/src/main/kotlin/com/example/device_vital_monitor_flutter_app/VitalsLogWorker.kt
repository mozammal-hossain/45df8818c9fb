package com.example.device_vital_monitor_flutter_app

import android.content.Context
import android.util.Log
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone

/**
 * WorkManager worker that logs device vitals to the backend every 15 minutes.
 * Reads baseUrl and deviceId from SharedPreferences (set by Flutter when enabling auto-log).
 */
class VitalsLogWorker(
    context: Context,
    params: WorkerParameters,
) : CoroutineWorker(context, params) {

    override suspend fun doWork(): Result = withContext(Dispatchers.IO) {
        val prefs = applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val baseUrl = prefs.getString(KEY_BASE_URL, null)?.trimEnd('/')
        val deviceId = prefs.getString(KEY_DEVICE_ID, null)
        if (baseUrl.isNullOrBlank() || deviceId.isNullOrBlank()) {
            Log.w(TAG, "doWork: missing baseUrl or deviceId, skip")
            return@withContext Result.success()
        }

        val thermal = VitalsSensorHelper.getThermalState(applicationContext)
        val battery = VitalsSensorHelper.getBatteryLevel(applicationContext)
        val memory = VitalsSensorHelper.getMemoryUsage(applicationContext)
        if (battery < 0) {
            Log.w(TAG, "doWork: battery unavailable, skip")
            return@withContext Result.success()
        }

        val iso8601 = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US).apply {
            timeZone = TimeZone.getTimeZone("UTC")
        }
        val timestamp = iso8601.format(Date())
        val body = JSONObject().apply {
            put("device_id", deviceId)
            put("timestamp", timestamp)
            put("thermal_value", thermal.coerceIn(0, 3))
            put("battery_level", battery.coerceIn(0, 100))
            put("memory_usage", memory.coerceIn(0, 100))
        }

        try {
            val url = URL("$baseUrl/api/vitals")
            val conn = url.openConnection() as HttpURLConnection
            conn.requestMethod = "POST"
            conn.setRequestProperty("Content-Type", "application/json")
            conn.doOutput = true
            conn.connectTimeout = 10_000
            conn.readTimeout = 10_000
            conn.outputStream.use { os ->
                os.write(body.toString().toByteArray(Charsets.UTF_8))
            }
            val code = conn.responseCode
            if (code in 200..399) {
                Log.d(TAG, "doWork: logged vitals successfully (HTTP $code)")
                Result.success()
            } else {
                Log.e(TAG, "doWork: HTTP $code ${conn.responseMessage}")
                Result.retry()
            }
        } catch (e: Exception) {
            Log.e(TAG, "doWork: failed", e)
            Result.retry()
        }
    }

    companion object {
        private const val TAG = "VitalsLogWorker"
        const val PREFS_NAME = "device_vital_monitor_auto_log"
        const val KEY_BASE_URL = "base_url"
        const val KEY_DEVICE_ID = "device_id"
        const val WORK_NAME = "VitalsLogPeriodicWork"
    }
}
