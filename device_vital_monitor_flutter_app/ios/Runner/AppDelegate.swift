import Flutter
import UIKit
import Darwin
import BackgroundTasks

private let kAutoLoggingPrefs = "device_vital_monitor_auto_log"
private let kBaseURLKey = "base_url"
private let kDeviceIdKey = "device_id"
private let kVitalsLogTaskId = "com.example.device_vital_monitor_flutter_app.vitalsLog"

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    UIDevice.current.isBatteryMonitoringEnabled = true

    registerBackgroundTask()
    setupChannels(application: application)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func setupChannels(application: UIApplication) {
    guard let controller = window?.rootViewController as? FlutterViewController else { return }

    let sensorsChannel = FlutterMethodChannel(
      name: "device_vital_monitor/sensors",
      binaryMessenger: controller.binaryMessenger
    )
    sensorsChannel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "getThermalState":
        result(VitalsLogHelper.getThermalState())
      case "getBatteryLevel":
        if let level = VitalsLogHelper.getBatteryLevel() {
          result(level)
        } else {
          result(FlutterError(code: "BATTERY_ERROR", message: "Failed to get battery level", details: nil))
        }
      case "getMemoryUsage":
        if let usage = VitalsLogHelper.getMemoryUsage() {
          result(usage)
        } else {
          result(FlutterError(code: "MEMORY_ERROR", message: "Failed to get memory usage", details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    // iOS has no thermal-state-change callback; stream emits current state once so listen succeeds.
    let thermalEventChannel = FlutterEventChannel(
      name: "device_vital_monitor/thermal_events",
      binaryMessenger: controller.binaryMessenger
    )
    thermalEventChannel.setStreamHandler(ThermalEventStreamHandler())

    let autoLoggingChannel = FlutterMethodChannel(
      name: "device_vital_monitor/auto_logging",
      binaryMessenger: controller.binaryMessenger
    )
    autoLoggingChannel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "scheduleBackgroundAutoLog":
        guard let args = call.arguments as? [String: Any],
              let baseUrl = args["baseUrl"] as? String, !baseUrl.isEmpty,
              let deviceId = args["deviceId"] as? String, !deviceId.isEmpty else {
          result(FlutterError(code: "INVALID_ARGS", message: "baseUrl and deviceId required", details: nil))
          return
        }
        let base = baseUrl.hasSuffix("/") ? String(baseUrl.dropLast()) : baseUrl
        UserDefaults.standard.set(base, forKey: "\(kAutoLoggingPrefs)_\(kBaseURLKey)")
        UserDefaults.standard.set(deviceId, forKey: "\(kAutoLoggingPrefs)_\(kDeviceIdKey)")
        self?.submitVitalsLogTask()
        result(nil)
      case "cancelBackgroundAutoLog":
        UserDefaults.standard.removeObject(forKey: "\(kAutoLoggingPrefs)_\(kBaseURLKey)")
        UserDefaults.standard.removeObject(forKey: "\(kAutoLoggingPrefs)_\(kDeviceIdKey)")
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: kVitalsLogTaskId)
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func registerBackgroundTask() {
    BGTaskScheduler.shared.register(forTaskWithIdentifier: kVitalsLogTaskId, using: nil) { [weak self] task in
      self?.handleVitalsLogTask(task as! BGAppRefreshTask)
    }
  }

  private func submitVitalsLogTask() {
    let request = BGAppRefreshTaskRequest(identifier: kVitalsLogTaskId)
    request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
    do {
      try BGTaskScheduler.shared.submit(request)
    } catch {
    }
  }

  private func handleVitalsLogTask(_ task: BGAppRefreshTask) {
    task.expirationHandler = {
      task.setTaskCompleted(success: false)
    }

    guard let baseUrl = UserDefaults.standard.string(forKey: "\(kAutoLoggingPrefs)_\(kBaseURLKey)"),
          let deviceId = UserDefaults.standard.string(forKey: "\(kAutoLoggingPrefs)_\(kDeviceIdKey)") else {
      task.setTaskCompleted(success: true)
      return
    }

    let fullBase = baseUrl.hasSuffix("/") ? baseUrl : "\(baseUrl)/"
    let ok = VitalsLogHelper.postVitals(baseURL: fullBase, deviceId: deviceId)
    task.setTaskCompleted(success: ok)
    submitVitalsLogTask()
  }
}

// MARK: - Thermal events stream (iOS has no thermal-state-change callback; emit current state once)
private class ThermalEventStreamHandler: NSObject, FlutterStreamHandler {
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    events(VitalsLogHelper.getThermalState())
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    return nil
  }
}

// MARK: - Vitals helper (sensors + POST), inlined so no separate file needed in Xcode project
private enum VitalsLogHelper {
  static func getThermalState() -> Int {
    let thermalState = ProcessInfo.processInfo.thermalState
    switch thermalState {
    case .nominal: return 0
    case .fair: return 1
    case .serious: return 2
    case .critical: return 3
    @unknown default: return 0
    }
  }

  static func getBatteryLevel() -> Int? {
    UIDevice.current.isBatteryMonitoringEnabled = true
    let raw = UIDevice.current.batteryLevel
    guard raw >= 0 else { return nil }
    let percent = Int(raw * 100)
    return min(100, max(0, percent))
  }

  static func getMemoryUsage() -> Int? {
    var info = mach_task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size / MemoryLayout<natural_t>.size)
    let kerr = withUnsafeMutablePointer(to: &info) { infoPtr in
      infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { machPtr in
        task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), machPtr, &count)
      }
    }
    guard kerr == KERN_SUCCESS else { return nil }
    let used = info.resident_size
    let total = ProcessInfo.processInfo.physicalMemory
    guard total > 0 else { return 0 }
    let percent = Int((Double(used) / Double(total)) * 100)
    return min(100, max(0, percent))
  }

  static func postVitals(baseURL: String, deviceId: String) -> Bool {
    let thermal = getThermalState()
    guard let battery = getBatteryLevel() else { return false }
    guard let memory = getMemoryUsage() else { return false }

    let iso8601 = ISO8601DateFormatter()
    iso8601.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    let timestamp = iso8601.string(from: Date())

    let body: [String: Any] = [
      "device_id": deviceId,
      "timestamp": timestamp,
      "thermal_value": thermal,
      "battery_level": battery,
      "memory_usage": memory,
    ]
    guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return false }

    let urlString = baseURL.hasSuffix("/") ? "\(baseURL)api/vitals" : "\(baseURL)/api/vitals"
    guard let url = URL(string: urlString) else { return false }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = jsonData
    request.timeoutInterval = 10

    var success = false
    let sem = DispatchSemaphore(value: 0)
    URLSession.shared.dataTask(with: request) { _, response, _ in
      if let http = response as? HTTPURLResponse, (200..<400).contains(http.statusCode) {
        success = true
      }
      sem.signal()
    }.resume()
    sem.wait()
    return success
  }
}
